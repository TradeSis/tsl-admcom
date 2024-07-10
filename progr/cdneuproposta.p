/*
*
*    neuproposta.p    -    Esqueleto de Programacao
*
*/
{admcab.i}

def input parameter par-rec as recid.

def var vhora as char.

find neuclien where recid(neuclien) = par-rec no-lock.

disp neuclien.cpfcnpj
     neuclien.clicod
     neuclien.VlrLimite label "Limite"
     neuclien.VctoLimite  label "Vcto"
     with frame f-cpf row 3 no-box side-label color message.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [""," Consulta "," Operacoes ",""].
def var esqhel1         as char format "x(80)" extent 5.

def buffer bneuproposta       for neuproposta.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels side-labels column 1 centered.
/* screen-lines */
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find neuproposta where recid(neuproposta) = recatu1 no-lock.
    if not available neuproposta
    then do.
        message "Sem registros para este cliente" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(neuproposta).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available neuproposta
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find neuproposta where recid(neuproposta) = recatu1 no-lock.

            status default
                esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(neuproposta.dtinclu)
                                        else "".
            run color-message.
            choose field neuproposta.dtinclu help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
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
                    if not avail neuproposta
                    then leave.
                    recatu1 = recid(neuproposta).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail neuproposta
                    then leave.
                    recatu1 = recid(neuproposta).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail neuproposta
                then next.
                color display white/red neuproposta.dtinclu with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail neuproposta
                then next.
                color display white/red neuproposta.dtinclu with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form neuproposta
                 with frame f-neuproposta color black/cyan
                      centered side-label row 5 with 2 col.
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-neuproposta.
                    disp neuproposta.
                end.

                if esqcom1[esqpos1] = " Operacoes "
                then do with frame f-Lista:
                    hide frame f-com1 no-pause.
                    run neuro/cdneupropostaoper.p (recid(neuproposta)).
                    view frame f-com1.
                    leave.
                end.
        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(neuproposta).
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
    vhora = string(neuproposta.hrinclu, "hh:mm:ss").
    display neuproposta 
        with frame frame-a 11 down centered color white/red row 5.
    disp vhora @ neuproposta.hrincl with frame frame-a.
end procedure.


procedure color-message.
color display message
        neuproposta.dtinclu
        neuproposta.hrinclu
        neuproposta.etbcod
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        neuproposta.dtinclu
        neuproposta.hrinclu
        neuproposta.etbcod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then find first neuproposta of neuclien no-lock no-error.
    else find last neuproposta  of neuclien no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then find next neuproposta  of neuclien no-lock no-error.
    else find prev neuproposta  of neuclien no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then find prev neuproposta of neuclien no-lock no-error.
    else find next neuproposta of neuclien no-lock no-error.
        
end procedure.
         
