/***************************************************************************
** Programa        : recibb4.p
** Objetivo        : Impressao de Recibo de Pagamento da DREBES
** Ultima Alteracao: 29/08/95
**
****************************************************************************/

{admcab.i}

def input param  rtitulo    as recid.
def var inicio              as log.
def var i                   as i.
def buffer btitulo for titulo.
def buffer ctitulo for titulo.

do:
/*
    display " COLOCAR O FORMULARIO NO INICIO DA FOLHA " with centered
	   row 10 color message frame fx.
    pause.
*/
    output to relat  page-size 0.
    i      = 0.
    inicio = yes.
    find titulo where
	 recid(titulo) = rtitulo no-lock no-error.
    find btitulo where
	 recid(btitulo) = rtitulo no-lock no-error.
    find clien where
	 clien.clicod = titulo.clifor no-lock no-error.
    find estab of titulo no-lock.
    put skip(4)
	titulo.etbcod
	etbnom              at  7 format "x(15)"
	titulo.titdtven     at 26
	titulo.etbcod       at 43
	etbnom              at 48 format "x(15)"
	titulo.titdtven     at 67 skip(1)
	titulo.clifor       at  3 format ">>>>>>9"
	titulo.titnum       at 18
	string(titulo.titpar) + "/" +
	string(btitulo.titpar) at 32
	titulo.clifor       at 45 format ">>>>>>9"
	titulo.titnum       at 60
	string(titulo.titpar)  + "/" +
	string(btitulo.titpar) at 73 skip(1)
	titulo.titvlcob           format ">>>,>>9.99" space (2)
	titulo.titvlpag - titulo.titvlcob format "->>>,>>9.99" space(3)
	titulo.titvlpag           format ">>>,>>9.99"
	titulo.titvlcob           format ">>>,>>9.99" at 44 space(2)
	titulo.titvlpag - titulo.titvlcob format "->>>,>>9.99" space(3)
	titulo.titvlpag           format ">>>,>>9.99"
	skip(1)
	clinom              at 5  format "x(30)"
	clinom              at 46 format "x(30)"  skip
	clien.endereco[1] format "x(20)" at 5 ","
	trim(string(clien.numero[1])) format "99999"  "-"
	(if  clien.compl[1] = ? then
	     ""
	 else
	     clien.compl[1])  format "x(5)" skip
	clien.cidade[1]   at 5 "/" clien.ufecod[1].
	if  i = 1 then
	    put skip(2).
	else do:
	    put skip(1).
	    i = 0.
	end.
    output close.
end.
