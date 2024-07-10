/*
*
*    tt-tbprice.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def temp-table tt-tbprice like tbprice.

form " " 
    tt-tbprice.serial help "Digite o SERIAL(ESN/IMEI) do aparelho celular."
    " "
    with frame f-linha 11 down color with/cyan width 60 centered.
 
def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," "].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.
assign
    esqpos1  = 1.

disp "                  INCLUSAO SERIAIS - ESN/IMEI       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
disp " " with frame f2 1 down width 80 color message no-box no-label row 21.
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-tbprice where recid(tt-tbprice) = recatu1 no-lock.
    if not available tt-tbprice
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(tt-tbprice).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-tbprice
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
            find tt-tbprice where recid(tt-tbprice) = recatu1 no-lock.

            status default "".
            choose field tt-tbprice.serial help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                      PF4 F4 ESC return) .
            status default "".
        end.

            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-tbprice
                    then leave.
                    recatu1 = recid(tt-tbprice).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-tbprice
                    then leave.
                    recatu1 = recid(tt-tbprice).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-tbprice
                then next.
                color display white/red tt-tbprice.serial with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-tbprice
                then next.
                color display white/red tt-tbprice.serial with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do.
                    run inclusao.
                    leave.
                end.
        end.
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-tbprice).
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    display tt-tbprice.serial
        with frame frame-a 11 down centered color white/red row 6.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first tt-tbprice where true no-lock no-error.

if par-tipo = "seg" or par-tipo = "down" 
then find next tt-tbprice  where true no-lock no-error.
             
if par-tipo = "up" 
then find prev tt-tbprice where true  no-lock no-error.
        
end procedure.

procedure inclusao:
    def var vok as log. 
    def buffer btbprice for tbprice.
    clear frame f-linha all.

    repeat with frame f-linha:
        scroll from-current down with frame f-linha.
        do on error undo:
            create tt-tbprice.
            update tt-tbprice.serial.
            vok = yes.
            run veresnimei.p(input tt-tbprice.serial, output vok).
            if not vok
            then do:
                message "SERIAL invalido."  view-as alert-box.
                undo.        
            end.
            find first btbprice where
                   btbprice.serial = tt-tbprice.serial no-lock no-error.
            if avail btbprice
            then do:
                message "Serial ja cadastrado." view-as alert-box.
                undo.
            end. 
            tt-tbprice.char3 = tt-tbprice.char3 +
                        "FILIAL=" + string(setbcod,"999") + "|".     
            create tbprice.
            buffer-copy tt-tbprice to tbprice.
        end.          
    END.
    
end procedure.

