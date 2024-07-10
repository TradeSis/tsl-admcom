for each estab where estab.etbcod <= 200 no-lock,
    each plani where plani.etbcod = estab.etbcod
                 and plani.pladat >= 11/01/2012
                 and plani.desti = estab.etbcod
                 and plani.serie = "1" no-lock.
    if plani.movtdc = 30
        or plani.movtdc = 5
        or plani.etbcod = 22
        or length(plani.ufdes) = 44
    then next.    
    find first a01_infnfe where a01_infnfe.etbcod = plani.etbcod
                      and a01_infnfe.placod = plani.placod no-lock no-error.
    if not avail a01_infnfe 
    then display plani.etbcod plani.numero format ">>>>>>>9"
                 plani.pladat plani.movtdc format ">>>9"
                 plani.datexp plani.serie plani.ufdes.
end.
