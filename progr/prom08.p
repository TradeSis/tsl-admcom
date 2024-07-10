{admcab.i}
def var vperc as dec format ">9.99 %".
def var vforcod like produ.fabcod.
DEF BUFFER BESTOQ FOR ESTOQ.
def var vdata like estoq.estprodat.
def var vpreco like estoq.estproper format ">,>>9.99" label "Promocao".
def var vprocod like produ.procod.
def var x as dec.
def var vcatcod like categoria.catcod.
repeat:
    update vcatcod colon 11 with frame f1 .
    find categoria where categoria.catcod = vcatcod no-lock no-error.
    if not avail categoria
    then do:
        message "Departamento nao Cadastrada".
        undo, retry.
    end.
    disp categoria.catnom no-label with frame f1.


    UPDATE vforcod colon 11 with frame f1 side-label width 80.
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do:
        message "Fornecedor nao Cadastrada".
        undo, retry.
    end.
    disp forne.fornom no-label with frame f1.
    update vperc label "Perc." colon 11
           vdata label "Data" with frame f1.


    message "Confirma Promocao" update sresp.
    for each produ where produ.catcod = categoria.catcod and
                         produ.fabcod = forne.forcod no-lock:
        display produ.procod
                produ.fabcod
                    with 1 down. pause 0.
        for each estoq where estoq.procod = produ.procod break by estoq.procod.
                
                               
               vpreco = estoq.estproper.
               estoq.datexp = today.

               x = estoq.estvenda - (estoq.estvenda * (vperc / 100)).
               x = int(x).
               estoq.estproper = x.
               estoq.estprodat = vdata.
               estoq.dtaltpromoc = today.
               if last-of(estoq.procod)
               then do:
                    find func where func.etbcod = 999 and
                                    func.funcod = sfuncod no-lock no-error.

 
                    create admprog.
                    assign admprog.menpro = string(year(today),"9999") +
                                            string(month(today),"99")  +
                                            string(day(today),"99") +
                                            string(produ.procod,"999999999") +
                                            string(time).
                    admprog.progtipo = string(produ.procod,"999999") + " " +
                                       string(func.funnom,"x(15)")   + " " +
                                       string(today) + " " +
                                       string(vdata) + " " +
                                      " Pro.Ant." + 
                                        string(vpreco,">,>>9.9") +
                              " Pro.Atu." + string(estoq.estproper,">,>>9.9").
               end.
               find hisprpro where 
                    hisprpro.procod = estoq.procod and
                    hisprpro.etbcod = estoq.etbcod and
                    hisprpro.Data_inicio = today
                    no-error.
                if not avail hisprpro
                then create hisprpro.
                ASSIGN 
                    hisprpro.preco_tipo = "P"
                    hisprpro.etbcod     = estoq.etbcod
                    hisprpro.procod     = estoq.procod
                    hisprpro.data_inicio = today
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
