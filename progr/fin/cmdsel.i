        /*if titulo.contnum = ?
         then next.*/
        
        find estab      where estab.etbcod =  titulo.etbcod  no-lock.
/*        find estab where estab.etbcod = uo.etbcod no-lock.*/
        find modal    of titulo  no-lock no-error.
        if not avail modal
        then next.
/***
        if par-modcod <> "0" and par-modcod <> modal.modcod
        then next.
***/
        find cobra    of titulo  no-lock.
        find clien    where clien.clicod = titulo.clifor  no-lock.

        /*
        find first wfmodal no-error.
        if avail wfmodal
        then do:
            if wfmodal.modcod = ""
            then.
            else do:
                find first wfmodal where wfmodal.modcod = modal.modcod no-error.
                if not avail wfmodal
                then next.
            end.
        end.
        */
        
        find first wfclien no-error.
        if avail wfclien
        then do:
            if wfclien.clicod = 0
            then.
            else do:
                find first wfclien where wfclien.clicod = clien.clicod
                                                                    no-error.
                if not avail wfclien
                then next.
            end.
        end.
        
        create wfselecao.
        assign
            wfselecao.rec      = recid(titulo)
            wfselecao.marcados = vmarc.
