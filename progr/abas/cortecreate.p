{admbatch.i}
def input param par-wms     like abaswms.wms.

def var vtty as char format "x(40)". 
unix silent value("tty > log.tty" ). 
input from ./log.tty. 
repeat. 
    import vtty. 
end. 
input close.

def temp-table ttdocbase no-undo
    field dcbcod    like tdocbase.dcbcod
    index idx is unique primary dcbcod asc.
    
def shared temp-table tt-marca no-undo
    field rec as recid
    field etbcod    like abastransf.etbcod
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
    
    create abascorte.      
    
    abascorte.interface = abaswms.interface.
    
    abascorte.dcbcod = next-value(seq-abascorte).

    abascorte.etbCorte = abaswms.etbCorte.
    
    abascorte.etbcod   = tt-estab.etbcod.
    abascorte.wms      = par-wms.
    abascorte.DtCorte  = today.
    abascorte.HrCorte  = time.
    
    abascorte.box      = if avail tab_box
                         then tab_box.box
                         else 0.

    
    create tdocbase.  
    tdocbase.dcbcod    = abascorte.dcbcod.

    tdocbase.geraraut  = no.   
    tdocbase.dcbnum    = tdocbase.dcbcod.
    
    tdocbase.tdcbcod   = "ROM" .
    tdocbase.chave-ext = ?  .
    tdocbase.DtDoc     = abascorte.dtcorte.
    tdocbase.DtEnv     = tdocbase.DtDoc.
    tdocbase.HrEnv     = abascorte.hrcorte.
    tdocbase.Etbdes    = abascorte.etbcod.
    tdocbase.plani-etbcod = ? .
    
    tdocbase.box       = abascorte.box.
    
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
                        
            create abasCorteProdu.
            
            /* relaciona tdocbase e tdocbpro */            
            abasCorteProdu.dcbcod   = tdocbase.dcbcod.
            abasCorteProdu.dcbpseq  = vseq.
            /* relacio abastransf origem */
            abasCorteProdu.etbcod   = abastransf.etbcod.
            abasCorteProdu.abtcod   = abastransf.abtcod.
            
            abasCorteProdu.qtdcorte = abastransf.abtqtd - abastransf.qtdatend.

            /* tdocbpro */     
            create  tdocbpro.
            tdocbpro.dcbcod  = tdocbase.dcbcod.
            tdocbpro.dcbpseq = abasCorteProdu.dcbpseq.
            
            tdocbpro.etbdes  = tdocbase.etbdes. 
            tdocbpro.predt   = tdocbase.dtdoc.
            tdocbpro.etbdes  = ?.   
            tdocbpro.campo_int3  = abastransf.orietbcod  /* estab do pedido */.
            tdocbpro.procod  = abastransf.procod.
                /*
                tdocbpro.movqtm  = if avail conjunto and conjunto.qtd > 1
                                            and tdocbase.ecommerce = no
                                     then tdocbpro.movqtm + wroma.wped
                                     else wroma.wped
                */
            tdocbpro.movqtm     = abasCorteProdu.qtdcorte.
                  
            tdocbpro.pednum     = abasCorteProdu.abtcod.
            
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
        find estab where estab.etbcod = tdocbase.etbdes no-lock.
        if abaswms.interface = "DSTR"
        then do:
            run dstrh-moda.p  (recid(tdocbase)).
        end.    
        if abaswms.interface = "ORDV"
        then do:
            run ordvh-moveis.p (recid(tdocbase), "NORM").
        end.
            
        do on error undo:
            find abascorte of tdocbase .
            abascorte.dtseparado = if abaswms.interface = "DSTR"
                                   then today
                                   else ?.
            abascorte.hrseparado = if abaswms.interface = "DSTR"
                                   then time
                                   else ?.
                                   
            for each abascorteprodu of abascorte.
                find abastransf of abascorteprodu exclusive.
                abastransf.abtsit = "IN".
                if abaswms.interface = "DSTR"
                then do:

                    abascorteprodu.procod   = abastransf.procod.
                    abascorteprodu.qtdSepar = abascorteprodu.qtdcorte.                    
                    abascorteprodu.abtsit   = "SE".
                    abastransf.abtsit       = "SE".
                
                end.
                                    
            end.
        end.
    end.        
    delete ttdocbase.
end. 
hide message no-pause.
message "Arquivos Gerados.".
pause 1 no-message.
