/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def var vseq as int.
def var vautoriz as char format "x(20)".
def var valor   like plani.platot.
def var vmotivo as char format "x(50)".
def var vclicod like clien.clicod.
def var vsenha  like func.senha.
def var vetbcod like estab.etbcod.
def var vfuncod like func.funcod.
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


def buffer bautoriz       for autoriz.


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
        find first autoriz where
            true no-error.
    else
        find autoriz where recid(autoriz) = recatu1.
    vinicio = yes.
    if not available autoriz
    then do:
        vsenha = "".
        valor  = 0.
        update vetbcod label "Filial" colon 15
                    with frame f-inc side-label centered width 80.
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame f-inc.
        
        update vfuncod label "Funcionario" colon 15
                    with frame f-inc.
        find func where func.etbcod = 999 and
                        func.funcod = vfuncod no-lock no-error.
        if not avail func
        then do:
            message "Funcionario Invalido".
            undo, retry.
        end.
        display func.funnom no-label with frame f-inc.
        update vsenha blank label "Senha" with frame f-inc.
        
        if vsenha <> func.senha
        then do:
            message "Senha Invalida".
            undo, retry.
        end.    
        
        update vclicod label "Cliente" colon 15 with frame f-inc.
        find clien where clien.clicod = vclicod no-lock no-error.
        if not avail clien
        then do:
            message "Cliente nao cadastrado".
            undo, retry.
        end.

        display clien.clinom no-label with frame f-inc.

        update vmotivo label "Motivo" colon 15 with frame f-inc.
        
        update valor colon 15 with frame f-inc.
        
        find last bautoriz use-index seq no-error.
        if avail bautoriz
        then vseq = bautoriz.autseq + 1.
        else vseq = 1.
        
        create autoriz.
        assign autoriz.etbcod = estab.etbcod
               autoriz.funcod = func.funcod
               autoriz.clicod = clien.clicod
               autoriz.motivo = vmotivo
               autoriz.valor1 = valor 
               autoriz.data   = today
               autoriz.hora   = time
               autoriz.autseq = vseq.
        

        vinicio = no.
        
    end.
    clear frame frame-a all no-pause.
    
    vautoriz = trim(string(autoriz.hora) + string(autoriz.clicod)). 
    display autoriz.etbcod
            autoriz.funcod 
            autoriz.clicod
            autoriz.data format "99/99/9999"
            autoriz.autseq
                with frame frame-a 14 down centered.

    recatu1 = recid(autoriz).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next autoriz where
                true.
        if not available autoriz
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
        vautoriz = trim(string(autoriz.hora) + string(autoriz.clicod)). 
        display autoriz.etbcod
                autoriz.funcod 
                autoriz.clicod
                autoriz.data 
                autoriz.autseq  with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find autoriz where recid(autoriz) = recatu1.

        choose field autoriz.etbcod
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
                find next autoriz where true no-error.
                if not avail autoriz
                then leave.
                recatu1 = recid(autoriz).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev autoriz where true no-error.
                if not avail autoriz
                then leave.
                recatu1 = recid(autoriz).
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
            find next autoriz where
                true no-error.
            if not avail autoriz
            then next.
            color display normal
                autoriz.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev autoriz where
                true no-error.
            if not avail autoriz
            then next.
            color display normal
                autoriz.etbcod.
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
                vsenha = "".
                valor  = 0. 
                update vetbcod label "Filial" colon 15
                    with frame f-inc side-label centered width 80.
                find estab where estab.etbcod = vetbcod no-lock no-error.
                display estab.etbnom no-label with frame f-inc.
        
                update vfuncod label "Funcionario" colon 15
                                    with frame f-inc.
                find func where func.etbcod = 999 and
                                func.funcod = vfuncod no-lock no-error.
                if not avail func
                then do:
                    message "Funcionario Invalido".
                    undo, retry.
                end.
                display func.funnom no-label with frame f-inc.
                update vsenha blank label "Senha" with frame f-inc.
        
                if vsenha <> func.senha
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.    
        
                update vclicod label "Cliente" colon 15 with frame f-inc.
                find clien where clien.clicod = vclicod no-lock no-error.
                if not avail clien
                then do:
                    message "Cliente nao cadastrado".
                    undo, retry.
                end.

                display clien.clinom no-label with frame f-inc.

                update vmotivo label "Motivo" colon 15 with frame f-inc.
                
                update valor colon 15 with frame f-inc.
        
                find last bautoriz use-index seq no-error.
                if avail bautoriz 
                then vseq = bautoriz.autseq + 1. 
                else vseq = 1.
        
                create autoriz.
                assign autoriz.etbcod = estab.etbcod
                       autoriz.funcod = func.funcod
                       autoriz.clicod = clien.clicod
                       autoriz.motivo = vmotivo
                       autoriz.valor1 = valor 
                       autoriz.data   = today
                       autoriz.hora   = time
                       autoriz.autseq = vseq.
        
                recatu1 = recid(autoriz).
                leave.
            end.
            if esqcom1[esqpos1] = "*Alteracao*"
            then do with frame f-altera overlay row 6 1 column centered.
                update autoriz with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp autoriz.etbcod
                     autoriz.funcod
                     autoriz.clicod
                     autoriz.motivo
                     autoriz.valor1
                     autoriz.data  format "99/99/9999"
                     string(autoriz.hora,"HH:MM:SS") label "Hora"
                        with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" autoriz.funcod update sresp.
                if not sresp
                then leave.
                find next autoriz where true no-error.
                if not available autoriz
                then do:
                    find autoriz where recid(autoriz) = recatu1.
                    find prev autoriz where true no-error.
                end.
                recatu2 = if available autoriz
                          then recid(autoriz)
                          else ?.
                find autoriz where recid(autoriz) = recatu1.
                delete autoriz.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de autorizidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each autoriz:
                    display autoriz.
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
         display autoriz.etbcod                                 
                 autoriz.funcod 
                 autoriz.clicod
                 autoriz.data 
                 autoriz.autseq with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(autoriz).
   end.
end.
