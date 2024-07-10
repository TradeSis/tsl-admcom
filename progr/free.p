/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6 initial
        ["Pagamento","Alteracao","Exclusao","Consulta","Listagem","Vendedor"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].

def var vetbcod like estab.etbcod.
def buffer bfree       for free.
def var vvencod         like free.vencod.


    form
        esqcom1
            with frame f-com1
                row 3 no-box no-labels side-labels  column 1.

    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
    
    update vetbcod label "Filial" with frame f-fil side-label centered.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f-fil row 5 no-box
                        color black/cyan width 55.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first free where free.etbcod = estab.etbcod
             no-error.
    else
        find free where recid(free) = recatu1.
    vinicio = yes.
    if not available free
    then do:
        message "Cadastro de Comissao Vazio".
        undo, retry.
    end.
    
    clear frame frame-a all no-pause.
    pause 0.
    find func where func.funcod = free.vencod and
                    func.etbcod = estab.etbcod no-lock no-error.
    display
        free.vencod column-label "Vend"
        func.funnom when avail func format "x(20)"
        free.fredtini
        free.fredtfin
        free.freval column-label "Comissao"
        free.fresal column-label "Pecas"
        free.fresit column-label "Sit" format "x(3)"
            with frame frame-a row  7 down centered color black/cyan.

    recatu1 = recid(free).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next free where
                true.
        if not available free
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        find func where func.etbcod = estab.etbcod and
                        func.funcod = free.vencod no-lock no-error.
        display
            free.vencod
            func.funnom when avail func
            free.fredtini
            free.fredtfin
            free.freval
            free.fresal
            free.fresit
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find free where recid(free) = recatu1.

        choose field free.vencod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display white/cyan
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display white/cyan esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 6
                          then 6
                          else esqpos1 + 1.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display white/cyan
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next free where true no-error.
                if not avail free
                then leave.
                recatu1 = recid(free).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev free where true no-error.
                if not avail free
                then leave.
                recatu1 = recid(free).
            end.
            leave.
        end.


        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next free where
                true no-error.
            if not avail free
            then next.
            color display black/cyan
                free.vencod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev free where
                true no-error.
            if not avail free
            then next.
            color display black/cyan
                free.vencod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
          hide frame frame-a no-pause.
          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.


            if esqcom1[esqpos1] = "Pagamento"
            then do:
                update free.fresit with frame frame-a.
                recatu1 = recid(free).
                leave.
            end.

            if esqcom1[esqpos1] = "Vendedor"
            then do:
                pause 0.
                run free01.p (input free.vencod,    
                              input free.etbcod).

                recatu1 = recid(free).
                leave.
            end.

            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update free with frame f-altera no-validate.
                hide frame f-altera.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp free with frame f-consulta no-validate.
                hide frame f-consulta.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" free.freval update sresp.
                if not sresp
                then leave.
                find next free where true no-error.
                if not available free
                then do:
                    find free where recid(free) = recatu1.
                    find prev free where true no-error.
                end.
                recatu2 = if available free
                          then recid(free)
                          else ?.
                find free where recid(free) = recatu1.
                delete free.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de freeidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each free:
                    display free.
                end.
                output close.
                recatu1 = recatu2.
                leave.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end.
          view frame frame-a .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        find func where func.funcod = free.venco and
                        func.etbcod = estab.etbcod no-lock no-error.

        display
                free.vencod
                func.funnom when avail func
                free.fredtini
                free.fredtfin
                free.freval
                free.fresal
                free.fresit
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(free).
   end.
end.
