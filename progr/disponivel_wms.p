/* Disponivel para o e-commerce 05/10/12 */
/* Projeto Melhorias Mix - Luciano    */


def input  parameter par-procod like produ.procod.
def output parameter par-disponivel as dec.

for each liped where liped.pedtdc = 10
                 and liped.etbcod = 200
                 and liped.lipsit = "P"
                 and liped.procod = par-procod
               no-lock.
    find pedid of liped no-lock.
    if pedid.peddti > today or
       pedid.peddtf < today
    then next.

    par-disponivel = par-disponivel + (liped.lipqtd - liped.lipent).
end.
