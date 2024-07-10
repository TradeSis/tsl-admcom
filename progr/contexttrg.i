/* 
* 08.2019 - Include De Registro de REPLICATION- USANDO TABELA contextTRG
*/

DO for contextTRG TRANSACTION.
    
    def var w_contextTRG_movtdc as int init 0.
    
    if '{&tabela}' = 'PLANI'
    then do:
        if avail plani
        then w_contextTRG_movtdc = plani.movtdc.
    end.    
    if '{&tabela}' = 'MOVIM'
    then do:
        if avail movim
        then w_contextTRG_movtdc = movim.movtdc.
    end.    
    
    

    find contextTRG where contextTRG.movtdc = w_contextTRG_movtdc and
                          contextTRG.tabela = '{&tabela}'         and
                          contextTRG.trecid = Recid({&tabela})
        exclusive no-wait no-error.
    if avail contextTRG or
       (not avail contextTRG and not locked contextTRG)
    then do:   
        if not avail contextTRG
        then do:
            create contextTRG.
            contextTRG.movtdc = w_contextTRG_movtdc.     
            contextTRG.tabela = '{&tabela}'.
            contextTRG.trecid = Recid({&tabela}).
            contextTRG.acao   = "INSERT".
            contextTRG.dtinc = today.
            contextTRG.hrinc = time. 
        end.
        else do:
            contextTRG.acao   = "UPDATE".
            contextTRG.dtenvio = ?.
            contextTRG.dtalt   = today.
            contextTRG.hralt   = time.
        end.
    
        contextTRG.dtenvio = ?.
        contextTRG.hrenvio = ?.

        if avail {&old}
        then do:
            BUFFER-COMPARE {&tabela} TO {&old} SAVE contextTRG.camposdif.
        end.
    end.
end.
