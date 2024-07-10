{admcab.i}

def input   parameter rec-clien  as recid.
def output  parameter vsalaberto as dec.

vsalaberto = 0.

connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld dragao no-error.
             
run salabertocli.p ( input rec-clien,
                        output vsalaberto).

disconnect dragao. 
