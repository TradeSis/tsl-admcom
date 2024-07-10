/*
*
*    procaract.p    -    Esqueleto de Programacao    com esqvazio


            substituir    procaract
                          sub
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 3
    initial [" Inclusao "," Alteracao "," Exclusao "].
def var esqhel1         as char format "x(80)" extent 3
    initial [" Inclusao  de procaract ",
             " Alteracao da procaract ",
             " Exclusao  da procaract "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def var sresp as log format "Sim/Nao".

def buffer bprocaract       for procaract.
def var vprocaract         like procaract.subcod.

form
    esqcom1
    with frame f-com1
                 row 3 no-labels side-labels column 1 centered overlay.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1 overlay.
    pause 0.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find procaract where recid(procaract) = recatu1 no-lock.
    if not available procaract
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(procaract).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    pause 0.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available procaract
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
            find procaract where recid(procaract) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(procaract.subcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(procaract.subcod)
                                        else "".
            run color-message.
            choose field procaract.subcod help "I=Incluir   E=Excluir"
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) color white/black.
            run color-normal.
            status default "".

        end.

            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    pause 0.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                    pause 0.
                end.
                else do:
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail procaract
                    then leave.
                    recatu1 = recid(procaract).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail procaract
                    then leave.
                    recatu1 = recid(procaract).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail procaract
                then next.
                color display white/red procaract.subcod with frame frame-a.
                pause 0.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail procaract
                then next.
                color display white/red procaract.subcod with frame frame-a.
                pause 0.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form procaract
                 with frame f-procaract color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                pause 0.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-procaract on error undo.
                    create procaract.
                    update procaract.
                    recatu1 = recid(procaract).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-procaract.
                    disp procaract.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-procaract on error undo.
                    find procaract where
                            recid(procaract) = recatu1 
                        exclusive.
                    update procaract.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" procaract.subcod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next procaract where true no-error.
                    if not available procaract
                    then do:
                        find procaract where recid(procaract) = recatu1.
                        find prev procaract where true no-error.
                    end.
                    recatu2 = if available procaract
                              then recid(procaract)
                              else ?.
                    find procaract where recid(procaract) = recatu1
                            exclusive.
                    delete procaract.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run lprocaract.p (input 0).
                    else run lprocaract.p (input procaract.subcod).
                    leave.
                end.
            end.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        pause 0.
        recatu1 = recid(procaract).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
display procaract 
     with frame frame-a 11 down centered color
                white/red row 6 overlay width 70 .
pause 0.
end procedure.
procedure color-message.
color display message
        procaract.procod
        with frame frame-a overlay.
pause 0.
end procedure.
procedure color-normal.
color display normal
        procaract.procod
        with frame frame-a overlay.
pause 0.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first procaract where true
                                                no-lock no-error.
    else  
        find last procaract  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next procaract  where true
                                                no-lock no-error.
    else  
        find prev procaract   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev procaract where true  
                                        no-lock no-error.
    else   
        find next procaract where true 
                                        no-lock no-error.
        
end procedure.
         
