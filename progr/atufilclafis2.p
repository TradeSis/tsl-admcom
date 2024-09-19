def buffer bclafis for nfeloja.clafis.

for each com.clafis no-lock.

    display "Atualizando..." com.clafis.codfis with 1 down. pause 0.

    find first nfeloja.clafis where
        nfeloja.clafis.codfi = com.clafis.codfis no-lock no-error.

    if not avail nfeloja.clafis
    then do:
        create nfeloja.clafis.
        buffer-copy com.clafis to nfeloja.clafis.
    end.
    else do:
        if nfeloja.clafis.char1 = "" and
           com.clafis.char1 <> ""
        then do:
            find bclafis of nfeloja.clafis.
            bclafis.char1 = com.clafis.char1.
        end.
    end.
end.
