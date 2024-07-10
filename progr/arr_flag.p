{admcab.i}
def var vetbcod like estab.etbcod.
def stream stela.
repeat:
    update vetbcod label "Filial" with frame f1 side-label.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label 
            with frame f1 width 80.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if avail estab
        then display estab.etbnom no-label with frame f1.
    end.
    
    output to printer.
    output stream stela to terminal.

    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each d.titulo where d.titulo.empcod = 19           and
                            d.titulo.titnat = no           and
                            d.titulo.modcod = "CRE"        and
                            d.titulo.titsit = "lib"        and
                            d.titulo.etbcod = estab.etbcod 
                                        no-lock break by d.titulo.clifor:
        display stream stela
                d.titulo.clifor with frame f2 1 down centered. pause 0.
        if first-of(d.titulo.clifor)
        then do:
        
            find first fin.titulo where 
                                  fin.titulo.modcod = "cre" and
                                  fin.titulo.titsit = "lib" and
                                  fin.titulo.clifor = d.titulo.clifor 
                                                no-lock no-error.
            if avail fin.titulo
            then do:
                display fin.titulo.etbcod
                        fin.titulo.clifor
                        fin.titulo.titnum
                        fin.titulo.titpar
                        fin.titulo.titvlcob with frame f3 down.
            end.
        
        end.
    
    end.
    output close.
    output stream stela close.
end.
                    
            
