{/admcom/progr/admbatch.i}
def input param par-wms     like abaswms.wms.

def var vtty as char format "x(40)". 
unix silent value("tty > log.tty" ). 
input from ./log.tty. 
repeat. 
    import vtty. 
end. 
input close.

def var par-dcbcod  like tdocbase.dcbcod.

def temp-table ttdocbase no-undo
    field dcbcod    like tdocbase.dcbcod
    index idx is unique primary dcbcod asc.
    
def shared temp-table tt-marca no-undo
    field rec as recid
    field etbcod    like abastransf.etbcod
    field qtdcorta  as dec

    field estatualFOTO like abascorteprod.estatualFOTO
    field estdispoFOTO like abascorteprod.estdispoFOTO
 
    index idx is unique primary rec asc
    index idx2                  etbcod asc.

def temp-table tt-estab no-undo
    field etbcod like abastransf.etbcod
    index idx is unique primary etbcod asc.
    
def var vseq    as int.
for each tt-marca  ,
    abastransf where recid(abastransf) = tt-marca.rec no-lock.
    
    find first tt-estab where
        tt-estab.etbcod = abastransf.etbcod no-error.
    if not avail tt-estab    
    then do:
        create tt-estab.
        tt-estab.etbcod = abastransf.etbcod.
    end.
    tt-marca.etbcod = abastransf.etbcod.

end.


find first abaswms where abaswms.wms = par-wms no-lock.

for each tt-estab on error undo, retry.
        
    find first tab_box where tab_box.etbcod = tt-estab.etbcod no-lock no-error.
    
    vseq = 0.

    run /admcom/progr/tdocbase-dcbcod.p
                    (output par-dcbcod).

    find first tab_ini where tab_ini.parametro = "ALCIS-ARQ-ORDVH" 
        exclusive no-error.
    if not avail tab_ini
    then do.
        create tab_ini. 
        ASSIGN tab_ini.etbcod    = 0
               tab_ini.cxacod    = 0
               tab_ini.parametro = "ALCIS-ARQ-ORDVH"
               tab_ini.valor     = "0"
               tab_ini.dtinclu   = today
               tab_ini.dtexp     = today
               tab_ini.exportar  = no.
    end.

        def var vordv as int.
        vordv = int(tab_ini.valor).
        vordv = vordv + 1.
        tab_ini.valor = string(vordv).

    create abasCORTE.       
    ASSIGN 
        abasCORTE.DataReal          = today .
        abasCORTE.HoraReal          = time .
        
        abasCORTE.dcbcod = par-dcbcod.

        abasCORTE.ArquivoIntegracao = if abaswms.interface = "ORDV"
                                      then      "ORDVH" + string(vordv,"99999999") + ".DAT"
                                      else if abaswms.interface = "DSTR"
                                           then "DSTRH" + string(abascorte.dcbcod,"99999999") + ".DAT"
                                           else "SAIDA" + string(abascorte.dcbcod) + ".DAT".
        abasCORTE.Diretorio         = abaswms.Diretorio + "in/".
        abasCORTE.interface         = abaswms.interface.
        abasCORTE.dtconf             = ? .
        abasCORTE.hrconf             = ?.

    abasCORTE.interface = abaswms.interface.
    
    
    abasCORTE.etbcd = abaswms.etbcd.
    
    abasCORTE.etbcod   = tt-estab.etbcod.
    abasCORTE.wms      = par-wms.
    abasCORTE.box      = if avail tab_box
                         then tab_box.box
                         else 0.

    
    create tdocbase.  
    tdocbase.dcbcod    = abasCORTE.dcbcod.

    tdocbase.geraraut  = no.   
    tdocbase.dcbnum    = tdocbase.dcbcod.
    
    tdocbase.tdcbcod   = "ROM" .
    tdocbase.chave-ext = ?  .
    tdocbase.DtDoc     = abasCORTE.datareal.
    tdocbase.DtEnv     = tdocbase.DtDoc.
    tdocbase.HrEnv     = abasCORTE.horareal.
    tdocbase.Etbdes    = abasCORTE.etbcod.
    tdocbase.plani-etbcod = ? .
    
    tdocbase.box       = abasCORTE.box.
    
    tdocbase.RomExterno     = no .
    tdocbase.ordem      = if avail tab_box
                          then tab_box.ordem 
                          else 0.

    
    /*  gravar o tty do usuário    */   
        tdocbase.cod_barra_nf = string(tdocbase.dcbnum) + "_" + 
                                string(sfuncod)           + "_" + 
                                vtty.  
    if tt-estab.etbcod = 200  
    then do.  
        tdocbase.Ecommerce = yes. 
        tdocbase.clfcod    = ?. 
    end.                
     
    for each tt-marca where tt-marca.etbcod = tt-estab.etbcod:
        find abastransf where recid(abastransf) = tt-marca.rec exclusive
            no-wait no-error.
        
        if avail abastransf
        then do:
            vseq = vseq + 1.
                        
            create abasCORTEprod.
            abasCORTEprod.dcbcod   = abascorte.dcbcod.
            abasCORTEprod.dcbpseq  = vseq.

            /* relacio abastransf origem */
            abasCORTEprod.etbcod   = abastransf.etbcod.
            abasCORTEprod.abtcod   = abastransf.abtcod.
            abascorteprod.procod   = abastransf.procod.
            abasCORTEprod.qtdcorte = tt-marca.qtdcorta. /*abastransf.abtqtd - abastransf.qtdatend.*/
            
            abascorteprod.estatualfoto = tt-marca.estatualfoto.
            abascorteprod.estdispofoto = tt-marca.estdispofoto.
            
            
            /* tdocbpro */     
            if abascorteprod.qtdcorte > 0
            then do:
                create  tdocbpro.
                tdocbpro.dcbcod  = tdocbase.dcbcod.
                tdocbpro.dcbpseq = abasCORTEprod.dcbpseq.
            
                tdocbpro.etbdes  = tdocbase.etbdes. 
                tdocbpro.predt   = tdocbase.dtdoc.
                tdocbpro.etbdes  = ?.   
                tdocbpro.campo_int3  = abastransf.orietbcod  /* estab do pedido */.
                tdocbpro.procod  = abastransf.procod.

                tdocbpro.movqtm     = abasCORTEprod.qtdcorte.
                  
                tdocbpro.pednum     = abasCORTEprod.abtcod.
            end.
            
        end.

    end.
    create ttdocbase.
    ttdocbase.dcbcod = tdocbase.dcbcod.
