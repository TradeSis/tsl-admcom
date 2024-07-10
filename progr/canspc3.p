/*****************************************************************************
 Programa           : Cancela o SPC dos Clientes que estao em dia
 Programador        : Cristiano Borges Brasil
 Nome do Programa   : CanSPC.p
 Criacao            : 01/11/1996
 Ultima Alteracao   : 01/11/1996
 ***************************************************************************/
 {admcab.i}

 def var vachou             as log                                  no-undo.
 def var vv1                as integer.
 def var vdata              as date     initial today.
 def var vcidade            as char     format "x(50)".

 for each clispc:
    if clispc.dtcanc <> ?
    then next.
    find clien of clispc.
    vachou = no.
    for each estab no-lock,
	each titulo where  titulo.empcod     = wempre.empcod and
			   titulo.titnat     = no            and
			   titulo.modcod     = "CRE"         and
			   titulo.titdtven  <= today         and
			   titulo.etbcod     = estab.etbcod  and
			   titulo.clifor     = clispc.clicod and
			   titulo.titsit     = "LIB"         and
			   titulo.titnum     = string(clispc.contnum)
							    no-lock:
	  vachou = yes.
     end.

     if not vachou
     then do:
	 for each estab no-lock,
	     each titulo where  titulo.empcod     = wempre.empcod and
				titulo.titnat     = no            and
				titulo.modcod     = "CRE"         and
				titulo.titdtven  <= today         and
				titulo.etbcod     = estab.etbcod  and
				titulo.clifor     = clispc.clicod and
				titulo.titsit     = "LIB" no-lock:
	     vachou = yes.
	 end.
      end.

      if not vachou
      then do:
	    assign clispc.dtcanc  = today
		   clien.dtspc[1] = ?.
	    vv1 = vv1 + 1.
      end.

      display "Aguarde... Cancelando" vv1 "Cliente(s) no SPC..."
		      clispc.clicod
		      with no-box color red/white row 22 no-label.
      pause 0.
 end.
