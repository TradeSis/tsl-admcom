/* 20.11.2019 - helio.neto - ajusta na regra de reserva ecom, colocando os pedidos web como prioridade */
def input  parameter pprocod        like produ.procod. 
def input  parameter precid         as    recid.
def output parameter vestoq_depos   as   int format "->>>>>9".
def output parameter vreserv_Ecom  as int.
def output parameter vreservas      as   int format "->>>>>9".
def output parameter vatend         as   int format "->>>>>9".
def output parameter vdisponivel    as   int format "->>>>>9".


def var vcalcularweb as log.

def var vdisponivelTOT  as int.
def var vreservasWEb as int.
def var vabtqtd     as int.
def var vqtd        as int.
def var vcalculo   as int.

def shared temp-table tt-pedtransf no-undo
    field prioridade    like abastipo.abatpri  
    field etbcod        like abastransf.etbcod
    field abtcod        like abastransf.abtcod
    field abtqtd        like abastransf.abtqtd    
    field atende        as int
    field reserv        as int
    field reservOPER    as char
    field dispo         as int
    field indispo       as int
    index sequencia is unique primary prioridade asc
    index abt is unique etbcod asc abtcod asc.

for each tt-pedtransf.
    delete tt-pedtransf.
end.    

def buffer babastransf for abastransf.
def var vsit    as char extent 3 init ["SE","IN","AC"].
def var isit    as int.
def var vprioridade as int.

/* 27.06.2019 */
def var vpack as int. /* substituindo conjunto.qtd */
def var vcon as int.
def var vres as int.
def var vqtdpack    like vabtqtd.

find produ where produ.procod = pprocod no-lock.

for each abascdestoq no-lock.
    find estoq where 
            estoq.procod = produ.procod and
            estoq.etbcod = abascdestoq.etbcod 
        no-lock no-error.
    vestoq_depos = vestoq_depos + 
                    if avail estoq
                    then estoq.estatual
                    else 0.
end.

vdisponivel = vestoq_depos.

run /admcom/progr/reserv_ecom.p (input  produ.procod,
                   output vreserv_ecom).

vreservasWEB = vreserv_ecom.
vdisponivel  = vestoq_depos - vreservasWEB.


                def var wdisponivel as int.
                def var watende     as int.
                def var wreservasWEB as int.


    /* 27.06.19 */
    find first produaux of produ where
            produaux.nome_campo = "PACK"  
       no-lock no-error.   
    vpack = (if avail produaux  
             then int(produaux.valor_campo)  
             else 0) no-error.  
    if vpack = ? or vpack = 0   
    then vpack = 1.
    /* 27.06.19 */

vprioridade = 0.
    
    vcalcularweb = no.
    
    if  vreservasWEB > 0
    then do:
        vcalcularweb = yes.
        vdisponivel = vreservasWEB.
        for each abastipo where
            abastipo.abatipo = "WEB"
            no-lock
            /*break /*by abastipo.origemvenda desc*/
                  by abastipo.abatpri .
            for*/ , each babastransf where 
                    babastransf.abtsit  = "AC" and
                    babastransf.abatipo = abastipo.abatipo and
                    babastransf.procod = produ.procod
                no-lock
                    by babastransf.dttransf
                    by abastipo.abatpri
                    by babastransf.dtinclu
                    by babastransf.hrinclu
                    by babastransf.abtcod.        

                vprioridade = vprioridade + 1.
                
                if babastransf.abtsit = "AC"
                then do:
                    vabtqtd = babastransf.abtqtd - (babastransf.qtdemWMS + baba~stransf.qtdatend).
                    
                    vdisponivel = vdisponivel - babastransf.qtdemWMS.
                    
                    if babastransf.dttransf > today
                    then do:
                        vqtd    = vabtqtd.
                        vabtqtd = 0.
                    end.    
                    
                end.    
                else do:
                    vabtqtd = babastransf.qtdemWMS.
                end.           
                
                vreservas = vreservas + vabtqtd.
                                
                wdisponivel = if babastransf.abatipo <> "WEB"
                              then vdisponivel
                              else vdisponivel /* +
                                    /*19112019*/ vreservasWEB*/ .

                watende     = if wdisponivel >= vabtqtd                
                              then vabtqtd
                              else if wdisponivel < 0
                                   then 0
                                   else wdisponivel.
                if watende < vabtqtd
                then do:
                    if vestoq_depos - vreserv_ecom >= vabtqtd - watende
                    then do:
                        
                        vdisponivel = vdisponivel + (vabtqtd - watende).
                        wdisponivel = vdisponivel.
                        watende = vabtqtd.
                        
                    end.
                end.
                
                vatend = vatend + watende.
 
                if precid = ? 
                then do:
                    create tt-pedtransf.
                    tt-pedtransf.prioridade = vprioridade.
                    tt-pedtransf.etbcod     = babastransf.etbcod.
                    tt-pedtransf.abtcod     = babastransf.abtcod.
                    tt-pedtransf.abtqtd     = if babastransf.dttransf > today 
                                                or 
                                                 vpack > 1
                                              then vqtd
                                              else vabtqtd. 
                    tt-pedtransf.dispo      = wdisponivel.
                    tt-pedtransf.atend      = watende.
                    
                    tt-pedtransf.reserv     =  if vreservasWEB > 0
                                               then vreservasWEB
                                               else 0.
                    tt-pedtransf.reservoper  =  if vreservasWEB <= 0
                                               then ""
                                               else
                                                    if babastransf.abatipo <> "~WEB"
                                                    then "-"
                                                    else "+".

                    tt-pedtransf.indispo    =  vdisponivel - vabtqtd.

                    
                     
                    if babastransf.abatipo <> "WEB"
                    then do:
                        if vreservasWEB > 0 
                        then do:
                            /*
                            tt-pedtransf.indispo =  tt-pedtransf.indispo - vres~ervasWEB.                   */
                            /*
                            if tt-pedtransf.indispo < 0
                            then tt-pedtransf.indispo = 0.
                            */
                        end.    
                    end.                      
                    
                end.
                                       
                if babastransf.abatipo = "WEB"
                then do:
                    if vreservasWEB > 0
                    then vreservasWEB = vreservasWEB - watende.
                end.
 
                vdisponivel = vdisponivel - /*if watende > 0
                                            then watende
                                            else*/ vabtqtd.
                if precid <> ?
                then do:
                    if recid(babastransf) = precid
                    then do:
                        vatend      = watende.
                        vdisponivel = wdisponivel.
                        return.
                    end.    
                end.
            if vdisponivel <= 0 then leave.        
        end.

        vdisponivel = vestoq_depos - (vreserv_ecom - vreservasWEB).
        vdisponivel = vestoq_depos - vreservasWEB.
        vdisponivel = vestoq_depos - vreserv_ecom.
    end.
 
