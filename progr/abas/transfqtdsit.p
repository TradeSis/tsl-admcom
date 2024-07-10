def input param par-rec     as recid.
def input param par-ajusta  as log.

def var vconf as log.
def var vabtsit like abastransf.abtsit.
def var vsldconf as int.
def var vqtdatend as int.
def shared temp-table tt-cortes no-undo
    field rec       as recid
    field etbcod    like abascorteprod.etbcod
    field abtcod    like abascorteprod.abtcod
    field seq       as int format ">>>>9"
    field Oper      as char
    field datareal  like abascorte.datareal
    field horareal  like abascorte.horareal
    field dcbcod    like abascorte.dcbcod   format ">>>>>>>"
    field numero    as   int                format ">>>>>>>"
    field qtd       as int format ">>>9"
    field qtdemWMS  like abastransf.qtdemwms
    field qtdatend  like abastransf.qtdatend 
    field qtdPEND   as int format ">>>9"
    field abtsit    like abastransf.abtsit
    field traetbcod like plani.etbcod
    field traplacod like plani.placod
    index sequencia is unique primary etbcod asc abtcod asc dcbcod asc seq  asc.

def temp-table tt-cargas no-undo
    field dcbcod    like abascargaprod.dcbcod
    field procod    like abascargaprod.procod
    field interface like abascargaprod.interface
    index idx is unique primary dcbcod asc procod.

def temp-table tt-cargaseq no-undo
    field rec       as rec
    field dcbcod    like abascargaprod.dcbcod
    field procod    like abascargaprod.procod
    field dcbpseq   like abasconfprod.dcbpseq
    field arquivoIntegracao like abascargaprod.arquivoIntegracao
    field qtdcarga  like abascargaprod.qtdcarga
    index idx is primary dcbcod asc procod asc dcbpseq asc arquivoIntegracao asc.
 
def temp-table tt-confprod no-undo
    field arquivo   like abasconfprod.arquivo
    field dcbcod    like abasconfprod.dcbcod
    field procod    like abasconfprod.procod
    field dcbpseq   like abasconfprod.dcbpseq
    field qtdconf   like abasconfprod.qtdconf
    field qtdcarga  like abasconfprod.qtdcarga
    index idx is unique primary arquivo asc dcbcod asc procod asc dcbpseq asc.


    

def var vqtdcarga as int.
def var vqtdpend    as int.
def var vqtdemwms   as int.
def var vseq as int.

for each tt-cortes.
    delete tt-cortes.
end.    
find abastransf where recid(abastransf) = par-rec
        no-lock.

        find tt-cortes where tt-cortes.oper   = "PEDIDO" and
                      tt-cortes.etbcod = abastransf.etbcod and
                      tt-cortes.abtcod = abastransf.abtcod
                      no-error.
        if not avail tt-cortes then do:
            vseq = vseq + 1.
            create tt-cortes.
            tt-cortes.seq = vseq.
            tt-cortes.oper = "PEDIDO".
            tt-cortes.rec  = recid(abastransf).
            tt-cortes.etbcod = abastransf.etbcod.
            tt-cortes.abtcod = abastransf.abtcod.
            tt-cortes.qtd    = abastransf.abtqtd.
            tt-cortes.datareal = abastransf.dttransf.
            tt-cortes.horareal = abastransf.hrinclu.
        end.


