/*{admcab.i}
  */
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
 
def input parameter rec-plani as recid.
def input parameter rec-contrato as recid.
def output parameter par-valorav as dec.
def output parameter par-outros as dec.
def var vi as int.
def var vchepres as dec.
par-valorav = 0.
vchepres = 0.
if rec-plani <> ? 
then do:
    find plani where recid(plani) = rec-plani no-lock.


    if plani.serie = "3"
    then do:
        if acha("QTDCHQUTILIZADO",plani.notobs[3]) <> ?
        then do vi = 1 to int(acha("QTDCHQUTILIZADO",plani.notobs[3])):
            vchepres = vchepres +  dec(acha("VALCHQPRESENTEUTILIZACAO" + 
                            string(vi),plani.notobs[3])) .
        end.    
        par-valorav = plani.platot -
              (plani.vlserv + plani.descprod + vchepres).
        par-outros = plani.vlserv + plani.descprod + vchepres.
    end.
    else do:
        par-valorav = plani.platot.
        par-outros  = 0.
    end.
end.
else if rec-contrato <> ?
    then do:
        find contrato where recid(contrato) = rec-contrato no-lock. 
        for each tit_novacao where 
                 tit_novacao.ger_contnum = contrato.contnum no-lock:
            par-valorav = par-valorav + tit_novacao.ori_titvlcob.
            par-outros  = 0.
        end. 
    end.
