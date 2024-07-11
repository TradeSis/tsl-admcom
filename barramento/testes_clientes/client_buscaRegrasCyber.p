def var par-filial as int init 0.
def var lcParamEntrada as LongChar.
def var lcParamRetorno as LongChar.
def var vi as int.
def var vok as log.

def temp-table ttparam no-undo
    field REGRA         as char format "x(20)"
    field OPCAO         as char format "x(10)"
    field PARAMETRO     as char format "x(16)"
    field PROGRAMA      as char format "x(12)".

{/admcom/barramento/metodos/buscaRegrasCyber.i}

/* GRAVA PRAMETROS DE ENTRADA */
create ttRegrasCyberEntrada.
ttRegrasCyberEntrada.codigoFilial = string(par-filial).

hconteudoEntrada:WRITE-JSON("LONGCHAR",   lcParamEntrada,   true).


run ../barramento/socketclient.p ("",
                            input  "buscaRegrasCyber",
                            input  lcParamEntrada,
                            output lcParamRetorno).

lokJSON = hconteudoSaida:READ-JSON("longchar", 
                                   lcParamRetorno, 
                                   "EMPTY") no-error.


hconteudoSaida:WRITE-JSON("FILE", "heliocyber.json", true).


