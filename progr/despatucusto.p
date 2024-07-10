def input parameter p-etbcod like fatudesp.etbcod.
def input parameter p-clicod like fatudes.clicod.
def input parameter p-fatnum like fatudesp.fatnum.

def var p-numeropi as char.
def var vcusto as dec.

def buffer bestoq for estoq.

find fatudesp where fatudesp.etbcod = p-etbcod and
                    fatudesp.clicod = p-clicod and
                    fatudesp.fatnum = p-fatnum
                    no-lock no-error.
if avail fatudesp
then do:    
    p-numeropi = fatudesp.numerodi.                
    find first tpimport where
               tpimport.numeropi = p-numeropi
               no-lock no-error.
    if avail tpimport
    then do:
        find first plani where
                   plani.etbcod = tpimport.etbcod and
                   plani.emite  = tpimport.etbcod and
                   plani.serie  = tpimport.sernfe and
                   plani.numero = tpimport.numnfe
                   no-lock no-error.
        if avail plani
        then do:
            for each movim where
                     movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc and
                     movim.movdat = plani.pladat
                     no-lock:
                find estoq where
                     estoq.etbcod = movim.etbcod and
                     estoq.procod = movim.procod
                     no-lock.
                vcusto = (fatudesp.val-liquido *
                    ((movim.movpc * movim.movqtm) / plani.protot))
                    / movim.movqtm.
                vcusto = vcusto + estoq.estcusto.
                if vcusto > estoq.estcusto
                then do:
                    for each bestoq where
                             bestoq.procod = movim.procod
                             :
                        bestoq.estcusto = vcusto.
                    end.
                    run /admcom/progr/calctom-pro.p(movim.procod, 
                                            input plani.dtinclu ,
                                            input today ,
                                            input "").
                end.
                vcusto = 0.
            end.
        end.           
    end.
end.    
