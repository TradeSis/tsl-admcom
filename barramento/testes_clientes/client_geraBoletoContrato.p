


def var lcParamEntrada as LongChar.
def var lcParamRetorno as LongChar.

{/admcom/barramento/metodos/geraBoletoContrato.i}
    
/* GRAVA PRAMETROS DE ENTRADA */
create ttgeraboletoentrada.
ttgeraboletoentrada.codigo_cpfcnpj = "1513".
venc_boleto    = string(today + 5).
vlr_boleto     = "14.95".
vlr_servicos   = "0.00".

create ttparcelasentrada.
ttparcelasentrada.codigo_cpfcnpj  = "1513".
numero_contrato = "0301932204".
seq_parcela     = "03".
venc_parcela    = string(02/28/19).
vlr_parcela_pago = "14.95".


hgeraboletoEntrada:WRITE-JSON("LONGCHAR",   lcParamEntrada,   true).


run ../barramento/socketclient.p ("HEADER",
                            input  "geraBoletoContrato",
                            input  lcParamEntrada,
                            output lcParamRetorno).

lokJSON = hgeraboletoSaida:READ-JSON("longchar", 
                                         lcParamRetorno, 
                                         "EMPTY") no-error.
for each ttboleto.
disp ttboleto.
end.
