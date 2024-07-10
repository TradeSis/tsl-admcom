def buffer bcretrigger for cretrigger.

for each cretrigger use-index envLid
    where 
        titnat = no        and 
        liddtEnvio    = ?  and
        tabela = "contrato" and
        (dtinc  > today - 7 or dtalt > today - 7) /* ajuste 25102021 */
    no-lock.

    run /admcom/barramento/async/geracontrato.p (input "contrato", input trecid).
    
    run p.

end.

for each cretrigger use-index envLid
    where 
        titnat = no        and 
        liddtEnvio    = ?  and
        tabela = "titulo"  and
        (dtinc  > today - 7 or dtalt > today - 7) /* ajuste 25102021 */

    no-lock.

    if dtalt <> ?
    then run /admcom/barramento/async/geracontrato.p (input "titulo", input trecid).
    else do:
        find titulo where recid(titulo) = cretrigger.trecid no-lock no-error.
        if avail titulo
        then do:
            find contrato where contrato.contnum = int(titulo.titnum) no-lock no-error.
            if avail contrato
            then do:
                find first bcretrigger where bcretrigger.titnat = cretrigger.titnat and
                                             bcretrigger.tabela = "contrato" and
                                             bcretrigger.trecid = recid(contrato)
                    no-lock no-error.
                if not avail bcretrigger
                then run /admcom/barramento/async/geracontrato.p (input "titulo", input cretrigger.trecid).
                else do:
                    if bcretrigger.liddtEnvio = ? or bcretrigger.liddtEnvio = today
                    then.
                    else do:
                        run /admcom/barramento/async/geracontrato.p (input "titulo", input cretrigger.trecid).
                    end.
                end.
            end.
            else run /admcom/barramento/async/geracontrato.p (input "titulo", input cretrigger.trecid).
        end.                                                         
    end.
    
    run p.

end.


procedure p.

    do on error undo.
        
        find current cretrigger exclusive no-wait no-error.
        if avail cretrigger
        then do:
            liddtEnvio = today.
            lidhrenvio = time.
        end.
     
    end.  

end procedure.


