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
    
    /* Se ontem foi feriado ou domingo, e foi o dia do vencimento, não cobra juros */
    find dtextra where dtextra.exdata = PTODAY - 1 no-lock no-error.
    if avail dtextra or weekday(PTODAY - 1) = 1
    then do:
        if par-titdtven = PTODAY - 1  
        then ljuros = no.
/*https://trello.com/c/EBbjANsa/12-cadastro-de-feriado-n%C3%A3o-dispensou-juros
*/        
        else if par-titdtven = PTODAY - 2 and
                weekday(par-titdtven) = 1
            then ljuros = no.        
/**/    
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
            
            find fin.tabjur where fin.tabjur.etbcod = par-etbcod
                              and fin.tabjur.nrdias = vnumdia
                            no-lock no-error.
            if not avail fin.tabjur and par-etbcod > 0
            then find fin.tabjur where fin.tabjur.etbcod = 0
                               and fin.tabjur.nrdias = vnumdia no-lock no-error.

            
            varred = par-titvlcob * fin.tabjur.fator.
            
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

