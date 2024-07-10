{admcab.i new}

def buffer sclase for clase.
def buffer iclase for clase.

def var vericlas like clase.clacod.
def var vericlai like clase.clacod.

update vericlas.

/* Superiores */

/*
for each clase where clase.clasup = 0 and clase.clacod <> 0 no-lock:
    disp clase.clacod (count) clasup with frame frr title "Superiores" down.
end.    


*/

/* Inferiores */

for each clase where clase.clacod = 1457 no-lock:
    disp clase.clacod clasup.
end.

