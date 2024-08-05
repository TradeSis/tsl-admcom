/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE ESTÁ GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
DEF VAR vpdf   AS CHAR. 
{tsr/tsrelat.i}
def temp-table ttparametros serialize-name "parametros"
    FIELD etbcod            AS INT
    FIELD dti       AS char
    FIELD dtf         AS char
    FIELD dtveni        AS char
    FIELD dtvenf         AS char
    FIELD consulta-parcelas-LP        AS LOG
    FIELD mod-sel           AS CHAR
    FIELD feirao-nome-limpo  AS LOG.

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/recper.p -> recper_run.p".

run marcatsrelat ("INICIO").
DEF VAR hentrada AS HANDLE.

hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
message "Lendo parametros " avail ttparametros.

if not avail ttparametros then return.

disp ttparametros with side-labels.

message "recper_run.p".

RUN recper_run.p (INPUT  lcjsonentrada,
                  output varquivo,
                  OUTPUT vpdf).

message "recper_run.p FIM".

run marcatsrelat (vdirweb + vpdf).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/recper.p -> recper_run.p " vpdf.