for each abascorteprod of abastransf no-lock,
    abascorte of abascorteprod no-lock    
        by abascorte.datareal
        by abascorte.horareal
        by abascorte.dcbcod
        by abascorteprod.dcbpseq.
            vseq = vseq + 1.
            create tt-cortes.
            tt-cortes.seq      = vseq.
            tt-cortes.oper     = "CORTE".
            tt-cortes.rec      = recid(abascorteprod).
            tt-cortes.etbcod   = abastransf.etbcod.
            tt-cortes.abtcod   = abastransf.abtcod.
            tt-cortes.datareal = abascorte.datareal.
            tt-cortes.horareal = abascorte.horareal.
            tt-cortes.dcbcod   = abascorte.dcbcod. 
            tt-cortes.numero   = abascorteprod.dcbcod.
            tt-cortes.qtd      = abascorteprod.qtdcorte.

    find abasconfprod of abascorteprod no-lock no-error.
    if avail abasconfprod and
       abasconfprod.interface = "CONF" 
    then do:
                vseq = vseq + 1.
                create tt-cortes.
                tt-cortes.seq      = vseq.
                tt-cortes.oper     = abasconfprod.interface.
                tt-cortes.rec      = recid(abasconfprod).
                tt-cortes.etbcod   = abastransf.etbcod.
                tt-cortes.abtcod   = abastransf.abtcod.
                tt-cortes.datareal = abasconfprod.datareal.
                tt-cortes.horareal = abasconfprod.horareal.
                tt-cortes.dcbcod   = abascorte.dcbcod. 
                tt-cortes.numero   = abascorteprod.dcbcod.
                tt-cortes.qtd      = abasconfprod.qtdconf.
        
    end.
    
    /*1 for each abascargaprod where 
            abascargaprod.dcbcod = abascorteprod.dcbcod and
            abascargaprod.procod = abascorteprod.procod
        no-lock.
            find first tt-cargas where
                tt-cargas.dcbcod = abascargaprod.dcbcod and
                tt-cargas.procod = abascargaprod.procod 
                no-error.
            if not avail tt-cargas
            then do:
                create tt-cargas.
                tt-cargas.dcbcod = abascargaprod.dcbcod.
                tt-cargas.procod = abascargaprod.procod.
                tt-cargas.interface = abascargaprod.interface.
            end.    
    end. 1*/ 
    
    for each abasconfprod of abascorteprod no-lock.
        for each abascargaprod where abascargaprod.dcbcod  = abasconfprod.dcbcod and
                                     abascargaprod.dcbpseq = abasconfprod.dcbpseq
                        no-lock.
            
            create tt-cargaseq. 
            tt-cargaseq.rec     = recid(abascargaprod). 
            tt-cargaseq.dcbcod  = abascargaprod.dcbcod. 
            tt-cargaseq.procod  = abascargaprod.procod. 
            tt-cargaseq.dcbpseq = abasconfprod.dcbpseq. 
            tt-cargaseq.arquivoIntegracao = abascargaprod.arquivoIntegracao. 
            tt-cargaseq.qtdcarga = abascargaprod.qtdcarga.

        end.
        /* Acontece apenas no EBLJ */
        for each abascargaprod where abascargaprod.dcbcod  = abasconfprod.dcbcod and
                                     abascargaprod.procod  = abasconfprod.procod and
                                     abascargaprod.dcbpseq = ?
                        no-lock.
            
            create tt-cargaseq. 
            tt-cargaseq.rec     = recid(abascargaprod). 
            tt-cargaseq.dcbcod  = abascargaprod.dcbcod. 
            tt-cargaseq.procod  = abascargaprod.procod. 
            tt-cargaseq.dcbpseq = abasconfprod.dcbpseq. 
            tt-cargaseq.arquivoIntegracao = abascargaprod.arquivoIntegracao. 
            tt-cargaseq.qtdcarga = if abasconfprod.interface = "FCGL"
                                   then abascargaprod.qtdcarga
                                   else abasconfprod.qtdcarga.

        end.
        
    end.    
    
end.


vqtdcarga = 0.
for each abascorteprod of abastransf no-lock,
    abascorte of abascorteprod no-lock    
        by abascorte.datareal
        by abascorte.horareal
        by abascorte.dcbcod
        by abascorteprod.dcbpseq.
    for each tt-cargaseq of abascorteprod
        where tt-cargaseq.qtd > 0.
        find abascargaprod where recid(abascargaprod) = tt-cargaseq.rec no-lock.
        find abasintegracao of abascargaprod no-lock no-error.
        
        
                vseq = vseq + 1.
                create tt-cortes.
                tt-cortes.seq      = vseq.
                tt-cortes.oper     = "CARGA".
                tt-cortes.rec      = recid(abascargaprod).
                tt-cortes.etbcod   = abastransf.etbcod.
                tt-cortes.abtcod   = abastransf.abtcod.
                tt-cortes.dcbcod   = abascorte.dcbcod. 
                if avail abasintegracao
                then do:
                    tt-cortes.numero   = abasintegracao.ncarga.
                    tt-cortes.datareal = abasintegracao.datareal.
                    tt-cortes.horareal = abasintegracao.horareal.
                end.
                tt-cortes.qtd      = tt-cargaseq.qtdcarga.

            if avail abasintegracao and abasintegracao.dtfim <> ? and
               (abasintegracao.placod <> 0 and
                abasintegracao.placod <> ?)
            then do:

                    find plani where plani.etbcod = abasintegracao.etbcd and
                                     plani.placod = abasintegracao.placod
                                     no-lock no-error.
                    vseq = vseq + 1.
                    create tt-cortes.
                    tt-cortes.seq      = vseq.
                    tt-cortes.oper     = "NOTA".
                    tt-cortes.rec      = recid(abascargaprod).
                    tt-cortes.etbcod   = abastransf.etbcod.
                    tt-cortes.abtcod   = abastransf.abtcod.
                    tt-cortes.dcbcod   = abascorte.dcbcod. 
                    tt-cortes.numero   = if avail plani
                                         then plani.numero
                                         else abasintegracao.ncarga.
                    tt-cortes.datareal = if avail plani
                                         then plani.dtinclu
                                         else abasintegracao.dtfim.
                    tt-cortes.horareal = if avail plani
                                         then plani.horinc
                                         else abasintegracao.hrfim.
                    tt-cortes.qtd      = tt-cargaseq.qtdcarga.
                    tt-cortes.traetbcod = if avail plani
                                          then plani.etbcod
                                          else 0.
                    tt-cortes.traplacod = if avail plani
                                          then plani.placod
                                          else 0.
            end.

        vqtdcarga = vqtdcarga + tt-cargaseq.qtdcarga.
    end.
