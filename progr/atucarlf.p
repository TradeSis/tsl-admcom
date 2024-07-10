{admcab.i}

def var vetbcod like estab.etbcod.
def var vdti    like com.plani.pladat initial today.
def var vdtf    like com.plani.pladat initial today.
def var ip   as char format "x(15)".
def var exptit  as log format "Sim/Nao" initial yes.
def var expcon  as log format "Sim/Nao" initial yes.



repeat:

    if connected ("finloja")
    then disconnect finloja.
    
    vdti = today.
    vdtf = today.

    update  vetbcod label "Filial"
                with frame f1 side-label width 80 1 column
                    title "ATUALIZACAO DE CARTAO LEBES". 
    ip = "filial" + string(vetbcod,"999").
    message "Conectando...  " ip.
    connect adm -H value(ip) -S sadm -N tcp -ld admloja no-error.
    
    if not connected ("admloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.    
        
    end.

    run atucarlf01.p (input vetbcod).
                   
    if connected ("admloja")
    then disconnect admloja.
    
 

end.