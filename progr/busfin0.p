{admcab.i}
def var vetbcod like estab.etbcod.
def var ip   as char format "x(15)".
def var vdti as date format "99/99/9999" initial today.
def var vdtf as date format "99/99/9999" initial today.
def var vclicod like clien.clicod.
repeat:

    if connected ("finloja")
    then disconnect finloja.
    

    update vetbcod label "Filial" with frame f1 side-label width 80.
    ip = "filial" + string(vetbcod,"999").
    update
           ip  label "IP - Filial" 
           with frame f1.
           
    update vclicod at 1 label "Cliente"    
            with frame f1.
    if vclicod > 0 
    then find clien where clien.clicod = vclicod no-lock.
    else update    
           vdti label "Periodo" 
           vdtf no-label with frame f1 side-label width 80.

    message "Conectando...".
    connect fin -H value(ip) -S sdrebfin -N tcp -ld finloja no-error.
    connect dragao -N tcp -S sdragao -H "erp.lebes.com.br" -ld d no-error.
    
    if not connected ("finloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.
        
    end.
    

    hide message no-pause.
    
    message "BANCO CONECTADO... AGUARDE ".
    
    run busfin1.p (input vdti,
                   input vdtf,
                   input vetbcod,
                   input vclicod).

end.