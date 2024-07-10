{admcab.i}
def var vavi as dec format ">,>>9.99" label "Prom.Avista".
def var vpre as dec.
def var vper as dec format ">>9.99 %" label "Perc.".
DEF BUFFER BESTOQ FOR ESTOQ.
def var vdata like estoq.estprodat.
def var vdata1 like plani.pladat.
def var vpreco like estoq.estproper format ">,>>9.99" label "Promocao".
def var vprocod like produ.procod.
def var vfincod   like finan.fincod.
def var vcondicao like plani.platot.
repeat:
    
    UPDATE vprocod with frame f1 side-label width 80.
    find produ where produ.procod = vprocod no-lock no-error.
    if not avail produ
    then do:
        message "Produto nao Cadastrado".
        undo, retry.
    end.
    disp produ.pronom no-label with frame f1.

    FIND BESTOQ WHERE BESTOQ.PROCOD = PRODU.PROCOD and
                      bestoq.etbcod = 1 NO-LOCK.
    disp bestoq.estvenda at 10
         bestoq.estproper label "Promocao" format ">>,>>9.99" 
         bestoq.tabcod    label "Plano Promocao" format ">>9"  at 10
         bestoq.estmin    label "Valor Parcelas"      format ">>,>>9.99"
                    with frame f1.
    vdata1     = bestoq.estprodat.
    vdata      = BESTOQ.ESTPRODAT.
    vpreco     = BESTOQ.ESTPROPER.
    vavi       = bestoq.estproper.
    vfincod    = bestoq.tabcod.
    vcondicao  = bestoq.estmin.
    
    vper = 0.
    update vdata 
           vper  with frame f2 width 80.
    if vpreco = 0
    then vpreco = bestoq.estvenda - ( bestoq.estvenda * (vper / 100)).
    update vpreco with frame f2 side-label.
    vavi = vpreco.
    vdata1 = vdata.
    
    update vfincod label "Plano" at 10 with frame f2 side-label.
    if vfincod <> 0
    then do:
        
        find finan where finan.fincod = vfincod no-lock no-error.
        if not avail finan 
        then do:
            message "Plano invalido".
            undo, retry.
        end.
        display finan.finnom no-label with frame f2 side-label. 
        update vcondicao label "Valor Parcelas" with frame f2.
    end.
    else vcondicao = 0.
    
        
    message "Confirma Promocao" update sresp.
    if sresp
    then do:
        do transaction:
            find func where func.etbcod = 999 and
                            func.funcod = sfuncod no-lock no-error.

            create admprog.
            assign admprog.menpro = string(year(today),"9999") +
                                    string(month(today),"99")  +
                                    string(day(today),"99") +
                                    string(time).
            admprog.progtipo = string(produ.procod,"999999") + " " +
                               string(func.funnom,"x(15)")   + " " +
                               string(today) + " " +
                               string(vdata) + " " +
                              " Pro.Ant." + 
                                string(bestoq.estproper,">,>>9.9") +
                              " Pro.Atu." + string(vpreco,">,>>9.9").
        end.
 
        
        for each estab no-lock:
            for each estoq where estoq.etbcod = estab.etbcod and
                                 estoq.procod = produ.procod.
                estoq.datexp = today.
                estoq.estproper = vpreco.
                estoq.estprodat = vdata.
                estoq.estmin    = vcondicao.
                estoq.tabcod    = vfincod. 
            end.
        end.
    end.
end.
