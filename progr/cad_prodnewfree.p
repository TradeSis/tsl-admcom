/*
*
*    prodnewfree.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [" "," Pesquisa "," Consulta "," "].

def buffer bprodnewfree       for prodnewfree.
def var vindice as int init 1.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find prodnewfree where recid(prodnewfree) = recatu1 no-lock.
    if not available prodnewfree
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(prodnewfree).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available prodnewfree
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find prodnewfree where recid(prodnewfree) = recatu1 no-lock.

            status default "".

            run color-message.
            choose field prodnewfree.procod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
            run color-normal.
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
                    if not avail prodnewfree
                    then leave.
                    recatu1 = recid(prodnewfree).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail prodnewfree
                    then leave.
                    recatu1 = recid(prodnewfree).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail prodnewfree
                then next.
                color display white/red prodnewfree.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail prodnewfree
                then next.
                color display white/red prodnewfree.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form prodnewfree except proclafis
                 with frame f-prodnewfree color black/cyan
                      centered side-label row 5 3 col.
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-prodnewfree.
                    prodnewfree.codfis:label  = "NCM".
                    prodnewfree.codfis:format = ">>>>>>>9".
                    prodnewfree.proipiper:label = "ICMS".
                    disp prodnewfree except proclafis.
                end.
                if esqcom1[esqpos1] = " Pesquisa "
                then do with frame f-pesq side-label.
                    prompt-for prodnewfree.procod.
                    if input prodnewfree.procod > 0
                    then do.
                        find bprodnewfree where bprodnewfree.procod =
                                input prodnewfree.procod no-lock no-error.
                        vindice = 1.
                    end.
                    else do.
                        prompt-for prodnewfree.pronom.
                        find first bprodnewfree where 
                                bprodnewfree.pronom begins
                                input prodnewfree.pronom no-lock no-error.
                        vindice = 2.
                    end.                                
                    if avail bprodnewfree
                    then recatu1 = recid(bprodnewfree).
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
        recatu1 = recid(prodnewfree).
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
    display
        prodnewfree.procod format ">>>>>>>9"
        prodnewfree.pronom
        prodnewfree.codfis format ">>>>>>>9"
        prodnewfree.proipiper column-label "ICMS"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
    color display message
        prodnewfree.procod
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
        prodnewfree.procod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if vindice = 1
    then find first prodnewfree  use-index iprodu  no-lock no-error.
    else find first prodnewfree  use-index ipronom no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if vindice = 1
    then find next  prodnewfree  use-index iprodu  no-lock no-error.
    else find next  prodnewfree  use-index ipronom no-lock no-error.
             
if par-tipo = "up" 
then                  
    if vindice = 1
    then find prev  prodnewfree  use-index iprodu  no-lock no-error.
    else find prev  prodnewfree  use-index ipronom no-lock no-error.

end procedure.
         
