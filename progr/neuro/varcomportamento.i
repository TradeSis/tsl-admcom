 
def var var-propriedades as char.
def var var-salaberto as dec.
def var var-sallimite   as dec.
def var var-qtdtit as int.
def var var-ATRASOATUAL as int.


function pega_prop returns char
    (input  par-acha as char).
    
    def var vret as char.
    
    vret = achahash(par-acha,var-propriedades).
    
    if vret = ? then vret = "".
     
    return vret.
    
end function.    
