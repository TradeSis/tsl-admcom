for each cretrigger 
    where 
        titnat = no       and 
        dtenveis4 = ?  and
        tabela = "clien" and
       ( dtinc >= today -  30 or dtalt >= today -  30 )
    no-lock.

    run /admcom/barramento/async/geracliente.p (input trecid).
    
    run p.

end.

procedure p.

    do on error undo.
        
        find current cretrigger exclusive no-wait no-error.
        if avail cretrigger
        then do:
            dtenveis4 = today.
        end.
     
    end.  

end procedure.
