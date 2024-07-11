


def var lcParamEntrada as LongChar.
def var lcParamRetorno as LongChar.

{/admcom/barramento/metodos/efetivaPagamentoTed.i}
    
/* GRAVA PRAMETROS DE ENTRADA */
create ttefetivapagamentotedentrada.
ttefetivapagamentotedentrada.codigo_cpfcnpj = "1513".
banco           = string(341).
idted           = "14952".



hefetivapagamentotedEntrada:WRITE-JSON("LONGCHAR",   lcParamEntrada,   true).


run ../barramento/socketclient.p ("HEADER",
                            input  "efetivaPagamentoTed",
                            input  lcParamEntrada,
                            output lcParamRetorno).

lokJSON = hefetivapagamentotedSaida:READ-JSON("longchar", 
                                         lcParamRetorno, 
                                         "EMPTY") no-error.
for each ttstatus.
disp ttstatus.
disp ttstatus.situacao format "x(40)".
end.
