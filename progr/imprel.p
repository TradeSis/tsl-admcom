/******************************************************************************
 Programa           : Relatorio de Posicao de Importacao
 Nome Programa      : ImpRel.p
 Programador        : Cristiano Borges Brasil
 Criacao            : 24/06/1996
 Alteracao          : 24/06/1996
 *****************************************************************************/

 {admcab.i}

 def input parameter par-dtini  as date.
 def input parameter par-dtfin  as date.
 def input parameter par-etbcod like estab.etbcod.

 def var movime                 as char format "x(15)" label "Modalidade".
 def var varq                   as char.

 find estab where estab.etbcod = par-etbcod.

 varq = "..\relat\" + STRING(TIME) + ".REL".

 {mdadmcab.i &Saida     = "value(varq)"
	     &Page-Size = "64"
	     &Cond-Var  = "160"
	     &Page-Line = "66"
	     &Nom-Rel   = ""ImpRel""
	     &Nom-Sis   = """SISTEMA CREDIARIO"""
	     &Tit-Rel   = """LISTAGEM DE POSICAO DE IMPORTACAO DA"" +
			  "" LOJA "" + string(estab.etbcod) + "" - "" +
				       estab.etbnom  + "" PERIODO DE "" +
				       string(par-dtini) + "" ATE "" +
				       string(par-dtfin) "
	     &Width     = "160"
	     &Form      = "frame f-cabcab"}

 for each salexporta where salexporta.saldt >= par-dtini        and
			   salexporta.saldt <= par-dtfin:
	if salexporta.modcod = "TOT"
	then next.

	if salexporta.modcod = "CRE"
	then movime = "Prestacoes".
	if salexporta.modcod = "VDV"
	then movime = "Venda a Vista".
	if salexporta.modcod = "VDP"
	then movime = "Venda a Prazo".
	if salexporta.modcod = "ENT"
	then movime = "Entradas".
	if salexporta.modcod = "JUR"
	then movime = "Juros".
	if salexporta.modcod = "DES"
	then movime = "Descontos".
	if salexporta.modcod = "JUR" and
	   salexporta.moecod = "PRE"
	then movime = "Juros Pre'".
	if salexporta.modcod = "CRE" and
	   salexporta.moecod = "PRE"
	then movime = "Pre'-datados".

	display salexporta.etbcod
		salexporta.cxacod
		movime
		salexporta.modcod
		salexporta.moecod
		salexporta.saldt
		salexporta.salexp(total)
		salexporta.salimp(total)
		salexporta.salqtd(total) with width 160.
 end.

 display skip(03)
	 fill("-",40) format "x(40)"
	 skip
	 "Assinatura Gerente CPD" with centered no-labels.

 output close.

 message "Imprime o Arquivo" varq "?" update sresp.
 if sresp
 then dos silent value("type " + varq + " > prn").
