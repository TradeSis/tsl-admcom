/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE EST� GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
DEF VAR vpdf   AS CHAR. 
{tsr/tsrelat.i}

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/lon_cred01.p -> loj/cred02_run.p".

run marcatsrelat ("INICIO").

RUN loj/cred02_run.p (INPUT  lcjsonentrada,
                      OUTPUT vpdf).

run marcatsrelat (vdirweb + vpdf).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/lon_cred01.p -> loj/cred02_run.p " vpdf.


