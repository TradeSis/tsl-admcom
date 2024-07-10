    
    def input param par-clicod as int.
    def output param par-perc-15 as dec.
    def output param par-perc-45 as dec.
    def output param par-perc-46 as dec.
     
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


def shared temp-table t_cliente no-undo
    field clicod like cyber_controle.cliente
    field vperc-15 as dec
    field vperc-45 as dec
    field vperc-46 as dec
    index c is unique primary clicod asc.


    find first t_cliente where t_cliente.clicod = par-clicod no-error.
    if avail t_cliente
    then do:
        par-perc-15 = t_cliente.vperc-15.
        par-perc-45 = t_cliente.vperc-45.
        par-perc-46 = t_cliente.vperc-46.
        return.        
    end.
    else do:
        create t_cliente.
        t_cliente.clicod = par-clicod.
        t_cliente.vperc-15 = 0.
        t_cliente.vperc-45 = 0.
        t_cliente.vperc-46 = 0.
    end.

    def buffer Xcontrato for contrato.
    def buffer Xtitulo   for titulo.
    
    for each Xcontrato where Xcontrato.clicod = par-clicod no-lock.
    
        for each Xtitulo where 
            Xtitulo.empcod = 19 and 
            Xtitulo.titnat = no and 
            Xtitulo.modcod = Xcontrato.modcod and 
            Xtitulo.etbcod = Xcontrato.etbcod and 
            Xtitulo.clifor = par-clicod 
         no-lock.
            
            if Xtitulo.titpar <> 0
            then do:
                if Xtitulo.titsit = "PAG"
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
 
        t_cliente.vperc-15 = par-perc-15.
        t_cliente.vperc-45 = par-perc-45.
        t_cliente.vperc-46 = par-perc-46.

         
    /**
    disp 
        par-paga
        par-qtd-15       label "(ate 15 dias)"  COLON 20
         par-perc-15 format ">>9.99%"
        par-qtd-45       label "(16 ate 45 dias)"  COLON 20
         (par-qtd-45 * 100) / par-paga format ">>9.99%"
        par-qtd-46       label "(acima de 45 dias)" COLON 20
         (par-qtd-46 * 100) / par-paga format ">>9.99%"
    **/         

