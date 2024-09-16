/* helio 28022022 - iepro  - PTODAY*/


vnumdia = 0.
par-juros = 0.
vtottit-jur = 0.
if PTODAY <= par-titdtven
then do:
    return.
end.

if PTODAY > par-titdtven
then do:
    ljuros = yes.
    /* HELIO 09092024 Modificacao para teste de nao cxobrar juros, quando:
            Vencimento é feriado ou sabado ou domingo
            Cliente vem pagar na segunda ou no dia seguinte do feriado
    */  
    if weekday(par-titdtven) = 1 /* Vencimento em Domingo */ and
       ptoday = par-titdtven + 1 
    then do:
        ljuros = no.
    end.
    else do:
        find dtextra where dtextra.exdata = par-titdtven no-lock no-error.
        if avail dtextra    /* Vencimento em Feriado */
        then do:
            if ptoday = par-titdtven + 1  /* Veio Pagar no dia seguinte */
            then do:
                ljuros = no.
            end.
            else do:
                if ptoday = par-titdtven + 2 and weekday(par-titdtven) = 7 /* Vencimento Sabado Feriado, Pagamento Segunda */
                then do:
                    ljuros = no.
                end. 
            end.
        end.
    end.

    if ljuros /* se cobra juros */
    then do:
        /* Calcula dias entre hj e vencimento */
        vnumdia = PTODAY - par-titdtven.
        
        if vabatedtesp
        then do:
            for each dtesp   where dtesp.etbcod = par-etbcod    and
                               dtesp.datesp >= par-titdtven and
                               dtesp.datesp <= PTODAY
                    no-lock.
                vnumdia = vnumdia - 1.
                /* Abate os dias cadastrados em DTESP * Corona */
            end.                                
        end.        
        
        if vnumdia > 0 /* pega tabela de juros por dias de atraso */
        then do:
            if vnumdia > 1766
            then vnumdia = 1766.
            
            find tabjur where tabjur.etbcod = par-etbcod
                              and tabjur.nrdias = vnumdia
                            no-lock no-error.
            if not avail tabjur and par-etbcod > 0
            then find tabjur where tabjur.etbcod = 0
                               and tabjur.nrdias = vnumdia no-lock no-error.

            
            varred = par-titvlcob * tabjur.fator.
            
            vv = (int(varred) - varred) - round(int(varred) - varred, 1).
            if vv < 0 
            then vv = 0.10 - (vv * -1).
            varred = varred + vv.
                
            vtottit-jur = vtottit-jur + (varred - par-titvlcob). 
        end.
        
    end.
    
end.
                                
par-juros = vtottit-jur.
if par-juros < 0
then par-juros = 0.

