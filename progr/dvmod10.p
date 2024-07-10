def input parameter p-numero as char format "x(12)".
def output parameter p-digito as int.

def var vnumero as char format "x(12)".
def var i as int.
def var vdig as int.
def var vtotal as int.
def var vfim as int.

vnumero = p-numero.
vdig = 2.
vtotal = 0.
def var vj as int.
def var vh as int.
def var vi as int.
vi = length(vnumero).
vh = vi.
vj = 1.
def var v-reg as int.
def var v-aux as char.
def var v-aux1 as char.
def var v-aux2 as char.
do while (vj <= vi) :
    v-reg = (int(substr(vnumero,vh,1)) * vdig).
    do while v-reg > 9 :
        v-aux = string(v-reg).
        v-aux1 = substr(v-aux,1,1).
        v-aux2 = substr(v-aux,2,1).
        v-reg = int(v-aux1) + int(v-aux2).
    end.
    vtotal = vtotal + v-reg.
    if vdig = 2 then vdig = 1.
    else vdig = vdig + 1.
    vj = vj + 1.
    vh = vh - 1.
end.

p-digito = vtotal mod 10.
p-digito = 10 - p-digito.
if p-digito >= 10
then p-digito = 0.
