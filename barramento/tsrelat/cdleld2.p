/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE ESTÁ GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
def var varquivo1 as character.

{tsr/tsrelat.i}

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/cdleld2.p -> cdleld2_run.p".

run marcatsrelat ("INICIO").

RUN cdleld2_run.p (INPUT  lcjsonentrada,
                   OUTPUT varquivo1).

run marcatsrelat (vdirweb + varquivo1).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/cdleld2.p -> cdleld2_run.p " varquivo1.


