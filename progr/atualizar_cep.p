/* helio 08082023 - ID 36311 - Menu do admcom, n�o tras mais todas as informa��es. */
/*
Programa:  atualizar_cep.p
Propósito: Exportador para atualização de CEP de clientes
Autor:     Lucas Leote
Data:      Dez/2016
*/

{admcab.i}

/* Definindo as variáveis */
def var i-flini as int format ">>9" no-undo.
def var i-flfim as int format ">>9" no-undo.
def var c-csv   as char no-undo format "x(50)".
def var c-bkp   as char no-undo.

/* Atribuindo os valores de diretório e nome dos arquivos gerados */
assign c-csv = "/admcom/import/clientes_cep.csv".
/*assign c-bkp = "/admcom/backupcep/clientes_cep.d".*/

/* Form que recebe os dados inputados pelo usuário */
update i-flini label "Filial inicial"
    with frame f1.
i-flfim = i-flini.
update
           i-flfim label "Filial final"
           with frame f1.
if i-flfim < i-flini
then undo.
c-csv = "/admcom/import/clientes_cep_filial_" + string(i-flini).
if i-flfim <> i-flini
then c-csv = c-csv + "_" + string(i-flfim).
c-csv = c-csv + ".csv".

update            
           c-csv label "Pasta e arquivo"
with 1 col frame f1 title "  Informe os dados abaixo  " centered width 80.

/* Validação dos dados inputados pelo usuário */
if i-flini < 1 or i-flfim > 999 then do:
        message "Filial invalida!".
        undo, retry.
end.

message "Gerando arquivos...".

/* Gerando CSV */
output to value(c-csv).
put unformatted 
"NOME;CODIGO CLIENTE;FILIAL;CPF;EMAIL;RUA;NUMERO;COMPLEMENTO;BAIRRO;CIDADE;ESTADO;CEP;TELEFONE;CLIENTE CELULAR;" +
"REFERENCIA 1;TELEFONE;REFERENCIA 2;TELEFONE REFERENCIA 2;TELEFONE REFERENCIA 3;" 
skip.

        for each clien where clien.etbcad >= i-flini and clien.etbcad <= i-flfim no-lock:
                put unformatted 
                    clien.clinom ";"
                        clien.clicod ";"
                    clien.etbcad ";"
                    clien.ciccgc ";"
                    lc(clien.zona) ";"    
                        clien.endereco[1] ";"
                    clien.numero[1] ";"
                    clien.compl[1] ";"
                        clien.bairro[1] ";" 
                        clien.cidade[1] ";"  
                        clien.ufecod[1] ";"
                        clien.cep[1] ";"
                    clien.fone ";"
                    clien.fax ";"
                    clien.entbairro[1] ";"
                    clien.entcidade[1] ";"
                    clien.entbairro[2] ";"
                    clien.entcidade[2] ";"
                    clien.entcidade[3] ";"
                    
            skip.
                        
        end.
output close.
/**
/* Gerando os .d */
do i-flini = i-flini TO i-flfim:
    c-bkp = "/admcom/backupcep/clien_cep_FL" + string(i-flini) + ".d".
    output to value(c-bkp).
        for each clien where etbcad = i-flini no-lock.
            export clien.
        end.
    output close.
end.

/*unix silent sudo chmod 777 value(c-csv).
unix silent sudo chmod 777 value(c-bkp).*/
*/


/* Msg de conclusão */
message "ARQUIVOS:" skip c-csv skip "GERADOS COM SUCESSO!" view-as alert-box.
