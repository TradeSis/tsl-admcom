{admcab.i}
def var vnumero     like plani.numero.
def var vserie      as char format "x(3)".
def var vetbcod     like plani.etbcod.

repeat:
    vetbcod = setbcod.
    vserie  = "1".
    update vetbcod label "Emitente"
           vnumero
           vserie with frame f-not centered side-label row 5.

    find first plani where movtdc = 6 and
                           etbcod = vetbcod and
                           emite  = vetbcod and
                           serie  = vserie and
                           numero = vnumero no-lock no-error.
    if not avail plani
    then do:
        bell.
        message "Nota nao Cadastrada".
        undo, retry.
    end.
    else do:
        disp " Prepare a Impressora " with frame f-imp centered row 10.
        pause.
        run imptra_l.p(input recid(plani)).
    end.
end.
