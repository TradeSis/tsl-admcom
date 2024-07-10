{admcab.i}
def var vtit        as integer.
def var vtot        as decimal format ">>>,>>9.99".
def var vcon        as integer.
def var vclia       as integer.
def var vclid       as integer.
def var vachou      as logical.
def var vetb        as logical.
def buffer bcontrato for contrato.
def stream s-tela1.
def stream s-tela2.
def stream s-tela3.


form skip(1)
     vclia label "Clientes Ativos"
     vclid label "Clientes Inativos"
     vcon  label "Contratos Abertos"
     vtit  label "Titulos Abertos"
     vtot  label "Valor em Aberto"
     skip(1) with 1 column 1 down centered row 9 color white/cyan
		    title " TOTAL GERAL " frame fmostra.

form skip(1)
     vclia label "Clientes Ativos"
     vclid label "Clientes Inativos"
     vcon  label "Contratos Abertos"
     vtit  label "Titulos Abertos"
     vtot  label "Valor em Aberto"
     skip(1) with 1 column 1 down centered row 9 color white/cyan
		    title " TOTAL GERAL " frame fmostra1.

prompt-for estab.etbcod
	   with side-labels color white/cyan width 80 frame fpede row 4.
find estab using estab.etbcod no-lock.
display estab.etbnom no-label with frame fpede.

    varquivo = "..\relat\totger" + STRING(TIME) + ".rel".
    {mdadmcab.i
	&Saida     = "value(varquivo)"
	&Page-Size = "64"
	&Cond-Var  = "80"
	&Page-Line = "66"
	&Nom-Rel   = """RESPAG"""
	&Nom-Sis   = """SISTEMA CREDIARIO"""
	&Tit-Rel   = """TOTAL GERAL - ESTABELECIMENTO "" +
	    string(ESTAB.ETBCOD)"
	&Width     = "80"
	&Form      = "frame f-cab"}


for each bcontrato no-lock where bcontrato.etbcod = estab.etbcod
    use-index est
    break by bcontrato.clicod:

    if first-of( bcontrato.clicod )
    then do:

for each clien where clien.clicod = bcontrato.clicod no-lock:
    for each contrato where contrato.etbcod = estab.etbcod and
			     contrato.clicod = clien.clicod no-lock:
	vetb = yes.
	for each titulo where titulo.empcod = wempre.empcod   and
			      titulo.titnat = no              and
			      titulo.modcod = "CRE"           and
			      titulo.etbcod = estab.etbcod    and
			      titulo.clifor = clien.clicod    and
			      titulo.titnum = string(contrato.contnum)
								    no-lock:
	    if titulo.titsit = "PAG"
	    then do:
		vachou = no.
		next.
	    end.
	    else vachou = yes.
	    vtit = vtit + 1.
	    vtot = vtot + titulo.titvlcob.
	    output stream s-tela1 to terminal.
		display stream s-tela1 vtit vtot with frame fmostra1.
	    output stream s-tela1 close.
	    display vtit vtot with frame fmostra.
	end.
	if vachou then vcon = vcon + 1.
	output stream s-tela2 to terminal.
	    display stream s-tela2 vcon with frame fmostra1.
	output stream s-tela2 close.
	display vcon with frame fmostra.
    end.
    if vachou
    then vclia = vclia + 1.
    else if vetb then vclid = vclid + 1.
    output stream s-tela3 to terminal.
	display stream s-tela3 vclia
			       vclid with frame fmostra1.
    output stream s-tela3 close.
    display vclia
	    vclid with frame fmostra.
    pause 0.
    assign vachou = no
	   vetb   = no.
end.
end.
end.
    output close.

    message "Deseja Imprimir o arquivo " varquivo + "?" update sresp.
    if sresp
    then dos silent value("type " + varquivo + " > prn").

pause.
