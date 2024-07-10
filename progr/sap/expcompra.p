{admcab.i  new}

def var vqtdabe as int.

def var vcp as char init ";".

output to /admcom/tmp/expsap/expcompra.csv.

def var vx as int.
for each estab where estab.etbcod = 996 or estab.etbcod = 999 no-lock.
for each pedid where pedid.etbcod = estab.etbcod and pedtdc = 1  and pedid.sitped = "A" no-lock.
    if acha("Filial origem",pedid.pedobs[1]) <> ? /* ESPECIAL */
    then next.
    vqtdabe = 0.
    for each liped of pedid no-lock.
        vqtdabe = (liped.lipqtd - liped.lipent).
        if vqtdabe > 0 
        then leave.
    end.
    if vqtdabe = 0
    then next.
    find crepl of pedid no-lock.
    put  unformatted 
         "Cabeçalho" vcp
         pedid.pednum vcp
         pedid.clfcod vcp
         crepl.crenom vcp
         pedid.dupdes vcp
         pedid.pedobs[1] + " " +
         pedid.pedobs[2] + " " +
         pedid.pedobs[3] + " " +
         pedid.pedobs[4] + " " +
         pedid.pedobs[5] vcp
         skip.

    vx = 0.             
    for each liped of pedid no-lock.
        vx = vx + 1.
        find  produ of liped no-lock no-error.
        if not avail produ then next.
        vqtdabe = (liped.lipqtd - liped.lipent).
        if vqtdabe <= 0
        then  next.
        put unformatted "Itens" vcp
             vx vcp
             liped.pednum  vcp
             liped.procod vcp
             produ.pronom vcp
             vqtdabe vcp
             pedid.peddtf format "99/99/9999" vcp
             skip.
    end.
end.        
end.
output close.


output to /admcom/tmp/expsap/expcompra_pe.csv.

for each pedid where etbcod = 999 and pedtdc = 1  and pedid.sitped = "A" no-lock.
    if acha("Filial origem",pedid.pedobs[1]) <> ? /* ESPECIAL */
    then.
    else next.

    vqtdabe = 0.
    for each liped of pedid no-lock.
        vqtdabe = (liped.lipqtd - liped.lipent).
        if vqtdabe > 0 
        then leave.
    end.
    if vqtdabe = 0
    then next.

    find crepl of pedid no-lock.
    put  unformatted 
         "Cabeçalho" vcp
         pedid.pednum vcp
         pedid.clfcod vcp
         crepl.crenom vcp
         pedid.dupdes vcp
         pedid.pedobs[1] + " " +
         pedid.pedobs[2] + " " +
         pedid.pedobs[3] + " " +
         pedid.pedobs[4] + " " +
         pedid.pedobs[5] vcp
         skip.

    vx = 0.             
    for each liped of pedid no-lock.
        vx = vx + 1.
        find  produ of liped no-lock no-error.
        if not avail produ then next.
        vqtdabe = (liped.lipqtd - liped.lipent).
        if vqtdabe <= 0 
        then next.         
        put unformatted "Itens" vcp
             vx vcp
             liped.pednum  vcp
             liped.procod vcp
             produ.pronom vcp
             vqtdabe vcp
             pedid.peddtf format "99/99/9999" vcp
             skip.
    end.
end.        
output close.

