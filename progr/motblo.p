{admcab.i}
def var i as int.
def var vfuncod like func.funcod.
def var vsenha like func.senha.


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


def buffer bmotblo       for motblo.
def var vmtbcod         like motblo.mtbcod.


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
    
    update vfuncod with frame f-senha centered row 4
                            side-label title " Seguranca ".
    find func where func.funcod = vfuncod and
                    func.etbcod = 999 no-lock no-error.
    if not avail func
    then do:
       message "Funcionario nao Cadastrado".
       undo, retry.
    end.
    disp func.funnom no-label with frame f-senha.
    if func.funfunc <> "CONTABILIDADE"
    then do:
        bell.
        message "Funcionario sem Permissao".
        undo, retry.
    end.
    update vsenha blank with frame f-senha.
    if vsenha = func.senha
    then.
    else do:
        message "Senha Invalida".
        pause.
        undo, retry.
    end.

 

 
    

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then find first motblo where true no-error.
    else find motblo where recid(motblo) = recatu1.
    vinicio = yes.
    if not available motblo
    then do:
        message "Cadastro de motbloidades de Tit. Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
                create motblo.
                update mtbnom
                       mtbcod.
          vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    display
        motblo.mtbcod column-label "Nota Fiscal" format ">>>>>9" 
        motblo.mtbnom column-label "Motivo"
        motblo.datexp column-label "Data" format "99/99/9999"
            with frame frame-a 13 down centered.

    recatu1 = recid(motblo).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next motblo where
                true.
        if not available motblo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        display
            motblo.mtbcod
            motblo.mtbnom
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find motblo where recid(motblo) = recatu1.

        choose field motblo.mtbcod
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
                find next motblo where true no-error.
                if not avail motblo
                then leave.
                recatu1 = recid(motblo).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev motblo where true no-error.
                if not avail motblo
                then leave.
                recatu1 = recid(motblo).
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
            find next motblo where
                true no-error.
            if not avail motblo
            then next.
            color display normal
                motblo.mtbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev motblo where
                true no-error.
            if not avail motblo
            then next.
            color display normal
                motblo.mtbcod.
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
                create motblo.
                update motblo.mtbcod label "Nota Fiscal" format ">>>>>9"
                       motblo.mtbnom format "x(50)".
                recatu1 = recid(motblo).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update motblo.mtbcod label "Nota Fiscal" format ">>>>>9"
                       motblo.mtbnom format "x(50)"
                            with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp motblo with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" motblo.mtbnom update sresp.
                if not sresp
                then leave.
                find next motblo where true no-error.
                if not available motblo
                then do:
                    find motblo where recid(motblo) = recatu1.
                    find prev motblo where true no-error.
                end.
                recatu2 = if available motblo
                          then recid(motblo)
                          else ?.
                find motblo where recid(motblo) = recatu1.
                delete motblo.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de motbloidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each motblo:
                    display motblo.
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
                motblo.mtbcod
                motblo.mtbnom
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(motblo).
   end.
end.
