{admcab.i}

def var ip   as char format "x(15)".
def var vdti as date format "99/99/9999" initial today.
def var vdtf as date format "99/99/9999" initial today.

repeat:

    if connected ("admloja")
    then disconnect admloja.
    

    update ip  label "IP - Filial" with frame f1 side-label width 80.
    
    message "Conectando...".
    connect adm -H value(ip) -S sadm -N tcp -ld admloja no-error.
    
    if not connected ("admloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.
        
    end.
    
 
    run buscaadm.p.

    if connected ("admloja")
    then disconnect admloja.

end.