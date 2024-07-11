def var vcpf as char.
vcpf = "1513".
def var lcParamEntrada as LongChar.
def var lcParamRetorno as LongChar.

{/admcom/barramento/metodos/consultaLimite.i}
    
/* GRAVA PRAMETROS DE ENTRADA */
create ttclienteEntrada.
ttclienteEntrada.codigo_cpfCNPJ = vcpf.

hclienteEntrada:WRITE-JSON("LONGCHAR",   lcParamEntrada,   true).


run ../barramento/socketclient.p ("HEADER",
                            input  "consultaLimite",
                            input  lcParamEntrada,
                            output lcParamRetorno).

lokJSON = hclienteSaida:READ-JSON("longchar", 
                                         lcParamRetorno, 
                                         "EMPTY") no-error.

for each ttclien.
    disp ttclien.
end.    
