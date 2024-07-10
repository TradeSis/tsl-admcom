/*
*
*    envfidc.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-recid as recid.

find titulo where recid(titulo) = par-recid no-lock.

def temp-table tt-lote
    field Data   as date
    field Hora   as char
    field lottip like lotefidc.lottip
    field lotnum like lotefidc.lotnum
    field Tipo   as char format "x(10)"

    index Data Data Hora.

for each envfinan where envfinan.empcod = titulo.empcod and
                       envfinan.titnat = titulo.titnat and
                       envfinan.modcod = titulo.modcod and
                       envfinan.etbcod = titulo.etbcod and
                       envfinan.clifor = titulo.clifor and
                       envfinan.titnum = titulo.titnum and
                       envfinan.titpar = titulo.titpar
                 no-lock.
    create tt-lote.
    assign
        tt-lote.lottip = envfinan.envsit
        tt-lote.lotnum = envfinan.lotinc
        tt-lote.Tipo   = "FINANCEIRA"
        tt-lote.data   = envfinan.envdtinc
        tt-lote.hora   = string(envfinan.envhora, "hh:mm:ss").
end.

for each envfidc where envfidc.empcod = titulo.empcod and
                       envfidc.titnat = titulo.titnat and
                       envfidc.modcod = titulo.modcod and
                       envfidc.etbcod = titulo.etbcod and
                       envfidc.clifor = titulo.clifor and
                       envfidc.titnum = titulo.titnum and
                       envfidc.titpar = titulo.titpar
                 no-lock.
    find lotefidc where lotefidc.lottip = envfidc.lottip
                    and lotefidc.lotnum = envfidc.lotnum
                  no-lock.
    create tt-lote.
    assign
        tt-lote.lottip = envfidc.lottip
        tt-lote.lotnum = envfidc.lotnum
        tt-lote.Tipo   = "FIDC"
        tt-lote.data   = lotefidc.data
        tt-lote.hora   = string(lotefidc.hora, "hh:mm:ss").
end.


def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-lote where recid(tt-lote) = recatu1 no-lock.
    if not available tt-lote
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(tt-lote).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tt-lote
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find tt-lote where recid(tt-lote) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field tt-lote.Data   help ""
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
                    if not avail tt-lote
                    then leave.
                    recatu1 = recid(tt-lote).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-lote
                    then leave.
                    recatu1 = recid(tt-lote).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-lote
                then next.
                color display white/red tt-lote.Data with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-lote
                then next.
                color display white/red tt-lote.Data with frame frame-a.
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
                then do with frame f-tt-lote.
                    disp tt-lote.
                end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-lote).
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
        tt-lote
        with frame frame-a 11 down centered color white/red row 5.
end procedure.


procedure color-message.
color display message
        tt-lote.Hora
        tt-lote.lottip
        tt-lote.lotnum
        tt-lote.tipo
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        tt-lote.Hora
        tt-lote.lottip
        tt-lote.lotnum
        tt-lote.tipo
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then find first tt-lote no-lock no-error.
    else find last tt-lote  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then find next tt-lote  no-lock no-error.
    else find prev tt-lote  no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then find prev tt-lote  no-lock no-error.
    else find next tt-lote  no-lock no-error.
        
end procedure.

