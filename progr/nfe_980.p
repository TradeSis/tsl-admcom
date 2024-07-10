{admcab.i}
def var vfuncod like func.funcod.
def var vetbcod like estab.etbcod.
vfuncod = sfuncod.
vetbcod = setbcod.
sfuncod = 980.
setbcod = 980.
run cham_nfe.p .
setbcod = vetbcod.
sfuncod = vfuncod.
return.

