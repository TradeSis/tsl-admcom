{admcab.i}
def temp-table wpro
    field wprocod like produ.procod
    field wqtd    like estoq.estatual.

DEF VAR VPROCOD  LIKE PRODU.PROCOD.
def var vdata   like plani.pladat.
def var vetbcod  like estab.etbcod.
def var vqtd     like estoq.estatual.

update vetbcod with frame f1 side-label width 80.
find estab where estab.etbcod = vetbcod no-lock.
display estab.etbnom no-label with frame f1.

for each wpro:
    delete wpro.
end.

update vdata label "Data" with frame f1.

repeat:
    create duplic.
    assign duplic.duppc = estab.etbcod
           duplic.dupven = vdata.

    update duplic.fatnum label "codigo" with frame f2 width 80 down.
    find produ where produ.procod = duplic.fatnum no-lock.
    display produ.pronom with frame f2.
    update duplic.dupval label "QTD" with frame f2.
end.
for each duplic where duplic.duppc = estab.etbcod and
                      duplic.dupven = vdata  break by duplic.fatnum:
    vqtd = vqtd + duplic.dupval.
    if last-of(duplic.fatnum)
    then assign duplic.dupjur = vqtd
                vqtd = 0.
end.

for each duplic where duplic.duppc = estab.etbcod and
                      duplic.dupven = vdata no-lock:
    find estoq where estoq.etbcod = estab.etbcod and
                     estoq.procod = duplic.fatnum.

        assign estoq.estatual = duplic.dupjur.

        for each movim where movim.procod  = duplic.fatnum and
                             movim.movdat >= duplic.dupven and
                             movim.etbcod  = estab.etbcod no-lock:
            run atuest.p (input recid(movim),
                          input "I",
                          0).
        end.
end.
