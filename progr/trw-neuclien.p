TRIGGER PROCEDURE FOR Replication-Write OF neuclien OLD BUFFER oldneuclien.

do on error undo transaction:
    if avail neuclien
    then neuclien.CompDtUltAlter = today. /* 14.03.19 helio.neto */
end.    

    {/admcom/progr/cretrigger.i
         &tabela =   neuclien
         &old    =   oldneuclien }

    {/admcom/progr/contexttrg.i
         &tabela =   neuclien
         &old    =   oldneuclien }


