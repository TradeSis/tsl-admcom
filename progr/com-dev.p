{admcab.i}
def var vtprcod       like comis.tprcod.
def var vvencod      like comis.vencod.
def var vmodcod      like comis.modcod.
def var vetbcod like notdev.etbcod.
def var vvalor  like notdev.clicod format ">>>,>>9.99" label "Valor".

repeat:
    update vetbcod with frame f-etb side-label width 80 color message.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label
		with frame f-etb.

    assign vtprcod  = 0
	   vvencod = 0
	   vmodcod = ""
	   vvalor  = 0.

    update vtprcod colon 20 with frame f-vend.
    find tippro where tippro.tprcod = vtprcod no-lock no-error.
    if not avail tippro
    then do:
	bell.
	message "Tipo de Produto nao Cadastrado !!".
	undo.
    end.
    display tippro.tprnom no-label with frame f-vend.
    update vvencod colon 20
	    with frame f-vend color white/cyan centered side-label.
    find func where func.funcod = vvencod and
		    func.etbcod = estab.etbcod no-lock.
    display func.funnom no-label with frame f-vend.
    vmodcod = "VVI".
    update vmodcod colon 20
	   vvalor colon 20 with frame f-vend.

    find notdev where notdev.movtdc = vtprcod and
		      notdev.movndc = 0       and
		      notdev.movsdc = ""      and
		      notdev.clicod = vvalor  and
		      notdev.etbcod = estab.etbcod and
		      notdev.forcod = vvencod and
		      notdev.ndvmovndc = 0 no-error.
    if not avail notdev
    then do:
	create notdev.
	assign notdev.movtdc = vtprcod
	       notdev.clicod = vvalor
	       notdev.etbcod = estab.etbcod
	       notdev.forcod = vvencod
	       notdev.movsdc = vmodcod
	       notdev.movndc = 0
	       notdev.ndvmovndc = 0.
    end.
    else message "Documento ja digitado".
end.
