


def var lcParamEntrada as LongChar.
def var lcParamRetorno as LongChar.

{/admcom/barramento/metodos/buscaProfinParam.i}
    
/* GRAVA PRAMETROS DE ENTRADA */
create ttbuscaProfinParamentrada.
ttbuscaProfinParamentrada.codigofilial = "0".


hconteudoEntrada:WRITE-JSON("FILE","helio_profin.json", true).


hconteudoEntrada:WRITE-JSON("LONGCHAR",   lcParamEntrada,   true).


run /admcom/barramento/socketclient.p ("",
                            input  "buscaProfinParam",
                            input  lcParamEntrada,
                            output lcParamRetorno).

lokJSON = hconteudoSaida:READ-JSON("longchar", 
                                         lcParamRetorno, 
                                         "EMPTY") no-error.
for each ttstatus.
disp ttstatus.
disp ttstatus.situacao format "x(40)".
for each ttprofin.
    disp ttprofin.
        /*
    for each ttprofinparam of ttprofin.
        disp ttprofinparam.
    end.
    */
    for each ttprofincond where ttprofincond.pfincod = ttprofin.fincod. 
        disp ttprofincond.
    end.    
    end.
end.
