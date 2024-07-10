/*
*
*    abastwms.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-rec as recid.

find abastipo where recid(abastipo) = par-rec no-lock.
disp abastipo.abatipo
    abastipo.abatnom no-label
    with frame f-cab row 3 side-label centered.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," "].

def buffer babastwms       for abastwms.

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
        find abastwms where recid(abastwms) = recatu1 no-lock.
    if not available abastwms
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(abastwms).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available abastwms
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
            find abastwms where recid(abastwms) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field abastwms.wms help ""
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
                    if not avail abastwms
                    then leave.
                    recatu1 = recid(abastwms).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail abastwms
                    then leave.
                    recatu1 = recid(abastwms).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail abastwms
                then next.
                color display white/red abastwms.wms with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail abastwms
                then next.
                color display white/red abastwms.wms with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form abastwms
                 with frame f-abastwms color black/cyan
                      centered side-label row 10 with 1 col.
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Inclusao " or esqvazio
            then do with frame f-abastwms:
                do on error undo.
                    prompt-for abastwms.wms.
                
                find abaswms where abaswms.wms = input abastwms.wms no-lock.

                    create abastwms.
                    assign
                        abastwms.abatipo = abastipo.abatipo
                        abastwms.wms = input abastwms.wms.

                    update abastwms.catcod.
                
                    recatu1 = recid(abastwms).
                end.
                
                run abas/transfajusta.p (recatu1).
                                    
                leave.
            end.
            if esqcom1[esqpos1] = " Alteracao "
            then do with frame f-abastwms:
                do on error undo.
                    find abastwms where recid(abastwms) = recatu1 exclusive.
                    disp abastwms.

                    prompt-for abastwms.wms.
                find abaswms where abaswms.wms = input abastwms.wms no-lock.
                
                    abastwms.wms = input abastwms.wms.
                
                    update abastwms.catcod.
                end.
                
                run abas/transfajusta.p (recid(abastwms)).
                    
            end.
        end.
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(abastwms).
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
    find abaswms of abastwms no-lock.
    display abastwms.abatipo
            abastwms.wms
            abastwms.catcod
            abaswms.etbcd
            abaswms.interface
            abaswms.diretorio
        with frame frame-a 11 down centered color white/red row 7 overlay
            title string(abastipo.abatipo) + " " + abastipo.abatnom.
end procedure.


procedure color-message.
    color display message
        abastwms.wms
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        abastwms.wms
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then   find first abastwms where abastwms.abatipo = abastipo.abatipo
                                                no-lock no-error.
    else   find last abastwms  where abastwms.abatipo = abastipo.abatipo
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then   find next abastwms  where abastwms.abatipo = abastipo.abatipo
                                                no-lock no-error.
    else   find prev abastwms  where abastwms.abatipo = abastipo.abatipo
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   find prev abastwms where abastwms.abatipo = abastipo.abatipo  
                                        no-lock no-error.
    else   find next abastwms where abastwms.abatipo = abastipo.abatipo 
                                        no-lock no-error.
        
end procedure.
         
