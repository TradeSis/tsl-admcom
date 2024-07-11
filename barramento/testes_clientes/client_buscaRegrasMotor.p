def var vcodigoFilial as char.
def var lcParamEntrada as LongChar.
def var lcParamRetorno as LongChar.

{/admcom/barramento/metodos/buscaRegrasMotor.i}

/* GRAVA PRAMETROS DE ENTRADA */
create ttregrasMotorEntrada.
ttregrasMotorEntrada.codigoFilial = vcodigoFilial.

hRegrasMotorEntrada:WRITE-JSON("LONGCHAR",   lcParamEntrada,   true).


run ../barramento/socketclient.p ("HEADER",
                            input  "buscaRegrasMotor",
                            input  lcParamEntrada,
                            output lcParamRetorno).

lokJSON = hRegrasMotor:READ-JSON("longchar", 
                                   lcParamRetorno, 
                                   "EMPTY") no-error.

hRegrasMotor:WRITE-JSON("FILE", "helioc.json", true).


for each ttgruposregras.
    disp ttgruposregras.
end.    

