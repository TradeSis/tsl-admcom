{admcab.i}
def var vtotal      like titulo.titvlcob.
def var vacum       like titulo.titvlcob.
def stream tela.

output stream tela to terminal.

update vtotal label "Valor Total"
       with side-label 1 column
       width 80.

varquivo = "..\relat\" + string(time,"999999") + ".rel".
{mdadmcab.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "100"
    &Page-Line = "66"
    &Nom-Rel   = """DREB002"""
    &Nom-Sis   = """SISTEMA CREDIARIO"""
    &Tit-Rel   = """RELATORIO DE DEVEDORES"""
    &Width     = "100"
    &Form      = "frame f-cab"}

for each titulo where titulo.empcod = wempre.empcod and
		      titulo.titnat = no            and
		      titulo.modcod = "CRE"         and
		      titulo.titsit = "LIB"
		      no-lock by titulo.clifor descending:

    vacum = vacum + titulo.titvlcob.
    if vacum > vtotal
    then leave.

    find clien where clien.clicod = titulo.clifor no-lock no-error.
    if avail clien
    then do:
	display stream tela titulo.titnum
			    clien.clinom
			    titulo.titvlcob
			    vacum with centered color white/cyan
			    row 8 1 column 1 down.
	pause 0.

	display titulo.titnum       column-label "Contrato"
		clien.clinom        column-label "Nome"
		titulo.titvlcob     column-label "Valor Devido" (total)
		with frame flin no-box width 160 down.
	down with frame flin.
    end.
    else vacum = vacum - titulo.titvlcob.
end.

output close.

message "Deseja Imprimir ?" update sresp.
if sresp
then dos silent value("type " + varquivo + " > prn").
