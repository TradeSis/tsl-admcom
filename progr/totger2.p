{admcab.i}
def var vtit        as integer.
def var vtot        as decimal format ">>>,>>9.99".
def var vcon        as integer.
def var vclia       as integer.
def var vclid       as integer.
def var vachou      as logical.
def var vetb        as logical.

form skip(1)
     vclia label "Clientes Ativos"      format ">>>,>>>,>>9.99"
     vclid label "Clientes Inativos"    format ">>>,>>>,>>9.99"
     vcon  label "Contratos Abertos"    format ">>>,>>>,>>9.99"
     vtit  label "Titulos Abertos"      format ">>>,>>>,>>9.99"
     vtot  label "Valor em Aberto"      format ">>>,>>>,>>9.99"
     skip(1) with 1 column 1 down centered row 9 color white/cyan
		    title " TOTAL GERAL " frame fmostra.

disp "TODOS OS ESTABELECIMENTOS - LENDO FILIAL"
	   with side-labels color white/cyan width 80 frame fpede row 4.

FOR EACH ESTAB:

DISP ESTAB.ETBCOD NO-LABEL WITH FRAME FPEDE.

for each clien no-lock:
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
	    display vtit vtot with frame fmostra.
	end.
	if vachou then vcon = vcon + 1.
	display vcon with frame fmostra.
    end.
    if vachou
    then vclia = vclia + 1.
    else if vetb then vclid = vclid + 1.
    display vclia
	    vclid with frame fmostra.
    pause 0.
    assign vachou = no
	   vetb   = no.
end.
END.
pause.
