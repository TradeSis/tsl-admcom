/*
#1 04/19 - Projeto ICMS Efetivo
*/
{admcab.i}

def var vforcod   like forne.forcod.
def var vnumero   like plani.numero format ">>>>>>>>>>" initial 0.
def var vetbcod   like plani.etbcod.
def var vserie    as char format "x(3)".

form
    vetbcod label "Filial" colon 15
    estab.etbnom no-label skip
    vforcod colon 15
    forne.fornom no-label
    vnumero   colon 15
    vserie    at 32   label "Serie" format "x(03)"
    with frame f1 side-label color blue/cyan width 80 row 4.

repeat:
    clear frame f1 no-pause.
    
    update vetbcod with frame f1.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom with frame f1.

    update vforcod with frame f1.
    find forne where forne.forcod = vforcod no-lock.
    disp forne.fornom no-label with frame f1.

    vserie = "U".
    update vnumero
           vserie with frame f1.
    find plani where plani.numero = vnumero and
                     plani.emite  = vforcod and
                     plani.movtdc = 4   and
                     plani.serie  = vserie and
                     plani.etbcod = estab.etbcod no-lock no-error.
    if not avail plani
    then do:
        message "Nota Fiscal nao cadastrada".
        undo, retry.
    end.

    run not_consnota.p (recid(plani)).
end.

