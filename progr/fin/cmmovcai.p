/*
*
* Manutencao em Movimentos de CMon - Extra             CMon/cmd.p
*
*/
def var par-cxacod as int.
def  var par-transit as log initial no.
def buffer xcmon for cmon.
def new shared var      l_souocmon      as log.

def var vcont as int.
def var par-pdvmov-recid   as recid.
def var par-moe-ok      as log no-undo.
def new shared var      vpdvmov-cmdvlr as dec.
def new shared var      vretorna        as log.

def var par-ctmcod     like pdvtmov.ctmcod.
def var par-operacao    as char.

def var vnome           as char label "Nome" .
def var vheader         as char format "x(30)".
def var vi as int.
def new shared frame ffmoetit.
form header vheader with frame ffmoetit.

{cabec.i}
def input parameter par-parametro as char.

def var par-cmtcod      like cmtipo.cmtcod.
def var par-recid-cmon as recid.
par-cmtcod = entry(1,par-parametro).
if num-entries(par-parametro) = 2
then do:
    par-cxacod = int(entry(2,par-parametro)).
    find cmon where cmon.cmtcod = par-cmtcod and
                    cmon.etbcod = setbcod and
                    cmon.cxacod = par-cxacod 
                    no-lock no-error.
    if not avail cmon
    then do:
        find cmon where recid(cmon) = par-cxacod no-lock no-error.
        if avail cmon
        then par-recid-cmon = recid(cmon).
        else par-recid-cmon = ?.
    end.
    else par-recid-cmon = recid(cmon).
end.    


def buffer bcmon    for cmon.
def new shared frame f-pdvmov.
/*def new shared frame separa.
form
     "|" skip
     "|" skip
     "|" skip
     "|" skip
     "|" skip
     "|" skip
     "|" skip
     "|" skip
     "|" skip
     "|" skip
     "|" skip
     "|"
    with frame separa   row 8 col 40
    1 down side-labels overlay no-box.
    */
/*
form
"____________________________________________________________________________"
space(0) "____"
    with frame separa1  row 5 centered 1 down overlay no-box .
*/
form
"____________________________________________________________________________"
space(0) "____"
    with frame separa2  row 20 centered 1 down overlay no-box .

form
    pdvtmov.ctmnom no-label
        with frame f-cmoper
            row 4 side-labels centered no-box color input 1 down.
form
    pdvmov.sequencia
    vpdvmov-cmdvlr  label "Total" format "zzzz,zz9.99"
    pdvmov.dtincl   
    pdvmov.datamov

     with frame f-pdvmov
           row 5 side-labels width 80 no-box color messages
           centered 1 down.
def var par-dtini as date.

def new shared frame f-ecmon.
    form cmon.etbcod    label "Etb" format ">>9"
         CMon.cxacod    label "Local"
         CMon.cxanom             no-label
                           par-dtini          label "Dt Ini"
         CMon.cxadt         colon 65 format "99/99/9999" label "Data"
         with frame f-eCMon row 3 width 81
                         side-labels no-box.

find cmtipo where cmtipo.cmtcod = par-cmtcod no-lock.

do:
if par-recid-cmon <> ?
then do:
do:
    if cmtipo.cmtcod = "EXT"
    then do:
        if par-recid-cmon <> ?
        then do:
            find cmon where recid(cmon) = par-recid-cmon no-lock no-error.
            if not avail cmon
            then return.
            if cmon.cmtcod <> cmtipo.cmtcod
            then return.
            display cmon.etbcod
                    CMon.cxanom
                    CMon.cxacod
                    with frame f-eCMon.

        end.
    end.
end.

end.
else do:

do:
    if cmtipo.cmtcod = "EXT"
    then do:
        find first CMon where CMon.cmtcod = "EXT" no-lock.
        display CMon.cxanom
                CMon.cxacod
                with frame f-eCMon.
        find first CMon where CMon.cmtcod = "EXT" no-lock.
        display CMon.cxanom
                CMon.cxacod
                with frame f-ecmon.
    end.
