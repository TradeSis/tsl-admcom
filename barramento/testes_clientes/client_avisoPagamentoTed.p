


def var lcParamEntrada as LongChar.
def var lcParamRetorno as LongChar.

{/admcom/barramento/metodos/avisoPagamentoTed.i}
    
/* GRAVA PRAMETROS DE ENTRADA */
create ttavisopagamentotedentrada.
ttavisopagamentotedentrada.codigo_cpfcnpj = "1513".
banco           = string(341).
idted           = "1495".

create ttparcelasentrada.
ttparcelasentrada.codigo_cpfcnpj  = "1513".
numero_contrato = "0301932204".
seq_parcela     = "03".
venc_parcela    = string(02/28/19).
vlr_parcela_pago = "14.95".


havisopagamentotedEntrada:WRITE-JSON("LONGCHAR",   lcParamEntrada,   true).


run ../barramento/socketclient.p ("HEADER",
                            input  "avisoPagamentoTed",
                            input  lcParamEntrada,
                            output lcParamRetorno).

lokJSON = havisopagamentotedSaida:READ-JSON("longchar", 
                                         lcParamRetorno, 
                                         "EMPTY") no-error.
for each ttstatus.
disp ttstatus.
end.