end.

        if abastransf.abtsit = "EL" or
           abastransf.abtsit = "CA"
        then do on error undo:    
            vseq = vseq + 2.
            create tt-cortes.
            tt-cortes.seq      = vseq.
            tt-cortes.oper     = "CANCELA".
            tt-cortes.abtsit   = abastransf.abtsit.
            tt-cortes.rec      = recid(abastransf).
            tt-cortes.etbcod   = abastransf.etbcod.
            tt-cortes.abtcod   = abastransf.abtcod.
            tt-cortes.datareal = if abastransf.candt = ?
                                 then abastransf.dttransf 
                                 else abastransf.candt.
            tt-cortes.horareal = abastransf.canhr.
            tt-cortes.dcbcod = ?.
            tt-cortes.numero   = abastransf.abtcod.
            tt-cortes.qtd      = abastransf.abtqtd - abastransf.qtdatend.
        end.            
            
vqtdatend = 0.
vqtdemwms = 0.
for each tt-cortes
    by  tt-cortes.etbcod
    by  tt-cortes.abtcod
    by  tt-cortes.seq .

    if tt-cortes.oper = "PEDIDO"
    then do:
        vqtdatend = 0.
        vqtdemwms  = 0. 
        tt-cortes.qtdPEND  = tt-cortes.qtd.
        tt-cortes.qtdemwms = vqtdemwms. 
        tt-cortes.qtdatend = vqtdatend.  
        vabtsit     = "AC".
        tt-cortes.abtsit = vabtsit.
    end.
    
    if tt-cortes.oper = "CORTE"
    then do: 
        find abascorteprod where recid(abascorteprod) = tt-cortes.rec no-lock. 
        find abascorte of abascorteprod no-lock.
        find abastransf    of abascorteprod no-lock. 
        vqtdemwms   = vqtdemwms + abascorteprod.qtdcorte. 
        tt-cortes.qtdemwms = vqtdemwms. 
        tt-cortes.qtdatend = vqtdatend. 
        tt-cortes.qtdPEND  = abastransf.abtqtd - vqtdemwms - vqtdatend. 
        if tt-cortes.qtdpend < 0
        then tt-cortes.qtdpend = 0.
        vabtsit   =  if tt-cortes.qtdpend > 0
                     then "AC"
                     else if abascorte.interface = "DSTR" 
                         then "IN" 
                         else "IN".
        tt-cortes.abtsit = vabtsit.
    end.
    if tt-cortes.oper = "FCGL"
    then do:
        tt-cortes.abtsit = vabtsit.
    end.
    if tt-cortes.oper = "CONF" /*or
       tt-cortes.oper = "FCGL" */
    then do: 
        find abasconfprod where recid(abasconfprod) = tt-cortes.rec no-lock. 
        find abascorteprod of abasconfprod no-lock.
        find abastransf    of abascorteprod no-lock.
        /*if abasconfprod.interface = "CONF"
        then*/ do: 
            vqtdemwms   = vqtdemwms - abascorteprod.qtdcorte. 
            vqtdemwms   = vqtdemwms + abasconfprod.qtdconf.   
            tt-cortes.qtdemwms = vqtdemwms. 
            tt-cortes.qtdatend = vqtdatend. 
            tt-cortes.qtdPEND  = abastransf.abtqtd - vqtdemwms - vqtdatend. 
            if tt-cortes.qtdpend < 0
            then tt-cortes.qtdpend = 0.
            vconf = yes.            
            if tt-cortes.qtdpend > 0 
            then vabtsit = "AC".
            else vabtsit = "SE".
            tt-cortes.abtsit = vabtsit.                          
        end.
    end.
    if tt-cortes.oper = "CARGA"
    then do: 
        find abascargaprod where recid(abascargaprod) = tt-cortes.rec no-lock.
        /**
        find abascorteprod of abasconfprod no-lock.
        find abastransf of abascorteprod no-lock.
        **/
        /**
        vqtdemwms   = vqtdemwms - abasconfprod.qtdconf. 
        vqtdemwms   = vqtdemwms + abasconfprod.qtdcarga.   
        **/
        tt-cortes.qtdemwms = vqtdemwms. 
        tt-cortes.qtdatend = vqtdatend. 
        tt-cortes.qtdPEND  = abastransf.abtqtd - vqtdemwms - vqtdatend. 
        if tt-cortes.qtdpend < 0
        then tt-cortes.qtdpend = 0.
        
        if tt-cortes.qtdemwms > 0 and vconf = no
        then vabtsit = "SE".
        
        tt-cortes.abtsit   = "SE" . /*vabtsit.*/
    end.
    if tt-cortes.oper = "NOTA"
    then do: 
        find abascargaprod where recid(abascargaprod) = tt-cortes.rec no-lock.
        /*
        find abascorteprod of abasconfprod no-lock.
        find abastransf of abascorteprod no-lock.
        */
        
        vqtdemwms   = vqtdemwms - tt-cortes.qtd /*abascargaprod.qtdcarga*/ . 
        if vqtdemwms < 0
        then vqtdemwms = 0.
        vqtdatend   = vqtdatend + tt-cortes.qtd /*abascargaprod.qtdcarga*/. 
        tt-cortes.qtdemwms = vqtdemwms. 
        tt-cortes.qtdatend = vqtdatend. 
        tt-cortes.qtdPEND  = abastransf.abtqtd - vqtdemwms - vqtdatend. 
        if tt-cortes.qtdpend < 0
        then tt-cortes.qtdpend = 0.

            if tt-cortes.qtdpend = 0 and
               tt-cortes.qtdemwms = 0
            then vabtsit = "NE".
        if vconf = no       
        then do:
            if tt-cortes.qtdemwms > 0
            then vabtsit = "SE".
        end.
        
        tt-cortes.abtsit = "NE" . /*vabtsit.*/
        
    end.
    
    if tt-cortes.oper = "CANCELA" and
       vabtsit <> "NE"
    then do:
        vqtdemwms  = 0. 
        tt-cortes.qtdPEND  = 0.
        tt-cortes.qtdemwms = vqtdemwms. 
        tt-cortes.qtdatend = vqtdatend.  
        vabtsit = tt-cortes.abtsit.
    end.

