/* #1 06.04.2018 - Acertado Indices para melhorar Performance */
    
    def input param par-clicod as int.
    def output param par-perc-15 as dec decimals 4.
    def output param par-perc-45 as dec decimals 4.
    def output param par-perc-46 as dec decimals 4.
     
    def var par-qtd-15 as int.
    def var par-qtd-45 as int.
    def var par-qtd-46 as int.
    def var par-paga as int.
    
    def var vaberta as int.
    
    par-paga = 0.
    vaberta = 0.
    par-qtd-15 = 0.
    par-qtd-45 = 0.
    par-qtd-46 = 0.


    def buffer Xcontrato for contrato.
    def buffer Xtitulo   for titulo.
    
    for each Xcontrato 
        use-index iconcli /* #1 */
        where Xcontrato.clicod = par-clicod no-lock.
    
        for each Xtitulo 
                use-index titnum  /* #1 */
                where 
            Xtitulo.empcod = 19 and 
            Xtitulo.titnat = no and 
            Xtitulo.modcod = Xcontrato.modcod and 
            Xtitulo.etbcod = Xcontrato.etbcod and 
            Xtitulo.titnum = string(Xcontrato.contnum) and /* #1 */
            Xtitulo.clifor = par-clicod 
         no-lock.
            
            if Xtitulo.titpar <> 0
            then do:
                if Xtitulo.titsit = "PAG" or
                   Xtitulo.titsit = "EXC" or
                   Xtitulo.titsit = "NOV"
                then do:
                    par-paga = par-paga + 1.
                    if Xtitulo.titdtpag <> ?
                    then do:
                        if (Xtitulo.titdtpag - Xtitulo.titdtven) <= 15
                        then par-qtd-15 = par-qtd-15 + 1.
                        if (Xtitulo.titdtpag - Xtitulo.titdtven) >= 16 and
                           (Xtitulo.titdtpag - Xtitulo.titdtven) <= 45
                        then par-qtd-45 = par-qtd-45 + 1.
                        if (Xtitulo.titdtpag - Xtitulo.titdtven) >= 46
                        then par-qtd-46 = par-qtd-46 + 1.
                    end. 
                end.
                else do:
                    vaberta = vaberta + 1.
                end.
            end.
            
         end.
    end.

         
    
    par-perc-15 = par-qtd-15 * 100 / par-paga.
    par-perc-45 = par-qtd-45 * 100 / par-paga.
    par-perc-46 = par-qtd-46 * 100 / par-paga.
 

