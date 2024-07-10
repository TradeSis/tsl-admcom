{cabec.i new}

function topto returns character
    (input par-virgula as char).
     return replace(par-virgula,",",".").
end function.

def temp-table tt-ncm
    field ncm    as int
    field st-rs  as char
    field st-sc  as char
    field cest   as char
    field mva-sc as char.

input from /admcom/import/mvasc.csv.
repeat.
    create tt-ncm.
    import delimiter ";" tt-ncm.
    tt-ncm.mva-sc = topto(tt-ncm.mva-sc).
    tt-ncm.cest   = replace(tt-ncm.cest,".","").
end.
input close.

/* Importar MVA */
for each tt-ncm where tt-ncm.st-sc = "S" no-lock.
    disp tt-ncm.
    disp dec(tt-ncm.mva-sc).

    find first tribicms where tribicms.pais-sigla   = "BRA"
                      and tribicms.ufecod       = "SC"
                      and tribicms.pais-dest    = "BRA"
                      and tribicms.unfed-dest   = "SC"
                      and tribicms.procod       = 0
                      and tribicms.cfop         = 0
                      and tribicms.agfis-cod    = tt-ncm.ncm
                      and tribicms.agfis-dest   = 0
                      and tribicms.dativig     <= today
                      and ( tribicms.datfvig    = ? or
                            tribicms.datfvig   >= today )
                            use-index tribicms no-error.
    disp avail tribicms.
    if avail tribicms
    then do.
        disp tribicms.PctMgSubst.
        tribicms.PctMgSubst = dec(tt-ncm.mva-sc).
    end.
end.

/* Importar CEST */
for each tt-ncm where length(tt-ncm.cest) = 7 and
         (tt-ncm.st-rs = "S" or tt-ncm.st-sc = "S") no-lock.
    find clafis where clafis.codfis = tt-ncm.ncm no-error.
    if avail clafis and clafis.char1 = ""
    then do.
        disp clafis.codfis.
        clafis.char1 = tt-ncm.cest.
    end.
end.

