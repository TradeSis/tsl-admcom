/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE ESTÁ GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
DEF VAR vpdf   AS CHAR. 
{tsr/tsrelat.i}
def temp-table ttparametros NO-UNDO serialize-name "parametros"
    field cre               as log
    field codigoFilial      as int
    field mod-sel           as char  format "x(20)"
    field dataInicial       as char  format "x(20)"
    field dataFinal         as char  format "x(20)"
    field dataReferencia    as char  format "x(20)"
    field consulta-parcelas-LP   as log
    field feirao-nome-limpo      as log
    field abreporanoemi          as log
    field clinovos          as log
    field porestab          as log
    field vindex            as INT.

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/frsalcart_v2002.p -> frsalcart_v2002_run.p".

run marcatsrelat ("INICIO").
DEF VAR hentrada AS HANDLE.

hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
message "Lendo parametros " avail ttparametros.

if not avail ttparametros then return.

disp ttparametros with side-labels.

message "frsalcart_v2002_run.p".

RUN frsalcart_v2002_run.p (INPUT  lcjsonentrada,
                               input no, /* tela */
                               OUTPUT varquivo,
                               OUTPUT vpdf).

message "frsalcart_v2002_run.p FIM".

run marcatsrelat (vdirweb + vpdf).

message today string(time,"HH:MM:SS") "Finalizou " pidrelat "tsrelat/frsalcart_v2002.p -> frsalcart_v2002_run.p " vpdf.


