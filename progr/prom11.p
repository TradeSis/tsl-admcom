/*  prom11.p  */
{admcab.i}

def var vtime as int.
def var vperc like estoq.estproper.
def var vcusto like estoq.estcusto.
def var vluc  like estoq.estmgluc.
def var vdata like estoq.estprodat.
def var vpreco like estoq.estVENDA.
def var vprocod like produ.procod.
def var cus like estoq.estcusto.
def var ven like estoq.estvenda.
def var i   as int.

def var vmenpro like admprog.menpro.

repeat:
    cus = 0.
    ven = 0.
    UPDATE vprocod with frame f1 side-label width 80.
    find produ where produ.procod = vprocod no-error.
    if not avail produ
    then do:
        message "Produto nao Cadastrado".
        undo, retry.
    end.
    disp produ.pronom no-label with frame f1.
    find estoq WHERE ESTOQ.ETBCOD = 999 AND
                     ESTOQ.PROCOD = produ.PROCOD.
    if estoq.estprodat < today
    then do transaction:
        assign estoq.estproper = 0
               estoq.estprodat = ?
               estoq.datexp = today
               estoq.dtaltpromoc = today.
               .
    end.
    display estoq.estvenda
            estoq.estcusto
            estoq.estproper format ">>,>>9.99" with frame f1.
    do transaction:
    update estoq.estcusto with frame f1.
    end.
    cus = estoq.estcusto. 
    ven = estoq.estvenda.
    
    vcusto = estoq.estcusto. 


    display vcusto colon 20 with frame f2.
    
    /*
    update vcusto colon 20 
           vluc   colon 20
            with frame f2.
    */
    
    if vluc = 0
    then vpreco = estoq.estvenda.
    else vpreco = (vcusto * (vluc / 100 + 1)).
    update  vperc label "Perc" colon 20 with frame f2.
    if vperc <> 0
    then vpreco = (estoq.estvenda * (vperc / 100 + 1)).
    vpreco = int(vpreco).

    update vpreco colon 20 with frame f2 centered side-label row 8.
    message "Confirma Preco de venda" update sresp.
    if sresp
    then do TRANSACTION:
        
        if cus <> vcusto or
           ven <> vpreco
        then do:
            vmenpro = string(year(today),"9999") +
                                    string(month(today),"99")  +
                                    string(day(today),"99") +
                                    string(produ.procod,"999999999") +
                                    string(time).

            find admprog where
                 admprog.menpro = vmenpro no-error.
            if not avail admprog
            then do:     
                create admprog.
                admprog.menpro = vmenpro.
            end.
            find func where func.etbcod = 999 and
                            func.funcod = sfuncod no-lock no-error.
            if not avail func
            then do:
                message "Funcionario Invalido".
                undo, retry.
            end.
            
            admprog.progtipo = string(string(vprocod,"999999") + " " +
                                      string(func.funnom,"x(10)") + " " +
                                      string(today) + 
                                      " CUSTO " + string(cus,">,>>9.99") +  
                                      "/" + string(vcusto,">,>>9.99") + 
                                      "   VENDA " + string(ven,">,>>9.99") +
                                      "/" + string(vpreco,">,>>9.99"),"x(78)").

            vtime = time.
            find hispre where hispre.procod   = vprocod
                          and hispre.dtalt    = today
                          and hispre.hora-inc = vtime
                          and hispre.funcod   = func.funcod no-error.
            if not avail hispre
            then do:
                create hispre.
                assign hispre.procod       = vprocod
                       hispre.dtalt        = today
                       hispre.hora-inc     = vtime
                       hispre.funcod       = func.funcod
                       hispre.estcusto-ant = cus
                       hispre.estcusto-nov = vcusto
                       hispre.estvenda-ant = ven
                       hispre.estvenda-nov = vpreco.
            end.

        end. 


        for each estab no-lock:
            for each estoq where estoq.etbcod = estab.etbcod and
                                 estoq.procod = produ.procod.
                estoq.datexp = today.
                estoq.estvenda = vpreco.
                estoq.dtaltpreco = today.
                /* estoq.estcusto = vcusto. */
                
                find hiest where hiest.etbcod = estoq.etbcod        and
                                 hiest.procod = estoq.procod        and
                                 hiest.hiemes = month(today) and
                                 hiest.hieano =  year(today) no-error.
                if not avail hiest
                then do:
                    create hiest.
                    assign hiest.etbcod = estoq.etbcod
                           hiest.procod = estoq.procod
                           hiest.hiemes = month(today)
                           hiest.hieano =  year(today).
                end.

                hiest.hiepcf = estoq.estcusto.
                hiest.hiepvf = estoq.estvenda.
                hiest.hiestf = estoq.estatual.

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
        produ.datexp = today.
    end.
end.


