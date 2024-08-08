/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE ESTÁ GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
DEF VAR vpdf   AS CHAR. 
{tsr/tsrelat.i}
DEF VAR hentrada AS HANDLE.


def temp-table ttparametros no-undo serialize-name "parametros"
    field posicao       as int
    field codigoFilial  as int
    field dataInicial   as CHAR
    field dataFinal     as CHAR
    field alfa          AS log.

def NEW shared temp-table tt-extrato 
    field rec as recid
    field ord as int
        index ind-1 ord.
                    
    hEntrada = temp-table ttparametros:HANDLE.

    hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                            
    find first ttparametros no-error.
    if not avail ttparametros then return.
    message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/loj_cred01.p -> POSICAO=" ttparametros.posicao.
    if ttparametros.posicao = 1
    then do:
        message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/loj_cred01.p -> loj/cred02_run.p".

        run marcatsrelat ("INICIO").
        
        RUN loj/cred02_run.p (INPUT  lcjsonentrada,
                              OUTPUT vpdf).
    end.
    if ttparametros.posicao = 2
    then do:
        message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/loj_cred01.p -> loj/cred03_run.p".

        run marcatsrelat ("INICIO").

        RUN loj/cred03_run.p (INPUT  lcjsonentrada,
                              OUTPUT vpdf).
    end.





run marcatsrelat (vdirweb + vpdf).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/lon_cred01.p -> loj/cred02_run.p " vpdf.


