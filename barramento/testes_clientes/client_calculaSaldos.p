def var vcpf as char.
vcpf = "1513".
def var lcParamEntrada as LongChar.
def var lcParamRetorno as LongChar.

{/admcom/barramento/metodos/calculaSaldos.i}
    
/* GRAVA PRAMETROS DE ENTRADA */
create ttsaldosEntrada.
ttsaldosEntrada.codigoCliente = vcpf.

create ttcredito.
ttcredito.codigoCliente = ttsaldosEntrada.codigoCliente.
ttcredito.limite        = string(10001.00).
ttcredito.vctolimite    = "10/02/2020".
   
create ttmodal.
ttmodal.codigoCliente = ttsaldosEntrada.codigoCliente.
ttmodal.modcod        = "CRE".
ttmodal.comprometido  = "2020.00".    

create ttmodal.
ttmodal.codigoCliente = ttsaldosEntrada.codigoCliente.
ttmodal.modcod        = "CP0".
ttmodal.comprometido  = "220.00".    



hsaldosEntrada:WRITE-JSON("LONGCHAR",   lcParamEntrada,   true).


run ../barramento/socketclient.p ("HEADER",
                            input  "calculaSaldos",
                            input  lcParamEntrada,
                            output lcParamRetorno).

lokJSON = hsaldosSaida:READ-JSON("longchar", 
                                         lcParamRetorno, 
                                         "EMPTY") no-error.

for each ttcredito.
    disp ttcredito.
end.    
