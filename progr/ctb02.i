            if titulo.modcod = "DUP" and
               titulo.titnat = yes   and
               titulo.etbcod >= 96
            then do:
                find fin.titctb where titctb.forcod = titulo.clifor and
                                  titctb.titnum = titulo.titnum and
                                  titctb.titpar = titulo.titpar no-error.
                if avail fin.titctb
                then do:
                    if titctb.datexp = ?
                    then delete fin.titctb.
                end.
            end.
