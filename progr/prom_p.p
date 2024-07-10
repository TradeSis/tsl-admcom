{admcab.i}
def var vavi as dec format ">,>>9.99" label "Prom.Avista".
def var vpre as dec.
def var vper as dec format ">>9.99 %" label "Perc.".
DEF BUFFER BESTOQ FOR ESTOQ.
def var vdata like estoq.estprodat.
def var vdata1 like plani.pladat.
def var vpreco like estoq.estproper format ">>,>>9.99" label "Promocao".
def var vprocod like produ.procod.
def var vfincod   like finan.fincod.
def var vcondicao like plani.platot.
def new shared temp-table tt-lj  like estab.
def var vfinnpc like finan.finnpc.

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
         bestoq.estproper label "Promocao" /*format ">>,>>9.99"*/ 
         bestoq.tabcod    label "Plano Promocao" format ">>9"  at 10
         bestoq.estmin    label "Valor Parcelas"      format ">>,>>9.99"
                    with frame f1.

    vdata1     = bestoq.estbaldat.
    vdata      = BESTOQ.ESTPRODAT.
    vpreco     = BESTOQ.ESTPROPER.
    vavi       = bestoq.estproper.
    vfincod    = bestoq.tabcod.
    vcondicao  = bestoq.estmin.
    
    if vdata = ? 
    then assign
             vdata  = today 
             vdata1 = today.
    
    if vdata > today 
    then do:
        message color red/with
        "Promocao ja existe de " vdata1  "ate " vdata
        view-as alert-box. 
    end.
    
    vper = 0.
    
    if vdata1 = ?
    then vdata1 = today.

    disp vdata1 vdata with frame f2.

    update vdata1  label "Periodo da promocao"
           vdata   label "A"  validate(vdata <> ? and 
           vdata >= vdata1,"Periodo invalido")
           vper  at 1 with frame f2 width 80.
    if vpreco = 0
    then vpreco = bestoq.estvenda - ( bestoq.estvenda * (vper / 100)).
    update vpreco with frame f2 side-label.
    vavi = vpreco.
    
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

        if finan.finent 
        then vfinnpc = finan.finnpc + 1. 
        else vfinnpc = finan.finnpc.
        
        if (vcondicao * vfinnpc) < vpreco
        then do:
            message color red/with
            "Informe corretamente o campo VALOR DE PARCELAS."
            view-as alert-box.
            next.
        end.    
    end.
    else vcondicao = 0.
    
    for each tt-lj:
        delete tt-lj.
    end.    
    run seletbgr.p .

    find first tt-lj where tt-lj.etbcod > 0 no-lock no-error.
    if not avail tt-lj 
    then do:
        bell.
        message color red/with
        "Nenuma filial selecionada para promocao." skip
        "Promocao nao sera cadastrada."
        view-as alert-box.
        undo.
    end.    
        
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
            find first tt-lj where 
                    tt-lj.etbcod = estab.etbcod no-lock no-error.
            if not avail tt-lj then next.        
            for each estoq where estoq.etbcod = estab.etbcod and
                                 estoq.procod = produ.procod.
                estoq.datexp = today.
                estoq.estproper = vpreco.
                estoq.estbaldat = vdata1.
                estoq.estprodat = vdata.
                estoq.estmin    = vcondicao.
                estoq.tabcod    = vfincod. 
                estoq.dtaltpromoc = today.

                find hisprpro where 
                    hisprpro.procod = estoq.procod and
                    hisprpro.etbcod = estoq.etbcod and
                    hisprpro.Data_inicio = estoq.estbaldat
                    no-error.
                if not avail hisprpro
                then create hisprpro.
                ASSIGN 
                    hisprpro.preco_tipo = "P"
                    hisprpro.etbcod     = estoq.etbcod
                    hisprpro.procod     = estoq.procod
                    hisprpro.data_inicio = estoq.estbaldat
                    hisprpro.data_fim    = estoq.estprodat
                    hisprpro.preco_valor = estoq.estproper
                    hisprpro.OFFER_ID    = ?
                    hisprpro.preco_plano  = estoq.tabcod
                    hisprpro.preco_parcela = estoq.estmin
                    hisprpro.PRICE_KEY  = program-name(1)
                    hisprpro.data_inclu = today
                    hisprpro.hora_inclu = time .

            end.
        end.
    end.
end.
