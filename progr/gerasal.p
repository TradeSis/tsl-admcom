{admcab.i}
def var vetbcod like estab.etbcod.
def stream sestoq.
output stream sestoq to terminal.
repeat:
    update vetbcod with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.

    message "Confirma Exportacao de dados" update sresp.
    if not sresp
    then return.

    output to ..\auditori\estoq.d.
    for each estoq where estoq.etbcod = vetbcod no-lock.
	export estoq.
	display stream sestoq
	    "SALDOS" estoq.procod estoq.estatual format "->>>,>>9" with 1 down.
	    pause 0.
    end.
    output close.
end.
