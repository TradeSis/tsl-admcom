/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE ESTÁ GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
def var vpdf as character.
{tsr/tsrelat.i}

def temp-table ttparametros no-undo serialize-name "parametros"
    field etbcod      AS int
    FIELD dti         AS char
    FIELD dtf         AS char.

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/relcpn-v012018.p -> relcpn-v012018_run.p".

run marcatsrelat ("INICIO").
DEF VAR hentrada AS HANDLE.

hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
message "Lendo parametros " avail ttparametros.

if not avail ttparametros then return.

disp ttparametros with side-labels.

message "relcpn-v012018_run.p".

RUN relcpn-v012018_run.p (INPUT  lcjsonentrada,
                           OUTPUT varquivo,
                           OUTPUT vpdf).

message "relcpn-v012018_run.p FIM".

run marcatsrelat (vdirweb + vpdf).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/relcpn-v012018.p -> relcpn-v012018_run.p " vpdf.