end.                

hide message no-pause.
message "Gerando arquivos.....".

def new shared var vALCIS-ARQ-ORDVH   as int.

for each ttdocbase.
    find tdocbase where tdocbase.dcbcod = ttdocbase.dcbcod no-lock.
    if avail tdocbase
    then do:

        find abascorte where abascorte.dcbcod = ttdocbase.dcbcod no-lock.
    
        find estab where estab.etbcod = tdocbase.etbdes no-lock.
        if abascorte.interface = "DSTR"
        then do:
            run abas/dstr.p  (recid(tdocbase),
                              abascorte.diretorio,
                              abascorte.arquivointegracao).
        end.    
        if abascorte.interface = "ORDV"
        then do:
            run abas/ordv.p (recid(tdocbase), 
                             if abascorte.wms = "ALCIS_ESP"
                             then "PESP"
                             else
                             if abascorte.wms = "ALCIS_VEX"
                             then "VEXM"
                             else "NORM",
                             abascorte.diretorio,
                             abascorte.arquivointegracao).
            
        end.
            
           
            for each abasCORTEprod of abasCORTE.
                find abastransf of abasCORTEprod exclusive.
            
                abastransf.qtdemWMS = abastransf.qtdemWMS + abascorteprod.qtdcorte.   
                
                if abastransf.abtqtd >  
                   (abastransf.qtdemWMS + abastransf.qtdatend) 
                then do: 
                    abastransf.abtsit = "AC". /* Volta pro Corte */ 
                end. 
                else do: 
                    if abaswms.interface = "ORDV"
                    then abastransf.abtsit = "IN". /* Integrado, aguarda arquivo conf*/ 
                    else abastransf.abtsit = "IN". /* Separado*/
                end.
            end.

            if abaswms.interface = "DSTR" or
               abaswms.wms = "ALCIS_VEX" 
            then do:
                
                for each abascorteprod of abascorte no-lock.    
                    
                    if abaswms.wms =  "ALCIS_VEX"
                    then do:
                        run abas/confcria.p (abaswms.interface,
                                             abasCORTE.ArquivoIntegracao,
                                             abascorte.dcbcod,
                                             abascorteprod.dcbpseq,
                                             abascorteprod.procod,
                                             abascorteprod.qtdcorte).
                    end.
                    
                end.
                
                do on error undo:
                    find current abascorte.
                
                    abasCORTE.dtconf = today.
                    abasCORTE.hrconf = time.
                                   
                end.
            end.

    end.        
    delete ttdocbase.
end. 
hide message no-pause.
message "Arquivos Gerados.".
pause 1 no-message.
