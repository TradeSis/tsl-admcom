{admcab.i}

def var vetbcod like estab.etbcod.
def var vdata   as date format "99/99/9999" initial today.
def var n-env   as int format "9999999999".


def var ip   as char format "x(15)".

repeat:

    if connected ("finloja")
    then disconnect finloja.
    


    update  vetbcod label "Filial"
            vdata   label "Data do Deposito"
            n-env   label "Envelope"
            ip  label "IP - Filial" with frame f1 side-label width 80.
    
    message "Conectando...".
    connect fin -H value(ip) -S sdrebfin -N tcp -ld finloja no-error.
    
    if not connected ("finloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.    
        
    end.

    run del_ban.p (input vetbcod,
                   input vdata,
                   input n-env).
                   
    if connected ("finloja")
    then disconnect finloja.
    
 

end.