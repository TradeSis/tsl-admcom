{admcab.i}

def var vetbcod like estab.etbcod.
def var vdti    like com.plani.pladat initial today.
def var vdtf    like com.plani.pladat initial today.
def var ip   as char format "x(15)".


repeat:

    if connected ("gerloja")
    then disconnect gerloja.
    
    update ip  label "IP - Filial"  
            with frame f1 side-label width 80 1 column
                    title "ATUALIZACAO DE CLIENTES".
    
    message "Conectando...".
    connect ger -H value(ip) -S sdrebger -N tcp -ld gerloja no-error.
    
    if not connected ("gerloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.    
        
    end.

    run atu55.p.
     
                   
    if connected ("gerloja")
    then disconnect gerloja.
    
 

end.