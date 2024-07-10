            if titulo.modcod = "DUP" and
               titulo.titnat = yes   and
               (titulo.etbcod >= 996 or
                titulo.etbcod = 98)
            then do:
                find fin.titctb where titctb.forcod = titulo.clifor and
                                  titctb.titnum = titulo.titnum and
                                  titctb.titpar = titulo.titpar no-error.
                if avail fin.titctb
                then do:
                    if fin.titctb.datexp = ?
                    then ASSIGN titctb.titsit   = titulo.titsit
                                titctb.titvlpag = titulo.titvlpag
                                titctb.titvlcob = titulo.titvlcob
                                titctb.titdtven = titulo.titdtven
                                titctb.titdtemi = titulo.titdtemi
                                titctb.titdtpag = titulo.titdtpag.
                end.
            end.
