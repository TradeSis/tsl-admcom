/*
*
*    gratam.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}
def input parameter par-gracod like grade.gracod.

def var vct as int.
def buffer bgrade for grade.
find bgrade where bgrade.gracod = par-gracod no-lock.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(10)" extent 3
    initial [" Inclusao "," Alteracao "," Exclusao "].

def buffer bgratam       for gratam.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels side-labels column 46.
assign
    esqregua = yes
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find gratam where recid(gratam) = recatu1 no-lock.
    if not available gratam
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(gratam).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available gratam
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
            find gratam where recid(gratam) = recatu1 no-lock.

            status default "".

            run color-message.
            choose field gratam.tamcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 3 then 3 else esqpos1 + 1.
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
                    if not avail gratam
                    then leave.
                    recatu1 = recid(gratam).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail gratam
                    then leave.
                    recatu1 = recid(gratam).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail gratam
                then next.
                color display white/red gratam.tamcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail gratam
                then next.
                color display white/red gratam.tamcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form gratam
                 with frame f-gratam color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame frame-a on error undo.
                    vct = 0.
                    for each Bgratam of bgrade no-lock.
                        vct = vct + 1.
                    end.
                    IF vct + 1 > bgrade.limtam
                    then do.
                        message "Limite de tamanhos na grade atingido"
                            view-as alert-box.
                        leave.
                    end.

                    create gratam.
                    gratam.gracod = bgrade.gracod.
                    update gratam.tamcod.
                    gratam.tamcod = caps(gratam.tamcod).
                    find taman of gratam no-lock no-error.
                    if not avail taman or
                       taman.situacao = no
                    then do.
                        message "Tamanho invalido" view-as alert-box.
                        undo.
                    end.
                    update gratam.graord validate(gratam.graord > 0, "").
                    gratam.dtexp = today.
                    recatu1 = recid(gratam).
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame frame-a on error undo.
                    find gratam where recid(gratam) = recatu1 exclusive.
                    update gratam.graord validate(gratam.graord > 0, "").
                end.

                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" gratam.tamcod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next gratam of bgrade no-error.
                    if not available gratam
                    then do:
                        find gratam where recid(gratam) = recatu1.
                        find prev gratam of bgrade no-error.
                    end.
                    recatu2 = if available gratam
                              then recid(gratam)
                              else ?.
                    find gratam where recid(gratam) = recatu1
                            exclusive.
                    delete gratam.
                    recatu1 = recatu2.
                    leave.
                end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(gratam).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    display
        gratam.tamcod
        gratam.graord
        with frame frame-a 12 down color white/red row 5 column 47
            title bgrade.granom.

end procedure.

procedure color-message.
    color display message
        gratam.tamcod
        gratam.graord
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
        gratam.tamcod
        gratam.graord
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first gratam of bgrade use-index graord no-lock no-error.
    else  
        find last gratam  of bgrade use-index graord no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next gratam  of bgrade use-index graord no-lock no-error.
    else  
        find prev gratam   of bgrade use-index graord no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev gratam of bgrade   use-index graord no-lock no-error.
    else   
        find next gratam of bgrade  use-index graord no-lock no-error.
        
end procedure.
