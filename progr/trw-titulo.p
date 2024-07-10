TRIGGER PROCEDURE FOR Replication-Write OF titulo OLD BUFFER oldTitulo.

    /* helio 28/06/2021 ajuste marcacao pagamento bonus crm */
    {/admcom/progr/cretrigger.i
         &tabela =   titulo
         &old    =   oldtitulo }

    if avail titulo
    then do:
    
        if titulo.titnat = no
        then do:
            find neuclien where neuclien.clicod = titulo.clifor no-lock no-error.
            if avail neuclien
            then do:
                {/admcom/progr/lid/cretriggerlid.i
                     &tabela =   neuclien }
            end.
        end.

    end.
                                 

