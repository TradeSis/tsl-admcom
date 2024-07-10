/*
*
*    <tabela>.p    -    Esqueleto de Programacao    com esqvazio


            substituir    <tabela>
                          <tab>
*
*/
{admcab.i}

def input parameter par-rec as recid.

find plani where recid(plani) = par-rec no-lock.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Ok "," "].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find planiaux where recid(planiaux) = recatu1 no-lock.
    if not available planiaux
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(planiaux).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available planiaux
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find planiaux where recid(planiaux) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field planiaux.nome_campo help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.

            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail planiaux
                    then leave.
                    recatu1 = recid(planiaux).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail planiaux
                    then leave.
                    recatu1 = recid(planiaux).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail planiaux
                then next.
                color display white/red planiaux.nome_campo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail planiaux
                then next.
                color display white/red planiaux.nome_campo with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error" or
           keyfunction(lastkey) = "return"
        then leave bl-princ.

            run frame-a.

        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(planiaux).
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

    display
        planiaux.nome_campo  format "x(20)"
        planiaux.valor_campo format "x(50)"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.


procedure color-message.
    color display message
        planiaux.nome_campo
        planiaux.valor_campo
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        planiaux.nome_campo
        planiaux.valor_campo
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first planiaux where
                   planiaux.movtdc = plani.movtdc and
                   planiaux.etbcod = plani.etbcod and
                   planiaux.emite  = plani.emite  and
                   planiaux.serie  = plani.serie  and
                   planiaux.numero = plani.numero
                    no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next planiaux  where
                   planiaux.movtdc = plani.movtdc and
                   planiaux.etbcod = plani.etbcod and
                   planiaux.emite  = plani.emite  and
                   planiaux.serie  = plani.serie  and
                   planiaux.numero = plani.numero 
                                                no-lock no-error.
             
if par-tipo = "up" 
then find prev planiaux where
                   planiaux.movtdc = plani.movtdc and
                   planiaux.etbcod = plani.etbcod and
                   planiaux.emite  = plani.emite  and
                   planiaux.serie  = plani.serie  and
                   planiaux.numero = plani.numero 
                                        no-lock no-error.
        
end procedure.
         
