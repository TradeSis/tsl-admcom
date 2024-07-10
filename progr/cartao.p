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
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bcartao       for cartao.
def var vetbcod         like cartao.etbcod.


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
        find first cartao where
            true no-error.
    else
        find cartao where recid(cartao) = recatu1.
    vinicio = yes.
    if not available cartao
    then do:
        message "Cadastro de Cartao Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1 overlay row 6 centered side-label. 
            create cartao. 
            update cartao.etbcod at 1.
            if cartao.etbcod = 0
            then display "GERAL" @ estab.etbnom no-label.
            else do:
                find estab where estab.etbcod = cartao.etbcod no-lock.
                display estab.etbnom no-label.
            end.
            update cartao.moecod at 1.
            find moeda where moeda.moecod = cartao.moecod no-lock no-error.
            if not avail moeda
            then do:
                message "Moeda nao cadastrada".
                pause.
                undo, retry.
            end.
            cartao.moenom = moeda.moenom.
            display cartao.moenom no-label.
            update cartao.cardia at 1
                   cartao.carpar at 1
                   cartao.carper at 1
                   cartao.bancod at 1
                   cartao.agencia at 1
                   cartao.conta at 1.  
                   
            vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    display
        cartao.etbcod
        cartao.moecod
        cartao.moenom format "x(20)"
        cartao.cardia
        cartao.carper
        cartao.carpar
            with frame frame-a 14 down centered.

    recatu1 = recid(cartao).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next cartao where
                true.
        if not available cartao
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        display
            cartao.etbcod
            cartao.moecod
            cartao.moenom
            cartao.cardia 
            cartao.carper 
            cartao.carpar
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find cartao where recid(cartao) = recatu1.

        run color-message.
        choose field cartao.etbcod
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
                find next cartao where true no-error.
                if not avail cartao
                then leave.
                recatu1 = recid(cartao).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev cartao where true no-error.
                if not avail cartao
                then leave.
                recatu1 = recid(cartao).
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
            find next cartao where
                true no-error.
            if not avail cartao
            then next.
            color display normal
                cartao.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev cartao where
                true no-error.
            if not avail cartao
            then next.
            color display normal
                cartao.etbcod.
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
            then do with frame f-inclui overlay row 6 
                        centered side-label.
            
                create cartao.  
                update cartao.etbcod at 1. 
                if cartao.etbcod = 0 
                then display "GERAL" @ estab.etbnom no-label. 
                else do: 
                    find estab where estab.etbcod = cartao.etbcod no-lock. 
                    display estab.etbnom no-label. 
                end. 
                update cartao.moecod at 1. 
                find moeda where moeda.moecod = cartao.moecod no-lock no-error. 
                if not avail moeda 
                then do: 
                    message "Moeda nao cadastrada". 
                    pause. 
                    undo, retry.
                end.
                cartao.moenom = moeda.moenom.
                display cartao.moenom no-label.
                update cartao.cardia at 1
                       cartao.carpar at 1 
                       cartao.carper at 1 
                       cartao.bancod at 1 
                       cartao.agencia at 1 
                       cartao.conta at 1.  
             
                recatu1 = recid(cartao).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 
                        centered side-label.
                        
                        
                update cartao.etbcod at 1.
                if cartao.etbcod = 0
                then display "GERAL" @ estab.etbnom no-label.
                else do:
                    find estab where estab.etbcod = cartao.etbcod no-lock.
                    display estab.etbnom no-label.
                end.
                update cartao.moecod at 1.
                find moeda where moeda.moecod = cartao.moecod no-lock no-error.
                if not avail moeda
                then do:
                    message "Moeda nao cadastrada".
                    pause.
                    undo, retry.
                end.
                cartao.moenom = moeda.moenom.
                display cartao.moenom no-label.
                update cartao.cardia at 1
                       cartao.carpar at 1
                       cartao.carper at 1
                       cartao.bancod at 1
                       cartao.agencia at 1
                       cartao.conta at 1.  
             
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 
                    centered side-label.
                    
                display cartao.etbcod at 1.
                if cartao.etbcod = 0
                then display "GERAL" @ estab.etbnom no-label.
                else do:
                    find estab where estab.etbcod = cartao.etbcod no-lock.
                    display estab.etbnom no-label.
                end.
                display cartao.moecod at 1.
                find moeda where moeda.moecod = cartao.moecod no-lock no-error.
                if not avail moeda
                then do:
                    message "Moeda nao cadastrada".
                    pause.
                    undo, retry.
                end.
                display cartao.moenom no-label.
                display cartao.cardia at 1
                        cartao.carpar at 1 
                        cartao.carper at 1 
                        cartao.bancod at 1 
                        cartao.agencia at 1 
                        cartao.conta at 1.  
                 
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" cartao.moecod update sresp.
                if not sresp
                then leave.
                find next cartao where true no-error.
                if not available cartao
                then do:
                    find cartao where recid(cartao) = recatu1.
                    find prev cartao where true no-error.
                end.
                recatu2 = if available cartao
                          then recid(cartao)
                          else ?.
                find cartao where recid(cartao) = recatu1.
                delete cartao.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de cartaoidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each cartao:
                    display cartao.
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
                cartao.etbcod
                cartao.moecod  
                cartao.moenom
                cartao.cardia 
                cartao.carper 
                cartao.carpar
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(cartao).
   end.
end.

procedure color-message.
color display message
        cartao.etbcod
        cartao.moecod 
        cartao.moenom
        cartao.cardia
        cartao.carper
        cartao.carpar
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        cartao.etbcod
        cartao.moecod 
        cartao.moenom
        cartao.cardia
        cartao.carper
        cartao.carpar
        with frame frame-a.
end procedure.

