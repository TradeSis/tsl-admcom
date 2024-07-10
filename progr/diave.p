{admcab.i}
define variable mes as integer format "99" label "Mes Processo".
define variable ano as integer format "9999" label "Ano Processo".
define variable livnum as integer format ">>>9" label "Numero Livro".
define variable pagini as integer format ">>>>9" label "Pagina Inicial"
       initial 2.
do with 1 column width 80 frame f1:
 update ano mes livnum pagini.
end.
message "Processando Diario Auxiliar, aguarde.".
output to printer.
put unformatted chr(15).
output close.
output to printer page-size 60.
define variable w01 like contrato.vltotal.
define variable w001 like contrato.vltotal.
define variable clinommes as character format "x(9)" extent 12
       initial ["Janeiro","Fevereiro","Marco","Abril","Maio","Junho",
		"Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"].
form header
 wempre.emprazsoc format "x(35)"
 "Diario Auxiliar  -  Vendas  -  " at 37
 clinommes[mes] "  de  " ano
 "Livro - " at 101 livnum format ">>>9"
 ", Folha - " page-number + pagini - 1 format ">>>>9"
 skip fill("-",130) format "x(130)"
 skip(2)
 with frame fcab page-top no-box width 130.
form header
 skip "Data         Contrato     Cliente     Nome do Cliente"
 "Valor da Venda" at 84
 skip "--------     --------     -------    "
 fill("-",40) format "x(40)" space(5)
 fill("-",14) format "x(14)"
 with frame fdet page-top no-box width 130.
view frame fcab.
view frame fdet.
assign w01 = 0
       w001 = 0.
for each contrato where month(dtinicial) = mes and
			year(dtinicial) = ano and
			contrato.situacao <> 9
	 break by dtinicial.
 if first-of(dtinicial)
  then put dtinicial space(8).
  else put space(16).
 find clien of contrato.
 put contrato.contnum format "99999" "      "
     clien.clicod "     "
     clien.clinom "     "
     contrato.vltotal skip.
 assign w01 = w01 + contrato.vltotal.
 if last-of(dtinicial)
 then do:
 put space(63) "Total de " dtinicial " = " w01 format ">>>,>>>,>>9.99"
     skip fill("-",97) format "x(97)" skip.
 assign w001 = w001 + w01
	w01 = 0.
 end.
end.
put skip(2) space(71) "Total Mes = " w001 format ">>>,>>>,>>9.99".
output close.
