def var vetbcod like estab.etbcod.
def var vprocod like produ.procod.
def var vdti as date.
def var vdtf as date.

update vetbcod label "Filial"
       vprocod label "Produto"
       vdti label "Data Inicio"
       vdtf label "Data Final"
        .

def var vatuest as dec.

def var vdtaux as date.
vdtaux = vdti - 1.
def var vsal-ant as dec.

for each estab where (if vetbcod > 0
                then estab.etbcod = vetbcod else true) no-lock:
    disp estab.etbcod.
    pause 0.
    for each produ where (if vprocod > 0
                        then produ.procod = vprocod else true) no-lock:
        vatuest = 0.
        find last hiest where hiest.etbcod = vetbcod and
                hiest.procod = vprocod and
                hiest.hieano = year(vdtaux) and
                hiest.hiemes = month(vdtaux) no-lock no-error.
        if avail hiest
        then do:
            vatuest = hiest.hiestf.
        end.

        vsal-ant = vatuest.

        for each movim where movim.movdat >= vdti and
                         movim.movdat <= vdtf and
                         movim.etbcod = estab.etbcod  and
                         movim.procod = produ.procod
                         no-lock:

                run recal-est.p(input vetbcod,
                        input recid(movim) , 
                        input-output vatuest) .
        end.
        for each movim where movim.movdat >= vdti and
                         movim.movdat <= vdtf and
                         movim.desti  = estab.etbcod  and
                         movim.procod = produ.procod
                         no-lock:
            run recal-est.p(input vetbcod,
                        input recid(movim) , 
                        input-output vatuest) .
                
        end.

        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod
                         no-lock no-error.
        if avail estoq and estoq.estatual <> vatuest
        then do:                 
            disp produ.procod vsal-ant estoq.estatual vatuest.

            pause.
        /***
        find last hiest where hiest.etbcod = vetbcod and
                    hiest.procod = vprocod and
                hiest.hieano = year(vdtf) and
                hiest.hiemes = month(vdtf)  no-error.
        if avail hiest
        then hiest.hiestf = vatuest.

        find estoq where estoq.etbcod = vetbcod and
                 estoq.procod = vprocod
                 no-error.
        if avail estoq
        then estoq.estatual = vatuest.      
        ***/     
        end.          
    end.
end.    
