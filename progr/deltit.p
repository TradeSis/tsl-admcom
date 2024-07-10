{admcab.i}

def var vetbcod like estab.etbcod.
def var vdti    like com.plani.pladat initial today.
def var vdtf    like com.plani.pladat initial today.
def var ip   as char format "x(15)".
def var exptit  as log format "Sim/Nao" initial yes.
def var expcon  as log format "Sim/Nao" initial yes.



repeat:

    
    if connected ("finloja")
    then disconnect finloja.
    
    

    update ip  label "IP - Filial" 
                with frame f1 side-label width 80 1 column
                    title "ATUALIZACAO DE CONTRATOS".
    
    message "Conectando...".
    connect fin -H value(ip) -S sdrebfin -N tcp -ld finloja no-error.
    
    if not connected ("finloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.    
        pause.
        
    end.

    run deltitav.p.
                   
    if connected ("finloja")
    then disconnect finloja.
    
 

end.