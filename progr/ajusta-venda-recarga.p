{admcab.i new}
def var vrecarga as log init no.
def var vtotal as dec init 0. 
def var vclicod like clien.clicod.
def var vnumero like plani.numero.
update vclicod vnumero.
for each plani where
         plani.movtdc = 5 and
         plani.desti  = vclicod and
         plani.numero = vnumero
         .
    vrecarga = no.
    for each movim where
             movim.etbcod = plani.etbcod and
             movim.placod = plani.placod and
             movim.movtdc = plani.movtdc and
             movim.movdat = plani.pladat
             no-lock:

        find produ where produ.procod = movim.procod no-lock no-error.
        if produ.pronom matches "*RECARGA*"
        then vrecarga = yes.
        disp movim.procod produ.pronom movpc * movqtm(total).
    end.
    if vrecarga
    then do:
        sresp = no.
        message "Ajustar RECARGA? " update sresp.
        if sresp
        then do:
            vtotal = 0.
            for each movim where
                 movim.etbcod = plani.etbcod and
                 movim.placod = plani.placod and
                 movim.movtdc = plani.movtdc and
                 movim.movdat = plani.pladat
                 :

                find produ where 
                    produ.procod = movim.procod no-lock no-error.
                if produ.pronom matches "*RECARGA*"
                then delete movim.
                else vtotal = vtotal + (movim.movpc * movim.movqtm).
            end.
            plani.platot = vtotal.
            plani.protot = vtotal.
        end.        
    end.
end.