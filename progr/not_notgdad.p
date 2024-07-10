{admcab.i}

def output parameter par-resp   like sresp.

def var vprotot   like  plani.protot.

def shared temp-table tt-plani    like plani.
def shared temp-table tt-movim    like movim.

find first tt-plani.
find opcom where opcom.opccod = string(tt-plani.opccod) no-lock.

    for each tt-movim where
             tt-movim.etbcod = tt-plani.etbcod and
             tt-movim.placod = tt-plani.placod and
             tt-movim.movtdc = tt-plani.movtdc and
             tt-movim.movdat = tt-plani.pladat
             no-lock:
        vprotot = vprotot + (tt-movim.movqtm * tt-movim.movpc).
    end.

    assign
        tt-plani.platot = vprotot
        tt-plani.protot = vprotot.

disp
    tt-plani.emite    colon 16
    tt-plani.desti    colon 16
    opcom.opccod   colon 16
    opcom.opcnom   no-label
    tt-plani.platot colon 16
    with frame f-nf side-label row 9 centered.

    par-resp = no.
    message "Confirma Emissao da Nota?" update par-resp.
