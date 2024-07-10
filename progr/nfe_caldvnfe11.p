/****************************
* Calculo DV modulo 11 p/NFE
****************************/

def input  parameter p-valor as dec.
def output parameter p-dv    as int.

def var vi as int.
def var vz as int.
def var vtama as int.
def var vval  as int .
def var vres  as int initial 0.
def var vacum as dec initial 0.
def var vfator as int.

vtama = length(string(p-valor)).
vacum = 0.
vfator = 1.
do vi = vtama to 1 by -1:
    vfator = vfator + 1.
    if vfator > 9 then vfator = 2.
    vval = int(substr(string(p-valor),vi,1)).
    vres = vval * vfator.
    vacum = vacum + vres.
end.

vres = vacum modulo 11.
if vres <= 1
then p-dv = 0.
else p-dv = 11 - vres.

