 {admcab.i}

 def var varq as char.
 find last pedid.

 varq = "..\relat\" + STRING(TIME) + ".REL".
 find estab where estab.etbcod = pedid.etbcod.
 {mdadmcab.i &Saida     = "value(varq)"
	     &Page-Size = "64"
	     &Cond-Var  = "160"
	     &Page-Line = "66"
	     &Nom-Rel   = ""ImpRel""
	     &Nom-Sis   = """SISTEMA CREDIARIO"""
	     &Tit-Rel   = """LISTAGEM DE PEDIDO"" +
			  "" LOJA "" + string(PEDID.etbcod) + "" - "" +
				       estab.etbnom"
	     &Width     = "160"
	     &Form      = "frame f-cabcab"}

 for each liped of pedid no-lock:
    find produ where produ.procod = liped.procod no-lock.
    display liped.lipqtd
	    produ.procod
	    produ.pronom
	    liped.lipcor
		with frame f-ped width 160 no-box down.
 end.

 display skip(03)
	 fill("-",40) format "x(20)"
	 skip
	 "Data Recebimento Pedido" with centered no-labels.

 output close.

 message "Imprime o Arquivo" varq "?" update sresp.
 if sresp
 then dos silent value("type " + varq + " > prn").
