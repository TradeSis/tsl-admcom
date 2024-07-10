{admcab.i}

def var vetbcod like estab.etbcod.
def var vmes    as int format "99".
def var vano    as int format "9999".
def var vok as log.
def var vqtd as dec.


repeat:

    vmes = 12.
    vano = year(today) - 1.
    update vetbcod label "Filial" with frame f1 side-label width 80.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f1.
    end.
    update vmes label "MES"
           vano label "ANO" with frame f1.

    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
        
        for each produ no-lock:
            
            display estab.etbcod
                    produ.procod with frame f2 side-label centered.
            pause 0.
            vqtd = 0.
            vok = no.
            
            find hiest where hiest.etbcod = estab.etbcod and
                             hiest.procod = produ.procod and
                             hiest.hiemes = vmes and
                             hiest.hieano = vano no-lock no-error.
            if avail hiest
            then do:
                assign vqtd = hiest.hiestf
                       vok = yes.
            end.
            else do:
                find last hiest where hiest.etbcod = estab.etbcod and
                                      hiest.procod = produ.procod and
                                      hiest.hiemes <= vmes        and
                                      hiest.hieano = vano
                                      no-lock no-error.
                if avail hiest
                then do:
                    vqtd = hiest.hiestf.
                    vok = yes.
                end.
                else do:
                    find last hiest where hiest.etbcod = estab.etbcod and
                                          hiest.procod = produ.procod and
                                          hiest.hieano = vano - 1
                                                      no-lock no-error.
                    if avail hiest
                    then do:
                        vqtd = hiest.hiestf.
                        vok = yes.
                    end.
                    else do:
                         find last hiest where hiest.etbcod = estab.etbcod and
                                          hiest.procod = produ.procod and
                                          hiest.hieano = vano - 2
                                                      no-lock no-error.
                        if avail hiest
                        then do:
                            vqtd = hiest.hiestf.
                            vok = yes.
                        end.
                        else do:
                            find last hiest where hiest.etbcod = estab.etbcod 
                                              and hiest.procod = produ.procod 
                                              and hiest.hieano < vano 
                                                      no-lock no-error.
                            if avail hiest
                            then do:
                                vqtd = hiest.hiestf.
                                vok = yes.
                            end.
                        end.
                    end.
                end.
            end.

            if vqtd < 0
            then vqtd = 0.
            
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.
            if estoq.estcusto = ? 
            then next.
            
            if vok = no
            then next.

            find ctbhie where ctbhie.etbcod = hiest.etbcod and
                              ctbhie.procod = hiest.procod and
                              ctbhie.ctbmes = vmes         and
                              ctbhie.ctbano = vano no-error.
            if not avail ctbhie
            then do transaction:
                create ctbhie.
                assign ctbhie.etbcod = hiest.etbcod
                       ctbhie.procod = hiest.procod
                       ctbhie.ctbmes = vmes
                       ctbhie.ctbano = vano
                       ctbhie.ctbest = vqtd
                       ctbhie.ctbcus = estoq.estcusto
                       ctbhie.ctbven = hiest.hiepvf.
            end.
        end.            
    end.
end.         
   
