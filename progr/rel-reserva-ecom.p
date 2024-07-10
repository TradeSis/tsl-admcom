{admcab.i}

def var reserva_ecom as int.

message "Gerando arquivo...".

output to /admcom/relat/estoq_ecom.csv.

for each estoq where estoq.etbcod = 900 and 
                    estoq.estatual > 0 no-lock.

find produ where produ.procod = estoq.procod no-lock no-error.

find first produaux where produaux.procod = estoq.procod and
                         produaux.nome_campo = "exporta-e-com" and
                         produaux.valor_campo = "yes" no-lock no-error.
if not avail produaux then next.

run reserv_ecom.p (input estoq.procod, output reserva_ecom).

disp estoq.etbcod ";"
    estoq.procod ";" 
    produ.pronom format "x(40)" ";" 
    estoq.estatual ";" 
    reserva_ecom skip
with width 200.                                      

end.
output close.    

message "Arquivo estoq_ecom.csv gerado com sucesso em L:/relat" view-as alert-box.                                             