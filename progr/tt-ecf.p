/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def temp-table tt-ecf
    field etbcod like estab.etbcod
    field cxacod like caixa.cxacod
    field codecf as int format ">>>>>>>>>>>>>99"
        index ind-1 etbcod
                    cxacod.

input from ..\progr\tt-ecf.txt.
repeat:
    create tt-ecf.
    import tt-ecf.
end.
input close.

for each tt-ecf where tt-ecf.etbcod = 0.
    delete tt-ecf.
end.


def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 3
            initial ["Inclusao","Exclusao","Alteracao"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btt-ecf       for tt-ecf.
def var vetbcod         like tt-ecf.etbcod.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first tt-ecf where
            true no-error.
    else
        find tt-ecf where recid(tt-ecf) = recatu1.
    vinicio = yes.
    if not available tt-ecf
    then do:
        message "Cadastro de impressoras fiscais".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
                create tt-ecf.
                update tt-ecf.etbcod
                       tt-ecf.cxacod
                       tt-ecf.codecf.
          vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.

    display
        tt-ecf.etbcod
        tt-ecf.cxacod
        tt-ecf.codecf
            with frame frame-a 14 down centered title "B R I N D E".

    recatu1 = recid(tt-ecf).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-ecf where
                true.
        if not available tt-ecf
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        display
            tt-ecf.etbcod
            tt-ecf.cxacod
            tt-ecf.codecf
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-ecf where recid(tt-ecf) = recatu1.

        choose field tt-ecf.etbcod
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
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
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
                esqpos1 = if esqpos1 = 3
                          then 3
                          else esqpos1 + 1.
                color display messages
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
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-ecf where true no-error.
                if not avail tt-ecf
                then leave.
                recatu1 = recid(tt-ecf).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-ecf where true no-error.
                if not avail tt-ecf
                then leave.
                recatu1 = recid(tt-ecf).
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
            find next tt-ecf where
                true no-error.
            if not avail tt-ecf
            then next.
            color display normal
                tt-ecf.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-ecf where
                true no-error.
            if not avail tt-ecf
            then next.
            color display normal
                tt-ecf.etbcod.
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

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
                create tt-ecf.
                update tt-ecf.etbcod
                       tt-ecf.cxacod
                       tt-ecf.codecf.
                recatu1 = recid(tt-ecf).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update tt-ecf with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp tt-ecf with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao" update sresp.
                if not sresp
                then leave.
                find next tt-ecf where true no-error.
                if not available tt-ecf
                then do:
                    find tt-ecf where recid(tt-ecf) = recatu1.
                    find prev tt-ecf where true no-error.
                end.
                recatu2 = if available tt-ecf
                          then recid(tt-ecf)
                          else ?.
                find tt-ecf where recid(tt-ecf) = recatu1.
                delete tt-ecf.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de tt-ecfidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each tt-ecf:
                    display tt-ecf.
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


        display
                tt-ecf.etbcod
                tt-ecf.cxacod
                tt-ecf.codecf
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-ecf).
   end.
end.
output to ..\progr\tt-ecf.txt.
for each tt-ecf.
    put tt-ecf.etbcod " " 
        tt-ecf.cxacod " " 
        tt-ecf.codecf " " skip.
end.
output close.
    
