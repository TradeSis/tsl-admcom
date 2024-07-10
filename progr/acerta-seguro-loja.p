    def var sresp as log format "Sim/Nao".
    def var vip as char format "x(15)".    
    def new shared var setbcod like estab.etbcod.
    update setbcod label "Filial" with frame f-5 .
        vip = "FILIAL" + string(setbcod,"999").
        disp vip  no-label 
        with frame f-5 side-label width 80.     
                
        message "Conectando..." vip.
        connect com -H value(vip) -S sdrebcom -N tcp -ld comloja.
    
        if not connected ("comloja")
        then do:
            message color red/with
            "FALHA NA CONEXAO COM A FILIAL"
            view-as alert-box.
            undo, retry.       
        end. 
        sresp = no.
        message "Confirma ajuste sequencia certificado seguro?"
        update sresp.
        
        run acerta-seguro-loja1.p.
        
        if connected ("comloja")
        then disconnect comloja.

 

