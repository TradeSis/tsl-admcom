{admcab.i}

def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
def var vdti    like com.plani.pladat initial today.
def var vdtf    like com.plani.pladat initial today.
def var ip   as char format "x(15)".
def buffer xestab for estab.

def new shared temp-table tt-estab
    field etbcod like ger.estab.etbcod
    index i1 etbcod.

form with frame f-1.
repeat:

                       
    if connected ("gerloja")
    then disconnect gerloja.
    
    vdti = today.
    vdtf = today.
    
    repeat:
        update vetbi label "Filial" at 7 /*
           vetbf label "Filial"*/ with frame f-1.
        find estab where estab.etbcod = vetbi no-lock .
        find first tt-estab where
                   tt-estab.etbcod = vetbi no-error.
        if not avail tt-estab
        then do:
            create tt-estab.
            tt-estab.etbcod = vetbi.
        end.           
        disp tt-estab.etbcod estab.etbnom
            with frame f-est down centered no-label.
    end.                            
    for each tt-estab where tt-estab.etbcod = 0 .
        delete tt-estab.
    end.    
    update 
           ip    label "IP - Filial" at 2 
           vdti  label "Data Inicial" at 1
           vdtf  label "Data Final"  at 3 
                 with frame f-1 side-label width 80
                         title "ATUALIZACAO DE CLIENTES".
                         
                         
    
    message "Conectando...".
    connect ger -H value(ip) -S sdrebger -N tcp -ld gerloja no-error.
    
    if not connected ("gerloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.    
        
    end.

    run atu33.p (input vetbi,
                 input vetbf,
                 input vdti,
                 input vdtf).

    if connected ("gerloja")
    then disconnect gerloja.
    

end.