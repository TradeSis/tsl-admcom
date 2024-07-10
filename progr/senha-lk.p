{admcab.i}

def var vsenha as int.
def var vetbcod like estab.etbcod.
repeat:

    update vetbcod label "Filial" with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "filial nao cadastrada".
        undo, retry.
    end.
    
    display estab.etbnom no-label with frame f1.

    vsenha = year(today)  + 
             month(today) + 
             day(today).
             
    
    vsenha = ((vsenha * 107) / estab.etbcod).
    vsenha = estab.etbcod + day(today) + month(today) + 100.
    
    disp vsenha label "       Senha" format ">>>>>>>>>9" 
                    with frame f1.
    

end.

