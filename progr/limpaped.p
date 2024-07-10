{admcab.i}
/* comentado em 01/08 por Luciano da Linx */
do on error undo.
leave.
end.

def var vetbcod like estab.etbcod.
def stream spedid.
def stream sliped.
def var varq1 as char.
def var varq2 as char.


repeat:


    update vetbcod label "Filial"
            with frame f1 side-label width 80.
    
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Filial nao cadastrada".
        undo, retry.
        
        
    end.

    display estab.etbnom no-label with frame f1.
    
    message "Confirma exclusao dos pedidos" update sresp.
    if sresp = no
    then undo, retry.
    
    if opsys = "unix"
    then assign varq1 = "/admcom/backup/pedid" + string(vetbcod,">>9") + ".d"
                varq2 = "/admcom/backup/liped" + string(vetbcod,">>9") + ".d".
    else assign varq1 = "l:\backup\pedid" + string(vetbcod,">>9") + ".d"
                varq2 = "l:\backup\liped" + string(vetbcod,">>9") + ".d".


    
    output stream spedid to value(varq1).
    output stream sliped to value(varq2).
    for each pedid where pedid.etbcod = estab.etbcod and
                         pedid.pedtdc = 03:
                         
        for each liped of pedid:
        
            export stream sliped liped.                 
            delete liped.

        end.
        

        export stream spedid pedid.
        
        delete pedid.
        
    end.     
    output stream spedid close.
    output stream sliped close. 
    
    message "Exclusao concluida".
    
    
end.    