do isit = 1 to 3.
    for each abastipo 
            no-lock
            /*break /*by abastipo.origemvenda desc*/
                  by abastipo.abatpri .
            for*/ , each babastransf where 
                    babastransf.abtsit  = vsit[isit] and
                    babastransf.abatipo = abastipo.abatipo and
                    babastransf.procod = produ.procod
                no-lock
                    by babastransf.dttransf
                    by abastipo.abatpri
                    by babastransf.dtinclu
                    by babastransf.hrinclu
                    by babastransf.abtcod.        
                    find tt-pedtransf where
                        tt-pedtransf.etbcod = babastransf.etbcod and
                        tt-pedtransf.abtcod = babastransf.abtcod
                        no-error.
                    if  avail tt-pedtransf
                    then next.    
                    
                vprioridade = vprioridade + 1.
                
                if babastransf.abtsit = "AC"
                then do:
                    vabtqtd = babastransf.abtqtd - (babastransf.qtdemWMS + babastransf.qtdatend).
                    
                    vdisponivel = vdisponivel - babastransf.qtdemWMS.
                    
                    if babastransf.dttransf > today
                    then do:
                        vqtd    = vabtqtd.
                        vabtqtd = 0.
                    end.    
                    
                end.    
                else do:
                    vabtqtd = babastransf.qtdemWMS.
                end.           
                
                /* teste pack */
                
                if vpack > 1 and
                   vabtqtd > 0 and
                   abastipo.abatipo <> "WEB"
                then do:   
                    vcon = truncate(vabtqtd / vpack,0). 
                    vres = if vabtqtd > (vpack * vcon) 
                           then vabtqtd - (vpack * vcon) 
                           else 0. 
                    vqtdpack = vpack * vcon. 
                    vqtd    = vabtqtd.
                    vabtqtd = vqtdpack.
                end.
                
                
                /* fim teste pack */
                     
                vreservas = vreservas + vabtqtd.

                                
                wdisponivel = if babastransf.abatipo <> "WEB"
                              then vdisponivel
                              else vdisponivel /*+
                                    /*19112019*/ vreservasWEB */.

                watende     = if wdisponivel >= vabtqtd                
                              then vabtqtd
                              else if wdisponivel < 0
                                   then 0
                                   else wdisponivel.
               
                if vpack > 1 and
                   watende > 0 and
                   abastipo.abatipo <> "WEB"
                then do:   
                    vcon = truncate(watende / vpack,0). 
                    vres = if watende > (vpack * vcon) 
                           then watende - (vpack * vcon) 
                           else 0. 
                    vqtdpack = vpack * vcon. 
                    watende = vqtdpack.
                end.

                vatend = vatend + watende.
 
 
                if precid = ?
                then do:
                
                    create tt-pedtransf.
                    tt-pedtransf.prioridade = vprioridade.
                    tt-pedtransf.etbcod     = babastransf.etbcod.
                    tt-pedtransf.abtcod     = babastransf.abtcod.
                    tt-pedtransf.abtqtd     = if babastransf.dttransf > today or 
                                                 vpack > 1
                                              then vqtd
                                              else vabtqtd. 
                    tt-pedtransf.dispo      = wdisponivel.
                    tt-pedtransf.atend      = watende.
                    
                    tt-pedtransf.reserv     =  if vreservasWEB > 0
                                               then vreservasWEB
                                               else 0.
                    tt-pedtransf.reservoper  =  if vreservasWEB <= 0
                                               then ""
                                               else
                                                    if babastransf.abatipo <> "WEB"
                                                    then "-"
                                                    else "+".

                    tt-pedtransf.indispo    = if vabtqtd - vdisponivel < 0
                                              then vdisponivel - vabtqtd
                                              else vdisponivel - vabtqtd.

                    
                     
                    if babastransf.abatipo <> "WEB"
                    then do:
                        if vreservasWEB > 0 
                        then do:
                            /*
                            tt-pedtransf.indispo =  tt-pedtransf.indispo - vreservasWEB.                   */
                            /*
                            if tt-pedtransf.indispo < 0
                            then tt-pedtransf.indispo = 0.
                            */
                        end.    
                    end.                      
                end.
                                       
                /*1911 if babastransf.abatipo = "WEB"
                then do:
                    if vreservasWEB > 0
                    then vreservasWEB = vreservasWEB - watende.
                end.
                */
                
                vdisponivel = vdisponivel - /*if watende > 0
                                            then watende
                                            else*/ vabtqtd.
                if precid <> ?
                then do:
                    if recid(babastransf) = precid
                    then do:
                        vatend      = watende.
                        vdisponivel = wdisponivel.
                        return.
                    end.    
                end.
                
    end.
    
end.                        


