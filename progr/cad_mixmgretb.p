/*
*
*    mixmgruetb.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-rec as recid.

def var vetbcod like mixmgruetb.etbcod.
find mixmgrupo where recid(mixmgrupo) = par-rec no-lock.
disp
    mixmgrupo.codgrupo
    mixmgrupo.nome no-label
    mixmgrupo.prioridade
    with frame f-grupo side-label no-box color message.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," "," Situacao "," "].

def buffer bmixmgruetb       for mixmgruetb.

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
        find mixmgruetb where recid(mixmgruetb) = recatu1 no-lock.
    if not available mixmgruetb
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(mixmgruetb).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available mixmgruetb
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
            find mixmgruetb where recid(mixmgruetb) = recatu1 no-lock.

            status default "".

            run color-message.
            choose field mixmgruetb.etbcod help ""
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
                    if not avail mixmgruetb
                    then leave.
                    recatu1 = recid(mixmgruetb).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail mixmgruetb
                    then leave.
                    recatu1 = recid(mixmgruetb).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail mixmgruetb
                then next.
                color display white/red mixmgruetb.etbcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail mixmgruetb
                then next.
                color display white/red mixmgruetb.etbcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame frame-a on error undo.
                    clear frame frame-a.
                    prompt-for mixmgruetb.etbcod.
                    vetbcod = input mixmgruetb.etbcod.

                    find estab where estab.etbcod = vetbcod no-lock no-error.
                    if not avail estab
                    then do.
                        message "Estabelecimento invalido" view-as alert-box.
                        undo.
                    end.

                    find first bmixmgruetb where 
                                     bmixmgruetb.codgrupo = mixmgrupo.codgrupo
                                 and bmixmgruetb.etbcod   = vetbcod
                                 no-lock no-error.
                    if avail bmixmgruetb
                    then do.
                        message "Estab.ja cadastrado para este grupo"
                            view-as alert-box.
                        undo.
                    end.

                    create mixmgruetb.
                    assign
                        mixmgruetb.codgrupo = mixmgrupo.codgrupo
                        mixmgruetb.etbcod   = vetbcod.
                    recatu1 = recid(mixmgruetb).
                    leave.
                end.
                if esqcom1[esqpos1] = " Situacao "
                then do on error undo.
                    sresp = no.
                    message "Confirma Alterar Situacao de" mixmgruetb.etb "?"
                            update sresp.
                    if sresp
                    then do.
                        find current mixmgruetb exclusive.
                        mixmgruetb.situacao = not mixmgruetb.situacao.
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
        recatu1 = recid(mixmgruetb).
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
    find estab of mixmgruetb no-lock.
    display
        mixmgruetb.etbcod 
        estab.etbnom
        mixmgruetb.situacao
        with frame frame-a 11 down centered color white/red row 6
            title " Grupo de Mix x Estabelecimento ".
end procedure.


procedure color-message.
color display message
        mixmgruetb.etbcod
        estab.etbnom
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        mixmgruetb.etbcod
        estab.etbnom
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first mixmgruetb of mixmgrupo no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next mixmgruetb  of mixmgrupo no-lock no-error.
             
if par-tipo = "up" 
then find prev mixmgruetb of mixmgrupo   no-lock no-error.
        
end procedure.
         
