{admcab.i new}
def var vcp as char initial ";".
def var vest900 as int.
def var vest998 as int.
def var vest900_91 as int.

output to /admcom/tmp/expsap/estoq.csv.

    put unformatted
        "Produto" vcp
        "Estoque 900"     vcp
        "Estoque 998"    vcp
        "Estoque 900 - Cat 91"  vcp
        skip.

for each produ no-lock.

    if produ.catcod = 31 or
       produ.catcod = 41
    then.
    else do:
        next.
    end.    
    
    if produ.proseq = 0
    then.
    else do:
        next.
    end.    

    vest900 = 0.
    for each estoq where estoq.procod = produ.procod and
                         (estoq.etbcod = 501 or 
                          estoq.etbcod = 901 or 
                          estoq.etbcod = 500 or
                          estoq.etbcod = 700 or
                          estoq.etbcod = 901 or
                          estoq.etbcod = 600 or
                          estoq.etbcod = 981)
                          no-lock.
        if estoq.estatual <= 0 then next.
        vest900 = vest900 + estoq.estatual.
    end.

    vest998 =  0.
    for each estoq where estoq.procod = produ.procod and
                         (estoq.etbcod = 930 or 
                          estoq.etbcod = 988)
                          no-lock.
        if estoq.estatual <= 0 then next.
        vest998 = vest998 + estoq.estatual.
    end.
    
    vest900_91 = 0.
    if produ.catcod = 91
    then do:
        for each estoq where estoq.procod = produ.procod and
                             (estoq.etbcod = 900)
                              no-lock.
            if estoq.estatual <= 0 then next.
            vest900_91 = vest900_91 + estoq.estatual.
        end.
    
    end.
    
    put unformatted
        produ.procod vcp
        vest900     vcp
        vest998     vcp
        vest900_91  vcp
        skip.
        
                                          

end.
output close.

