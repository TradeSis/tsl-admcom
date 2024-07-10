{admcab.i}
def var vfuncod like func.funcod.
def var vetbcod like estab.etbcod.
vfuncod = sfuncod.
vetbcod = setbcod.
sfuncod = 988.
setbcod = 988.
run cham_nfe.p .
setbcod = vetbcod.
sfuncod = vfuncod.
return.

