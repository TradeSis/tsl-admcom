def shared temp-table tt-clispc
    field clicod like clien.clicod
    index i1 is primary unique clicod.

def var vspc as log init no.
for each tt-clispc:
    find clien where clien.clicod = tt-clispc.clicod no-lock no-error.
    if not avail clien 
    then next.
    else do:
        find first fin.clispc where 
                           fin.clispc.clicod = clien.clicod and 
                           fin.clispc.dtcanc = ? no-lock no-error.
        if avail fin.clispc
        then vspc = yes.
        else do:
            find first d.titulo where
                               d.titulo.empcod = 19 and
                               d.titulo.titnat = no and
                               d.titulo.modcod = "CRE" and
                               d.titulo.titdtven < today - 60 and
                               d.titulo.clifor = clien.clicod and
                               d.titulo.titsit = "LIB"
                               no-lock no-error.
            if avail d.titulo
            then vspc = yes.
            else do:
                find first fin.cheque where 
                                   fin.cheque.clicod = clien.clicod and
                                   fin.cheque.chesit = "LIB"
                                   no-lock no-error.
                if avail fin.cheque
                then vspc = yes.           
                else vspc = no.
            end.
        end.
        if vspc = no
        then delete tt-clispc.
   end.
end.