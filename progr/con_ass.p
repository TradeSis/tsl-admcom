/*
*
*    tt-plani.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-rec as recid.

def temp-table tt-plani
    field rec    as   recid
    field numero like plani.numero.

find contrato where recid(contrato) = par-rec no-lock.

for each contnf where contnf.contnum = contrato.contnum
                  AND contnf.etbcod  = contrato.etbcod 
                  and contnf.notaser <> "v"
                  no-lock.
    find first plani where plani.placod = contnf.placod
                       and plani.etbcod = contnf.etbcod
                       and plani.serie  = contnf.notaser
                     no-lock no-error.
    if avail plani
    then do.
        create tt-plani.
        tt-plani.rec = recid(plani).
        tt-plani.numero = plani.numero.
    end.
end.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 3
    init [" Consulta ", "F4 Retorna",""].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 40.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-plani where recid(tt-plani) = recatu1 no-lock.
    if not available tt-plani
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(tt-plani).
    color display message esqcom1[esqpos1] with frame f-com1.

    repeat.
        run leitura (input "seg").
        if not available tt-plani
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find tt-plani where recid(tt-plani) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field tt-plani.numero help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.

            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-plani
                    then leave.
                    recatu1 = recid(tt-plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-plani
                    then leave.
                    recatu1 = recid(tt-plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-plani
                then next.
                color display white/red tt-plani.numero with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-plani
                then next.
                color display white/red tt-plani.numero with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta "
                then do.
                    run not_consnota.p (tt-plani.rec).
                end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-plani).
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
        tt-plani.numero
        plani.serie  column-label "Ser"
        plani.platot format ">>>>>9.99"
        plani.vlserv column-label "Vlr Devol"   format ">>>>>9.99"
        plani.biss   column-label "Vlr C/Acres" format ">>>>>9.99"
        plani.pedcod column-label "Plano" format ">>>>9"
        with frame frame-a screen-lines - 17 down col 31 color white/red row 13
            title " Notas Fiscais ".
end procedure.


procedure color-message.
    color display message
        tt-plani.numero
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        tt-plani.numero
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first tt-plani where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next tt-plani  where true no-lock no-error.
             
if par-tipo = "up" 
then find prev tt-plani where true  no-lock no-error.
        
end procedure.
