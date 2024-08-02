/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE ESTÁ GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
def var arquivo as CHAR. 
{tsr/tsrelat.i}
def temp-table ttparametros serialize-name "parametros"
    field etb_ini       AS INT
    field etb_fim       AS INT.

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/cdleld.p -> cdleld_run.p".

run marcatsrelat ("INICIO").
DEF VAR hentrada AS HANDLE.

hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
message "Lendo parametros " avail ttparametros.

if not avail ttparametros then return.

disp ttparametros with side-labels.

message "cdleld_run.p".

RUN cdleld_run.p (INPUT  lcjsonentrada,
                      OUTPUT arquivo).

message "cdleld_run.p FIM".

run marcatsrelat (vdirweb + arquivo).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/cdleld.p -> cdleld_run.p " arquivo.


