/*                                                 
*
*/
{admcab.i}

def input parameter pclicod as int.

def var vhora as char.

find clien where clien.clicod = pclicod no-lock.

/*    disp 
        NeuClien.CpfCnpj
        NeuClien.Clicod
        clien.clinom when avail clien
        NeuClien.VlrLimite
        NeuClien.VctoLimite
        with frame f-neuclien
         side-label 2 col centered 1 down row 3.
  */
def var vantigo as char format "x(15)".
def var vnovo   as char format "x(15)".

form
      clienstahist.dataalt  format "99/99/9999" column-label "Data"
      vhora column-label "Hora" 
      clienstahist.IDstatusCAD-Antigo column-label "Sta"
      vantigo  column-label "Antigo"
      clienstahist.IDstatusCAD-Novo column-label "Sta"
      vnovo column-label "Novo"
      with frame frame-a 11 down centered no-box row 9.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [""," ","  ",""].
def var esqhel1         as char format "x(80)" extent 5.

def buffer bclienstahist       for clienstahist.

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
    else find clienstahist where recid(clienstahist) = recatu1 no-lock.
    if not available clienstahist
    then do.
        message "Sem registros para este cliente" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(clienstahist).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available clienstahist
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find clienstahist where recid(clienstahist) = recatu1 no-lock.
            
            status default
                esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(clienstahist.dataalt)
                                        else "".
            run color-message.
            
            choose field clienstahist.dataalt help ""
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
                    if not avail clienstahist
                    then leave.
                    recatu1 = recid(clienstahist).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail clienstahist
                    then leave.
                    recatu1 = recid(clienstahist).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail clienstahist
                then next.
                color display white/red clienstahist.dataalt with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail clienstahist
                then next.
                color display white/red clienstahist.dataalt with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form clienstahist
                 with frame f-clienstahist color black/cyan
                      centered side-label row 9 with 2 col.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-clienstahist.
                    hide frame frame-a no-pause.
                    disp clienstahist.
                end.

                if esqcom1[esqpos1] = " Operacoes "
                then do with frame f-Lista:
                    hide frame f-com1 no-pause.
                    hide frame frame-a no-pause.
                    run neuro/cdclienstahistoper.p (recid(clienstahist)).
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
                        find current clienstahist exclusive.
                        clienstahist.IDstatusCAD-Novo = "X".
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
        recatu1 = recid(clienstahist).
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
    vhora = string(clienstahist.horaalt, "hh:mm:ss").
    find clienstatus where clienstatus.IDstatusCAD = clienstahist.IDstatusCAD-Antigo no-lock no-error.
    vantigo = if avail clienstatus then clienstatus.statuscadnome else "".
    find clienstatus where clienstatus.IDstatusCAD = clienstahist.IDstatusCAD-novo no-lock no-error.
    vnovo = if avail clienstatus then clienstatus.statuscadnome else "".
    
    display 
      clienstahist.dataalt  
      vhora
      clienstahist.IDstatusCAD-Antigo
      vantigo 
      clienstahist.IDstatusCAD-Novo
      vnovo 

      with frame frame-a.

end procedure.


procedure color-message.
    color display message
      clienstahist.dataalt  
      vhora  
      clienstahist.IDstatusCAD-Antigo
      vantigo  
      clienstahist.IDstatusCAD-Novo
      vnovo 

        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
      clienstahist.dataalt  
      vhora  
      clienstahist.IDstatusCAD-Antigo
      vantigo  
      clienstahist.IDstatusCAD-Novo
      vnovo 

        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.

if par-tipo = "pri" 
then
    if esqascend
    then find first clienstahist of clien  no-lock no-error.
    else find last clienstahist  of clien  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then
    if esqascend
    then find next clienstahist  of clien  no-lock no-error.
    else find prev clienstahist  of clien no-lock no-error.
             
if par-tipo = "up" 
then
    if esqascend
    then find prev clienstahist  of clien  no-lock no-error.
    else find next clienstahist  of clien  no-lock no-error.

end procedure.

