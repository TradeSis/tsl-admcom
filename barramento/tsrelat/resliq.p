/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE EST� GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
def var vpdf as character.

{tsr/tsrelat.i}

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/resliq.p -> fin/resliq_run.p".

run marcatsrelat ("INICIO").

RUN fin/resliq_run.p (INPUT  lcjsonentrada,
                       input  no, /* tela */
                       output varquivo,
                       OUTPUT vpdf).

run marcatsrelat (vdirweb + vpdf).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/resliq.p -> fin/resliq_run.p " vpdf.


