{admcab.i}

def var vetbcod like estab.etbcod.
def var ip      as char format "x(15)".
def var vdti    like plani.pladat.
def var vdtf    like plani.pladat.
def var vprocod-1 like produ.procod format ">>>>>>>>>".
def var vprocod-2 like produ.procod format ">>>>>>>>>".
def var resp_dat as log format "Sim/Nao" initial no.
def var resp_pro as log format "Sim/Nao" initial no.


repeat:

    if connected ("comloja")
    then disconnect comloja.
    

    update vetbcod label "Filial     "   at 2
           ip      label "IP - Filial"   at 2
                with frame f1 side-label width 80 
                    title "ATUALIZACAO DE PRODUTOS".
    
    update resp_dat      label "Por Periodo" at 2 with frame f1.
    if resp_dat
    then do:
        update vdti no-label
               vdtf no-label with frame f1.
    end.
    else do:
        resp_pro = yes.
        update vprocod-1 label "Produto    " at 2
               vprocod-2 no-label with frame f1.
        if vprocod-1 = 0 and
           vprocod-2 = 0
        then display "Todos" with frame f1.
    
    end.

    message "Conectando...".
    connect com -H value(ip) -S sdrebcom -N tcp -ld comloja no-error.
    
    if not connected ("comloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.    
        
    end.

    run atu44.p (input vetbcod,
                 input resp_dat,
                 input vdti,
                 input vdtf,
                 input resp_pro,
                 input vprocod-1,
                 input vprocod-2).
                   
    if connected ("comloja")
    then disconnect comloja.
    
 

end.