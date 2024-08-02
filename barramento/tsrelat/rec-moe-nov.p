/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE ESTÁ GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
def var vpdf as character.
{tsr/tsrelat.i}
def temp-table ttparametros serialize-name "parametros"
    field etbcod                AS int
    field dtinicial             AS DATE
    field dtfinal               AS DATE
    field sel-mod               AS CHAR
    field considerarfeirao      AS LOG.

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/rec-moe-nov.p -> rec-moe-nov_run.p".

run marcatsrelat ("INICIO").
DEF VAR hentrada AS HANDLE.

hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
message "Lendo parametros " avail ttparametros.

if not avail ttparametros then return.

disp ttparametros with side-labels.

message "rec-moe-nov_run.p".

RUN rec-moe-nov_run.p (INPUT  lcjsonentrada,
                           OUTPUT varquivo,
                           OUTPUT vpdf).

message "rec-moe-nov_run.p FIM".

run marcatsrelat (vdirweb + vpdf).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/rec-moe-nov.p -> rec-moe-nov_run.p " vpdf.


