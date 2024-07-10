/*
*
*    profinparam.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-rec as recid.

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

def buffer bprofinparam       for profinparam.

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
        find profinparam where recid(profinparam) = recatu1 no-lock.
    if not available profinparam
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(profinparam).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available profinparam
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
            find profinparam where recid(profinparam) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field profinparam.etbcod help ""
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
                    if not avail profinparam
                    then leave.
                    recatu1 = recid(profinparam).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail profinparam
                    then leave.
                    recatu1 = recid(profinparam).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail profinparam
                then next.
                color display white/red profinparam.etbcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail profinparam
                then next.
                color display white/red profinparam.etbcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form profinparam
                 with frame f-profinparam color black/cyan
                      centered side-label row 10 with 1 col.
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Inclusao " or esqvazio
            then do with frame f-profinparam on error undo.
                prompt-for profinparam.etbcod.

                find first bprofinparam where 
                                    bprofinparam.fincod  = profin.fincod
                                and bprofinparam.etbcod  = 
                                                    input profinparam.etbcod
                                and(bprofinparam.dtfinal = ? or
                                    bprofinparam.dtfinal >= today)
                                no-lock no-error.
                if avail bprofinparam
                then do.
                    message "Existe parametro vigente. Inicio em"
                        bprofinparam.dtinicial
                        view-as alert-box.
                    undo.
                end.

                create profinparam.
                assign
                    profinparam.fincod = profin.fincod
                    profinparam.etbcod = input profinparam.etbcod.

                update profinparam except fincod etbcod dtfinal dtinclu.
                recatu1 = recid(profinparam).
                leave.
            end.
            if esqcom1[esqpos1] = " Alteracao "
            then do with frame f-profinparam on error undo.
                disp profinparam.
                find profinparam where recid(profinparam) = recatu1 exclusive.
                update profinparam.dtfinal 
                                validate (profinparam.dtfinal = ? or
                                          profinparam.dtfinal >= today, "").
                if profinparam.dtinicial <= today
                then update
                        profinparam.vlminimo
                        profinparam.vlmaximo
                        profinparam.perclimite
                        profinparam.TempoRelac
                        profinparam.parcpagas.
            end.
        end.
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(profinparam).
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
    display profinparam except fincod
        with frame frame-a 11 down centered color white/red row 7 overlay
            title string(profin.fincod) + " " + profin.findesc.
end procedure.


procedure color-message.
    color display message
        profinparam.etbcod
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        profinparam.etbcod
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then   find first profinparam where profinparam.fincod = profin.fincod
                                                no-lock no-error.
    else   find last profinparam  where profinparam.fincod = profin.fincod
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then   find next profinparam  where profinparam.fincod = profin.fincod
                                                no-lock no-error.
    else   find prev profinparam  where profinparam.fincod = profin.fincod
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   find prev profinparam where profinparam.fincod = profin.fincod  
                                        no-lock no-error.
    else   find next profinparam where profinparam.fincod = profin.fincod 
                                        no-lock no-error.
        
end procedure.
         
