{admcab.i new}

/*** ate filial 10 ***/

def var vetbcod like estab.etbcod.
def var ip      as char format "x(15)".
def var vdti    like com.plani.pladat.
def var vdtf    like com.plani.pladat.
def var vprocod-1 like com.produ.procod format ">>>>>>".
def var vprocod-2 like com.produ.procod format ">>>>>>".
def var resp_dat as log format "Sim/Nao" initial no.
def var resp_pro as log format "Sim/Nao" initial no.

def var vetb1 like vetbcod.
def var vetb2 like vetbcod.

repeat:

    if connected ("comloja")
    then disconnect comloja.
    

    update vetb1 label "Filial "   at 2
           vetb2 label "Ate"
           with frame f1 side-label width 80 .

    resp_dat = yes.
    update vdti no-label
           vdtf no-label with frame f1.
    
    
    do vetbcod = vetb1 to vetb2:
    ip = "filial"  + string(vetbcod,"999").
    message "Conectando...  " ip.
    connect com -H value(ip) -S sdrebcom -N tcp -ld comloja no-error.
    
    if not connected ("comloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.    
        
    end.

    run atu-pro-campo1.p (input vetbcod,
                 input resp_dat,
                 input vdti,
                 input vdtf,
                 input resp_pro,
                 input vprocod-1,
                 input vprocod-2).
                   
    if connected ("comloja")
    then disconnect comloja.
    end.
 

end.