


def var lcCondicoesEntrada as LongChar.
def var lcCondicoesRetorno as LongChar.

{/admcom/barramento/metodos/buscaProfinCondicoes.i}
    
/* GRAVA PRAMETROS DE ENTRADA */
create ttProfinCondicoesentrada.
ttProfinCondicoesentrada.codigofilial = "0".
ttProfinCondicoesentrada.codigoProfin = "8000".



hconteudoEntrada:WRITE-JSON("FILE","helio_profin.json", true).


hconteudoEntrada:WRITE-JSON("LONGCHAR",   lcCondicoesEntrada,   true).


run /admcom/barramento/socketclient.p ("",
                            input  "buscaProfinCondicoes",
                            input  lcCondicoesEntrada,
                            output lcCondicoesRetorno).

lokJSON = hconteudoSaida:READ-JSON("longchar", 
                                         lcCondicoesRetorno, 
                                         "EMPTY") no-error.
for each ttstatus.
disp ttstatus.
    for each ttprofincond .
        disp ttprofincond.
    end.    
    end.
