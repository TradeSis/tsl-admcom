def input  parameter par-movtdc as int.
def output parameter par-opccod as int.

def var vct as int.

def temp-table tt-opcom
    field opccod    like opcom.opccod
    field opcnom    like opcom.opcnom
    index opcom is primary unique opccod.

find tipmov where tipmov.movtdc = par-movtdc no-lock.
for each opcom where opcom.movtdc = par-movtdc no-lock.
    if (tipmov.tipemite      /* Saida */ and
        opcom.opccod > "5000" and
        opcom.opccod < "6000") or
       (tipmov.tipemite = no /* Entrada */ and
        opcom.opccod > "1000" and
        opcom.opccod < "2000")
    then do.
        vct = vct + 1.
        par-opccod = int(opcom.opccod).
        create tt-opcom.
        assign
            tt-opcom.opccod = opcom.opccod
            tt-opcom.opcnom = opcom.opcnom.
    end.
end.

if vct > 1
then do.
    par-opccod = 0.
    update par-opccod with frame f no-label no-box editing.
        readkey pause 0.
        {zoomesq.i tt-opcom tt-opcom.opccod
            "tt-opcom.opcnom + "" | "" + string(tt-opcom.opccod) "
            78
            Operacao.Comercial
            "true" }
        par-opccod = int(frame-value) no-error.
        apply lastkey.
    end.
    hide frame f.
end.

