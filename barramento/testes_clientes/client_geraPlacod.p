def var lcParamEntrada as LongChar.
def var lcParamRetorno as LongChar.

def var lOk             as log.

DEFINE TEMP-TABLE tt-placodEntrada NO-UNDO SERIALIZE-NAME "placodEntrada"
    FIELD etbcod as char.

DEFINE TEMP-TABLE tt-placodSaida NO-UNDO SERIALIZE-NAME "placodSaida"
    FIELD etbcod AS CHARACTER
    FIELD placod as char.

DEFINE DATASET conteudoEntrada FOR tt-placodEntrada.
DEFINE DATASET conteudoSaida FOR tt-placodSaida.

CREATE tt-placodEntrada.
tt-placodEntrada.etbcod = "100".

lok =  DATASET conteudoEntrada:HANDLE:WRITE-JSON("LONGCHAR",  
            lcParamEntrada,  
            true).

run ../barramento/socketclient.p ("PASSOSROBERTO",
                            input  "geraPlacod",
                            input  lcParamEntrada,
                            output lcParamRetorno).

lOK = DATASET conteudoSaida:READ-JSON("longchar", 
                             lcParamRetorno, 
                             "EMPTY").

for each tt-placodSaida.
    disp tt-placodSaida.
end.    
message string(lcParamRetorno)
    view-as alert-box.       