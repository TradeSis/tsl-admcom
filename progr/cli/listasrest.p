/*                                                 
*
*/
{admcab.i}

def input parameter pcpf as dec.
                     
def var vhora as char.

find neuclien where neuclien.cpf = pcpf no-lock.


form
      clienlista.dtconsulta  format "99/99/9999" column-label "Data"
      vhora column-label "Hora"    format "x(5)"
      clienlista.lista format "x(30)"
      clienlista.historico
      with frame frame-a 11 down centered no-box row 9.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [""," ","  ",""].
def var esqhel1         as char format "x(80)" extent 5.

def buffer bclienlista       for clienlista.

form
    esqcom1
    with frame f-com1 row 8 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find clienlista where recid(clienlista) = recatu1 no-lock.
    if not available clienlista
    then do.
        message "Sem registros para este cliente" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(clienlista).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available clienlista
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find clienlista where recid(clienlista) = recatu1 no-lock.
            
            status default
                esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(clienlista.dtconsulta)
                                        else "".
            run color-message.
            
            choose field clienlista.dtconsulta help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
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
                    if not avail clienlista
                    then leave.
                    recatu1 = recid(clienlista).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail clienlista
                    then leave.
                    recatu1 = recid(clienlista).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail clienlista
                then next.
                color display white/red clienlista.dtconsulta with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail clienlista
                then next.
                color display white/red clienlista.dtconsulta with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form clienlista
                 with frame f-clienlista color black/cyan
                      centered side-label row 9 with 2 col.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-clienlista.
                    hide frame frame-a no-pause.
                    disp clienlista.
                end.

                if esqcom1[esqpos1] = " Operacoes "
                then do with frame f-Lista:
                    hide frame f-com1 no-pause.
                    hide frame frame-a no-pause.
                    run neuro/cdclienlistaoper.p (recid(clienlista)).
                    view frame f-com1.
                    leave.
                end.
                /**************
                #1
                if esqcom1[esqpos1] = " Elimina "
                then do on error undo:
                    sresp = yes.
                    message "Mesmo???" update sresp.
                    if sresp
                    then do:
                        find current clienlista exclusive.
                        clienlista.historico = "X".
                    end.
                    leave.
                end.
                ************/
                /* #1 */
                if esqcom1[esqpos1] = " Manutencao "
                then do.
                    run manutencao.
                    leave.
                end.
                /* #1 */
            end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(clienlista).
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
    vhora = string(clienlista.hrconsulta, "hh:mm:ss").
    disp    
      clienlista.dtconsulta 
      vhora 
      clienlista.lista 
      clienlista.historico

      with frame frame-a.

end procedure.


procedure color-message.
    color display message
      clienlista.dtconsulta 
      vhora 
      clienlista.lista 
      clienlista.historico


        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
      clienlista.dtconsulta 
      vhora 
      clienlista.lista 
      clienlista.historico


        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.

if par-tipo = "pri" 
then
    if esqascend
    then find first clienlista of neuclien  no-lock no-error.
    else find last clienlista  of neuclien  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then
    if esqascend
    then find next clienlista  of neuclien  no-lock no-error.
    else find prev clienlista  of neuclien no-lock no-error.
             
if par-tipo = "up" 
then
    if esqascend
    then find prev clienlista  of neuclien  no-lock no-error.
    else find next clienlista  of neuclien  no-lock no-error.

end procedure.

