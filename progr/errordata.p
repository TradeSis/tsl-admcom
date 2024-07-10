def var vplacod like plani.placod.
def var vetbcod like plani.etbcod.
input from l:\gener\errodata.log.
repeat:
    import vplacod
           vetbcod
           ^.
         
    find first plani where plani.etbcod = vetbcod and
                           plani.placod = vplacod no-lock.
    disp movtdc format "99" emite desti format "9999999999" 
         datexp format "99/99/9999" pladat.
         
end.
input close.
