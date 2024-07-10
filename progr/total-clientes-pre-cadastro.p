def var vq as int.
def var va as int.
for each clien where dtcad > 09/30/2012 no-lock:
    find cpclien of clien no-lock no-error.
    if avail cpclien
    then next.
    if clien.dtnasc = ?
        and clien.pai = ?
        and clien.mae = ?
    then do:
        find first contrato where 
                contrato.clicod = clien.clicod no-lock no-error.
        if not avail contrato
        then do:
            find first titulo where
                       titulo.clifor = clien.clicod and 
                       titulo.modcod = "CRE"
                       no-lock no-error.
            if not avail titulo
            then do:           
            find first plani where plani.movtdc = 5 and
                        plani.desti  = clien.clicod /*
                        plani.crecod = 1*/
                        no-lock no-error.
            if avail plani
            then vq = vq + 1.
            else va = va + 1.
            end.
        end.
        /*else disp clien.clicod clien.dtcad clien.dtnasc clien.datexp.
        */
    end.
end.
disp vq label "Compraram" va label "Nao compraram"
vq + va label "Total".

    