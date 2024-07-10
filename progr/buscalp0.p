


def var vetbcod like estab.etbcod.
def var ip   as char format "x(15)".
def var vdti as date format "99/99/9999" initial today.
def var vdtf as date format "99/99/9999" initial today.

repeat:

    if connected ("finloja")
    then disconnect finloja.
    


    update  vdti 
            vdtf
            vetbcod label "filial"
            ip  label "IP - Filial" with frame f1 side-label width 80.
    
    message "Conectando...".
    connect fin -H value(ip) -S sdrebfin -N tcp -ld finloja no-error.
    
    if not connected ("finloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.
        
    end.

    run buscalp.p (input vetbcod,
                   input vdti,
                   input vdtf).
    

end.