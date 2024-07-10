/*
Programa:  nf-tit-por-cliente.p
Propósito: Listar notas e titulos do cliente
Autor:     Lucas Leote
Data:      Setembro/2016
*/

{admcab.i}

def var vclicod like clien.clicod.
def var varquivo as char.

/* Formulario */
form vclicod label "Codigo"

with frame f01 title "Informe os dados abaixo:" with 1 col width 80.

/* Atualiza variaveis */
update vclicod
with frame f01.

/*hide frame f01 no-pause.*/

/* -------------------------------------------------------------------------------------- */

/* Inicia o gerenciador de Impressao*/
if opsys = "UNIX" then
	varquivo = "/admcom/relat/nf-tit-por-cliente." + string(time).
else
	varquivo = "l:\relat\nf-tit-por-cliente" + string(day(today)).
      
{
mdad.i
&Saida     = "value(varquivo)"
&Page-Size = "64"
&Cond-Var  = "135"
&Page-Line = "66"
&Nom-Rel   = ""nf-tit-por-cliente""
&Nom-Sis   = """SISTEMA GERENCIAL"""
&Tit-Rel   = """NOTAS E TITULOS POR CLIENTE"""
&Width     = "135"
&Form      = "frame f-cabcab"
}

find first clien where clicod = vclicod no-lock no-error.

disp clicod clinom ciccgc dtcad skip(2) with width 200.

put "------------------------- N O T A S  A  V I S T A -------------------------".

for each plani where movtdc = 5 and desti = vclicod and (modcod = "VVI" or modcod = "FIN") no-lock by pladat desc.
	disp etbcod numero format ">>>>>>>9" serie pladat platot(total) modcod.
end.

put skip(2) "------------------------- N O T A S  A  P R A Z O -------------------------".

for each plani where movtdc = 5 and desti = vclicod and modcod <> "VVI" and modcod <> "FIN" no-lock by pladat desc.
	disp etbcod numero format ">>>>>>>9" serie pladat platot(total) modcod.
end.

put skip(2) "------------------------- T I T U L O S -------------------------".

for each titulo where clifor = vclicod and
	empcod = 19 and 
	titnat = no and 
	(modcod = "VVI" or modcod = "CRE" or modcod = "FIN" or modcod = "CP0" or modcod = "CP1")
	no-lock by titdtven desc.
	disp etbcod titnum titpar titvlcob(total) titvlpag(total) titdtemi titdtpag titdtven titsit modcod with width 200.
end.

output close.

if opsys = "UNIX" then do:
	run visurel.p (input varquivo, input "NOTAS E TITULOS POR CLIENTE").
end.
else do:
	{mrod.i}
end.

/* Finaliza o gerenciador de Impressao */
message "RELATORIO GERADO!" view-as alert-box.