FUNCTION achahash returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"#"). 
        if num-entries( entry(vx,par-onde,"#"),"=") = 2 and
           entry(1,entry(vx,par-onde,"#"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"#"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.

