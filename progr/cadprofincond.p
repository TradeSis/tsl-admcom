/*
*
*    profincond.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-rec as recid.

def var vsituacao   as log format "Ativo/Inativo" label "Situacao".

find profin where recid(profin) = par-rec no-lock.
disp profin.fincod
    profin.findesc no-label
    profin.procod
    profin.modcod
    with frame f-cab row 3 side-label centered.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," "].

def buffer bprofincond       for profincond.

form
    esqcom1
    with frame f-com1 row 6 no-labels column 1 centered no-box.
assign
    esqpos1  = 1.
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find profincond where recid(profincond) = recatu1 no-lock.
    if not available profincond
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(profincond).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available profincond
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
            find profincond where recid(profincond) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field profincond.etbcod help ""
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
                    if not avail profincond
                    then leave.
                    recatu1 = recid(profincond).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail profincond
                    then leave.
                    recatu1 = recid(profincond).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail profincond
                then next.
                color display white/red profincond.etbcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail profincond
                then next.
                color display white/red profincond.etbcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form profincond
                 with frame f-profincond color black/cyan
                      centered side-label row 10 with 1 col.
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Inclusao " or esqvazio
            then do with frame f-profincond on error undo.
                prompt-for profincond.etbcod.

                create profincond.
                assign
                    profincond.pfincod = profin.fincod
                    profincond.etbcod = input profincond.etbcod.

                update profincond.fincod.
                update profincond.favorito format "Sim/Nao".
                recatu1 = recid(profincond).
                leave.
            end.
            if esqcom1[esqpos1] = " Alteracao " 
            then do with frame f-profincond on error undo.
                disp profincond.
                find profincond where recid(profincond) = recatu1 exclusive.
                if profincond.dtfinal = ?
                then
                update profincond.favorito format "Sim/Nao" .
                update vsituacao.
                if profincond.dtfinal = ? and
                   vsituacao = no
                then profincond.dtfinal = today.
                if vsituacao = yes
                then profincond.dtfinal = ?.
                   
            end.
        end.
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(profincond).
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
    
    find finan of profincond no-lock.
    vsituacao = profincond.dtfinal = ?.
    disp
      profincond.Etbcod
      profincond.fincod
      finan.finnom
      profincond.favorito
      finan.finnpc column-label "NParc"
      profincond.dtfinal
      vSituacao
      
        with frame frame-a 11 down centered color white/red row 7 overlay
            title string(profin.fincod) + " " + profin.findesc.
end procedure.


procedure color-message.
    color display message
        profincond.etbcod
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        profincond.etbcod
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then   find first profincond where profincond.pfincod = profin.fincod
                                                no-lock no-error.
    else   find last profincond  where profincond.pfincod = profin.fincod
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then   find next profincond  where profincond.pfincod = profin.fincod
                                                no-lock no-error.
    else   find prev profincond  where profincond.pfincod = profin.fincod
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   find prev profincond where profincond.pfincod = profin.fincod  
                                        no-lock no-error.
    else   find next profincond where profincond.pfincod = profin.fincod 
                                        no-lock no-error.
        
end procedure.
         
