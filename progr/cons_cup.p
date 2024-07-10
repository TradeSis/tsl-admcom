{admcab.i}
def var vcatcod like categoria.catcod.
def var sem as dec label "ValSem".
def var com as dec label "ValCom".
def var numsem as int label "NumSem".
def var numcom as int label "NumCom".

def var vdati as date format "99/99/9999" initial today.
def var vdatf as date format "99/99/9999" initial today.
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.


def var vsenha like func.senha.
do on error undo, return on endkey undo, retry:
    vsenha = "".
    update vsenha blank with frame f-senh side-label centered row 10.
    if vsenha  <> "1951"
    then do:
        message "Senha Invalido.".
        undo, return.
    end.
end.
hide frame f-senh no-pause.


repeat:

    sem = 0.
    com = 0.
    numsem = 0.
    numcom = 0.
    
    update vetbi label "Filial" colon 15
           vetbf label "Filial"
           vdati label "Data Inicial" colon 15
           vdatf label "Data Final  " with frame f1 side-label width 80.
           
    update vcatcod label "Departamento" colon 15 with frame f1.       
    
    find categoria where categoria.catcod = vcatcod no-lock.
    
    display categoria.catnom no-label with frame f1.

    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:
        assign sem    = 0
               com    = 0
               numsem = 0
               numcom = 0.
                            
        
        for each plani where plani.pladat >= vdati        and
                             plani.pladat <= vdatf        and
                             plani.etbcod  = estab.etbcod and
                             plani.movtdc  = 05 no-lock: 
    
            find first movim where movim.etbcod = plani.etbcod and
                                   movim.placod = plani.placod and
                                   movim.movdat = plani.pladat and
                                   movim.movtdc = plani.movtdc no-lock no-error.
        
            if not avail movim
            then next.
            find produ where produ.procod = movim.procod no-lock.                            
            if produ.catcod <> vcatcod
            then next. 
    
            if notped = ""
            then do:
                sem = sem + (plani.platot - vlserv - descprod + acfprod).
                numsem = numsem + 1.
            end.
            else do:
                com = com + (plani.platot - vlserv - descprod + acfprod).
                numcom = numcom + 1.
            end.
    
        end. 
    
        disp estab.etbcod format ">>9" column-label "Fl"
             sem 
             com  
             ((sem * 100) / com) format ">>9.99%" column-label " % "
             numsem format ">>>9"
             numcom format ">>>9"
             ((numsem * 100) / numcom) format ">>9.99%" column-label " % "
                    with frame f2 down centered color black/message. 
    end.
    
end.