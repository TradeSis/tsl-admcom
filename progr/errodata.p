def temp-table tt-pro
    field procod like produ.procod
    field placod like plani.placod
    field etbcod like plani.etbcod.

def var vprocod like produ.procod.
def var vplacod like plani.placod.
def var vetbcod like plani.etbcod.

for each tt-pro:
    delete tt-pro.
end.
    
input from l:\gener\errodata.log.
repeat:
    import vplacod
           vetbcod
           ^
           ^
           ^
           vprocod. 
    
    create tt-pro.
    assign tt-pro.procod = vprocod
           tt-pro.etbcod = vetbcod
           tt-pro.placod = vplacod.
end.
input close.

for each tt-pro,
    each movim where movim.etbcod = tt-pro.etbcod and
                     movim.placod = tt-pro.placod and
                     movim.procod = tt-pro.procod no-lock by movim.datexp
                                                          by tt-pro.etbcod:
                         
        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod no-lock no-error.
                   
        find tipmov where tipmov.movtdc = plani.movtdc no-lock.
        display movim.procod 
                tipmov.movtdc
                plani.emite
                plani.desti  format ">>>>>>>999"
                plani.numero
                plani.datexp format "99/99/9999" column-label "Data"
                plani.platot
                        with frame ff down width 80.
        down with frame ff.
end.
