/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE ESTÁ GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
def var vpdf as character.
{tsr/tsrelat.i}
def temp-table ttparametros NO-UNDO serialize-name "parametros"
    field mod-sel       as char
    field dataInicial   as char
    field dataFinal     as char
    field feirao-nome-limpo    as log.

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/resliq.p -> fin/resliq_run.p".

run marcatsrelat ("INICIO").
DEF VAR hentrada AS HANDLE.

hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
message "Lendo parametros " avail ttparametros.

if not avail ttparametros then return.

disp ttparametros with side-labels.

message "resliq_run.p".

RUN fin/resliq_run.p (INPUT  lcjsonentrada,
                       input  no, /* tela */
                       output varquivo,
                       OUTPUT vpdf).

message "resliq_run.p FIM".

run marcatsrelat (vdirweb + vpdf).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/resliq.p -> fin/resliq_run.p " vpdf.


