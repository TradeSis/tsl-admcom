/*
*
*    MANUTENCAO EM acrfilELECIMENTOS               
*/

{admcab.i}

def shared temp-table tt-dep
   field  deprec      as recid
   field  Etbcod      like estab.Etbcod
   field  pladat      like plani.pladat
   field  cheque-dia  like plani.platot
   field  cheque-pre  like plani.platot
/*   field  cheque-glo  like plani.platot */
   field  pagam       like plani.platot
   field  deposito    like plani.platot
   field  situacao    as l format "Sim/Nao".


def var v-mar as dec.
def var vmarca          as char format "x"                          no-undo.
def temp-table wfin
    field wrec as recid.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.

def var v-ven  as dec.
def var v-con  as dec.
def var v-acr  as dec.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    if recatu1 = ?
    then
        find first tt-dep where
            true no-error.
    else
        find tt-dep where recid(tt-dep) = recatu1.
        vinicio = no.
    if not available tt-dep
    then do:
        bell.
        message "Nao existe acrescimo para esta filial".
        pause.
        return.
        form tt-dep
            with frame f-altera
            overlay row 6 1 column centered color white/cyan.
        message "Cadastro de tt-depelecimento Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-altera:
                create tt-dep.
                update tt-dep.
                vinicio = yes.
        end.
    end.
    clear frame frame-a all no-pause.
    find first wfin where wfin.wrec = recid(tt-dep) no-error.

    display tt-dep.etbcod    column-label "Fl" format ">>9"
            tt-dep.deposito   column-label "Deposito" format ">>,>>9.99"
            tt-dep.cheque-dia column-label "Cheq Dia" format ">>,>>9.99"
            tt-dep.cheque-pre column-label "Cheq Pre" format ">>,>>9.99" 
       /*   tt-dep.cheque-glo column-label "Cheq Glo" format ">>,>>9.99"  */
            tt-dep.pagam      column-label "Pagamento" format ">>,>>9.99"
            tt-dep.situacao column-label "Conf."
                with frame frame-a 12 down centered color white/red.

    recatu1 = recid(tt-dep).
    repeat:
        find next tt-dep where
                true.
        if not available tt-dep
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio = no
        then
        down with frame frame-a.
        
        display tt-dep.etbcod    
                tt-dep.deposito  
                tt-dep.cheque-dia
                tt-dep.cheque-pre
            /*  tt-dep.cheque-glo */
                tt-dep.pagam     
                tt-dep.situacao 
                    with frame frame-a 12 down centered color white/red.

    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-dep where recid(tt-dep) = recatu1.

        choose field tt-dep.etbcod
            go-on(cursor-down cursor-up
                  page-down   page-up
                  cursor-left cursor-right
                  tab PF4 F4 ESC return).
        hide message no-pause.
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-dep where
                    true no-error.
                if not avail tt-dep
                then leave.
                recatu2 = recid(tt-dep).
            end.
            if reccont = frame-down(frame-a)
            then recatu1 = recatu2.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-dep where
                    true no-error.
                if not avail tt-dep
                then leave.
                recatu1 = recid(tt-dep).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-dep where
                true no-error.
            if not avail tt-dep
            then next.
            color display white/red
                tt-dep.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-dep where
                true no-error.
            if not avail tt-dep
            then next.
            color display white/red
                tt-dep.etbcod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
            hide frame frame-a no-pause.
            if tt-dep.situacao
            then do:
                message "Movimento ja confirmado".
                undo, retry.
            end.
            update tt-dep.situacao with frame frame-a.
            find plani where recid(plani) = tt-dep.deprec no-error.
            if avail plani
            then assign plani.tmovdev = tt-dep.situacao
                        plani.dtinclu = today.
            view frame frame-a .
        end.
        if keyfunction (lastkey) = "end-error"
        then view frame frame-a.
        find first wfin where wfin.wrec = recid(tt-dep) no-error.

        
        display tt-dep.etbcod  
                tt-dep.deposito
                tt-dep.cheque-dia
                tt-dep.cheque-pre
            /*  tt-dep.cheque-glo */
                tt-dep.pagam     
                tt-dep.situacao 
                    with frame frame-a 12 down centered color white/red.


        recatu1 = recid(tt-dep).
   end.
end.
