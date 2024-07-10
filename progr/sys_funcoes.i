/* 
PRECOTABELA 
*/ 
function precotabela return decimal 
        (input par-procod as int, 
         input par-etbcod as int, 
         input par-data   as date). 
    def var vpreco as dec. 
    def buffer rprodu for produ. 
    def var perc-promocao as dec. 
    def var valor-promocao as dec. 
    find rprodu where rprodu.procod = par-procod no-lock no-error. 
    if not avail rprodu 
    then return 0.00. 
    find estab where estab.etbcod = par-etbcod no-lock. 
    find first precohrg where precohrg.procod  = par-procod  and 
                              precohrg.etbcod  = estab.etbcod and 
                              precohrg.dativig <= par-data 
                              no-lock no-error. 
    if not avail precohrg 
    then do: 
        return 0.00.
        /*******
        find first precohrg where 
                   precohrg.procod = par-procod and 
                   precohrg.etbcod  = 1 and 
                   precohrg.dativig <= par-data 
                   no-lock no-error.  
        if not avail precohrg 
        then return 0.00. 
        else return precohrg.prvenda. 
        ***********/
    end. 
    else return precohrg.prvenda.
end function. 
