def var vcodigocpfcnpj as char format "x(14)".
def var vnumeroContrato as char format "x(15)".


update vcodigocpfcnpj vnumerocontrato.

def var lcParamEntrada as LongChar.
def var lcParamRetorno as LongChar.

{/admcom/barramento/metodos/consultaParcelas.i}
    
/* GRAVA PRAMETROS DE ENTRADA */
create ttParcelasEntrada.
ttParcelasEntrada.codigo_cpfcnpj = vcodigocpfcnpj.
ttParcelasEntrada.numero_contrato = vnumeroContrato.

hParcelasEntrada:WRITE-JSON("LONGCHAR",   lcParamEntrada,   true).


run ../barramento/socketclient.p ("HEADER",
                            input  "consultaParcelas",
                            input  lcParamEntrada,
                            output lcParamRetorno).

lokJSON = hParcelasSaida:READ-JSON("longchar", 
                                         lcParamRetorno, 
                                         "EMPTY") no-error.

for each ttclien.
    disp ttclien.
    for each ttcontratos of ttclien.
            disp ttcontratos.
        for each ttparcelas   of ttcontratos.
            disp ttparcelas.
        end.                                    
    end.                
end.    
