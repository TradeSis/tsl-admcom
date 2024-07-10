{admcab.i}

def var vsel1 as char format "x(15)" extent 2
    init ["  Geral  "," Com Bonus "].
def var vsel2 as char format "x(30)" extent 3
    init ["Com Bonus - NF","Com Bonus - Dia",
          "Com Bonus - Mes"].
def var vindex1 as int.
def var vindex2 as int.            
           
disp vsel1 with frame f1 no-label 1 down centered.
choose field vsel1 with frame f1.
vindex1 = frame-index.

if vindex1 = 1
then do:
    run geral.p.
end.
else do:
    disp vsel2 with frame f2 1 down no-label centered 1 column.
    choose field vsel2 with frame f2.
    vindex2 = frame-index.

    run marg_bon.p(input vindex2).

    hide frame f2 no-pause.
end.

