FUNCTION acha returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if num-entries( entry(vx,par-onde,"|"),"=") = 2 and
           entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.


FUNCTION tiraacentos returns character
    (input par-palavra as char).

    def var vconta as int.
    def var vnome as char.
    def var vl as char.
    def var va as int.
    vnome = "".
    do vconta = 1 to length(par-palavra).
        vl = substring(par-palavra,vconta,1).
        va = asc(vl).
        vnome = vnome +
                if (va >= 48 and va <= 57) or (va >= 65 and va <= 90) or
                   (va >= 97 and va <= 122)
                then vl
                else if va = 199 then "C" else " ".
    end.            

    return vnome. 
END FUNCTION.
 