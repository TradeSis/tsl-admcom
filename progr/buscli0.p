
def var ip   as char format "x(15)".
def var vdti as date format "99/99/9999" initial today.
def var vdtf as date format "99/99/9999" initial today.

repeat:

    if connected ("gerloja")
    then disconnect gerloja.
    

    update ip  label "IP - Filial" with frame f1 side-label width 80.
    
    message "Conectando...".
    connect ger -H value(ip) -S sdrebger -N tcp -ld gerloja no-error.
    
    if not connected ("gerloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.
        
    end.
    
 
    run buscacli.p.

end.