end.
vqtdpend = abastransf.abtqtd - vqtdatend - vqtdemwms.

/*
if vqtdpend > 0
then vabtsit = "AC".
else if vqtdcarga >= abastransf.abtqtd
     then vabtsit = "NE".
     else vabtsit = "SE".
  */
  
def var sresp as log.

/*    for each tt-cortes
        by  tt-cortes.etbcod
        by  tt-cortes.abtcod
        by  tt-cortes.seq .
        disp tt-cortes.
    end.
  */

if par-ajusta = no
    and (vqtdemwms <> abastransf.qtdemwms or
         vqtdatend <> abastransf.qtdatend or
         vabtsit <> abastransf.abtsit or 
         abastransf.abtqtd - abastransf.qtdemwms - abastransf.qtdatend <> vqtdpend)
then do:
    if vabtsit = abastransf.abtsit
    then sresp = yes.
    else sresp = no.
    /*
    message
    abastransf.wms abastransf.abtqtd "emwms" "novo" vqtdemwms abastransf.qtdemwms "atend" "nvo" vqtdatend abastransf.qtdatend "pend" vqtdpend vabtsit abastransf.abtsit
    update sresp.    
    */
    
end.
else sresp = par-ajusta.

if sresp
then do:
    if abastransf.qtdemwms <> vqtdemwms 
    then do on error undo:
        find current abastransf exclusive.
        abastransf.qtdemwms = vqtdemwms. 
        find current abastransf no-lock.
    end.
    if abastransf.qtdatend <> vqtdatend 
    then     do on error undo:
        find current abastransf exclusive.
        abastransf.qtdatend = vqtdatend. 
        find current abastransf no-lock.
    end.
    if abastransf.abtsit <> vabtsit 
    then do on error undo:
        find current abastransf exclusive.
        abastransf.abtsit = vabtsit. 
        find current abastransf no-lock.
    end.
end.



