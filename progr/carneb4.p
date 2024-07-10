/***************************************************************************
** Programa        : carneb4.p
** Objetivo        : Impressao de Carne especifico Drebes
** Ultima Alteracao: 19/09/95
**                   Retiradas as atribuicoes titsit = EXP
****************************************************************************/
{admcab.i}
def var inicio  as log.
def var i       as i.
def var v-ant   as i.
def var v-dep   as i.

def stream tela.

output stream tela to terminal.

def buffer btitulo for titulo.

for each titulo where titulo.empcod = wempre.empcod and
		      titulo.titnat = no and
		      titulo.modcod = "CRE" and
		      titulo.titsit = "IMP" use-index titsit.
    v-ant = v-ant + 1.
    display v-ant label "Nro.Parcelas"
	    v-ant / 4 label "Nro. de Folhas" format ">>>>9"
	    with frame fant
		side-label centered 1 down row 5 . pause 0.
end.

do:
    display " COLOCAR O FORMULARIO NO INICIO DA FOLHA " with centered
	    row 10 color message frame fx.

    pause.

    output to PRINTER page-size 0.

    i = 0.
    inicio = yes.
	for each titulo where titulo.empcod = wempre.empcod and
			      titulo.titnat = no and
			      titulo.modcod = "CRE" and
			      titulo.titsit = "IMP"
			      use-index titsit,
	    clien where clien.clicod = titulo.clifor no-lock
				BY TITULO.ETBCOD
				by clien.clinom
				by titulo.titnum
				by titulo.titpar .

	    if titulo.etbcod = 01 or
	       titulo.etbcod = 06
	    then next.

	    find estab of titulo no-lock.

	    find last btitulo where
		      btitulo.empcod = titulo.empcod and
		      btitulo.titnat = titulo.titnat and
		      btitulo.modcod = titulo.modcod and
		      btitulo.etbcod = titulo.etbcod and
		      btitulo.clifor = titulo.clifor and
		      btitulo.titnum = titulo.titnum.

	    i = i + 1.
	    put skip(2)
		titulo.etbcod
		etbnom at 7  format "x(15)"
		titulo.titdtven  at 26
		titulo.etbcod  at 43
		etbnom  at 48 format "x(15)"
		titulo.titdtven at 67 skip(1)
		titulo.clifor at 3 FORMAT ">>>>>>9"
		titulo.titnum at 18
		string(titulo.titpar) + "/" +
		string(btitulo.titpar) at 32
		titulo.clifor at 45 FORMAT ">>>>>>9"
		titulo.titnum at 60
		string(titulo.titpar)  + "/" +
		string(btitulo.titpar) at 73
		skip(1)
		titulo.titvlcob format ">>>,>>9.99"
		titulo.titvlcob format ">>>,>>9.99" at 44 skip(1)
		clinom          at 5  format "x(30)"
		clinom          at 46 format "x(30)"  skip
		clien.endereco[1] format "x(20)" at 5 ","
		trim(string(clien.numero[1])) format "99999"  "-"
		(if  clien.compl[1] = ? then
		     ""
		else
		clien.compl[1])  format "x(5)" skip
		clien.cidade[1]   at 5 "/" clien.ufecod[1].
		if  i = 1 then
		    put skip(6).
		else do:
		    put skip(6).
		    i = 0.
		end.
	    assign titulo.titsit = "LIB".
	    v-dep = v-dep + 1.
	    display stream tela
		    v-dep label "Contando e Processando Carne"
		    v-dep / 4 label "Nro. de Folhas" format ">>>>9"
		    with frame fdep
			side-label 1 down centered
			. pause 0.
	end.

    output close.
end.
output stream tela close.
