/*
{admcab.i}
message "Gerar arquivo l:\audit\ecf.txt" update sresp.
if not sresp
then return.
*/

def var sresp as log format "Sim/Nao".
def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
 

def var varq as char.

if opsys = "unix" and sparam = "AniTA"
then varq = "/admcom/decision/ecf.txt".
else varq = "/file_server/ecf.txt".


output to value(varq).
for each tabecf no-lock:

    if tabecf.datfin >= today - 60
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
