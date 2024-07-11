def var  vcodigocpfcnpj as char.
update vcodigocpfcnpj.
def var lcParamEntrada as LongChar.
def var lcParamRetorno as LongChar.

{/admcom/barramento/metodos/consultaCliente.i}
    
/* GRAVA PRAMETROS DE ENTRADA */
create ttclienteEntrada.
ttclienteEntrada.codigo_cpfCNPJ = trim(vcodigocpfcnpj).

hclienteEntrada:WRITE-JSON("LONGCHAR",   lcParamEntrada,   true).


run ../barramento/socketclient.p ("HEADER",
                            input  "consultaCliente",
                            input  lcParamEntrada,
                            output lcParamRetorno).

lokJSON = hClienteSaida:READ-JSON("longchar", 
                                         lcParamRetorno, 
                                         "EMPTY") no-error.

for each ttclien.
    disp ttclien.
end.    
