/*  cmdok.p */
{admcab.i}
def input  parameter    par-pdvmov-recid   as recid.
def output parameter    par-ok              as log init no.
def output parameter    par-retorna         as log.

def var vescolha as char format "x(9)" extent 3
                        init ["  O K  ", " Retorna ", " Cancela "].
def var vindex as int.
def buffer bpdvmov for pdvmov.
par-retorna = no.
find pdvmov where recid(pdvmov) = par-pdvmov-recid no-lock.
find cmon   of pdvmov no-lock.
find pdvtmov of pdvmov no-lock.
find cmtipo of cmon    no-lock.


vindex = 1.

def var vtotdeb like pdvdoc.valor.
def var vjurodesc       as dec.

do:
    vtotdeb = 0.
    for each pdvdoc of pdvmov no-lock.
        vjurodesc = pdvdoc.valor_encargo - pdvdoc.desconto.
        vtotdeb = vtotdeb + pdvdoc.valor + vjurodesc.
    end.

end.

find first pdvdoc of pdvmov no-lock no-error.

if not avail pdvdoc
then do:
    vindex = 3.
    hide message no-pause.
    message "Vai Cancelar...".
    pause 2 no-message.
    
end.


bl-esc:
repeat on endkey undo.
    if vescolha[vindex] <> " Cancela "
    then do:
    pause 0.
    display /*space(3)*/
           "<" space(0) vescolha[1] format "x(7)" space(0) ">"
           space(2)
           "<" space(0) vescolha[2] space(0) ">"
           space(5)
           "<" space(0) vescolha[3] space(0) ">"
           space(3)
           with frame fescolha centered row screen-lines overlay
                      width 80 color message no-labels no-box.
    next-prompt vescolha[vindex] with frame fescolha.
    choose field vescolha color normal
                go-on(cursor-down cursor-up)
                    with frame fescolha.

    if keyfunction(lastkey) = "cursor-down" or
       keyfunction(lastkey) = "cursor-up"
    then undo bl-esc.
    hide frame fescolha no-pause.
    vindex = frame-index.
    end.

do:
    if vescolha[vindex] = "  O K  "
    then do:
        run fin/cmdfec.p (input recid(pdvmov)).
        par-ok = yes.
        leave.
    end.
    if vescolha[vindex] = " Retorna "
    then do:
        par-retorna = yes.
        clear frame ffmoetit all.
        hide frame ffmoetit no-pause.
        leave.
    end.
    if vescolha[vindex] = " Cancela "
    then do transaction:
        find pdvmov where recid(pdvmov) = par-pdvmov-recid.
        find pdvtmov of pdvmov no-lock.
        do:
            for each pdvdoc of pdvmov.
                delete pdvdoc.
            end.
            delete pdvmov.
        end.
        par-pdvmov-recid = ?.
        leave.
    end.
end.
end.

