/*--------------------------------------------Etiquetas Butique peao----------*/
/* admcom/cp/peaoetiq.p                                                       */
/*----------------------------------------------------------------------------*/

{admcab.i NEW}

def buffer btitulo for titulo.
def buffer ctitulo for titulo.

def var vok as log.

def var vend as char format "x(23)".
def var vnum as i    format ">>>9".
def var vcom as char format "x(4)".

def var vsexo like clien.sexo.
def var vidadeini as i format "99" label "Idade Inicial".
def var vidadefim as i format "99" label "Idade   Final".
def var vatraso as i format ">>9" label "Atraso".
def var vdias as i.

def var vini as date format "99/99/99" label "Dt.Ini.Ult.Comp.".
def var vi as int.
def var vfim as date format "99/99/99" label "Dt.Fin.Ult.Comp.".
def var diaini as int format ">>9" label "Dias Inicial".
def var diafim as int format ">>9" label "Dias Final".
def var vtotal      as char  extent 8 format "x(10)".
def var vcliente    LIKE TITULO.CLIFOR.
def var vbairro     like clien.bairro extent 4.
def var vcontrato like titulo.titnum.
def var vclicod like clien.clicod  extent 4.
def var vclinom like clien.clinom format "x(25)"  extent 4.
def var vtitpar like titulo.titpar extent 4.
def var vtitnum like titulo.titnum format "x(7)" extent 4.
def var vnumero like clien.numero  extent 4 .
def var vendereco like clien.endereco format "x(32)" extent 4 .
def var vcep      like clien.cep extent 4 .
def var vcompl  like clien.compl extent 4.
def var vetbcod like titulo.etbcod extent 4 .
def var vfone   like clien.fone extent 4.
def var vcidade like clien.cidade format "x(12)" extent 4.
def var vtitvlpag like titulo.titvlpag extent 4 .
def var vtitdtven like titulo.titdtven extent 4 .
def var n-etiq  as int.
def var wetbcod like estab.etbcod.
def var vquita as log format "Sim/Nao" label "Quitados".

def var i as i label "Quantidade".

def var t as i.
def var v as i.

do with width 80 title " Emissao de Etiquetas de Aviso " frame f1 side-label
		1 column
		row 4:

    update wetbcod .

    update vini
	   vfim.

    update vquita.

    update vatraso.

    vsexo = ?.
    update vsexo .

    vidadeini = 0.
    vidadefim = 0.
    update vidadeini
	   vidadefim.

    /*
    i = 0.
    for each contrato use-index mala
		      where contrato.etbcod = wetbcod  and
			    contrato.dtinicial >= vini and
			    contrato.dtinicial <= vfim no-lock
						      break by(contrato.clicod):

	if first-of(contrato.clicod)
	then do:


	    find last titulo where titulo.clifor = contrato.clicod no-lock
								       no-error.
	    if not avail titulo then next.


	    if vquita = yes
	    then do:
		vok = yes.
		for each ctitulo where ctitulo.clifor = contrato.clicod:
		    if titulo.titsit = "LIB"
		    then do:
			vok = no.
		    end.
		end.
	    end.
	    if vok = no
	    then next.

	    vok = yes.
	    for each btitulo where btitulo.clifor = contrato.clicod:

		if btitulo.titdtemi < vini and
		   btitulo.titdtemi > vfim
		then vok = no.

		vdias = 0.

		if btitulo.titsit = "PAG"
		then vdias = btitulo.titdtpag - btitulo.titdtven.
		else vdias = today - btitulo.titdtven.

		if vdias > vatraso
		then vok = no.

	    end.

	    if vok = no
	    then next.

	    i = i + 1.

	    find clien where clien.clicod = contrato.clicod no-lock no-error.
	    if not avail clien
	    then next.

	    if vsexo <> ?
	    then if clien.sexo <> vsexo
		 then next.

	    if (year(today) - year(clien.dtnasc)) < vidadeini and
	       (year(today) - year(clien.dtnasc)) > vidadefim
	    then next.

	    disp clien.clicod i with 1 down centered.
	    pause 0.

	end.

    end.
    */

    sresp = yes.
    message "Comfirma Impressao de Mala Direta ?" update sresp.
    if sresp = no
    then undo,retry.


    {mdadmcab.i
	&Saida     = "printer"
	&Page-Size = "64"
	&Cond-Var  = "140"
	&Page-Line = "66"
	&Nom-Rel   = ""MALA05""
	&Nom-Sis   = """SISTEMA DE CREDIARIO"""
	&Tit-Rel   = """MALA DIRETA"""
	&Width     = "140"
	&Form      = "frame f-cabcab"}

    for each contrato where contrato.etbcod = wetbcod  and
			    contrato.dtinicial >= vini and
			    contrato.dtinicial <= vfim no-lock
					       break by(contrato.clicod):

	if first-of(contrato.clicod)
	then do:

	    find last titulo where titulo.clifor = contrato.clicod no-lock
								       no-error.
	    if not avail titulo then next.

	    if titulo.titdtemi < vini and
	       titulo.titdtemi > vfim
	    then next.

	    /*
	    if vquita = yes
	    then do:
		vok = yes.
		for each ctitulo where ctitulo.clifor = contrato.clicod:
		    if titulo.titsit = "LIB"
		    then do:
			vok = no.
		    end.
		end.
	    end.
	    if vok = no
	    then next.
	    */

	    vok = yes.
	    for each btitulo where btitulo.clifor = contrato.clicod:

		if btitulo.titdtemi < vini and
		   btitulo.titdtemi > vfim
		then vok = no.

		vdias = 0.

		if btitulo.titsit = "PAG"
		then vdias = btitulo.titdtpag - btitulo.titdtven.
		else vdias = today - btitulo.titdtven.

		if vdias > vatraso
		then vok = no.

	    end.

	    if vok = no
	    then next.

	    find clien where clien.clicod = contrato.clicod no-lock no-error.
	    if not avail clien
	    then next.

	    if vsexo <> ?
	    then if clien.sexo <> vsexo
		 then next.

	    if (year(today) - year(clien.dtnasc)) < vidadeini and
	       (year(today) - year(clien.dtnasc)) > vidadefim
	    then next.

	    disp
	    clien.clinom column-label "Nome"
	    trim(clien.endereco[1] + "," + string(clien.numero[1])
				       + " - " +
				       (if clien.compl[1] = ?
					then ""
					else string(clien.compl[1])))
					format "x(30)"
	    clien.bairro[1] column-label "bairro"
	    cidade[1]       column-label "Cidade"
	    cep[1] column-label "CEP" with frame f-1 down width 140.

	end.
    end.
    output  close.

    /*
    message "Deseja imprimir relatorio" update sresp.
    if sresp
    then dos silent type ..\relat\mala.rel > prn.
    message "Emissao de Etiquetas p/ Cobranca encerrada.".
    */

end.
