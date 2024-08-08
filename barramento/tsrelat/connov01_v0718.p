/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE ESTÁ GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
DEF VAR vpdf   AS CHAR.
{tsr/tsrelat.i}
def temp-table ttparametros no-undo serialize-name "parametros"
    field codigoFilial      as int
    field dataInicial       as char  format "x(20)"
    field dataFinal         as char  format "x(20)"
    field considerarFeirao  as log
    field mod-sel           as char  format "x(20)"
    field vindex            as int.

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/connov01_v0718.p -> connov01_v0718_run.p".

run marcatsrelat ("INICIO").
DEF VAR hentrada AS HANDLE.

hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
message "Lendo parametros " avail ttparametros.

if not avail ttparametros then return.

disp ttparametros with side-labels.

message "connov01_v0718_run.p".

RUN connov01_v0718_run.p (INPUT  lcjsonentrada,
                              input no, /* tela */
                              output varquivo,
                              OUTPUT vpdf).

message "connov01_v0718_run.p FIM".

run marcatsrelat (vdirweb + vpdf).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/connov01_v0718.p -> connov01_v0718_run.p " vpdf.


