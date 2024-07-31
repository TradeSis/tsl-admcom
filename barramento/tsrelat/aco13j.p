/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE ESTÁ GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
def var varquivo2 as char.
{tsr/tsrelat.i}

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/aco13j.p -> aco13j_run.p".

run marcatsrelat ("INICIO").

RUN aco13j_run.p (INPUT  lcjsonentrada,
                  OUTPUT varquivo2).

run marcatsrelat (vdirweb + varquivo2).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/aco13j.p -> aco13j_run.p " varquivo2.


