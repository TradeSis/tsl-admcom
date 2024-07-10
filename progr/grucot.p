/**    MANUTENCAO EM Grupos de Consorcio    **/

{admcab.i}

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


def buffer bgrucot       for grucot.
def var vgrupo         like grucot.grupo.


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
        find first grucot where
            true no-lock no-error.
    else
        find grucot where recid(grucot) = recatu1 no-lock.
        vinicio = no.
    if not available grucot
    then do:
        form grucot
            with frame f-altera
            overlay row 6 1 column centered color white/cyan.
        message "Cadastro de Grupos Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-altera transaction:
            
            find last bgrucot no-lock no-error.
            if not avail bgrucot
            then vgrupo = 1.
            else vgrupo = bgrucot.grupo + 1.
            create grucot.
            assign grucot.grupo    = vgrupo
                   grucot.datexp   = today
                   grucot.grudtini = today.

            vinicio = yes.

        end.
    end.
    clear frame frame-a all no-pause.
    display grucot.grupo column-label "Grupo"
            grucot.cota column-label "Cota"
            grucot.grudtini column-label "Data Inicio"
            grucot.grusit   column-label "Situacao"
                with frame frame-a 14 down centered color white/red.

    recatu1 = recid(grucot).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next grucot where
                true no-lock.
        if not available grucot
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio = no
        then down with frame frame-a.
        
        display grucot.grupo 
                grucot.cota 
                grucot.grudtini
                grucot.grusit with frame frame-a.
                
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find grucot where recid(grucot) = recatu1 no-lock.

        choose field grucot.grupo
            go-on(cursor-down cursor-up
                  page-down   page-up
                  cursor-left cursor-right
                  tab PF4 F4 ESC return).
        hide message no-pause.
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
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next grucot where
                    true no-lock no-error.
                if not avail grucot
                then leave.
                recatu2 = recid(grucot).
            end.
            if reccont = frame-down(frame-a)
            then recatu1 = recatu2.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev grucot where
                    true no-lock no-error.
                if not avail grucot
                then leave.
                recatu1 = recid(grucot).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next grucot where
                true no-lock no-error.
            if not avail grucot
            then next.
            color display white/red
                grucot.grupo.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev grucot where
                true no-lock no-error.
            if not avail grucot
            then next.
            color display white/red
                grucot.grupo.
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
            then do transaction
                with frame f-inc side-label centered no-validate.
                
                message "Incluir novo Grupo" update sresp.
                if sresp
                then do:
                    find last bgrucot no-lock no-error.
                    if not avail bgrucot
                    then vgrupo = 1.
                    else vgrupo = bgrucot.grupo + 1.
                    create grucot.
                    assign grucot.grupo    = vgrupo
                           grucot.datexp   = today
                           grucot.grudtini = today.

                    recatu1 = recid(grucot).
                    leave.
                end.
            end.
            
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao" or
               esqcom1[esqpos1] = "Listagem"
            then do with frame f-con centered side-label no-validate:
                disp grucot.grupo
                     grucot.cota.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do transaction
                with frame f-alt centered side-label no-validate:
            
                find grucot where recid(grucot) = recatu1 no-error.
                
                update grucot.grupo
                       grucot.cota 
                       grucot.grudtfin
                       grucot.grusit label "Situacao" with no-validate.
                
                find current grucot no-lock.        
                
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do transaction with frame f-altera:
                
                message "Confirma Exclusao de" grucot.cota update sresp.
                if not sresp
                then leave.
                find next grucot where true no-lock no-error.
                if not available grucot
                then do:
                    find grucot where recid(grucot) = recatu1 no-lock.
                    find prev grucot where true no-lock no-error.
                end.
                recatu2 = if available grucot
                          then recid(grucot)
                          else ?.
                find grucot where recid(grucot) = recatu1.
                delete grucot.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do:
                message "Confirma Impressao do grucotelecimento" update sresp.
                if not sresp
                then LEAVE.
                recatu2 = recatu1.
                output to printer.
                for each grucot:
                    display grucot.
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
        if keyfunction (lastkey) = "end-error"
         then view frame frame-a.

        
        display grucot.grupo 
                grucot.cota 
                grucot.grudtini
                grucot.grusit with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(grucot).
   end.
end.
