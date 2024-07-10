{admcab.i}

def var vetbcod like estab.etbcod.
def var ip      as char format "x(15)".


repeat:

   
    if connected ("comloja")
    then disconnect comloja.
    

    ip = "192.168.42.254".
    
    update ip label "IP - Filial"   at 2
                with frame f1 side-label width 80 
                    title "ATUALIZACAO DE NOTAS FISCAIS".
    
    message "Conectando...".
    connect com -H value(ip) -S sdrebcom -N tcp -ld comloja no-error.
    
    if not connected ("comloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.    
        
    end.
    
    run tipmov-22.p.

    run nfctbloj.p.
                   
    if connected ("comloja")
    then disconnect comloja.
    
 

end.