def input parameter wrecpla as recid.

def var vqtdtot     like movim.movqtm.
def var wpcticm     like tribu.triicms.
def var vtitnum     like titulo.titnum.

find plani where recid(plani) = wrecpla .
find tipmov of plani .

find nota  of plani no-error.
find estab of plani .
find crepl of plani.
find vende of plani no-error.
find clien where clien.clicod = plani.clifor .

if avail nota
then do:
    find tofis of nota .
    for each tribu where tribu.triufemi = estab.ufecod
		     and tribu.triufdes = clien.ufecod[1] .
	if tribu.triufdes = tribu.triufemi
	then do:
	    wpcticm  = tribu.triicms.
	    leave.
	end.
	else do:
	    wpcticm  = tribu.triicms.
	    leave.
	end.
    end.
end.

output to printer .
put skip(1)
    caps(estab.etbnom)  at 01 format "x(25)"
    "Numero da Nota: "   at 71 nota.notnum
    "CGC : " at 01  estab.etbcgc  "   "
    "Ins.Est.: " estab.etbinsc
    "Serie         : "   at 71 caps(nota.notser)
    "End.: " at 01 estab.endereco
    "Data Emissao  : "   at 71 nota.notdat
    "Nat.Operacao  : "   at 71 nota.tofcod "  "  tofis.tofnom skip
    "Via Transporte: "   at 71 nota.notviatr
    "Numero Pedido : " at 01  plani.pednum "       "
    "Plano Credito : " crepl.crenom skip
    "Representante: " at 01 trim(string(plani.vencod) + " - " +
				 vennom ) format "x(40)" skip(1)
    "Cliente : "  at 01 clien.clinom  " (" clien.clicod ")" skip
    "Endereco: "  at 01 trim(clien.endereco[1] + ", " +
			     string(clien.numero  [1]) + " - " +
			     clien.compl[1]) format "x(40)" skip
    "Cidade  : " at 01 trim(clien.cidade[1] + " / " +
			    clien.uf[1]) format "x(40)"
    "CEP : " clien.cep[1]  skip
    "CGC     : " at 01 clien.ciccgc
    "Insc.Estadual : " at 41 clien.ciinsc skip(1)
    "Qtd"               at 03
    "Cod. Item"         at 10
    "Item"              at 30   format "x(35)"
    "Pco. Unitario"     at 71
    "   Valor Total"    at 92
    "----"              at 02
    "--------"          at 10
    fill("-",35)        format "x(35)" at 30
    "--------------"    at 70
    "--------------"    at 92.

for each movim of plani,
    produ of movim       break by produ.itecod :

    vqtdtot = vqtdtot + movim.movqtm .
    if last-of(PRODU.itecod)
    then do:
	find item where item.itecod = produ.itecod .
	put vqtdtot         at 02   format ">>>9"
	    item.itecod     at 10
	    item.itenom     at 30   format "x(35)"
	    movim.movpc at 70
	    vqtdtot * movpc format ">>>,>>>,>>9.99" at 92.
	vqtdtot = 0.
    end.
end.

put skip
    "--------------"            at 92  skip
    "Total"                     at 83
    plani.platot                at 92  skip
    "ICMS (" at 74 wpcticm ") "
    plani.platot * (wpcticm / 100)  format ">>>,>>9.99"  at 96 skip.

put skip
    "Transportadora : " at 01 /* forne.forfant */
    "End.Entrega    : " at 01 trim(clien.entendereco[1] + ", " +
				   string(clien.entnumero[1])  + "  " +
				   CLIEN.ENTCOMPL[1])
				   format "x(30)" skip
    trim(clien.entbairro[1] + "   " + clien.entcidade[1] + "   " +
				      clien.entufecod[1]) format "x(50)" at 17
    "CEP : " at 16 clien.entcep[1]    .

vtitnum = if plani.notnum <> 0
	  then string(plani.notnum)
	  else string(plani.movndc).

for each titulo where titulo.titnum = vtitnum              and
		      titulo.modcod = tipmov.modcod        and
		      titulo.titnat = tipmov.movtnat       and
		      titulo.clifor = plani.clifor         and
		      titulo.etbcod = plani.etbcod
		      break by titulo.titnum .
    if first-of(titnum)
    then
	put skip(2)
	    "Condicoes de Pagamento"    at 10 skip
	    "Data"                      at 05
	    "Valor Parcelas"            at 20
	    "----------"                at 05
	    "--------------"            at 20 skip .

    put titulo.titdtven                         at 05
	titulo.titvlcob format ">>>,>>9.99"     at 24.

end.



output close.
