/*
*
*    mixmgrucla.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-rec as recid.

def var vcla-cod like clase.clacod.

find mixmgrupo where recid(mixmgrupo) = par-rec no-lock.
disp
    mixmgrupo.codgrupo
    mixmgrupo.nome no-label
    mixmgrupo.prioridade
    with frame f-grupo side-label no-box.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," "," Situacao "," "].

def buffer bmixmgrucla       for mixmgrucla.

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find mixmgrucla where recid(mixmgrucla) = recatu1 no-lock.
    if not available mixmgrucla
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(mixmgrucla).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available mixmgrucla
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find mixmgrucla where recid(mixmgrucla) = recatu1 no-lock.

            status default "".

            run color-message.
            choose field mixmgrucla.clacod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail mixmgrucla
                    then leave.
                    recatu1 = recid(mixmgrucla).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail mixmgrucla
                    then leave.
                    recatu1 = recid(mixmgrucla).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail mixmgrucla
                then next.
                color display white/red mixmgrucla.clacod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail mixmgrucla
                then next.
                color display white/red mixmgrucla.clacod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form vcla-cod
                clase.clanom no-label
                with frame f-mixmgrucla
                            color black/cyan centered side-label row 7.
                                               
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-mixmgrucla.
                    update vcla-cod.
                    find clase where clase.clacod = vcla-cod no-lock no-error.
                    if not avail clase
                    then do.
                        message "Classe invalida" view-as alert-box.
                        undo.
                    end.
                    disp clase.clanom.

                    sresp = no.
                    message "Confirma inclusao?" update sresp.
                    if sresp
                    then do on error undo.
                        create mixmgrucla.
                        assign
                            mixmgrucla.codgrupo = mixmgrupo.codgrupo.
                            mixmgrucla.clacod   = vcla-cod.
                            recatu1 = recid(mixmgrucla).
                    end.
                    leave.
                end.
                if esqcom1[esqpos1] = " Situacao "
                then do on error undo.
                    sresp = no.
                    message "Confirma Alterar Situacao de" mixmgrucla.clacod "?"
                            update sresp.
                    if sresp
                    then do.
                        find current mixmgrucla exclusive.
                        mixmgrucla.situacao = not mixmgrucla.situacao.
                    end.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    leave.
                end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(mixmgrucla).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-grupo no-pause.

procedure frame-a.
    find clase of mixmgrucla no-lock.
    display
        mixmgrucla.clacod 
        clase.clanom
        mixmgrucla.situacao
        with frame frame-a 11 down centered color white/red row 6
            title " Grupo de Mix x Classes ".
end procedure.


procedure color-message.
color display message
        mixmgrucla.clacod
        clase.clanom
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        mixmgrucla.clacod
        clase.clanom
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first mixmgrucla of mixmgrupo no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next mixmgrucla  of mixmgrupo no-lock no-error.
             
if par-tipo = "up" 
then find prev mixmgrucla of mixmgrupo   no-lock no-error.
        
end procedure.
         
