{admcab.i}

def var vetbcod like estab.etbcod.
def var vdti    like com.plani.pladat initial today.
def var vdtf    like com.plani.pladat initial today.
def var ip   as char format "x(15)".


repeat:

    if connected ("comloja")
    then disconnect comloja.
    
    vdti = today.
    vdtf = today.

    update  vetbcod label "Filial"
            vdti    label "Data Inicial"
            vdtf    label "Data Final" 
            ip  label "IP - Filial" 
                with frame f1 side-label width 80 1 column
                    title "ATUALIZACAO DE NOTAS FISCAIS".
    
    message "Conectando...".
    connect com -H value(ip) -S sdrebcom -N tcp -ld comloja no-error.
    
    message "Conectando banco NFE...".
    connect nfe -H value(ip) -S sdrebnfe -N tcp -ld nfeloja no-error.
    
    if not connected ("comloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.    
        
    end.

    if not connected ("nfeloja")
    then do:
    
        sresp = no.
        message "Banco NFE nao conectado, deseja continuar?" update sresp.

        if not sresp
        then undo, retry.

    end.
    
    run atu11.p (input vetbcod,
                 input vdti,
                 input vdtf).
                   
    if connected ("comloja")
    then disconnect comloja.
    
    if connected ("nfeloja")
    then disconnect nfeloja.

end.