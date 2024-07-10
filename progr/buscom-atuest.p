{admcab.i}
def shared temp-table tt-movim like com.movim.

for each tt-movim :
    find movim where movim.etbcod = tt-movim.etbcod and
                     movim.placod = tt-movim.placod and
                     movim.procod = tt-movim.procod
                     no-lock no-error.
    if avail movim
    then do:
        run atuest.p(input recid(com.movim),
                         input "i",
                         input 0).
    end.
    delete tt-movim.    
end.
             

