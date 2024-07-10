{admcab.i}
def var vregcod         like regiao.regcod.
def var vtot            as integer.
def var vclicod         like clien.clicod.
def var vcol            as integer          initial 75.
def var vachou          as log.

def stream tela.

output stream tela to terminal.

do on error undo, retry
    with centered width 80 color white/cyan side-label row 4
	 title " LISTAGEM DE CLIENTES ORDEM ALFABETICA ".
    update vregcod.
    find regiao where regiao.regcod = vregcod no-lock no-error.
    if not avail regiao
    then do:
	bell.
	message "Regiao nao Cadastrado !!".
	pause.
	undo, retry.
    end.
    display regiao.regnom no-label.
end.

message "Gerando o relatorio".

varquivo = "..\relat\" + STRING(TIME) + ".REL".
{mdadmcab.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "140"
    &Page-Line = "66"
    &Nom-Rel   = """CLINOMRE"""
    &Nom-Sis   = """SISTEMA CREDIARIO"""
    &Tit-Rel   = """LISTAGEM ALFABETICA DE CLIENTES POR REGIAO "" +
		    "" - "" + string(vregcod) "
    &Width     = "140"
    &Form      = "frame f-cab"}

put "Fil."                 at   1
    "Nome do Cliente"      at   6
    "Codigo"               at  45
    "Dt.Nasc"              at  55
    "Fil."                 at  71
    "Nome do Cliente"      at  76
    "Codigo"               at 115
    "Dt.Nasc"              at 125 skip.

put fill("-",140) format "x(140)".

for each clien no-lock break by clien.clinom:
    vachou = no.

    for each titulo where titulo.clifor = clien.clicod no-lock:
	find estab where estab.etbcod = titulo.etbcod no-lock.

	if estab.regcod <> vregcod
	then next.

	if titulo.titsit = "LIB"
	then do:
	    vachou = yes.
	    leave.
	end.

	if titulo.titdtemi >= 01/01/1994
	then do:
	    vachou = yes.
	    leave.
	end.
    end.


    if vachou
    then do:
	vtot = vtot + 1.
	display stream tela estab.etbcod
			    clien.clinom
			    vtot            label "Total de Clientes"
			    with frame cbb 1 column color
			    white/red centered row 9.
	pause 0.

	if vcol = 75
	then vcol = 0.
	else vcol = 75.

	put estab.etbcod                      at vcol + 1
	    string(clien.clinom,"x(35)") at vcol + 6  format "x(35)"
	    clien.clicod                 at vcol + 45
	    clien.dtnasc                 at vcol + 55.

    end.
end.

display skip(2) "TOTAL DE CLIENTES :" vtot with frame ff no-labels no-box.
output close.
bell.
bell.
message "Listar na Impressora o Arquivo " varquivo "?" update sresp.
if sresp
then dos silent value("type " + varquivo + " > prn").
