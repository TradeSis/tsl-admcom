def var lcParamEntrada as LongChar.
def var lcParamRetorno as LongChar.

def var lOk             as log.

DEFINE TEMP-TABLE ttEntrada NO-UNDO SERIALIZE-NAME "Entrada"
    FIELD Metodo AS CHARACTER.

DEFINE DATASET DSEntrada FOR ttEntrada .
DEFINE TEMP-TABLE ttRetorno NO-UNDO SERIALIZE-NAME "timeSaida"
    FIELD vtime AS CHARACTER.
DEFINE DATASET DSRetorno serialize-name "conteudoSaida"
    FOR ttRetorno.


CREATE ttEntrada.
ttEntrada.Metodo = "buscaTime".
lok =  DATASET DSEntrada:HANDLE:WRITE-JSON("LONGCHAR",  
            lcParamEntrada,  
            true).

find first ttEntrada.
run ../barramento/socketclient.p ("PASSOSROBERTO",
                            input  ttEntrada.metodo,
                            input  lcParamEntrada,
                            output lcParamRetorno).

lOK = DATASET DSRetorno:READ-JSON("longchar", 
                             lcParamRetorno, 
                             "EMPTY").

for each ttRetorno.
    disp ttretorno.
end.    
message string(lcParamRetorno)
    view-as alert-box.       