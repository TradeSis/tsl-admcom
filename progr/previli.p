/*----------------------------------------------------------------------------*/
/* previli.p                                     Titulo Previsao - Listagem   */
/*                                                                            */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var    wperdes as dec format ">9.99 %" label "Perc. Desc.".
def var    wperjur as dec format ">9.99 %" label "Perc. Juros".
def var    wdti like titulo.titdtven label "Periodo".
def var    wdtf like titulo.titdtven.
def var    vlrpg like titulo.titvlcob
				label "A Pagar"   format ">>>,>>>,>>>,>>9.99".
def var    vlrrc like titulo.titvlcob
				label "A Receber" format ">>>,>>>,>>>,>>9.99".
def var    vlrsl like titulo.titvlcob
				label "Saldo"     format "->>,>>>,>>>,>>9.99".
def var    totpg like titulo.titvlcob
				label "A Pagar"   format ">>>,>>>,>>>,>>9.99".
def var    totrc like titulo.titvlcob
				label "A Receber" format ">>>,>>>,>>>,>>9.99".
def var    totsl like titulo.titvlcob
				label "Saldo"     format "->>,>>>,>>>,>>9.99".
def var    totti as integer format ">>>>>9".
def var    gerpg like titulo.titvlcob  format ">>>,>>>,>>>,>>9.99".
def var    gerrc like titulo.titvlcob  format ">>>,>>>,>>>,>>9.99".
def var    gersl like titulo.titvlcob  format "->>,>>>,>>>,>>9.99".
def var    gerti as integer format ">>>>>9".
def var    titdd as integer format ">>>>>9" label "Nr.Tit".
def buffer wtitulo for titulo.
def var vetbnom      like estab.etbnom.
def var wchave as cha format " 999999  xxxxxxxx  999 "
		      label  "CLI/FOR  Num.Tit.  Par.".

form titulo.etbcod colon 18
	validate(true,"")
     estab.etbnom  no-label colon 30
     wdti          colon 18  " A"
     wdtf          colon 35  no-label
		   with side-labels width 80 frame f1.

wdti = today.
wdtf = wdti + 30.
repeat with frame f1:
    clear frame f1 all.
    disp "" @ titulo.etbcod.
    prompt-for titulo.etbcod .
    if input titulo.etbcod <> ""
       then do:
	       find estab where
			     estab.etbcod  = input titulo.etbcod.
	       display  etbnom.
	       assign vetbnom = string(estab.etbcod) + " " + estab.etbnom.
       end.
       else do:
	    disp "Geral" @ etbnom .
	    vetbnom = "Geral".
	end.
    update wdti validate(input wdti <> ?,
			"Data deve ser Informada")
			 with frame f1.

    update wdtf validate(input wdtf > input wdti,
			 "Data Invalida")
			 with frame f1.

    {confir.i 1 "Listagem Previsao"}
    {mdadmcab.i
	&Saida     = "printer"
	&Page-Size = "64"
	&Cond-Var  = "120"
	&Page-Line = "66"
	&Nom-Rel   = ""PREVILI""
	&Nom-Sis   = """SISTEMA FINANCEIRO"""
	&Tit-Rel   = """PREVISAO FINANCEIRA  -  PERIODO : "" +
			    string(wdti,""99/99/9999"") + "" A "" +
			    string(wdtf,""99/99/9999"") "
	&Width     = "120"
	&Form      = "frame f-cabcab"}

    form titulo.titdtven column-label "Vencim." format "99/99/99"
	 space(3)
	 titulo.modcod
	 space(3)
	 titdd
	 vlrpg
	 vlrrc
	 vlrsl with frame fdet width 80  down no-box.

    form "Total" colon 12
	 totti
	 totpg
	 totrc
	 totsl with frame ftot width 80 no-label no-box.

    form "Total Geral" colon 6
	 gerti
	 gerpg
	 gerrc
	 gersl with frame fger width 80 no-label no-box.

    form header
	  "estab : " at 01
	  vetbnom no-label skip(1)
	  with frame fcab no-box width 80.
    view frame fcab.

    for each titulo where empcod = 19 and
			  titnat = yes and
			  titdtven >= input wdti        and
			  titdtven <= input wdtf        and
			  titsit   <> "BLO"             and
			( if input titulo.etbcod = 0
			     then true
			     else titulo.etbcod = input titulo.etbcod )
			  break by month(titdtven) by titdtven by modcod:

	titdd = titdd + 1.

	if titnat
	   then do:
		   vlrpg = vlrpg + titvlcob.
	   end.
	   else do:
		   vlrrc = vlrrc + titvlcob.
	   end.

	if last-of(titdtven) or
	   last-of(modcod)
	   then do:
		   vlrsl = vlrrc - vlrpg.
		   display titdtven
			   modcod
			   titdd
			   vlrpg
			   vlrrc
			   vlrsl with frame fdet.
		   down with frame fdet.
		   totpg = totpg + vlrpg.
		   totrc = totrc + vlrrc.
		   totsl = totrc - totpg.
		   totti = totti + titdd.
		   vlrpg = 0.
		   vlrrc = 0.
		   titdd = 0.
	   end.

	if last-of (month(titdtven))
	   then do:
		   put skip
		       space(11)
		       fill("-",69) format "x(69)" skip.
		   display totti
			   totpg
			   totrc
			   totsl with frame ftot.
		   put skip
		       space(11)
		       fill("-",69) format "x(69)" skip(1).
		   gerti = gerti + totti.
		   gerpg = gerpg + totpg.
		   gerrc = gerrc + totrc.
		   gersl = gersl + totsl.
		   totpg = 0.
		   totrc = 0.
		   totsl = 0.
		   totti = 0.
	   end.
    end.
    put skip fill("-",80) format "x(80)" skip.
    display gerti
	    gerpg
	    gerrc
	    gersl with frame fger.
    output close.
end.
