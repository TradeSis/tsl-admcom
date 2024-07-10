{admcab.i}
def var vetbcod like estab.etbcod.
def var vdti as date format "99/99/9999" initial today.
def var vdtf as date format "99/99/9999" initial today.
    
def stream shabil.

repeat:


    update vetbcod label "Filial"
           vdti label "Periodo" 
           vdtf no-label with frame f1 side-label width 80.
    
    output stream shabil to l:\dados\habil.d.
    
    for each habil where habil.etbcod = vetbcod and
                         habil.habdat >= vdti   and
                         habil.habdat <= vdtf   no-lock.

        display "Exportando..." habil.habdat with 1 down. pause 0.
        export stream shabil habil.        
        
    end.
    output stream shabil close.
    
end.


