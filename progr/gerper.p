/*******************************************************************************
 Programador        : Cristiano Borges Brasil
 Nome do Programa   : libPer.p
 Programa           : Lista os Pagamentos e Liberados
 Criacao            : 15/07/1996.
 ultima Alteracao   : 15/07/1996.
******************************************************************************/

    {admcab.i}
    def var vsaida                  as char.
    def var vetbcod                 like estab.etbcod.
    def var vdatini                 like titulo.cxmdat.
    def var vdatfim                 like titulo.cxmdat.
    def var vdata                   like titulo.cxmdat.
    def var i                       as   int.
    def var tcob                    like titulo.titvlcob.
    def var tjur                    like titulo.titjuro.
    def var tdes                    like titulo.titdesc.
    def var vjuro                   like titulo.titjuro.
    def var vdesc                   like titulo.titdesc.
    def var vpago                   like titulo.titdesc label "Cobrado".
    def var vaber                   like titulo.titvlcob.
    def var vjurotot                like titulo.titjuro.
    def var vdesctot                like titulo.titdesc.
    def var vpagotot                like titulo.titdesc label "Cobrado".
    def var vabertot                like titulo.titvlcob.

    def buffer bestab for estab.

    def stream tela.

    update vetbcod
	   vdatini
	   vdatfim with centered 1 column color white/cyan width 80.

    find estab where estab.etbcod = vetbcod.
    display estab.etbnom no-label.

    vsaida = "..\relat\rel" + string(time).

    output to value(vsaida) page-size 64.
    form header
	 wempre.emprazsoc
		 space(6) "GERPER"   at 60
		 "Pag.: " at 71 page-number format ">>9" skip
		 "RESUMO DE TITULOS POR PERIODO"   at 1
		 vdatini format "99/99/99" at 50
		 vdatfim format "99/99/99" at 60
		 string(time,"hh:mm:ss") at 73
		 skip fill("-",80) format "x(80)" skip
		 with frame fcab no-label page-top no-box width 137.
    view frame fcab.

    assign vabertot = 0
	   vpagotot = 0
	   vdesctot = 0
	   vjurotot = 0.

    do on error undo:
	do vdata = vdatini to vdatfim:
	    output stream tela to terminal.
		disp stream tela vdata with frame fdata centered 1 down.
	    output stream tela close.

	    display estab.etbcod      column-label "Etb" format ">>9"
		    vdata column-label "Data"       format "99/99/99"
		    with frame frel width 137.
	    assign
		vaber = 0
		vpago = 0
		vdesc = 0
		vjuro = 0.

	    for each titulo where titulo.empcod   = wempre.empcod and
				  titulo.titnat   = no and
				  titulo.modcod   = "CRE" and
				  titulo.titdtven = vdata and
				  titulo.etbcod   = vetbcod
				  use-index titdtven:

		    if titulo.titsit = "PAG"
		    then next.

		    vaber = vaber + titulo.titvlcob.
		    vabertot = vabertot + titulo.titvlcob.

	    end.

	    disp vaber column-label "Valor Aberto" with frame frel
							down width 137.

	    for each titulo where titulo.empcod   = wempre.empcod and
				  titulo.titnat   = no and
				  titulo.modcod   = "CRE" and
				  titulo.titdtpag = vdata and
				  titulo.etbcod   = vetbcod and
				  titulo.clifor   > 1
				  use-index titdtpag:


		if titulo.titpar = 0
		then next.

		assign vpago = vpago + titulo.titvlpag
			      - titulo.titjuro + titulo.titdesc
		       vjuro = vjuro + if titulo.titjuro = titulo.titdesc
				       then 0
				       else titulo.titjuro
		       vdesc = vdesc + if titulo.titjuro = titulo.titdesc
				       then 0
				       else titulo.titdesc .

		assign vpagotot = vpagotot + titulo.titvlpag
			      - titulo.titjuro + titulo.titdesc
		       vjurotot = vjurotot + if titulo.titjuro = titulo.titdesc
				       then 0
				       else titulo.titjuro
		       vdesctot = vdesctot + if titulo.titjuro = titulo.titdesc
				       then 0
				       else titulo.titdesc .
	    end.

	    disp vpago column-label "Valor Pago"
		 vjuro column-label "Valor Juro"
		 vdesc column-label "Valor Desconto" with frame frel.

	    down with frame frel.

	end.

	disp skip(2) vabertot label "TOTAL ABERTO"
		     vpagotot label "TOTAL PAGO"
		     vjurotot label "TOTAL JURO"
		     vdesctot label "TOTAL DESCONTO"
		     with frame ftot side-labels centered width 137.

    end.
    output close.

    /*
    message "Deseja Listar o arquivo" vsaida "?" update sresp.
    if sresp
    then
    */

    dos silent value("type " + vsaida + " > prn").
