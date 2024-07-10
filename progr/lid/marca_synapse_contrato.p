{admcab.i new}
    def var vtot as int.
    def var vok as int.
    def var vt as int.
    def var vn as int.
    
    def temp-table ttcontrato no-undo
        field contnum    as int format ">>>>>>>>>9"
        field prec      as recid
        index x is unique primary contnum asc.
 
def var vc as int.
def var vl as int.

    vtot = 0.
    vc = 0.
    vok = 0.
    vn = 0.
    vt = 0.
    empty temp-table ttcontrato.
       
    def var varqcsv as char format "x(65)" init "/admcom/tmp/contratos.csv".
    
    update varqcsv no-label colon 12
                            with side-labels width 80 frame f1
                            row 15 title "csv com numeros de contratos"
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
        create ttcontrato.
        import ttcontrato.
        
        if ttcontrato.contnum = ? or ttcontrato.contnum = 0 then do:
            delete ttcontrato.
        end.    
        
    end.
    input close.
    for each ttcontrato where ttcontrato.contnum = 0.
        delete ttcontrato.
    end.
    pause before-hide.        
    
    vt = 0.
    for each ttcontrato.
        vt = vt + 1.
        if ttcontrato.contnum = ? or ttcontrato.contnum = 0 or ttcontrato.contnum = 1
        then do:
            vn = vn + 1.
            delete ttcontrato.
            next.
        end.         
        find contrato where contrato.contnum = ttcontrato.contnum no-lock no-error.
        if not avail contrato
        then do:
            vn = vn + 1.
            delete ttcontrato.
            next.
        end.
        
        vok = vok + 1.
        ttcontrato.prec = recid(contrato).

    end.
    
    vtot = vc + vok.
    
    if vtot > 100000
    then do:
        message "TOTAL DE REGISTROS SUPERIOR AO LIMITE DE 100000" vtot
            view-as alert-box.
        UNDO.
    end.    
        
    message "Contratos Importados:" vt ", Erro:" vn ", Ok:" vok  
            "TOTAL=" vtot "    | Prosseguir?" update sresp. 
            
    if not sresp
    then return.

    pause 0 before-hide.
                    
        for each ttcontrato.
            find cretrigger where cretrigger.titnat = no and
                                  cretrigger.tabela = 'contrato'         and
                                  cretrigger.trecid = ttcontrato.prec
                exclusive no-wait no-error.
            if avail cretrigger or
               (not avail cretrigger and not locked cretrigger)
            then do:   
                if not avail cretrigger
                then do:
                    create cretrigger.
                    cretrigger.titnat = no.     
                    cretrigger.tabela = 'contrato'.
                    cretrigger.trecid = ttcontrato.prec.
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
        
    pause before-hide.
    message "processo encerrado".
            pause 2.
