{admcab-batch.i}

def input   parameter rec-clien  as recid.
def output  parameter vcalclimite as dec.

def var vcalclim as dec.
def var vpardias as dec.
def new shared temp-table tt-dados
    field parametro as char
    field valor     as dec
    field valoralt  as dec
    field percent   as dec
    field vcalclim  as dec
    field operacao  as char format "x(1)" column-label ""
    field numseq    as int
    index dado1 numseq.

vcalclim = 0.
vpardias = 0.

def var limite-disponivel as dec init 0.
/*
connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao no-error.
  */
           
run calccredscore.p (input "",
                        input rec-clien,
                        output vcalclim,
                        output vpardias,
                        output limite-disponivel).
/*
disconnect dragao. 
*/
vcalclimite = vcalclim.
