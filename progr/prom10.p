{admcab.i}

def var vtime as int.
def var vdesc like plani.platot format ">9.99%".
def var vperc like estoq.estproper.
def var vcusto like estoq.estcusto.
def var vluc  like estoq.estmgluc.
def var vdata like estoq.estprodat.
def var vpreco like estoq.estVENDA.
def var vprocod like produ.procod.
def var vforcod like produ.fabcod.
def var vcus    like estoq.estcusto.
def var vven    like estoq.estvenda.
DEF BUFFER BESTOQ FOR ESTOQ.
def var x as dec.
def var vcatcod like categoria.catcod.
def var i as int.
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

    vluc  = 0.
    vperc = 0.
    vdesc = 0.

    update vluc  label "Perc. Custo" colon 20
           vperc label "Perc. Venda" colon 20 
           vdesc label "Desconto"    colon 20
                with frame f2  side-label centered.


    message "Confirma Preco de venda" update sresp.
    if sresp
    then do:
        
        find func where func.etbcod = 999 and
                        func.funcod = sfuncod no-lock no-error.
        if not avail func
        then do:
            message "Funcionario Invalido".
            undo, retry.
        end.


        for each produ where produ.catcod = categoria.catcod and
                             produ.fabcod = forne.forcod:
    
            display produ.procod
                    produ.fabcod with 1 down. pause 0.
            for each estoq where estoq.procod = produ.procod 
                                        break by estoq.procod.
                        
                vcus = estoq.estcusto.
                vven = estoq.estvenda.
                
                do transaction:
                    estoq.datexp = today.
                    if vluc <> 0
                    then estoq.estvenda = (estoq.estcusto * (vluc / 100 + 1)).
                    if vperc <> 0
                    then estoq.estvenda = (estoq.estvenda * (vperc / 100 + 1)).
                    if vdesc <> 0
                    then estoq.estvenda = estoq.estvenda - 
                                         (estoq.estvenda * (vdesc / 100)).
                    estoq.estvenda = int(estoq.estvenda).
                    estoq.dtaltpreco = today.
                end.

                if first-of(estoq.procod)
                then do transaction:
                    create admprog.
                    assign admprog.menpro = string(year(today),"9999") +
                                            string(month(today),"99")  +
                                            string(day(today),"99")    +
                                            string(estoq.procod,"999999999") + 
                                            string(time).
                 
                    admprog.progtipo = 
                       string(string(produ.procod,"999999") + " " +
                              string(func.funnom,"x(10)") + " " +
                              string(today) + 
                              " CUSTO " + string(vcus,">,>>9.99") +  
                              "/" + string(estoq.estcusto,">,>>9.99") + 
                              "   VENDA " + string(vven,">,>>9.99") +
                              "/" + string(estoq.estvenda,">,>>9.99"),"x(78)").

                    vtime = time.
                    find hispre where hispre.procod   = produ.procod
                                  and hispre.dtalt    = today
                                  and hispre.hora-inc = vtime
                                  and hispre.funcod   = func.funcod no-error.
                    if not avail hispre
                    then do:
                        create hispre.
                        assign hispre.procod       = produ.procod
                               hispre.dtalt        = today
                               hispre.hora-inc     = vtime
                               hispre.funcod       = func.funcod
                               hispre.estcusto-ant = vcus
                               hispre.estcusto-nov = estoq.estcusto
                               hispre.estvenda-ant = vven
                               hispre.estvenda-nov = estoq.estvenda.
                    end.
                end.
                do transaction:
                find hisprpro where 
                    hisprpro.procod = estoq.procod and
                    hisprpro.etbcod = estoq.etbcod and
                    hisprpro.Data_inicio = today
                    no-error.
                if not avail hisprpro
                then create hisprpro.
                ASSIGN 
                    hisprpro.preco_tipo = "R"
                    hisprpro.etbcod     = estoq.etbcod
                    hisprpro.procod     = estoq.procod
                    hisprpro.data_inicio = today
                    hisprpro.data_fim    = ?
                    hisprpro.preco_valor = estoq.estvenda
                    hisprpro.OFFER_ID    = ?
                    hisprpro.preco_plano  = 0
                    hisprpro.preco_parcela = 0
                    hisprpro.PRICE_KEY  = program-name(1)
                    hisprpro.data_inclu = today
                    hisprpro.hora_inclu = time .
                end.
            end.
                
            do transaction:
                produ.datexp = today.
            end.
        end.
    end.
end.
