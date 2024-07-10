
FUNCTION acha returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 10 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.

def var vaspas as char format "x(1)".

vaspas = chr(34).

def var vesc as log format "Sim/Nao" initial no.
repeat:              

    if connected ("banfin")
    then disconnect banfin.
                       
    connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.

    run rmetdes-dg17.p(input vesc). 

    disconnect banfin.
    leave.
end.    


