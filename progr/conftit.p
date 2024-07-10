{admcab.i}
def stream stela .

output stream stela to terminal.
message "confirma relatorio" update sresp.
if not sresp
then return.
    {mdadmcab.i &Saida     = "printer"
		&Page-Size = "63"
		&Cond-Var  = "120"
		&Page-Line = "66"
		&Nom-Rel   = ""CONFTIT""
		&Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
		&Tit-Rel   = """LISTAGEM DE CONTRATOS SEM PARCELAS """
		&Width     = "120"
		&Form      = "frame f-cabcab"}

for each clien no-lock:

    display stream stela clien.clicod with 1 down. pause 0.

    for each contrato where contrato.clicod = clien.clicod no-lock:

	find first titulo where titulo.empcod = 19 and
				titulo.titnat = no and
				titulo.modcod = "CRE" and
				titulo.etbcod = contrato.etbcod and
				titulo.clifor = clien.clicod and
				titulo.titnum = string(contrato.contnum)
					no-lock no-error.
	    if not avail titulo and
	    contrato.dtinicial >= 01/01/96
	    then do:
		disp clien.clicod
		     clien.clinom
		     contrato.contnum
		     contrato.dtinicial
		     contrato.etbcod with frame f-cli width 115 down.
	    end.
     end.
end.
output close.
