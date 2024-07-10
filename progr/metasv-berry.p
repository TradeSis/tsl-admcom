{/admcom/progr/admcab-batch.i new}

sparam = SESSION:PARAMETER.
 
def var vmes as int.

vmes = int(sparam).
def var varqexc as char.
varqexc = "/admcom/relat/metas-vendas-" + string(vmes,"99") +
                                   ".txt".
 
output to value(varqexc) page-size 0.
for each estab no-lock:
    for each duplic where duplic.duppc = vmes and
                          duplic.fatnum = estab.etbcod
                          no-lock:
        put unformatted 
            duplic.duppc  format "99" ";"
            duplic.fatnum format ">>9" ";" 
            duplic.dupdia format "99" ";"
            duplic.dupjur format ">>,>>>,>>9.99" ";"
            duplic.dupval format ">>,>>>,>>9.99"
            skip.
    end.    
end.
output close.

