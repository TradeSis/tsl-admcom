def input parameter p-rectit as recid.
def output parameter p-catcod like produ.catcod.

def buffer bplani for plani.
def temp-table tt-plani like plani.
for each tt-plani: delete tt-plani. end.
def var i-serie as int.
find titulo where recid(titulo) = p-rectit no-lock.

if titulo.clifor = 111782 and
   titulo.clifor = 111768 and
   titulo.clifor = 103444
then do:
    find plani where  plani.movtdc = 37 and
                      plani.etbcod = titulo.etbcod and
                      plani.emite  = titulo.clifor and
                      plani.serie  = "1" and
                      plani.numero = int(titnum)
                      no-lock no-error.
    if not avail plani
    then find plani where  plani.movtdc = 37 and
                           plani.etbcod = titulo.etbcod and
                           plani.emite  = titulo.clifor and
                           plani.serie  = "U" and
                           plani.numero = int(titnum)
                           no-lock no-error.
 
    if avail plani
    then do:
        find first tt-plani where 
                           tt-plani.etbcod = plani.etbcod and
                           tt-plani.placod = plani.placod and
                           tt-plani.serie  = plani.serie
                           no-error.
        if not avail tt-plani
        then do:
                    create tt-plani.
                    buffer-copy plani to tt-plani.
        end.
    end.
end.
else do:   
    find first plani where  plani.movtdc = 4 and
                          plani.etbcod = titulo.etbcod and
                          plani.emite  = titulo.clifor and
                          plani.serie  = "0" and
                          plani.numero = int(titnum) 
                          no-lock no-error.
    if avail plani and plani.dtinclu = titulo.titdtemi
    then do:
        find first tt-plani where 
                           tt-plani.etbcod = plani.etbcod and
                           tt-plani.placod = plani.placod and
                           tt-plani.serie  = plani.serie
                           no-error.
        if not avail tt-plani
        then do:
                create tt-plani.
                buffer-copy plani to tt-plani.
        end.
    end.                      
    else find first plani where  plani.movtdc = 4 and
                          plani.etbcod = titulo.etbcod and
                          plani.emite  = titulo.clifor and
                          plani.serie  = "1" and
                          plani.numero = int(titnum)
                          no-lock no-error.
    if avail plani and plani.dtinclu = titulo.titdtemi
    then do:
        find first tt-plani where 
                           tt-plani.etbcod = plani.etbcod and
                           tt-plani.placod = plani.placod and
                           tt-plani.serie  = plani.serie
                           no-error.
        if not avail tt-plani
        then do:
                create tt-plani.
                buffer-copy plani to tt-plani.
        end.
    end.
    else do:
 
        find last bplani use-index pladat where bplani.movtdc = 4 and
                               bplani.emite = titulo.clifor  and
                               bplani.etbcod = titulo.etbcod and
                               bplani.pladat <= titulo.titdtemi
                               no-lock no-error.
        if not avail bplani
        then                       
        do i-serie = 1 to 50:
            find last plani where  plani.movtdc = 4 and
                          plani.etbcod = titulo.etbcod and
                          plani.emite  = titulo.clifor and
                          plani.serie  = string(i-serie) and
                          plani.numero = int(titnum)
                          no-lock no-error.
            if avail plani
            then do:
                find first tt-plani where 
                           tt-plani.etbcod = plani.etbcod and
                           tt-plani.placod = plani.placod and
                           tt-plani.serie  = plani.serie
                           no-error.
                if not avail tt-plani
                then do:
                    create tt-plani.
                    buffer-copy plani to tt-plani.
                    leave.
                end.
            end.
        end.
        else do:
            find last plani where  plani.movtdc = 4 and
                                    plani.etbcod = titulo.etbcod and
                                    plani.emite  = titulo.clifor and
                                    plani.serie  = bplani.serie and
                                    plani.numero = int(titnum)
                                    no-lock no-error.
            if avail plani
            then do:
                find first tt-plani where 
                           tt-plani.etbcod = plani.etbcod and
                           tt-plani.placod = plani.placod and
                           tt-plani.serie  = plani.serie
                           no-error.
                if not avail tt-plani
                then do:
                    create tt-plani.
                    buffer-copy plani to tt-plani.
                end.
            end.
        end.                   
    end.
end.
p-catcod = 0.
find first tt-plani where  
           tt-plani.etbcod = titulo.etbcod and
           tt-plani.emite  = titulo.clifor and
           tt-plani.numero = int(titulo.titnum) and
           tt-plani.dtinclu = titulo.titdtemi
           no-lock no-error.
if avail tt-plani
then do:
    for each movim where 
             movim.etbcod = plani.etbcod and
             movim.placod = plani.placod and
             movim.movtdc = plani.movtdc
             no-lock:
        find produ where produ.procod = movim.procod
                                 no-lock no-error.
        if avail produ and p-catcod = 0
        then p-catcod = produ.catcod.
    end. 
end.