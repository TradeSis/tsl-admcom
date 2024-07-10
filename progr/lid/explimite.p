for each cretrigger use-index envLid
    where 
        titnat = no        and 
        liddtEnvio    = ?  and
        tabela = "neuclien" and
        (dtinc  > today - 7 or dtalt > today - 7) /* ajuste 25102021 */
        
    no-lock.

    run /admcom/barramento/async/geralimite.p (input trecid).
    
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
