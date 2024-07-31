/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE ESTÁ GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
def var vpdf as character.

{tsr/tsrelat.i}

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/frsalcart_v2002.p -> frsalcart_v2002_run.p".

run marcatsrelat ("INICIO").

RUN frsalcart_v2002_run.p (INPUT  lcjsonentrada,
                               input no, /* tela */
                               OUTPUT varquivo,
                               OUTPUT vpdf). 

run marcatsrelat (vdirweb + vpdf).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/frsalcart_v2002.p -> frsalcart_v2002_run.p " vpdf.


