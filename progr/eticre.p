/*--------------------------------------------Etiquetas Butique peao----------*/
/* admcom/cp/peaoetiq.p                                                       */
/*----------------------------------------------------------------------------*/

{admcab.i}
def var vdata as date.
def var vini as date format "99/99/99" label "Data Inicial".
def var vi as int.
def var vfim as date format "99/99/99" label  "Data Final".
def var diaini as int format ">>9" label "Dias Inicial".
def var diafim as int format ">>9" label "Dias Final".
def var vtotal      as char  extent 8 format "x(10)".
def var vcontrato like titulo.titnum.
def var vcli    like clien.clicod.
def var vclicod like clien.clicod  extent 2 format "999999999".
def var vclinom like clien.clinom format "x(25)"  extent 2.
def var vtitpar like titulo.titpar extent 2.
def var vtitnum like titulo.titnum format "x(7)" extent 2.
def var vnumero like clien.numero  extent 2 .
def var vendereco like clien.endereco format "x(32)" extent 2 .
def var vcep      like clien.cep extent 2 .
def var vcompl  like clien.compl extent 2.
def var vetbcod like titulo.etbcod extent 2 format ">>9".
def var vcidade like clien.cidade format "x(12)" extent 2.
def var vbairro like clien.bairro format "x(10)" extent 2.
def var vtitvlpag like titulo.titvlpag extent 2 .
def var vtitdtven like titulo.titdtven extent 2 format "99/99/99".

def var n-etiq  as int.
def var wetbcod like estab.etbcod.
def var wetbcod2 like estab.etbcod.

def buffer btitulo for titulo.

def var t as i.
def var i as int.
def var v as i.


do with width 80 title " Emissao de Etiquetas de Aviso " frame f1 side-label
		row 4:
    for each clipar:
	delete clipar.
    end.
    update wetbcod colon 20
	   wetbcod2.

    if wetbcod <> 0
    then do:
	/*
	find estab where estab.etbcod = wetbcod.
	disp estab.etbnom no-label. */
    end.
    else disp " GERAL " @ estab.etbnom colon 20.
    update diaini colon 20
	   diafim colon 45.
	vfim = today - diaini.
	vini = today - diafim.
    update vini colon 20 vfim colon 45.
    output to printer page-size 0.
    vcontrato = "".
    vcli = 0.
    vi = 0.


    for each estab where estab.etbcod >= wetbcod and
			 estab.etbcod <= wetbcod2 no-lock:
	do vdata = vini to vfim:
	for each titulo use-index titdtven where
			titulo.empcod = 19           and
			titulo.titnat = no           and
			titulo.modcod = "CRE"        and
			titulo.titdtven = vdata      and
			titulo.etbcod = estab.etbcod and
			titulo.titsit = "LIB" no-lock break by titulo.clifor:

	    if last-of(titulo.clifor)
	    then do:
		find clipar where clipar.clicod = titulo.clifor no-error.
		if avail clipar
		then next.
		find first btitulo where btitulo.empcod = 19 and
					 btitulo.titnat = no and
					 btitulo.modcod = "CRE" and
					 btitulo.titdtven < vini and
				   /*    btitulo.etbcod = estab.etbcod and */
					 btitulo.clifor = titulo.clifor and
					 btitulo.titsit = "LIB"
					  no-lock use-index iclicod no-error.
		if avail btitulo
		then next.
		/*
		if titulo.clifor = vcli
		then next.
		*/

		find clien where clien.clicod = titulo.clifor no-lock no-error.
		if not avail clien
		then next.
		vi = vi + 1.
		assign vetbcod[vi] = titulo.etbcod
		       vtitdtven[vi] = titulo.titdtven
		       vclicod[vi] = titulo.clifor
		       vtitnum[vi] = titulo.titnum
		       vclinom[vi] = clien.clinom
		       vendereco[vi] = trim(endereco[1] + "," +
					    string(clien.numero[1])
					    + " - " +
				       (if clien.compl[1] = ?
					then ""
					else string(clien.compl[1])))
		       vcep[vi] = cep[1]
		       vcidade[vi] = cidade[1]
		       vbairro[vi] = bairro[1].

		if vi = 2
		then do:
		    put
		    "F: " at 1  vetbcod[1] "C: " at 7  vclicod[1]
					     "Ctr: " at 20 vtitnum[1]
		    "F: " at 37 vetbcod[2] "C: " at 43 vclicod[2]
					     "Ctr: " at 56 vtitnum[2] skip

		    "Bair: " at 1 vbairro[1]  vtitdtven[1] at 20
		    "bair: " at 37 vbairro[2] vtitdtven[2] at 56 skip

		    vclinom[1] at 1
		    vclinom[2] at 37 skip
		    vendereco[1] at 1
		    vendereco[2] at 37 skip
		    "CEP: " at 1 vcep[1]  vcidade[1]   at 20
		    "CEP: " at 37 vcep[2] vcidade[2]   at 56 skip(1).
		    assign vetbcod[vi] = 0
			   vtitdtven[vi] = ?
			   vclicod[vi] = 0
			   vtitnum[vi] = ""
			   vclinom[vi] = ""
			   vendereco[vi] = ""
			   vcep[vi] = ""
			   vcidade[vi] = "".
		    vi = 0.
		end.
		do transaction:
		    create clipar.
		    assign clipar.clicod = titulo.clifor.
		end.
		vcli = titulo.clifor.
	    end.
	end.
	end.
    end.
	    put
		"Fil: " at 1  vetbcod[1] vtitdtven[1] at 20
		"Fil: " at 37 vetbcod[2] vtitdtven[2] at 56 skip
		"Cta: " at 1  vclicod[1] "Ctr: " at 20 vtitnum[1]
		"Cta: " at 37 vclicod[2] "Ctr: " at 56 vtitnum[2] skip
		vclinom[1] at 1
		vclinom[2] at 37 skip
		"End: " at 1 vendereco[1]
		"End: " at 37 vendereco[2] skip
		"CEP: " at 1 vcep[1]  vcidade[1]   at 20
		"CEP: " at 37 vcep[2] vcidade[2]   at 56 skip(1).
    output  close.
    message "Emissao de Etiquetas p/ Cobranca encerrada.".
    message "Confirma listagem de clientes" update sresp.
    if not sresp
    then leave.
    output to printer page-size 66.
    put skip(3)
    "RELACAO DE CLIENTES NOTIFICADOS PARA EFEITO DE REGISTRO NO " AT 20
    "SPC (SERVICO DE PROTECAO AO CREDITO) EM CONFORMIDADE COM   " AT 20
    "O CODIGO DE DEFESA DO CONSUMIDOR." AT 20 SKIP(3).
    for each clipar no-lock:
	find clien where clien.clicod = clipar.clicod no-lock no-error.
	if not avail clien
	then next.
	display clien.clicod column-label "Codigo"
		clien.clinom column-label "Nome"
		    with frame f-cli down width 80.
    end.
    PUT SKIP(3)
	"DATA DE ENVIO       ___/___/___" AT 40 SKIP(2)
	"         _________________     " AT 40 SKIP
	"              E B C T          " AT 40.
    output close.


end.
