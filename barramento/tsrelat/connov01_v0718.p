/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE EST� GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
DEF VAR vpdf   AS CHAR. 

{tsr/tsrelat.i}

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/connov01_v0718.p -> connov01_v0718_run.p".

run marcatsrelat ("INICIO").

RUN connov01_v0718_run.p (INPUT  lcjsonentrada,
                              input no, /* tela */
                              output varquivo,
                              OUTPUT vpdf).

run marcatsrelat (vdirweb + vpdf).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/connov01_v0718.p -> connov01_v0718_run.p " vpdf.


