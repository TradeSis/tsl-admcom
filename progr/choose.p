/*
*
*    MANUTENCAO EM chequeELECIMENTOS                         estab.p    02/05/95
*
*/

{admcab.i}
def temp-table tt-cheque like cheque.
def input parameter par-cli like clien.clicod.
def output parameter par-rec as recid.
def buffer bclien for clien.
def var vopcao          as  char format "x(10)" extent 2
                                    initial ["Por Codigo","Por Cheque"] .
def var vnum like cheque.chenum.
def var vban like cheque.cheban.
def var vage like cheque.cheage.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.

def buffer bcheque       for cheque.
def var vchenum         like cheque.chenum.
    for each tt-cheque:
        delete tt-cheque.
    end.
    for each cheque where cheque.clicod = par-cli no-lock:

        create tt-cheque.
        assign tt-cheque.clicod = cheque.clicod
               tt-cheque.cheage = cheque.cheage
               tt-cheque.cheban = cheque.cheban 
               tt-cheque.chenum = cheque.chenum
               tt-cheque.cheval = cheque.cheval
               tt-cheque.chesit = cheque.chesit
               tt-cheque.checon = cheque.checon
               .

    end.

bl-princ:
repeat:
    if recatu1 = ?
    then
        find first tt-cheque where true no-error.
    else
        find first tt-cheque where recid(cheque) = recatu1.
        vinicio = no.
    if not available tt-cheque
    then do:
        message "Cadastro de cheque Vazio".
        undo.
    end.
    clear frame frame-a all no-pause.

    display tt-cheque.cheage
            tt-cheque.cheban
            tt-cheque.chenum
            tt-cheque.cheval
            tt-cheque.chesit
                       with frame frame-a down row 18 centered
                                       color black/cyan overlay.

    recatu1 = recid(tt-cheque).
    repeat:
        find next tt-cheque where true.
        if not available tt-cheque
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio = no
        then down with frame frame-a.
        display tt-cheque.cheage
                tt-cheque.cheban
                tt-cheque.chenum
                tt-cheque.cheval
                tt-cheque.chesit
                       with frame frame-a down row 15 centered
                                       color black/cyan overlay.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find first tt-cheque where recid(tt-cheque) = recatu1.
        choose field tt-cheque.cheage
            go-on(cursor-down cursor-up
                  page-down   page-up
                  cursor-left cursor-right
                  tab PF4 F4 ESC return).
        hide message no-pause.
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-cheque where true no-error.
                if not avail tt-cheque
                then leave.
                recatu2 = recid(tt-cheque).
            end.
            if reccont = frame-down(frame-a)
            then recatu1 = recatu2.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-cheque where true no-error.
                if not avail tt-cheque
                then leave.
                recatu1 = recid(tt-cheque).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-cheque where true no-error.
            if not avail tt-cheque
            then next.
            color display black/cyan
                tt-cheque.cheage.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-cheque where true no-error.
            if not avail tt-cheque
            then next.
            color display black/cyan
                tt-cheque.cheage.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            hide frame frame-a no-pause.
            find cheque where cheque.chenum = tt-cheque.chenum and
                              cheque.cheage = tt-cheque.cheage and
                              cheque.cheban = tt-cheque.cheban and
                              cheque.checon = tt-cheque.checon and
                              cheque.clicod = tt-cheque.clicod
                              no-lock.
            par-rec = recid(cheque).
            return.
            /*
            leave bl-princ.
            */
        end.
        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause.
           /* view frame frame-a. */
            find first cheque where cheque.chenum = tt-cheque.chenum and
                              cheque.cheage = tt-cheque.cheage and
                              cheque.cheban = tt-cheque.cheban and
                              cheque.checon = tt-cheque.checon and
                              cheque.clicod = tt-cheque.clicod
                              no-lock.
            par-rec = recid(cheque).
            return.
        end.
        if keyfunction (lastkey) = "end-error"
        then do:
            find cheque where cheque.chenum = tt-cheque.chenum and
                              cheque.cheage = tt-cheque.cheage and
                              cheque.cheban = tt-cheque.cheban and
                              cheque.checon = tt-cheque.checon and
                              cheque.clicod = tt-cheque.clicod
                              no-lock.
            par-rec = recid(cheque).
            hide frame frame-a no-pause.
            return.
        end.
        /*
        view frame frame-a.
        hide frame f-cli no-pause.
        */
        display tt-cheque.cheage
                tt-cheque.cheban
                tt-cheque.chenum
                tt-cheque.cheval
                tt-cheque.chesit
                       with frame frame-a down row 15 centered
                                       color black/cyan overlay.
        recatu1 = recid(tt-cheque).
   end.
end.


