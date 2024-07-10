/*                                                             relcicm.p
*               Relatorio de Historico de Pordutos
*/

{admcab.i}


DEF VAR i AS i FORMAT "9".
def var vclacod like clase.clacod.
def var vclanom like clase.clanom.
def var estqtd  as dec.
def var estval  as dec.
def var venqtd  as dec.
def var venval  as dec.
def var mark    as dec.

DEF VAR vproini LIKE produ.procod LABEL "Produto Inicial".
DEF VAR vprofin LIKE produ.procod LABEL "Produto Final".

def var vdtini as date label "Data Inicial".
def var vdtfin as date label "Data Final".

def var vven1 as dec.
def var vven2 as dec.

def var vqtd as i.
def var vcompras    as i .
def var venhiestfl1 as i.
def var venvaltot1  as dec.
def var venhiestfl2 as i.
def var venvaltot2  as dec.
def var venvtotqtd  as i.
def var venvvaltot  as dec.
def var marksem     as dec.
def var markcom     as dec.
def var vcober      as i.
def var vgiro       as dec.
def var vetcnom     like estac.etcnom.

def var vetccod like estac.etccod.
DEF VAR vano AS i FORMAT ">>>>".
DEF VAR vmes AS i FORMAT "99".
DEF VAR hiesttot AS DEC.
DEF VAR venhiesttot AS DEC.

DEF VAR hiestfl1 LIKE hiest.hiestf.
DEF VAR hiestfl2 LIKE hiest.hiestf.
DEF VAR totestcus LIKE estoq.estcusto.
DEF VAR totgerfl1 LIKE estoq.estcusto.
DEF VAR totgerfl2 LIKE estoq.estvenda.
DEF VAR tothiestfl1 LIKE hiest.hiestf.
DEF VAR tothiestfl2 LIKE hiest.hiestf.
DEF VAR tothiegerfl1 LIKE hiest.hiestf.
DEF VAR tothiegerfl2 LIKE hiest.hiestf.
DEF VAR valhiegerfl1 LIKE estoq.estcusto.
DEF VAR valhiegerfl2 LIKE estoq.estcusto.
DEF VAR TOTSUB1 LIKE HIEST.HIESTF.
DEF VAR TOTSUB2 LIKE HIEST.HIESTF.
DEF VAR TOTGERSUB1 LIKE ESTOQ.ESTCUSTO.
DEF VAR TOTGERSUB2 LIKE ESTOQ.ESTCUSTO.
DEF VAR TOTSUB LIKE HIEST.HIESTF.
DEF VAR TOTALSUB LIKE ESTOQ.ESTCUSTO.
DEF VAR HIESTSUB LIKE HIEST.HIESTF.
DEF VAR tothiegeralfl1 LIKE hiest.hiestf.
DEF VAR tothiegeralfl2 LIKE hiest.hiestf.
DEF VAR valhiegeralfl1 LIKE estoq.estcusto.
DEF VAR valhiegeralfl2 LIKE estoq.estcusto.
DEF VAR valtot1 LIKE estoq.estcusto.
DEF VAR valtot2 LIKE estoq.estcusto.
DEF VAR vtotqtd LIKE hiest.hiestf.
DEF VAR vvaltot LIKE estoq.estcusto.
DEF VAR totger  LIKE hiest.hiestf.
DEF VAR hiestger LIKE estoq.estcusto.

DEF VAR ventotger  LIKE hiest.hiestf.
DEF VAR venhiestger LIKE estoq.estcusto.
DEF VAR ventotestcus LIKE estoq.estcusto.
DEF VAR ventotgerfl1 LIKE estoq.estcusto.
DEF VAR ventotgerfl2 LIKE estoq.estvenda.
DEF VAR ventothiestfl1 LIKE hiest.hiestf.
DEF VAR ventothiestfl2 LIKE hiest.hiestf.
DEF VAR ventothiegerfl1 LIKE hiest.hiestf.
DEF VAR ventothiegerfl2 LIKE hiest.hiestf.
DEF VAR venvalhiegerfl1 LIKE estoq.estcusto.
DEF VAR venvalhiegerfl2 LIKE estoq.estcusto.
DEF VAR venTOTSUB1 LIKE HIEST.HIESTF.
DEF VAR venTOTSUB2 LIKE HIEST.HIESTF.
DEF VAR venTOTGERSUB1 LIKE ESTOQ.ESTCUSTO.
DEF VAR venTOTGERSUB2 LIKE ESTOQ.ESTCUSTO.
DEF VAR venTOTSUB LIKE HIEST.HIESTF.
DEF VAR venTOTALSUB LIKE ESTOQ.ESTCUSTO.
DEF VAR venHIESTSUB LIKE HIEST.HIESTF.
DEF VAR ventothiegeralfl1 LIKE hiest.hiestf.
DEF VAR ventothiegeralfl2 LIKE hiest.hiestf.
DEF VAR venvalhiegeralfl1 LIKE estoq.estcusto.
DEF VAR venvalhiegeralfl2 LIKE estoq.estcusto.
def var vcla like clase.clacod.

