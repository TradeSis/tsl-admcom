/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def var varquivo as char.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.


def buffer btabmen       for tabmen.
def var vetbcod         like tabmen.etbcod.


    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    if recatu1 = ?
    then
        find last tabmen use-index datexp where
            true no-error.
    else
        find tabmen where recid(tabmen) = recatu1.
    vinicio = yes.
    if not available tabmen
    then do:
        message "Cadastro de Mensagens Vazio".
        undo, leave.
    end.
    clear frame frame-a all no-pause.
    display tabmen.datexp
            with frame frame-a 10 down
                row 9 no-label title "Data".

    display tabmen.datexp no-label with frame f-data
                side-label color message no-box column 43 row 8.

    display tabmen.mensa[01]  no-label
            tabmen.mensa[02]  no-label
            tabmen.mensa[03]  no-label
            tabmen.mensa[04]  no-label
            tabmen.mensa[05]  no-label
            tabmen.mensa[06]  no-label
            tabmen.mensa[07]  no-label
            tabmen.mensa[08]  no-label
            tabmen.mensa[09]  no-label
            tabmen.mensa[10]  no-label
                    with frame ff-men row 9
                        title "Mensagem" color message column 17.
    recatu1 = recid(tabmen).
    repeat:
        find prev tabmen use-index datexp where
                true.
        if not available tabmen
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        
        display
            tabmen.datexp
                with frame frame-a.

        display tabmen.datexp no-label with frame f-data
                    side-label color message no-box column 43 row 8.

        display tabmen.mensa[01]  no-label
                tabmen.mensa[02]  no-label
                tabmen.mensa[03]  no-label
                tabmen.mensa[04]  no-label
                tabmen.mensa[05]  no-label
                tabmen.mensa[06]  no-label
                tabmen.mensa[07]  no-label
                tabmen.mensa[08]  no-label
                tabmen.mensa[09]  no-label
                tabmen.mensa[10]  no-label
                    with frame ff-men
                        title "Mensagem" color message column 17.

    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tabmen where recid(tabmen) = recatu1.

        choose field tabmen.datexp help "             [ P ]  Imprimir Mensagem"
            go-on(cursor-down cursor-up P p
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).

        if keyfunction(lastkey) = "P" or
           keyfunction(lastkey) = "p"
        then do:
           output to printer. 
               display tabmen.datexp no-label with frame f-data
                        side-label color message no-box column 43 row 8.

               display tabmen.mensa[01]  no-label
                       tabmen.mensa[02]  no-label
                       tabmen.mensa[03]  no-label
                       tabmen.mensa[04]  no-label
                       tabmen.mensa[05]  no-label
                       tabmen.mensa[06]  no-label
                       tabmen.mensa[07]  no-label
                       tabmen.mensa[08]  no-label
                       tabmen.mensa[09]  no-label
                       tabmen.mensa[10]  no-label
                            with frame ff-men
                            title "Mensagem" color message column 17.
           output close.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tabmen use-index datexp where true no-error.
                if not avail tabmen
                then leave.
                recatu1 = recid(tabmen).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tabmen  use-index datexp where true no-error.
                if not avail tabmen
                then leave.
                recatu1 = recid(tabmen).
            end.
            leave.
        end.


        if keyfunction(lastkey) = "cursor-down"
        then do:
            find prev tabmen use-index datexp where
                true no-error.
            if not avail tabmen
            then next.
            color display normal
                tabmen.datexp.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find next tabmen use-index datexp where
                true no-error.
            if not avail tabmen
            then next.
            color display normal
                tabmen.datexp.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        display tabmen.datexp
                    with frame frame-a.

        display tabmen.datexp no-label with frame f-data
                    side-label color message no-box column 43 row 8.
        display tabmen.mensa[01]  no-label
                tabmen.mensa[02]  no-label
                tabmen.mensa[03]  no-label
                tabmen.mensa[04]  no-label
                tabmen.mensa[05]  no-label
                tabmen.mensa[06]  no-label
                tabmen.mensa[07]  no-label
                tabmen.mensa[08]  no-label
                tabmen.mensa[09]  no-label
                tabmen.mensa[10]  no-label
                    with frame ff-men
                        title "Mensagem" color message column 17.

        recatu1 = recid(tabmen).
   end.
end.
