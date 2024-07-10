{admcab.i}  

def var vnumi    like plani.numero initial 0.
def var vnumf    like plani.numero initial 0.
def var vetbcod like estab.etbcod.

repeat:

    update vetbcod colon 20 with frame f1.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vnumi label "Numeracao de Nota" colon 20
           "Ate " vnumf no-label with frame f1 side-label width 80.
    
    dos silent del 
            value("m:\livros\entra" + string(estab.etbcod,">>9") +  ".txt").
 
    dos silent del 
            value("m:\livros\saida" + string(estab.etbcod,">>9") +  ".txt").
                
    
    run placon_4.p( input vetbcod,
                   input vnumi,
                   input vnumf).
        
    run placon_6.p( input vetbcod,
                    input vnumi,
                    input vnumf).

end.                    
       
       

