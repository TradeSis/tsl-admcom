
def input parameter rec-plani as recid.

def shared temp-table wf-plani like plani.
def shared temp-table wf-movim like movim.

def var vdtct-aux as date.

find first plani where recid(plani) = rec-plani no-lock no-error.
if avail plani and
         plani.notpis = 0 and
         plani.notcofins = 0
then run /admcom/progr/piscofins2.p(input recid(plani)).

find first plani where recid(plani) = rec-plani no-lock.
create wf-plani.
buffer-copy plani to wf-plani.
for each movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc and
                     movim.movdat = plani.pladat
                     no-lock:
    find first produ where produ.procod = movim.procod no-lock no-error.
    find estoq where estoq.etbcod = movim.etbcod and
                     estoq.procod = movim.procod 
                     no-lock no-error.

    release wf-movim.
    find first wf-movim where wf-movim.etbcod = movim.etbcod
                          and wf-movim.placod = movim.placod  
                          and wf-movim.procod = movim.procod
                                    no-error.
    if not avail wf-movim
    then create wf-movim.
    buffer-copy movim to wf-movim.
    if plani.vlserv > 0
    then wf-movim.movdev = plani.vlserv * 
                ((movim.movpc * movim.movqtm) / plani.platot).
    vdtct-aux = movim.movdat.            
    vdtct-aux = date(if month(movim.movdat) = 12 then 1
                                                 else month(movim.movdat) + 1
                     ,01,
                     if month(movim.movdat) = 12 then year(movim.movdat) + 1
                                                else year(movim.movdat)
                     ) - 1.
    if vdtct-aux = ?
    then vdtct-aux = movim.movdat.
    find last mvcusto where
              mvcusto.procod = movim.procod and
              mvcusto.dativig <= vdtct-aux 
                            no-lock no-error.
    if avail mvcusto and mvcusto.valctomedio <> ?
    then wf-movim.MovCtM = mvcusto.valctomedio * wf-movim.movqtm.
    else if avail estoq and
            estoq.estcusto <> ?
         then wf-movim.MovCtM = estoq.estcusto * wf-movim.movqtm.
    if avail produ and
             produ.proipiper > 0 and
             produ.proipiper <> 99
    then wf-movim.movicms = ((wf-movim.movpc * wf-movim.movqtm) *
            (produ.proipiper / 100)).
            
                    
end.    


