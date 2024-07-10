                if v-feirao-nome-limpo 
                then
                    if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                       acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                    then .
                    else next.
                else do.
                    if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                       acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                    then next.
                    else .
                end.
 