end.
end.
l_souocmon = no.

do:
    /**/
    /**/
end.

 DEF VAR PAR-OK AS LOG.
    PAR-OK = NO.


repeat:
    vretorna = no.
    hide  frame ffmoetit no-pause.
    hide  frame f-cmoper no-pause.
    hide  frame f-pdvmov no-pause.
    hide  frame freceben no-pause.
/*    hide  frame separa no-pause.*/
    hide  frame separa2 no-pause.
    clear frame freceben all no-pause.
    clear frame ffmoetit all.

    run fin/cmmovmen.p (input recid(CMon),
                   input-output par-transit,
                   output par-ctmcod,
                   output par-operacao).

    if keyfunction(lastkey) = "END-ERROR"
    then leave.
      pause 0.
    
     find pdvtmov where pdvtmov.ctmcod = par-ctmcod no-lock no-error.
    if not avail pdvtmov
    then do:
        message pdvtmov.ctmnom cmon.cxanom "Sem Operacoes Cadastradas".
        pause.
        leave.
    end.
    disp
        pdvtmov.ctmnom
            with frame f-cmoper.

    if pdvtmov.operacao = yes /* Pagamento */
    then do:
        vheader  = "Saida do " + cmtipo.cmtnom.
    end.
    else do:
        vheader  = "Entradas no " + cmtipo.cmtnom.
    end.
    vretorna = no.
    par-moe-ok = yes.
    
    if par-ctmcod = "RNF"
    then 
        par-moe-ok = no.

            if pdvtmov.ctmcod = "CER" or
               pdvtmov.ctmcod = "GOL"
            then do :
                pause 0.
                run fin/cdtransfereconta_v2003.p (input pdvtmov.ctmcod).
                next.
            end.
            if pdvtmov.ctmcod = "REP"
            then do: 
                pause 0 .
                run fin/repactua.p.
                next.
            end.                    

    do while true.
        
        do: /* Encontro de Contas */
            if par-moe-ok
            then
                run fin/cmdinc.p (input recid(cmon),
                              input recid(pdvtmov),
                              output par-pdvmov-recid).
                              
            find pdvmov where recid(pdvmov) = par-pdvmov-recid no-lock.
            sresp = yes.
            if pdvtmov.ctmcod = "SIP"
            then do :
            
                /* helio 18112020 paliativo baixa sinistro sem arquivo */

                    run sys/message.p (input-output sresp,
                           input "BAIXA UTILIZANDO " +
                                 " ARQUIVO ?",
                                   input " !! ATENCAO !! ",
                                   input "    SIM",
                                   input "    NAO").
            
            
            end.            
            if pdvtmov.ctmcod = "SIP" and sresp = yes
            then do :
                run fin/ctsinsegbaixa_v0219.p (input par-pdvmov-recid).
                def var vtotal as dec.
                vtotal = 0.
                for each pdvdoc of pdvmov.
                    vtotal = vtotal + pdvdoc.valor.
                end.
                do on error undo:
                    find current pdvmov exclusive.
                    pdvmov.valortot = vtotal.
                end.
                leave.
            end.
            else do:
                par-moe-ok = no.
                run fin/cmdope.p (input par-pdvmov-recid,
                              input "NOVO").
            end.
        end.
        vretorna = no.
        hide message no-pause.
        message "Fechamento...".
        pause 1 no-message. 
        run fin/cmdok.p (input  par-pdvmov-recid,
                     output par-ok,
                     output vretorna).
        hide message no-pause.
/*        message "fim do fechamento". pause.*/
        find pdvmov where recid(pdvmov) = par-pdvmov-recid no-lock no-error.
        if avail pdvmov
        then do:
            if par-ok = yes /* OK */
            then leave.
        end.
        else leave.         /* Cancela */
    end.
end.

hide frame ffmoetit no-pause.
hide frame f-pdvmov no-pause.
hide frame separa no-pause.
hide frame separa2 no-pause.
hide frame f-cmoper no-pause.
hide frame f-ecmon no-pause.
hide frame f-opera no-pause.
end.