UPDATE
    vclaCOD
    vdtini
    vdtfin
  WITH SIDE-LABEL CENTERED FRAME f1
  ROW 5 COLOR black/cyan.

FIND clase WHERE clase.claCOD = VclaCOD.
vclanom = clase.clanom.

/*if opsys = "MSDOS"
then
varqsai = "..\impress\relcicm" + string(time).
else
varqsai = "../impress/relcicm" + string(time).*/



{mdadmcab.i
  &Saida     = "printer" /*"value(varqsai)"*/
  &Page-Size = "64"
  &Cond-Var  = "160"
  &Page-Line = "66"
  &Nom-Rel   = ""GERENC""
  &Nom-Sis   = """SISTEMA COMERCIAL - ESTOQ"""
  &Tit-Rel   = """ACOMPANHAMENTO ESTOQUE/VENDA/GIRO "" + "" ESTACAO "" +
		 vetcnom +
		"" - Periodo "" + string(vdtini) + ""  a "" +
		    string(vdtfin) "
  &Width     = "160"
  &Form      = "frame f-cabcab"}


put "E S T O Q U E" AT 99
    "V E N D A S  " AT 118.

FOR EACH produ WHERE produ.clacod = vclacod AND
		     PRODU.FABCOD > 0
		     BY PRODU.FABCOD
		     BY produ.procod.
    ESTQTD = 0.
    ESTVAL = 0.
    VENQTD = 0.
    VENVAL = 0.

    FIND fabri OF produ NO-LOCK.

    FIND FIRST ESTOQ WHERE ESTOQ.PROCOD = PRODU.PROCOD NO-LOCK NO-ERROR.
    IF NOT AVAIL ESTOQ
    THEN NEXT.

    /******************** QUANTIDADE DE ENTRADAS ********************/
    vcompras = 0.
    for each movim where movim.procod = produ.procod and
			 movim.movtdc = 4 no-lock:
	vcompras = vcompras + movim.movqtm.
    end.

    /******************** QUANTIDADE DE ESTOQUE *******************/

    for each estoq WHERE estoq.procod = produ.procod NO-LOCK.

	estqtd = estqtd + estoq.estatual.
	estval = estval + (estoq.estatual + estoq.estcusto).

    end.

    /******************** QUANTIDADE VENDIDA ***********************/

    for each movim where movim.procod = produ.procod and
			 movim.movtdc = 5 and
			 movim.movdat >= vdtini and
			 movim.movdat <= vdtfin
			 no-lock:
	venqtd = venqtd + movim.movqtm.
	venval = venval + (movim.movqtm * movim.movpc).
    end.

    /********************  MARKUP *********************/

    FIND FIRST ESTOQ WHERE ESTOQ.PROCOD = PRODU.PROCOD NO-LOCK NO-ERROR.
    IF NOT AVAIL ESTOQ
    THEN NEXT.
    mark = (venval / venqtd) / estoq.estcusto.

    if mark = ?
    then mark = 0.

    /********************* COBERTURA ******************/

    vcober = (estqtd / (venqtd / (vdtfin - vdtini))).
    if vcober = ? or vcober < 0
    then vcober = 0.

    /********************* GIRO **********************/

    vgiro = ((venqtd / (estqtd + venqtd) * 100)).
    if vgiro = ?
    then vgiro = 0.

    IF (estqtd > 0 OR
	venqtd > 0)
    THEN DO:
	FIND FIRST ESTOQ WHERE ESTOQ.PROCOD = PRODU.PROCOD NO-LOCK NO-ERROR.
	IF NOT AVAIL ESTOQ
	THEN NEXT.
	disp
      produ.procod   column-label "Cod"
      produ.pronom   column-label "Produto"     format "x(45)"
      fabri.fabfant  column-label "Fabricante"  format "x(15)"
      vcompras       column-label "Q.E."        format ">>>9" (TOTAL)
      estoq.estcusto column-label "P.Custo"     format ">>,>>9.99"
      estoq.estvenda column-label "P.Venda"     format ">>,>>9.99"
      estqtd         column-label "Est.Qtd"      format "->>>9" (TOTAL)
      estval         column-label "Est.Val"     format "->>>,>>9.99" (TOTAL)
      venqtd         column-label "Ven.Qtd"      format "->>>9" (TOTAL)
      venval         column-label "Ven.Val"     format "->>>,>>9.99" (TOTAL)
      mark           column-label "MK."       format ">9.99"    (AVERAGE)
      vcober         column-label "COB"         format ">>>9"   (AVERAGE)
      vgiro          column-label "Giro"        format "->>9.99%" (AVERAGE)
      skip
	with frame f-prodx width 170 down.
    END.

end.

OUTPUT CLOSE.
