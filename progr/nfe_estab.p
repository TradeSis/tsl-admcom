{admcab.i}
def var vfuncod like func.funcod.
def var vetbcod like estab.etbcod.

vfuncod = sfuncod.
vetbcod = setbcod.

do on error undo with side-label.
/***
    update setbcod.
***/
    find estab where estab.etbcod = setbcod no-lock.
    disp setbcod estab.etbnom no-label.
    sfuncod = setbcod.
end.

run cham_nfe.p.

setbcod = vetbcod.
sfuncod = vfuncod.

