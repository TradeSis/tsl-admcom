def var maior-credito-aberto as dec.
def var media-credito-aberto as dec.
def var v1 as dec.
def var v2 as dec.

output to /gera-embrace/renda-clientes.txt.
put "CODIGO;RENDA INDIVIDUAL;RENDA FAMILIAR" SKIP.  
for each clien no-lock:
    if clien.clicod = 1 or
       clien.clicod = 1513 or
       clien.clicod = 0 or
       clien.clicod = 1313
    then next. 
    if clien.prorenda[1] = 0 and
       clien.prorenda[2] = 0
    then next.   
    find ncrm where ncrm.clicod = clien.clicod no-lock no-error.
    if not avail ncrm or ncrm.spc
    then next.
    
    put unformatted
        clien.clicod ";"
        clien.prorenda[1]  format ">>,>>>,>>9.99" ";"
        clien.prorenda[1] + clien.prorenda[2] format ">>,>>>,>>9.99"
         skip.
end.
output close.
