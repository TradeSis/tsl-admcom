pause 0.
def buffer xestab for estab.
def shared temp-table tt-estab no-undo
    field etbcod    like estab.etbcod
    field Ordem     as int
    field sim       as log init yes
    index idx is unique primary etbcod asc
    index ordem sim desc ordem asc etbcod asc.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5.
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

def  var sresp as log format "Sim/Nao".  
form
        tt-estab.sim        format "*/" no-label
        tt-estab.etbcod 
        xestab.etbnom
        tt-estab.ordem
        with frame frame-a
         8 down centered row 5 overlay
         
                    title " Selecao de Filiais para Corte " .

def buffer btt-estab       for tt-estab.
def var vtt-estab         like tt-estab.etbcod.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


bl-princ:
repeat:

    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-estab where recid(tt-estab) = recatu1 no-lock.
    if not available tt-estab
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-estab).
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-estab
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
            find tt-estab where recid(tt-estab) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-estab.etbcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-estab.etbcod)
                                        else "".
            run color-message.
            choose field tt-estab.etbcod help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                      PF4 F4 ESC return).
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
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
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-estab
                    then leave.
                    recatu1 = recid(tt-estab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-estab
                    then leave.
                    recatu1 = recid(tt-estab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-estab
                then next.
                color display white/red tt-estab.etbcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-estab
                then next.
                color display white/red tt-estab.etbcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do.
            sresp = yes.
                            run message.p (input-output sresp, 
                                  input " .                                      " +
                                  "..  CONFIRMA CORTE ??? ..",
                                  input " !! FILIAIS !! ") /*,
                                  input " Sim ",
                                  input " Nao ") */ . 
            
            if sresp = no
            then do.
                for each tt-estab.
                    tt-estab.sim = no. 
                end.
            end. 
            leave bl-princ.
        end.            

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            find tt-estab where recid(tt-estab) = recatu1.
            tt-estab.sim = not tt-estab.sim.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        recatu1 = recid(tt-estab).
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
find xestab where xestab.etbcod = tt-estab.etbcod no-lock no-error.
display 
        tt-estab.etbcod 
        xestab.etbnom  when avail xestab
        tt-estab.ordem
        tt-estab.sim 
        with frame frame-a. end procedure.
procedure color-message.
color display message
        xestab.etbnom
        tt-estab.ordem
        tt-estab.sim
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        xestab.etbnom
        tt-estab.ordem
        tt-estab.sim
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-estab use-index ordem where true
                                                 no-lock no-error.
    else  
        find last tt-estab  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-estab  use-index ordem where true
                                                no-lock no-error.
    else  
        find prev tt-estab   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-estab use-index ordem where true  
                                        no-lock no-error.
    else   
        find next tt-estab where true 
                                        no-lock no-error.
        
end procedure.

