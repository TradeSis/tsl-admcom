/*
{admcab.i}
message "Gerar arquivo l:\audit\ecf.txt" update sresp.
if not sresp
then return.
*/


def var varq as char.

if opsys = "unix"
then varq = "/admcom/audit/ecf.txt".
else varq = "l:~\audit~\ecf.txt".


output to value(varq).
for each tabecf no-lock:

    if tabecf.datfin >= 10/01/13
    then.
    else next.
    if tabecf.serie = ""
    then next.
    
    put tabecf.etbcod format ">99"
        tabecf.equipa format ">>9"
        /*dec(tabecf.serie)  format ">>>>>>>>>>>>>>>>>>>9"
        */
        tabecf.serie format "x(20)"
        "2D"
        " " format "x(10)"
        "CAIXA: "
        tabecf.de1 format " >9"
        " " format "x(90)"
        "1  " format "x(03)"
        year(tabecf.datini)  format "9999"
        month(tabecf.datini) format "99"
        day(tabecf.datini)   format "99"
        year(tabecf.datfin)  format "9999"
        month(tabecf.datfin) format "99" 
        day(tabecf.datfin)   format "99" skip.
        
end.
input close.
