{admcab.i}
def var vetbcod like estab.etbcod.
def var ip   as char format "x(15)".
def var vdti as date format "99/99/9999" initial today.
def var vdtf as date format "99/99/9999" initial today.

def new shared temp-table tt-movim like com.movim.
repeat:

    if connected ("comloja")
    then disconnect comloja.
    

    update vetbcod label "Filial"
           ip  label "IP - Filial" 
           vdti label "Periodo"
           vdtf no-label with frame f1 side-label width 80.
    
    message "Conectando...".
    connect com -H value(ip) -S sdrebcom -N tcp -ld comloja no-error.
    
    if not connected ("comloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.
        
    end.
    

 
    run buscom1.p (input vetbcod,
                   input vdti,
                   input vdtf).

    if connected ("comloja")
    then disconnect comloja.
    
    run buscom-atuest.p .

end.