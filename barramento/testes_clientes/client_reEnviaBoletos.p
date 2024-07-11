


def var lcParamEntrada as LongChar.
def var lcParamRetorno as LongChar.

{/admcom/barramento/metodos/reEnviaBoletos.i}
    
/* GRAVA PRAMETROS DE ENTRADA */
create ttreEnviaBoletosentrada.
ttreEnviaBoletosentrada.codigo_cpfcnpj = "1513".
ttreEnviaBoletosentrada.banco           = string(341).
ttreEnviaBoletosentrada.nossonumero     = "26231".



hreEnviaBoletosEntrada:WRITE-JSON("LONGCHAR",   lcParamEntrada,   true).


run ../barramento/socketclient.p ("HEADER",
                            input  "reEnviaBoletos",
                            input  lcParamEntrada,
                            output lcParamRetorno).

lokJSON = hreEnviaBoletosSaida:READ-JSON("longchar", 
                                         lcParamRetorno, 
                                         "EMPTY") no-error.
for each ttstatus.
disp ttstatus.
disp ttstatus.situacao format "x(40)".
for each ttboleto.
    disp ttboleto.
    end.
end.
