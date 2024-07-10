{admcab.i}
def var vv          as integer label "Contador".
def var vrel        as char.
def stream tela.

output stream tela to terminal.

prompt-for estab.regcod.
find regiao where regiao.regcod = input estab.regcod no-lock no-error.
if avail regiao
then display stream tela regiao.regnom no-label
		with side-label width 80 color white/cyan row 4.


vrel = "..\relat\" + string(time) + ".rel".
output to value(vrel).

for each estab where estab.regcod = input estab.regcod:
	for each titulo where titulo.empcod = 19 and
			      titulo.titnat = no and
			      titulo.modcod = "CRE" and
			      titulo.etbcod = estab.etbcod:

	    find clien where clien.clicod = titulo.clifor no-error.
	    if not avail clien then
		disp titulo.titnum titulo.titpar titulo.clifor.
	    else do:
		vv = vv + 1.
		display stream tela vv
			estab.etbcod
			titulo.clifor with 1 column centered row 10 color
			white/cyan frame f-conta.
		pause 0.
		next.
	    end.
	end.
end.
output to close.

message "Confirma a Impressao do Arquivo " vrel "?" update sresp.
if sresp
then dos silent value("type " + varquivo + " > prn").
