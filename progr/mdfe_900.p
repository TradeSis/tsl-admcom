{admcab.i}
def var vfuncod like func.funcod.
def var vetbcod like estab.etbcod.
vfuncod = sfuncod.
vetbcod = setbcod.
sfuncod = 900.
setbcod = 900.
run mdfe/viagem.p .
setbcod = vetbcod.
sfuncod = vfuncod.
return.

