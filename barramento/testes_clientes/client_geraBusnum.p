def var lcParamEntrada as LongChar.
def var lcParamRetorno as LongChar.

def var lOk             as log.

DEFINE TEMP-TABLE tt-titcodEntrada NO-UNDO SERIALIZE-NAME "titcodEntrada"
    FIELD etbcod LIKE plani.etbcod.

DEFINE TEMP-TABLE tt-titcodSaida NO-UNDO SERIALIZE-NAME "titcodSaida"
    FIELD etbcod AS CHARACTER
    FIELD titcod AS CHARACTER.

DEFINE DATASET conteudoEntrada FOR tt-titcodEntrada.

DEFINE DATASET conteudoSaida FOR tt-titcodSaida.

CREATE tt-titcodEntrada.
tt-titcodEntrada.etbcod = 100.
lok =  DATASET conteudoEntrada:HANDLE:WRITE-JSON("LONGCHAR",  
            lcParamEntrada,  
            true).

run ../barramento/socketclient.p ("PASSOSROBERTO",
                            input  "geraBusnum",
                            input  lcParamEntrada,
                            output lcParamRetorno).

lOK = DATASET conteudoSaida:READ-JSON("longchar", 
                             lcParamRetorno, 
                             "EMPTY").

for each tt-titcodSaida.
    disp tt-titcodSaida.
end.    
message string(lcParamRetorno)
    view-as alert-box.       