{admcab.i}
def var ss as dec.
def var vperc as dec format ">9.99 %".
def var vetccod like produ.etccod.
DEF BUFFER BESTOQ FOR ESTOQ.
def var vdata like estoq.estprodat.
def var vpreco like estoq.estproper format ">,>>9.99" label "Promocao".
def var vprocod like produ.procod.
repeat:
    UPDATE vetccod with frame f1 side-label width 80.
    find estac where estac.etccod = vetccod no-lock no-error.
    if not avail estac
    then do:
        message "Estacao nao Cadastrada".
        undo, retry.
    end.
    disp estac.etcnom no-label with frame f1.
    update vperc label "Perc."
           vdata label "Data" with frame f1.
    
     
    message "Confirma Promocao" update sresp.
    for each produ where produ.etccod = estac.etccod no-lock:
        display produ.procod produ.etccod with 1 down. pause 0.
        for each estoq where estoq.procod = produ.procod break by estoq.procod.
                vpreco = estoq.estproper.
                estoq.datexp = today.
                estoq.estproper = estoq.estvenda -
                                  (estoq.estvenda * (vperc / 100)).
                estoq.estprodat = vdata.
                
                /*********** arredonda ***************/
                ss = ( (int(estoq.estproper) - (estoq.estproper)) ) - 
                        round(( (int(estoq.estproper) - 
                                    (estoq.estproper)) ),1).

                if ss < 0 
                then ss = 0.10 - (ss * -1). 

                if ss >= 0.05
                then estoq.estproper = estoq.estproper - (0.10 - ss).
                else estoq.estproper = estoq.estproper + ss.
                estoq.dtaltpromoc = today.
                /************************************/
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
