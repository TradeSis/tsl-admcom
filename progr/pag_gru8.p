{admcab.i}
/*
find func where func.etbcod = setbcod and
                func.funcod = sfuncod 
                no-lock no-error.
if not avail func
then find func where func.etbcod = 999 and
                func.funcod = sfuncod 
                no-lock.
*/                                 
def var vesc as log format "Sim/Nao" initial no.

def var vsetcod like setaut.setcod.
update vsetcod label "Setor" with frame f-sel
    side-label 1 down width 80 no-box color message.

if vsetcod <> 0
then do:
    find setaut where setaut.setcod = vsetcod no-lock.
    disp setaut.setnom no-label with frame f-sel.
end.
else disp "Relatorio geral" @ setaut.setnom with frame f-sel.

/**
if func.funfunc begins "DIRETOR"
then.
else if vsetcod <> 0 and (func.funfunc begins "GERENTE" or
                          func.funfunc begins "CUSTOM") and
            func.aplicod = string(vsetcod)
    then.
    else do:
        bell.
        message color red/with
        "Acesso nao autorizado." view-as alert-box.
        return.
    end.
**/
repeat:
    if connected ("banfin")
    then disconnect banfin.
    
    if entry(1,sparam,";") = "sv-ca-dbr.lebes.com.br"
    then connect banfin -H dbr -S sbanfin_r -N tcp -ld banfin.
    else connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.
    
    run pag_gru78.p(input vsetcod). 
    disconnect banfin.
    leave.
end.    

