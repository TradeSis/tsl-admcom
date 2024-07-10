def input parameter p-numero as char format "x(12)".
def output parameter p-digito as int.

def var vnumero as char format "x(12)".
def var i as int.
def var vdig as int.
def var vtotal as int.
def var vfim as int.

vnumero = "".

do i = length(p-numero) to 1 by -1.
    vnumero = vnumero + substr(string(p-numero),i,1).
end.

vdig = 2.
vtotal - 0.

do i = 1 to length(vnumero) :
    vtotal = vtotal + (int(substr(vnumero,i,1)) * vdig).
    vdig = vdig + 1.
    if vdig > 9 
    then vdig = 2.
end.

vfim = vtotal mod 11.

p-digito = 11 - vfim.
if vfim = 0 or vfim = 1 
then p-digito = 0.


