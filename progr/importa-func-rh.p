/*
Programa:  importa-func-rh.p
Propósito: Importar os CPFs dos funcionarios para desconto
Autor:     Lucas Leote
Data:      Setembro/2016
*/

{admcab.i}

message "Atualizando os dados...".

/* Limpa todos os clientes funcionario */
for each clien where clien.tipocod = 3:
	clien.tipocod = 1.
end.

/* Definindo variáveis e temp-table */
def temp-table tt-clien
	field ciccgc like clien.ciccgc.

def var c-csv as char no-undo.

/* Atribuindo diretório e nome do arquivo recebido */
assign c-csv = "/admcom/import/funcs.csv".

/* Lendo o arquivo e gravando na temp-table */
input from value(c-csv) no-convert.
	repeat:
		create tt-clien.
		import delimiter ";" tt-clien no-error.
	end.
input close.

/* Gerando arquivo com os CPFs nao encontrados na base */
output to /admcom/import/funcs-erro.txt.
	/* Percorrendo a temp-table */
	for each tt-clien:
		if length(tt-clien.ciccgc) = 10 then tt-clien.ciccgc = "0" + string(tt-clien.ciccgc).
		if length(tt-clien.ciccgc) = 9 then tt-clien.ciccgc = "00" + string(tt-clien.ciccgc).
		if length(tt-clien.ciccgc) = 8 then tt-clien.ciccgc = "000" + string(tt-clien.ciccgc).

		find first clien where clien.ciccgc = tt-clien.ciccgc no-lock no-error.
		if not avail clien then do:
			put tt-clien.ciccgc skip.
		end.
	end.
output close.

/* Gerando arquivo com os clientes alterados e setando eles como funcionario */
output to /admcom/import/funcs-sucesso.txt.
	put "CODIGO ;  NOME ; CPF ; TIPO CLIEN" skip.
	/* Percorrendo a temp-table */
	for each tt-clien:
		if length(tt-clien.ciccgc) = 10 then tt-clien.ciccgc = "0" + string(tt-clien.ciccgc).
		if length(tt-clien.ciccgc) = 9 then tt-clien.ciccgc = "00" + string(tt-clien.ciccgc).
		if length(tt-clien.ciccgc) = 8 then tt-clien.ciccgc = "000" + string(tt-clien.ciccgc).

		find first clien where clien.ciccgc = tt-clien.ciccgc no-error.
		if not avail clien then next.

		clien.tipocod = 3.
		
		put clien.clicod ";" clien.clinom ";" tt-clien.ciccgc ";" clien.tipocod skip.
	end.
output close.

message "Dados atualizados!" view-as alert-box.