{admcab.i} 

def var vdti    like plani.pladat.
def var vdtf    like plani.pladat.
def var vetbcod like estab.etbcod.

repeat:
    update vetbcod with frame f1.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1 side-label width 80.
    
    dos silent del 
            value("m:\livros\entra" + string(estab.etbcod,">>9") +  ".txt").
 
    dos silent del 
            value("m:\livros\saida" + string(estab.etbcod,">>9") +  ".txt").
                
    
    run expser_l.p( input vetbcod,
                    input vdti,
                    input vdtf).
    
    
    run expfis_l.p( input vetbcod,
                    input vdti,
                    input vdtf).

    
    run expla_4.p( input vetbcod,
                   input vdti,
                   input vdtf).
        
    run expla_6.p( input vetbcod,
                    input vdti,
                    input vdtf).

 
    run expfis_1.p( input vetbcod,
                    input vdti,
                    input vdtf).
    
     
end.                    
       
       

