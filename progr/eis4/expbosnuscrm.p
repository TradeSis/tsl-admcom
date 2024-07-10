for each cretrigger 
    where 
        titnat = yes        and 
        dtenveis4bonus = ?  and
        tabela = "titulo" and
        dtinc >= today -  100 or dtalt >= today - 7
    no-lock.

    run /admcom/barramento/async/gerabonuscrm.p (input trecid).
    
    run p.

end.

procedure p.

    do on error undo.
        
        find current cretrigger exclusive no-wait no-error.
        if avail cretrigger
        then do:
            dtenveis4bonus = today.
        end.
     
    end.  

end procedure.
