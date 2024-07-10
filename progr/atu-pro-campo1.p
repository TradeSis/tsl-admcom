def input parameter vetbcod like estab.etbcod.

def input parameter resp_dat as log.
def input parameter vdti    like com.plani.pladat.
def input parameter vdtf    like com.plani.pladat.

def input parameter resp_pro as log.
def input parameter vprocod-1 like com.produ.procod.
def input parameter vprocod-2 like com.produ.procod.

def var vqtd as int.
def var vqtdatu as int.

if resp_dat
then do:

    for each com.produ where com.produ.datexp = vdti /*and
                             com.produ.datexp <= vdtf*/ no-lock.
        vqtd = vqtd + 1.                     
        display "Atualizando Produtos...."
                vetbcod no-label
                com.produ.procod format ">>>>>>>>9" no-label
                vqtd no-label
                    with frame f1 1 down centered.
        pause 0.         
                               
    
        
        find comloja.produ where comloja.produ.procod = com.produ.procod 
                                                                    no-error.
        if not avail comloja.produ
        then next.

        if comloja.produ.procar = "INATIVO"
        then next.

        if com.produ.procar = "INATIVO"
        then do:
            comloja.produ.procar = com.produ.procar.
            vqtdatu = vqtdatu + 1.
        end.    
        disp vqtdatu no-label with frame f1 .
        pause 0.
    end.
end.
    
    



         

                       
