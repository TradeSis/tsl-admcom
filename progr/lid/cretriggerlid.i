/* 
* 08.2019 - Include De Registro de REPLICATION- USANDO TABELA CreTrigger
*/

DO for creTrigger TRANSACTION.

    find cretrigger where cretrigger.titnat = no and
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
        
        cretrigger.liddtenvio = ?.
        cretrigger.lidhrenvio = ?.
        
    end.
end.
