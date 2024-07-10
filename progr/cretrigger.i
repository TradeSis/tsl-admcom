/* 
* 08.2019 - Include De Registro de REPLICATION- USANDO TABELA CreTrigger
*/

DO for creTrigger TRANSACTION.

    def var w_cretrigger_titnat as log init no.

    if '{&tabela}' = 'TITULO'
    then do:
        if avail titulo
        then do:
            w_cretrigger_titnat = titulo.titnat.
        end.    
    end.    
    if '{&tabela}' = "CONTRATO"
    then do:
        w_cretrigger_titnat = no.
    end.    
    

    find cretrigger where cretrigger.titnat = w_cretrigger_titnat and
                          cretrigger.tabela = '{&tabela}'         and
                          cretrigger.trecid = Recid({&tabela})
        exclusive no-wait no-error.
    if avail cretrigger or
       (not avail cretrigger and not locked cretrigger)
    then do:   
        if not avail cretrigger
        then do:
            create cretrigger.
            cretrigger.titnat = w_cretrigger_titnat.     
            cretrigger.tabela = '{&tabela}'.
            cretrigger.trecid = Recid({&tabela}).
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
        
        if avail {&old} 
        then do: 
            BUFFER-COMPARE {&tabela} TO {&old} SAVE cretrigger.camposdif. 

            if '{&tabela}' = 'TITULO'
            then do:
                if avail titulo
                then do:
                    if titulo.titnat = no
                    then do:
                        run /admcom/progr/fin/testaposcart.p 
                            (new {&tabela}, 
                                buffer {&old}, 
                                buffer {&tabela}).
                
                    end.
                    if titulo.titnat = yes and titulo.modcod = "BON" /* helio 2/06/2021 */
                    then do: 
                        dtenveis4bonus = ?.
                    end.
                end.    
            end.    
            
        end.
    
        cretrigger.dtenvio = ?.
        cretrigger.hrenvio = ?.
        cretrigger.dtenveis4 = ?.   
        cretrigger.liddtenvio = ?.
        cretrigger.lidhrenvio = ?.
        
        
        
        
    end.
end.
