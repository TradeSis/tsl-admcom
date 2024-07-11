def var vcpf as char.
vcpf = "1513".
def var lcParamEntrada as LongChar.
def var lcParamRetorno as LongChar.

{/admcom/barramento/metodos/consultaComportamento.i}
    
/* GRAVA PRAMETROS DE ENTRADA */
create ttComportamentoEntrada.
ttComportamentoEntrada.codigo_cpfCNPJ = vcpf.

hcomportamentoEntrada:WRITE-JSON("LONGCHAR",   lcParamEntrada,   true).


run ../barramento/socketclient.p ("HEADER",
                            input  "consultaComportamento",
                            input  lcParamEntrada,
                            output lcParamRetorno).

lokJSON = hcomportamentoCliente:READ-JSON("longchar", 
                                         lcParamRetorno, 
                                         "EMPTY") no-error.

for each ttclien.
    disp ttclien.
    for each ttmodalcomportamento of ttclien.
        disp ttmodalcomportamento.
    end.
    for each ttcomportamento of ttclien.
        disp ttcomportamento except ttcomportamento.clicod.
    end.    
end.    
