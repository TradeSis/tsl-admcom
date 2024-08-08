/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE ESTÁ GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
def var varquivo2 as char.
{tsr/tsrelat.i}
def temp-table ttparametros no-undo serialize-name "parametros"
    field dataInicial   as char
    field dataFinal     as char.

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/aco13j.p -> aco13j_run.p".

run marcatsrelat ("INICIO").
DEF VAR hentrada AS HANDLE.

hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
message "Lendo parametros " avail ttparametros.

if not avail ttparametros then return.

disp ttparametros with side-labels.

message "aco13j_run.p".

RUN aco13j_run.p (INPUT  lcjsonentrada,
                  OUTPUT varquivo2).

message "aco13j_run.p FIM".

run marcatsrelat (vdirweb + varquivo2).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/aco13j.p -> aco13j_run.p " varquivo2.


