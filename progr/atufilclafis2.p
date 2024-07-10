def buffer bclafis for nfeloja.clafis.

for each nfe.clafis no-lock.

    display "Atualizando..." nfe.clafis.codfis with 1 down. pause 0.

    find first nfeloja.clafis where
        nfeloja.clafis.codfi = nfe.clafis.codfis no-lock no-error.

    if not avail nfeloja.clafis
    then do:
        create nfeloja.clafis.
        buffer-copy nfe.clafis to nfeloja.clafis.
    end.
    else do:
        if nfeloja.clafis.char1 = "" and
           nfe.clafis.char1 <> ""
        then do:
            find bclafis of nfeloja.clafis.
            bclafis.char1 = nfe.clafis.char1.
        end.
    end.
end.
