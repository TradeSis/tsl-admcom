{admcab.i}
def var vfuncod like func.funcod.
def var vetbcod like estab.etbcod.
vfuncod = sfuncod.
vetbcod = setbcod.
sfuncod = 995.
setbcod = 995.
run cham_nfe.p .
setbcod = vetbcod.
sfuncod = vfuncod.
return.


