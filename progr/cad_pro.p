{admcab.i}
def buffer bprodu for produ.
def var vprocod like produ.procod.
def var vicms like plani.icms.
def var vvenda like estoq.estvenda.
def var vcusto like estoq.estcusto.
repeat:
    find last produ no-lock no-error.
    if not avail produ
    then vprocod = 0.
    else vprocod = produ.procod.
    {di.v 1 "vprocod"}
    create produ.
    assign produ.procod = vprocod.
    update produ.pronom
	   produ.prounven
	   produ.clacod label "Grupo/Subgrupo"
	   produ.proipival label "Aliquota Icms"
	   produ.proipiper label "Aliquota Ipi" with frame f-produ side-label
			centered color message 1 column row 6.
    vvenda = 0.
    vcusto = 0.
    update vvenda
	   vcusto with frame f-estoq centered color message.

    for each estab no-lock:
	create estoq.
	assign estoq.etbcod = estab.etbcod
	       estoq.procod = produ.procod
	       estoq.estvenda = vvenda
	       estoq.estcusto = vcusto.
    end.
end.
