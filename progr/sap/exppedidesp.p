{admcab.i  new}

def var vqtdabe as int.

def var vcp as char init ";".

output to /admcom/tmp/expsap/exppedidesp.csv.
        put unformatted 
             "Pedido"  vcp
             "Produto" vcp
             "Filial" vcp
             "Qtd" vcp
             skip.

def var vx as int.
for each estab no-lock.
for each pedid where pedid.etbcod = estab.etbcod and 
        pedtdc = 6  and 
        pedid.sitped = "A" no-lock.

    vqtdabe = 0.
    for each liped of pedid no-lock.
        vqtdabe = (liped.lipqtd - liped.lipent).
        if vqtdabe > 0 
        then leave.
    end.
    if vqtdabe = 0
    then next.
    vx = 0.             
    for each liped of pedid no-lock.
        vx = vx + 1.
        find  produ of liped no-lock no-error.
        if not avail produ then next.
        vqtdabe = (liped.lipqtd - liped.lipent).
        if vqtdabe <= 0
        then  next.
        put unformatted 
             liped.pednum  vcp
             liped.procod vcp
             liped.etbcod vcp
             vqtdabe vcp
             skip.
    end.
end.        
end.
output close.



