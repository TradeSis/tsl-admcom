{admcab.i new}
    def var vtot as int.
    def var vok as int.
    def var vt as int.
    def var vn as int.
    
    def temp-table ttclien no-undo
        field clicod    as int format ">>>>>>>>>9"
        field prec      as recid
        field pneu      as recid
        index x is unique primary clicod asc.
 
def var vc as int.
def var vl as int.

def var vmarcar as char format "x(15)"
        extent 3 init ["Clientes","Limites","Contratos"].
def var lmarcar as log format "*/ "
        extent 3 init [no,no,no].



repeat:
    hide message no-pause.
    message color normal "tecle F1 para confirmar".
    disp 
    lmarcar[1]  vmarcar[1] skip
    lmarcar[2]  vmarcar[2] skip
    lmarcar[3] vmarcar[3]
    with frame fmarcar
        no-labels centered side-labels
        row 5
        with title "selecione as interfaces".
    
    choose field vmarcar
        go-on(F1 PF1)
    with frame fmarcar.
    if keyfunction(lastkey) = "GO"
    then leave.

    lmarcar[frame-index] = not lmarcar[frame-index].
           
end.           
hide message no-pause.
hide frame fmarcar no-pause.
if keyfunction(lastkey) = "END-ERROR"
then return.





    vtot = 0.
    vc = 0.
    vok = 0.
    vn = 0.
    vt = 0.
    empty temp-table ttclien.
       
    def var varqcsv as char format "x(65)" init "/admcom/tmp/clientes.csv".
    
    update varqcsv no-label colon 12
                            with side-labels width 80 frame f1
                            row 15 title "csv com codigos de clientes"
                            overlay.


    
    if search(varqcsv) = ?
    then do:
        message "arquivo não encontrado".
        undo.
    end.
    

   
    pause 0 before-hide.
    vn = 0.    
    input from value(varqcsv).
    repeat transaction:
        create ttclien.
        import ttclien.
        
        if ttclien.clicod = ? or ttclien.clicod = 0 then do:
            delete ttclien.
        end.    
        
    end.
    input close.
    for each ttclien where ttclien.clicod = 0.
        delete ttclien.
    end.
    pause before-hide.        
    
    vt = 0.
    for each ttclien.
        vt = vt + 1.
        if ttclien.clicod = ? or ttclien.clicod = 0 or ttclien.clicod = 1
        then do:
            vn = vn + 1.
            delete ttclien.
            next.
        end.         
        find clien where clien.clicod = ttclien.clicod no-lock no-error.
        if not avail clien
        then do:
            vn = vn + 1.
            delete ttclien.
            next.
        end.
        
        vok = vok + 1.
        ttclien.prec = recid(clien).

        if lmarcar[2] 
        then do:
            find first neuclien where neuclien.clicod = clien.clicod no-lock no-error.
            if avail neuclien
            then do:
                vl = vl + 1.
                ttclien.pneu = recid(neuclien).
            end.
        end.
        
        if lmarcar[3] 
        then do:
            for each contrato where contrato.clicod = clien.clicod no-lock.
                vc = vc + 1.
            end.
        end.
    end.
    
    vtot = vc + vok.
    
    if vtot > 100000
    then do:
        message "TOTAL DE REGISTROS SUPERIOR AO LIMITE DE 100000" vtot
            view-as alert-box.
        UNDO.
    end.    
        
    message (if lmarcar[3] then "Contratos: " + string(vc) else "") " Limites:" vl.

            
    message "Clientes Importados:" vt ", Erro:" vn ", Ok:" vok  
            "TOTAL=" vtot "    | Prosseguir?" update sresp. 
            
    if not sresp
    then return.

    pause 0 before-hide.
                    
    if lmarcar[1]
    then do:
        for each ttclien.
            find cretrigger where cretrigger.titnat = no and
                                  cretrigger.tabela = 'clien'         and
                                  cretrigger.trecid = ttclien.prec
                exclusive no-wait no-error.
            if avail cretrigger or
               (not avail cretrigger and not locked cretrigger)
            then do:   
                if not avail cretrigger
                then do:
                    create cretrigger.
                    cretrigger.titnat = no.     
                    cretrigger.tabela = 'clien'.
                    cretrigger.trecid = ttclien.prec.
                    cretrigger.acao   = "INSERT".
                    cretrigger.dtinc = today.
                    cretrigger.hrinc = time. 
                end.
                else do:
                    if not (cretrigger.dtinc = today and
                            cretrigger.hrinc = time)
                    then do:   
                        cretrigger.acao   = "UPDATE".
                        cretrigger.dtalt   = today.
                        cretrigger.hralt   = time.
                    end.       
                end. 
        
                cretrigger.dtenveis4 = ?.   
        
            end.        
        end.              
    end.
    if lmarcar[2]
    then do:
        for each ttclien where ttclien.pneu <> ?.
            find cretrigger where cretrigger.titnat = no and
                                  cretrigger.tabela = 'neuclien'         and
                                  cretrigger.trecid = ttclien.pneu
                exclusive no-wait no-error.
            if avail cretrigger or
               (not avail cretrigger and not locked cretrigger)
            then do:   
                if not avail cretrigger
                then do:
                    create cretrigger.
                    cretrigger.titnat = no.     
                    cretrigger.tabela = 'neuclien'.
                    cretrigger.trecid = ttclien.pneu.
                    cretrigger.acao   = "INSERT".
                    cretrigger.dtinc = today.
                    cretrigger.hrinc = time. 
                end.
                else do:
                    if not (cretrigger.dtinc = today and
                            cretrigger.hrinc = time)
                    then do:   
                        cretrigger.acao   = "UPDATE".
                        cretrigger.dtalt   = today.
                        cretrigger.hralt   = time.
                    end.       
                end. 
        
                cretrigger.liddtEnvio    = ?.
            end.        
        end.    
    end.
    if lmarcar[3]
    then do:
        for each ttclien.
          for each contrato where contrato.clicod = ttclien.clicod no-lock.
            find cretrigger where cretrigger.titnat = no and
                                  cretrigger.tabela = 'contrato'         and
                                  cretrigger.trecid = recid(contrato)
                exclusive no-wait no-error.
            if avail cretrigger or
               (not avail cretrigger and not locked cretrigger)
            then do:   
                if not avail cretrigger
                then do:
                    create cretrigger.
                    cretrigger.titnat = no.     
                    cretrigger.tabela = 'contrato'.
                    cretrigger.trecid = recid(contrato).
                    cretrigger.acao   = "INSERT".
                    cretrigger.dtinc = today.
                    cretrigger.hrinc = time. 
                end.
                else do:
                    if not (cretrigger.dtinc = today and
                            cretrigger.hrinc = time)
                    then do:   
                        cretrigger.acao   = "UPDATE".
                        cretrigger.dtalt   = today.
                        cretrigger.hralt   = time.
                    end.       
                end. 
        
                cretrigger.liddtEnvio    = ?        .
                
            end.        
        end.  
      end.
    
    end.        

    pause before-hide.
    message "processo encerrado".
            pause 2.

