{admcab.i}

/* Baixa reserva de produtos do e-commerce após checkout no Ábacos */

def input  parameter par-procod like produ.procod.
def output parameter par-qtd    as int.

def buffer buf-liped for liped.
def buffer buf-pedid for pedid.

for each buf-liped where buf-liped.pedtdc = 10
                     and buf-liped.etbcod = 200
                     and buf-liped.lipsit = "P"
                     and buf-liped.procod = par-procod
                       exclusive-lock,
    first buf-pedid of buf-liped no-lock.
    if buf-pedid.peddti > today or
        buf-pedid.peddtf < today
    then next.

    if buf-liped.lipent >= buf-liped.lipqtd
    then next.

    assign buf-liped.lipent = buf-liped.lipent + par-qtd.

    /* Baixa apenas na primeira reserva*/
    leave.

end.







