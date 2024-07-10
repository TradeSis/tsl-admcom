/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def var recatu1         as recid.
def var reccont         as int.
def var vinicio         as log.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bfincla       for fincla.
def input parameter      vfincod         like fincla.fincod.


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

    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first fincla where
            fincla.fincod = vfincod no-error.
    else
        find fincla where recid(fincla) = recatu1.
    vinicio = yes.
    if not available fincla
    then do:
        message "Cadastro de Classes Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1 overlay row 6 1 column centered.
            create fincla.
            update fincla.clacod.
            find clase where clase.clacod = fincla.clacod no-lock no-error.
            if not avail clase
            then do:
                message "Classe nao Cadastrada".
                undo, retry.
            end.
            if clase.clatipo 
            then do:
                message "Cadastrar somente classes associaveis".
                pause.
                undo, retry.
            end.
            fincla.fincod = vfincod.
            vinicio = no.

        end.
    end.
    clear frame frame-a all no-pause.
    find clase where clase.clacod = fincla.clacod no-lock no-error.
    display fincla.clacod
            clase.clanom column-label "Descricao"
                with frame frame-a 14 down centered.

    recatu1 = recid(fincla).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next fincla where fincla.fincod = vfincod.
        if not available fincla
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
        find clase where clase.clacod = fincla.clacod no-lock no-error.
        display fincla.clacod 
                clase.clanom with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find fincla where recid(fincla) = recatu1.

        run color-message.
        choose field fincla.clacod
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
                find next fincla where fincla.fincod = vfincod no-error.
                if not avail fincla
                then leave.
                recatu1 = recid(fincla).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev fincla where fincla.fincod = vfincod no-error.
                if not avail fincla
                then leave.
                recatu1 = recid(fincla).
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
            find next fincla where
                fincla.fincod = vfincod no-error.
            if not avail fincla
            then next.
            color display normal
                fincla.clacod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev fincla where
                fincla.fincod = vfincod no-error.
            if not avail fincla
            then next.
            color display normal
                fincla.clacod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then return. 
        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

        if esqregua 
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
                create fincla.
                update fincla.clacod.
                find clase where clase.clacod = fincla.clacod no-lock.
                if clase.clatipo 
                then do:
                    message "Cadastrar somente classes associaveis".
                    pause.
                    undo, retry.
                end.
 
                fincla.fincod = vfincod.
                recatu1 = recid(fincla).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update fincla.clacod
                    with frame f-altera no-validate.
                find clase where clase.clacod = fincla.clacod no-lock no-error.
                if not avail clase 
                then do: 
                    message "Classe nao Cadastrada". 
                    undo, retry. 
                end. 
                if clase.clatipo  
                then do: 
                    message "Cadastrar somente classes associaveis". 
                    pause.
                    undo, retry.
                end.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp fincla with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" fincla.clacod update sresp.
                if not sresp
                then leave.
                find next fincla where fincla.fincod = vfincod no-error.
                if not available fincla
                then do:
                    find fincla where recid(fincla) = recatu1.
                    find prev fincla where fincla.fincod = vfincod no-error.
                end.
                recatu2 = if available fincla
                          then recid(fincla)
                          else ?.
                find fincla where recid(fincla) = recatu1.
                delete fincla.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de finclaidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each fincla:
                    display fincla.
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
        then do:
            view frame frame-a. 
        end.
        display fincla.clacod
                clase.clanom with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(fincla).
   end.
end.

procedure color-message.
color display message
        fincla.clacod
        clase.clanom
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        fincla.clacod
        clase.clanom
        with frame frame-a.
end procedure.

