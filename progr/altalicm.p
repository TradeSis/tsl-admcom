{admcab.i}
def var vprocod like produ.procod.
def var vst as log format "Sim/Nao".
repeat:
    update vprocod  label "Codigo Produto"
        with frame f-1 1 down side-label width 80.
    find produ where produ.procod = vprocod .
    disp produ.pronom no-label with frame f-1.
    
    vst = no.
    find produaux where produaux.procod = produ.procod and
                            produaux.nome_campo  = "ST"
                            no-error. 
    if avail produaux 
    then do:
        if produaux.valor_campo = "Sim"
        then vst = yes.
        else vst = no.
    end.
    else if produ.proipiper = 99
       then vst = yes.
    
 
    do transaction:

        update produ.proipiper label "Aliquota ICMS"
               vst             at 1 label "           ST"
            with frame f-2 side-label.
        produ.datexp = today.    
        find produaux where produaux.procod = produ.procod and
                            produaux.nome_campo  = "ST"
                            no-error.
        if not avail produaux 
        then do:
            if produ.proipiper > 0 and produ.proipiper < 99 
                and vst 
            then do:
                create produaux.
                assign
                    produaux.procod = produ.procod
                    produaux.nome_campo  = "ST"
                    produaux.tipo_campo = "log"
                    produaux.exportar = yes
                    produaux.datexp = today
                    produaux.valor_campo = "Sim".
            end.
        end.
        else do:
            if produ.proipiper > 0 and produ.proipiper < 99
            then do:
                if vst
                then produaux.valor_campo = "Sim".
                else produaux.valor_campo = "Nao".
            end.
            else produaux.valor_campo = "Nao". 
            produaux.datexp = today.   
        end.                 
    end.
end.         