/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE ESTÁ GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
DEF VAR vpdf   AS CHAR. 
{tsr/tsrelat.i}
def temp-table ttparametros serialize-name "parametros"
    field cre               as LOG
    field dti            as char     format "x(20)"
    field dtf               AS char  format "x(20)"
    field clinovos              AS LOG
    field sel-mod               AS CHAR  format "x(20)"
    field feirao-nome-limpo      AS LOG
    FIELD vindex                AS INT.

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/frrescart_v1801.p -> frrescart_v1801_run.p".

run marcatsrelat ("INICIO").
DEF VAR hentrada AS HANDLE.

hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
message "Lendo parametros " avail ttparametros.

if not avail ttparametros then return.

disp ttparametros with side-labels.

message "frrescart_v1801_run.p".

RUN frrescart_v1801_run.p (INPUT  lcjsonentrada,
                               output varquivo,
                               OUTPUT vpdf).

message "frrescart_v1801_run.p FIM".

run marcatsrelat (vdirweb + vpdf).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/frrescart_v1801.p -> frrescart_v1801_run.p " vpdf.


