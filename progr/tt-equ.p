/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def var vequ as char format "x(20)".
def temp-table tt-equ
    field etbcod like estab.etbcod
    field cxacod like caixa.cxacod
    field numequ as int
    field numwin as int
    index ind-1 etbcod
                cxacod
                numequ.


input from l:\progr\numecf.txt.
repeat:
    import vequ.
    find first tt-equ where tt-equ.etbcod = int(substring(vequ,8,2))  and
                            tt-equ.cxacod = int(substring(vequ,12,2)) and
                            tt-equ.numequ = int(substring(vequ,10,2)) and
                            tt-equ.numwin = int(substring(vequ,14,3))
                                no-error.
                                
    if not avail tt-equ
    then do:
        create tt-equ.
        assign tt-equ.etbcod =  int(substring(vequ,8,2)) 
               tt-equ.cxacod =  int(substring(vequ,12,2)) 
               tt-equ.numequ =  int(substring(vequ,10,2))
               tt-equ.numwin =  int(substring(vequ,14,3)). 
    end.

end.

input close.



def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btt-equ       for tt-equ.
def var vetbcod         like tt-equ.etbcod.



    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
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
        find first tt-equ where true no-error.
    else
        find tt-equ where recid(tt-equ) = recatu1.
    vinicio = yes.
    if not available tt-equ
    then do:
        message "Cadastro vazio".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.
    display
        tt-equ.etbcod column-label "Filial"
        tt-equ.cxacod column-label "Caixa"
        tt-equ.numequ column-label "Equipamento"
        tt-equ.numwin column-label "Winlivros"
            with frame frame-a 14 down centered.

    recatu1 = recid(tt-equ).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-equ where
                true.
        if not available tt-equ
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        display
            tt-equ.etbcod
            tt-equ.cxacod
            tt-equ.numequ
            tt-equ.numwin
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-equ where recid(tt-equ) = recatu1.

        run color-message.
        choose field tt-equ.etbcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        run color-normal.
        
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
                esqpos1 = if esqpos1 = 5
                          then 5
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
                find next tt-equ where true no-error.
                if not avail tt-equ
                then leave.
                recatu1 = recid(tt-equ).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-equ where true no-error.
                if not avail tt-equ
                then leave.
                recatu1 = recid(tt-equ).
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
            find next tt-equ where
                true no-error.
            if not avail tt-equ
            then next.
            color display normal
                tt-equ.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-equ where
                true no-error.
            if not avail tt-equ
            then next.
            color display normal
                tt-equ.etbcod.
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
                create tt-equ.
                update tt-equ.etbcod
                       tt-equ.cxacod
                       tt-equ.numequ
                       tt-equ.numwin.
                recatu1 = recid(tt-equ).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update tt-equ.etbcod
                       tt-equ.cxacod
                       tt-equ.numequ
                       tt-equ.numwin
                        with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp tt-equ with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" tt-equ.cxacod update sresp.
                if not sresp
                then leave.
                find next tt-equ where true no-error.
                if not available tt-equ
                then do:
                    find tt-equ where recid(tt-equ) = recatu1.
                    find prev tt-equ where true no-error.
                end.
                recatu2 = if available tt-equ
                          then recid(tt-equ)
                          else ?.
                find tt-equ where recid(tt-equ) = recatu1.
                delete tt-equ.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de tt-equidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each tt-equ:
                    display tt-equ.
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
                tt-equ.etbcod
                tt-equ.cxacod
                tt-equ.numequ
                tt-equ.numwin
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-equ).
   end.
end.

procedure color-message.
color display message
        tt-equ.etbcod
        tt-equ.cxacod
        tt-equ.numequ
        tt-equ.numwin
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-equ.etbcod
        tt-equ.cxacod
        tt-equ.numequ
        tt-equ.numwin
        with frame frame-a.
end procedure.


output to l:\progr\numecf.txt.
for each tt-equ:
    if tt-equ.cxacod = 0
    then do:
        delete tt-equ.
        next.
    end.    

    put chr(34)
        tt-equ.etbcod format ">>9"
        tt-equ.numequ format "99"
        tt-equ.cxacod format "99" 
        tt-equ.numwin format "999" chr(34) skip.
end.
output close.



