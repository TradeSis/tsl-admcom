/*
*
*    cyber_controle.p    -    Esqueleto de Programacao
*
*/
{admcab.i}
{cyb/cyb_reenvia.i}

def input parameter par-rec as recid.

find cyber_clien where recid(cyber_clien) = par-rec no-lock.
find clien of cyber_clien no-lock.
disp cyber_clien.clicod
    clien.clinom no-label
    with frame f-cab row 3 no-box side-label.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(14)" extent 5
    initial [" "," Consulta "," ", "", "Reenvia contrato"].
def var esqcom2         as char format "x(14)" extent 5
    initial ["","","","","_"].

def buffer bcyber_controle       for cyber_controle.

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
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find cyber_controle where recid(cyber_controle) = recatu1 no-lock.
    if not available cyber_controle
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(cyber_controle).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    repeat:
        run leitura (input "seg").
        if not available cyber_controle
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find cyber_controle where recid(cyber_controle) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field cyber_controle.contnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
            run color-normal.
            status default "".

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
                    if not avail cyber_controle
                    then leave.
                    recatu1 = recid(cyber_controle).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cyber_controle
                    then leave.
                    recatu1 = recid(cyber_controle).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cyber_controle
                then next.
                color display white/red cyber_controle.contnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cyber_controle
                then next.
                color display white/red cyber_controle.contnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form cyber_controle
                 with frame f-cyber_controle color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-cyber_controle.
                    disp cyber_controle.
                end.
            end.
            if esqcom1[esqpos1] = "Reenvia contrato"
            then do.
                run reenvia (string(cyber_controle.contnum), yes).
                pause.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "_"
                then do on error undo:
                    find current cyber_controle.
                    update cyber_controle.situacao.
                    find current cyber_controle no-lock.
                end.
                leave.
            end.
        end.
            run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(cyber_controle).
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
        cyber_controle.loja
        cyber_controle.contnum
        cyber_controle.situacao
        cyber_controle.dtemissao
        cyber_controle.vlraberto
        cyber_controle.vlratrasado
        cyber_controle.dtenvio
        with frame frame-a 11 down centered color white/red row 5.
end procedure.


procedure color-message.
color display message
        cyber_controle.contnum
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        cyber_controle.contnum
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first cyber_controle where cyber_controle.cliente = cyber_clien.clicod
                                                no-lock no-error.
    else  
        find last cyber_controle  where cyber_controle.cliente = cyber_clien.clicod
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next cyber_controle  where cyber_controle.cliente = cyber_clien.clicod
                                                no-lock no-error.
    else  
        find prev cyber_controle   where cyber_controle.cliente = cyber_clien.clicod
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev cyber_controle where cyber_controle.cliente = cyber_clien.clicod  
                                        no-lock no-error.
    else   
        find next cyber_controle where cyber_controle.cliente = cyber_clien.clicod 
                                        no-lock no-error.
        
end procedure.
         
