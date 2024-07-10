def var vclacod like clase.clacod.

update vclacod label "Classe" with frame f1 1 down side-label.
find clase where clase.clacod = vclacod no-lock.
disp clase.clanom no-label with frame f1.
for each produ where produ.clacod = vclacod no-lock:
    disp produ.procod produ.pronom with frame f2 down.
end.
pause.

