{admcab.i}
def var varquivo as char format "x(20)".
def var vetbcod like estab.etbcod.
repeat:
    update vetbcod with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod.
    disp estab.etbnom no-label with frame f1.
    estab.estcota = estab.estcota + 1.
    message "Confirma impressao do livro" update sresp.
    if not sresp
    then return.

    varquivo = "..\import\liv" + STRING(estab.etbcod,">>9") + ".d".
    dos silent value("type " + varquivo + " > prn").
end.
