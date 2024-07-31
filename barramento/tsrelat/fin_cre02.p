/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE ESTÁ GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
DEF VAR vpdf   AS CHAR. 
DEF VAR    varqpagamentos          AS CHAR.
DEF VAR    varqjuro          AS CHAR.
{tsr/tsrelat.i}
def temp-table ttparametros serialize-name "parametros"
    field etbcod                as int
    field cre               as LOG
    field dtini             as CHAR
    field dtfin               AS CHAR
    field relatorio-geral        AS LOG
    field sel-mod               AS CHAR
    field consulta-parcelas-LP            AS LOG
    field feirao-nome-limpo      AS LOG.

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/fin_cre02.p -> fin/cre02_run.p".

run marcatsrelat ("INICIO").
DEF VAR hentrada AS HANDLE.

hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
message "Lendo parametros " avail ttparametros.

if not avail ttparametros then return.

disp ttparametros with side-labels.

message "fin/cre02_run.p".

RUN fin/cre02_run.p (INPUT  lcjsonentrada,
                      OUTPUT vpdf,
                      OUTPUT varqpagamentos,
                      OUTPUT varqjuro).

message "fin/cre02_run.p FIM".

run marcatsrelat (vdirweb + vpdf).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/fin_cre02.p -> fin/cre02_run.p " vpdf.


