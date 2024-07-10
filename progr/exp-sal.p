{admcab.i}
DEF VAR VPRO LIKE PRODU.PROCOD INITIAL ?.
def var vetbcod like estab.etbcod.
def stream spla.
def stream smov.
def stream spro.
def stream sest.
def stream stela.


def temp-table wfpro
    field cod like produ.procod.

update vetbcod with frame f-2 side-label width 80.
find estab where estab.etbcod = vetbcod no-lock.
display estab.etbnom no-label with frame f-2.
vpro = ?.
repeat:
    update vpro with frame f-for width 80 side-label.

    if vpro = ?
    then leave.
    find produ where produ.procod = vpro no-lock.
    disp produ.pronom no-label with frame f-for.

    find first wfpro where wfpro.cod = vpro no-error.
    if not avail wfpro
    then do:
        create wfpro.
        assign wfpro.cod = vpro.
    end.
end.

output stream spla    to ..\auditori\plani.d.
output stream smov    to ..\auditori\movim.d.
output stream spro    to ..\auditori\produ.d.
output stream sest    to ..\auditori\estoq.d.
output stream stela   to terminal.


FOR EACH WFPRO:

    find produ where produ.procod = wfpro.cod no-lock.
    export stream spro produ.

    for each estoq where estoq.procod = produ.procod and
                         estoq.etbcod = estab.etbcod no-lock.
        export stream sest estoq.
    end.
    for each movim where movim.procod = produ.procod no-lock:
        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               plani.movtdc = movim.movtdc and
                               plani.pladat = movim.movdat no-lock no-error.
        if not avail plani
        then next.
        if plani.desti <> vetbcod and
           plani.emite <> vetbcod
        then next.
        export stream spla plani.
        export stream smov movim.
        display stream stela movim.movdat
                             plani.emite
                             plani.desti format "99999999"
                             plani.movtdc
                             produ.procod
                                with frame fd1 down.
        pause 0.
    end.
end.
output stream spla  close.
output stream smov  close.
output stream spro  close.
output stream sest  close.
output stream stela close.
message "Insira o disquete no drive". pause.

dos silent "copy /y ..\auditori\plani.d  a: " .
dos silent "copy /y ..\auditori\movim.d  a:" .
dos silent "copy /y ..\auditori\estoq.d  a:" .
dos silent "copy /y ..\auditori\produ.d  a:" .
