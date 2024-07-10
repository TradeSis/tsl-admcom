{admcab.i}

def input parameter par-rec as recid.

find plani where recid(plani) = par-rec no-lock.
def buffer bplani for plani.

def shared temp-table tt-docrefer
    field etbcod like plani.etbcod
    field placod like plani.placod
    field numero like plani.numero.

for each ctdevven where ctdevven.movtdc = plani.movtdc
                    and ctdevven.etbcod = plani.etbcod
                    and ctdevven.placod = plani.placod
                  no-lock.
    create tt-docrefer.
    tt-docrefer.etbcod = ctdevven.etbcod-ori.
    tt-docrefer.placod = ctdevven.placod-ori.
    tt-docrefer.numero = ctdevven.numero-ori.
end.                  

/*
*
*    tt-docrefer.p    -    Esqueleto de Programacao
*
*/

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta ",""].

form
    esqcom1 with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-docrefer where recid(tt-docrefer) = recatu1 no-lock.
    if not available tt-docrefer
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(tt-docrefer).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat.
        run leitura (input "seg").
        if not available tt-docrefer
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find tt-docrefer where recid(tt-docrefer) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field tt-docrefer.numero help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            run color-normal.
            status default "".

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
                    if not avail tt-docrefer
                    then leave.
                    recatu1 = recid(tt-docrefer).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-docrefer
                    then leave.
                    recatu1 = recid(tt-docrefer).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-docrefer
                then next.
                color display white/red tt-docrefer.numero with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-docrefer
                then next.
                color display white/red tt-docrefer.numero with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause.
            hide frame f-com1 no-pause.
/*
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
*/
            if esqcom1[esqpos1] = " Consulta "
            then do.
                find plani where plani.etbcod = tt-docrefer.etbcod 
                             and plani.placod = tt-docrefer.placod
                       no-lock.
                run not_consnota.p (recid(plani)).
                leave.
            end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-docrefer).
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

    find plani where plani.etbcod = tt-docrefer.etbcod 
                 and plani.placod = tt-docrefer.placod
               no-lock.
    display
        plani.emite  format ">>>>>>>>9" column-label "Emite"
        plani.serie  column-label "Serie"
        tt-docrefer.numero format ">>>>>>>>9" column-label "Numero"
        plani.desti  format ">>>>>>>>9"
        plani.pladat column-label "Emissao"
        plani.dtincl
        plani.platot
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
color display message
        plani.serie
        tt-docrefer.numero
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        plani.serie
        tt-docrefer.numero
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first tt-docrefer no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next  tt-docrefer no-lock no-error.
             
if par-tipo = "up" 
then find prev  tt-docrefer no-lock no-error.
        
end procedure.
