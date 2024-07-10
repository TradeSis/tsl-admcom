{admcab.i}
def stream stela.
def buffer btitulo for titulo.
def var vok as log.
def var vetbcod like estab.etbcod.
def var varquivo as char format "x(20)".
repeat:
    update vetbcod with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
    varquivo = "..\relat\inat" + string(day(today)).

    {mdadmcab.i
	&Saida     = "value(varquivo)"
	&Page-Size = "64"
	&Cond-Var  = "130"
	&Page-Line = "66"
	&Nom-Rel   = ""INATIVO""
	&Nom-Sis   = """SISTEMA DE CREDIARIO"""
	&Tit-Rel   = """CLIENTES INATIVOS FILIAL "" +
				  string(vetbcod,"">>9"")"
	&Width     = "130"
	&Form      = "frame f-cabcab"}
    for each titulo where titulo.empcod = 19 and
			  titulo.titnat = no and
			  titulo.modcod = "CRE" and
			  titulo.etbcod = vetbcod
				    no-lock break by titulo.clifor.
	if titulo.clifor = 1
	then next.

	if first-of(titulo.clifor)
	then do:
	    vok = no.
	    for each btitulo where btitulo.clifor = titulo.clifor no-lock:
		if btitulo.titsit = "LIB"
		then do:
		    vok = no.
		    leave.
		end.
		else vok = yes.
	    end.
	    if vok
	    then do:
		find clien where clien.clicod = titulo.clifor no-lock no-error.
		if not avail clien
		then next.
		display clien.clicod
			clien.clinom with frame f2 down width 80.
		output stream stela to terminal.
		    display stream stela
			    clien.clicod
			    clien.clinom with frame f3
				    1 down centered color white/cyan. pause 0.
		output stream stela close.
	    end.
	end.
    end.
    output close.
    dos silent value("type " + varquivo + "  > prn").
end.
