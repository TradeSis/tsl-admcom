def input parameter pcpf     as dec.
def input parameter pcontnum as int.
def input parameter petbcod  as int.
def input parameter pmodcod  as char.
def input parameter pclicod  as int.
def input parameter pprincipal as int.
def output parameter pok      as log.

pok = no.

disable triggers for load of finloja.contrato.
disable triggers for load of finloja.titulo.
do on error undo:
    find finloja.contrato where 
        finloja.contrato.contnum = pcontnum
          no-lock no-error.
    if avail finloja.contrato
    then do: 
        finloja.contrato.clicod = pprincipal. 
    end.
    for each finloja.titulo where   
            finloja.titulo.empcod = 19 and
            finloja.titulo.titnat = no and
            finloja.titulo.etbcod = petbcod and   
            finloja.titulo.clifor = pclicod and
            finloja.titulo.modcod = pmodcod and
            finloja.titulo.titnum = string(pcontnum) and
            finloja.titulo.titsit = "LIB" and
            finloja.titulo.titdtpag = ?
            exclusive.
        finloja.titulo.clifor   = pprincipal.
        pok = yes.
    end.

end.

