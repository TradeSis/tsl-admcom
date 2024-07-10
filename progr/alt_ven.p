{admcab.i}
def var vcusto like estoq.estcusto.
def var vluc  like estoq.estmgluc.
def var vdata like estoq.estprodat.
def var vpreco like estoq.estVENDA.
def var vprocod like produ.procod.
repeat:
    UPDATE vprocod with frame f1 side-label width 80.
    find produ where produ.procod = vprocod no-lock no-error.
    if not avail produ
    then do:
	message "Produto nao Cadastrado".
	undo, retry.
    end.
    disp produ.pronom no-label with frame f1.
    find estoq WHERE ESTOQ.ETBCOD = 999 AND
		     ESTOQ.PROCOD = produ.PROCOD no-lock.
    display estoq.estvenda
	    estoq.estcusto
	    estoq.estproper format ">>,>>9.99" with frame f1.
    vcusto = estoq.estcusto.


    update vcusto
	   vluc
	    with frame f2.
    if vluc = 0
    then vpreco = estoq.estvenda.
    else vpreco = (vcusto * (vluc / 100 + 1)).
    update vpreco with frame f2 centered side-label row 8.
    message "Confirma Preco de venda" update sresp.
    if sresp
    then do TRANSACTION:
	for each estab no-lock:
	    for each estoq where estoq.etbcod = estab.etbcod and
				 estoq.procod = produ.procod.
		estoq.datexp = today.
		estoq.estvenda = vpreco.
		estoq.estcusto = vcusto.
	    end.
	end.
    end.
end.
