
def var ip   as char format "x(15)".
def var vdti as date format "99/99/9999" initial today.
def var vdtf as date format "99/99/9999" initial today.

repeat:
    
    
    if connected ("comloja")
    then disconnect comloja.
    
    

    update ip  label "IP - Filial" with frame f1 side-label width 80.
    
    message "Conectando...".
    connect com -H value(ip) -S sdrebcom -N tcp -ld comloja no-error.
    
    if not connected ("comloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.
        
    end.
    
 

end.