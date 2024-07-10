{admcab.i}
def var vdt like titulo.titdtven.
def var vdti like titulo.titdtven.
def var vdtf like titulo.titdtven.
def var vetbcod like estab.etbcod.
repeat:
    update vetbcod label "Filial" with frame f1.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vdti label "Data Inicial"
	   vdtf label "Data Final" with frame f1 side-label width 80.
    do vdt = vdti to vdtf:
	for each titulo where titulo.empcod = 19 and
			      titulo.titnat = no and
			      titulo.modcod = "CRE" and
			      titulo.titsit = "IMP" and
			      titulo.etbcod = vetbcod and
			      titulo.titdtven = vdt no-lock:
	    find clien where clien.clicod = titulo.clifor no-lock no-error.
	    display titulo.etbcod
		    clien.clinom when avail clien
		    titulo.titnum
		    titulo.titpar with frame f1 down.
		    pause 0.
	end.
    end.
    /*
    {mdadmcab.i
	&Saida     = "printer"
	&Page-Size = "64"
	&Cond-Var  = "130"
	&Page-Line = "66"
	&Nom-Rel   = ""CARTE1""
	    &Nom-Sis   = """SISTEMA DE CREDIARIO"""
	    &Tit-Rel   = """MOVIMENTO DA CARTEIRA POR FILIAL - PERIODO DE "" +
				  string(vdti,""99/99/9999"") + "" A "" +
				  string(vdtf,""99/99/9999"") "
	    &Width     = "130"
	    &Form      = "frame f-cabcab"}

    for each wtit by wtit.wetb:
	disp wtit.wetb column-label "Filial"
	     wtit.wvalor(total) column-label "Vl.Total"
	     wtit.wpar   column-label "Tot.Par" with frame f2 down width 130.
    end.
    output close.
    */
end.
