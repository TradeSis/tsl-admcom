procedure limitearea.

    def input  param par-clicod as int.
    def input  param par-liacod as char.
    def output param par-vlrlimite  as dec.
    def output param par-vctolimite as date.


    par-vlrlimite  = 0.
    par-vctolimite = today - 1.
    find limarea where limarea.liacod = par-liacod no-lock no-error.
    if not avail limarea then return.
    find limclien where limclien.clicod = par-clicod and
                        limclien.liacod  = limarea.liacod
                        no-lock no-error.
    if avail limclien
    then do:
        if limarea.usavctolimite = no
        then par-vctolimite = ?.
        else do:
            if limclien.vctolimite <= today or 
               limclien.vctolimite = ?
            then par-vctolimite = today - 1. /* vencido */
            else par-vctolimite = limclien.vctolimite.   
        end.
        if par-vctolimite < today
        then par-vlrlimite = 0.
        else do:
            par-vlrlimite = limclien.vlrlimite.
        end.
    end.


END PROCEDURE.

function limiteLista returns logical 
    (input par-liacod as char, 
     input par-lista  as char,
     input par-codigo as char).
     
    find limarea where limarea.liacod = par-liacod no-lock no-error.
    if not avail limarea then return FALSE.

    if par-lista = "MODAL" 
    then do:
    
            return (par-codigo = (if limarea.listamodcod = ""  
                                 then par-codigo
                                 else if  lookup(par-codigo,limarea.listamodcod) = 0
                                     then ?
                                     else entry(lookup(par-codigo,limarea.listamodcod),limarea.listamodcod))) .
    end.
    if par-lista = "TPCONTRATO"
    then do:
        return
               (par-codigo = (if limarea.listatpcontrato = "" 
                              then par-codigo
                                 else if  lookup(par-codigo,limarea.listatpcontrato) = 0
                                     then ?
                                     else entry(lookup(par-codigo,limarea.listatpcontrato),limarea.listatpcontrato ))) .
    end.
    
    return false.
    
end.