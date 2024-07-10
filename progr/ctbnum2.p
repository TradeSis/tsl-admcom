{admcab.i}
    
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vdt     like plani.pladat.
def var numant  like plani.numero.
    
def var vprocod like produ.procod.
def var vfil      like estab.etbcod.
def var tot-valor like plani.platot.
def var tot-base  like plani.platot.
def var tot-icms  like plani.platot.
def buffer bestab for estab.

def var vetb     like estab.etbcod.
def var vetbcod  like estab.etbcod.
def var vdti    as date format "99/99/9999".
def var  vdtf    as date format "99/99/9999".
def stream sarq.
def var vemp like estab.etbcod.
def var valor-icms as dec.
def var alicota-icms as dec.


def temp-table tt-ctb
    field etbmat like estab.etbcod 
    field etbliv like estab.etbcod.


input from l:\progr\ctbnum.txt.
repeat:

    create tt-ctb.
    import tt-ctb.

end.
input close.

for each tt-ctb where tt-ctb.etbmat = 0 or
                      tt-ctb.etbliv = 0:
    delete tt-ctb.

end.    
 


repeat:
    
    
    assign tot-valor = 0 
           tot-base  = 0 
           tot-icms  = 0.

    
    update vetbcod with frame f1.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom with frame f1.
    else do:
    
        find estab where estab.etbcod = vetbcod no-lock.

        display estab.etbnom no-label with frame f1.
        
    end.
    
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1 side-label width 80.

         
    find estab where estab.etbcod = vetbcod no-lock.
    
    find first tt-ctb where tt-ctb.etbmat = estab.etbcod no-lock no-error.
    if avail tt-ctb
    then vetb = tt-ctb.etbliv.
    else vetb = estab.etbcod.
    
    
    output to value("m:\livros\lebes" + string(vetb,"999") + ".imp").
 

    do vdt = vdti to vdtf:
        for each tipmov where tipmov.movtdc = 6 no-lock,
            each estab where if vetbcod = 0
                             then true
                             else estab.etbcod = vetbcod no-lock,
            each plani where  plani.desti  = estab.etbcod and
                              plani.pladat = vdt and
                              plani.movtdc = tipmov.movtdc no-lock:
            
            if plani.nottran = 0
            then numant = plani.numero.
            else numant = plani.nottran.
            
            put plani.pladat  " "
                numant        format "9999999" " "
                plani.numero  format "999999"  " "
                plani.platot  format "999999999.99" skip.
        
        end.
    end.
    output close.
end.




