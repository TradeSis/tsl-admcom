{admcab.i}
def var vdtini      like titulo.titdtemi label "Data Inicial".
def var vdtfin      like titulo.titdtemi label "Data Final  ".
def var sresumo     as   log format "Sim/Nao" initial yes.
def var i           as int format ">>>>>9".
def var v           like contrato.vltotal.
def var varquivo as char format "x(30)".

repeat with 1 down side-label width 80 row 4:
    update vdtini colon 20
	   vdtfin colon 50 with color white/cyan.

    message "Imprimir ?" update sresumo.
    if sresumo
    then do:
	
   /* Inicia o gerànciador de Impress∆o */
 if opsys <> "UNIX"
        then varquivo = "..\relat\rel-" + string(time).
        else varquivo = "/admcom/relat/rel-" + string(time).
        {mdad_l.i
        &Saida     = "value(varquivo)"
	    &Page-Size = "64"
	    &Cond-Var  = "135"
	    &Page-Line = "66"
	    &Nom-Rel   = """RELCTPZ"""
	    &Nom-Sis   = """SISTEMA CREDIARIO"""
	    &Tit-Rel   = """VENDAS A PRAZO NO PERIODO DE "" +
				string(vdtini) + "" A "" +
				string(vdtfin) "
	    &Width     = "135"
	    &Form      = "frame f-cabcab"}

	for each contrato where contrato.dtinicial >= vdtini and
				contrato.dtinicial <= vdtfin
				break by contrato.etbcod.

	    i = i + 1.
	    v = v + contrato.vltotal.

	    if last-of(contrato.etbcod)
	    then do:

		 find estab where estab.etbcod = contrato.etbcod no-error.

		 display contrato.etbcod   column-label "Estab."
			 estab.etbnom
			 i                 column-label "Nr.Contratos"  (TOTAL)
			 v                 column-label "Vlr Contratos" (TOTAL)
		 with frame f1 down.
		 i = 0.
		 v = 0.
	    end.
	end .
		output close.
	    if opsys <> "UNIX"
    then do:
        {mrod_l.i} 
    end.
    else run visurel.p (input varquivo, input "").
end.
	
    else undo,retry.

	
end.
