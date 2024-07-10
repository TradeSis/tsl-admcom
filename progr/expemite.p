def var varquivo as char.
varquivo = string("m:\livros\emite") + string(day(today)) + ".exp".
output to value(varquivo).

for each forne where forne.forcod = 01 no-lock.

    put forne.forcod   format "99999"
        forne.fornom   format "x(40)"
        forne.forrua   format "x(30)"
        forne.formunic format "x(30)"
        forne.forcep   format "x(08)"
        forne.ufecod   format "x(02)"
        forne.forcgc   format "x(18)"
        forne.forinest format "x(18)"
        "      "       format "x(06)"
        "S"
        forne.forfone  format "x(15)"
        "           "  format "x(11)" skip.   
end.     
output close.
     
     
            
