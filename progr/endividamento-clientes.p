def var maior-credito-aberto as dec.
def var media-credito-aberto as dec.
def var v1 as dec.
def var v2 as dec.

output to /gera-embrace/endividamento-clientes.txt.
put "CODIGO;MAIOR-CREDITO;CREDITO-MEDIO" SKIP.  
for each clien no-lock:
    if clien.clicod = 1 or
       clien.clicod = 1513 or
       clien.clicod = 0 or
       clien.clicod = 1313
    then next.   
    find ncrm where ncrm.clicod = clien.clicod no-lock no-error.
    if not avail ncrm or ncrm.spc
    then next.
    run stcrecli.p(input clien.clicod,
                   input 36, 
                   output maior-credito-aberto,
                   output media-credito-aberto,
                   output v1,
                   output v2).
                   if maior-credito-aberto < 0  or
                    maior-credito-aberto = ?
                   then maior-credito-aberto = 0.
                   if media-credito-aberto < 0 or
                    media-credito-aberto = ?
                   then media-credito-aberto = 0.
    put unformatted
        clien.clicod ";"
         maior-credito-aberto format ">>,>>>,>>9.99" ";"
         media-credito-aberto format ">>,>>>,>>9.99"
         skip.
end.
output close.
