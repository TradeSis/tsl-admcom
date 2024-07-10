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
    
    
    run expsai.p( input vetbcod,
                  input vdti,
                  input vdtf).
    
    run expent.p( input vetbcod,
                  input vdti,
                  input vdtf).

end.                    
       
       

