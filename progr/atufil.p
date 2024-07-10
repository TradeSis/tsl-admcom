{admcab.i}

def var vetbcod like estab.etbcod.
def var vdti    like com.plani.pladat initial today.
def var vdtf    like com.plani.pladat initial today.
def var ip   as char format "x(15)".
def buffer xestab for estab.
def var v-conecta as log format "Sim/Nao".



repeat:

    if connected ("finloja")
    then disconnect finloja.

    if connected ("comloja")
    then disconnect comloja.
 
    if connected ("gerloja")
    then disconnect gerloja.
    
    vdti = date(month(today),day(today),year(today) - 1).
    vdtf = today.
    do on error undo:
        update  vetbcod label "Filial" at 7
                with frame f-1.
                                
        if vetbcod <> 0
        then do:
            find xestab where xestab.etbcod = vetbcod no-lock no-error.
            if not avail xestab
            then do:
                message "Estabelecimento nao Cadastrado".
                undo.
            end.
            else disp xestab.etbnom no-label 
                        with frame f-1.
        end.
        else disp "Todas" @ xestab.etbnom no-label with frame f-1.
                                     
    end.
                    
    update  vdti  label "Data Inicial"  at 1
            vdtf  label "Data Final  "  at 1
                    with frame f-1.
                    
    update v-conecta label "Conectar Servidor" 
                    with frame f-1.
    if v-conecta = no 
    then do:

        display  "ARQUIVOS EXPORTADOS PARA O DIRETORIO ---> /admcom/dados"
            with frame f-message centered no-box.

    
        run atu_ger1.p (input vetbcod, 
                        input vdti, 
                        input vdtf).

        run atu_com1.p (input vetbcod, 
                        input vdti,  
                        input vdtf).

        run atu_fin1.p (input vetbcod, 
                        input vdti,  
                        input vdtf).
    
    
        return.
    end.

    update ip label "IP - Filial" at 2 
                     with frame f-1 side-label width 80
                             title "ATUALIZACAO DE CLIENTES".
                         
                         
    message "Conectando...".
    connect ger -H value(ip) -S sdrebger -N tcp -ld gerloja no-error.
    
    if not connected ("gerloja")
    then do:
        
        message "Banco nao conectado". 
        undo, retry.    
        
    end.

    run atu_ger.p (input vetbcod, 
                   input vdti, 
                   input vdtf).
    if connected ("gerloja")
    then disconnect gerloja.
    
    message "Conectando...".
    connect com -H value(ip) -S sdrebcom -N tcp -ld comloja no-error.
    
    if not connected ("comloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.    
        
    end.

    run atu_com.p (input vetbcod,
                   input vdti,
                   input vdtf).
                   
    if connected ("comloja")
    then disconnect comloja.
    
    message "Conectando...".
    connect fin -H value(ip) -S sdrebfin -N tcp -ld finloja no-error.
    
    if not connected ("finloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.    
        
    end.
    
    run atu_fin.p (input vetbcod,
                   input vdti,
                   input vdtf).
                   
    if connected ("finloja")
    then disconnect finloja.
    
    
    message "Conectando...".
    connect nfe -H value(ip) -S sdrebnfe -N tcp -ld nfeloja no-error.
    
    if not connected ("nfeloja")
    then do:
        
        message "Banco nao conectado".
        undo, retry.    
        
    end.

    run atu_nfe.p (input vetbcod,
                   input vdti,
                   input vdtf).
                   
    if connected ("nfeloja")
    then disconnect nfeloja.



end.