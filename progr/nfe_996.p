{admcab.i}
def var vfuncod like func.funcod.
def var vetbcod like estab.etbcod.
vfuncod = sfuncod.
vetbcod = setbcod.
setbcod = 996.
sfuncod = 996.
run cham_nfe.p.
setbcod = vetbcod.
sfuncod = vfuncod.
return.


