def input param par-rec as recid.

find abastwms where recid(abastwms) = par-rec no-lock.

for each abastransf where abastransf.abatipo = abastwms.abatipo
    exclusive.
    find produ of abastransf no-lock.
    if produ.catcod = abastwms.catcod
    then do:
        abastransf.wms = abastwms.wms.
    end.
end.    
