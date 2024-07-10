/*
{admcab.i}


message "Gerar arquivo de Filiais" update sresp.
if not sresp
then return.
*/


def var varq as char.
def var vcod as char format "x(18)".

if opsys = "unix" 
then varq = "/admcom/audit/estab.txt".
else varq = "l:\audit\estab.txt".

def var cod-ibge as char.

output to value(varq).

for each estab no-lock:

    if estab.etbcgc = ""
    then next.

    vcod = "E" + string(estab.etbcod,"9999999999") + "       ". 
    find first munic where 
            munic.cidnom = estab.munic and
            munic.ufeco = estab.ufecod
            no-lock no-error.
    if avail munic
    then cod-ibge = string(munic.cidcod).
    else cod-ibge = "".   
    put unformatted
        vcod                 format "x(18)"        /* 001-018 */
        estab.etbcgc         format "x(18)"        /* 019-036 */
        estab.etbinsc        format "x(20)"        /* 037-056 */
        " "                  format "x(14)"        /* 057-070 */
        estab.etbnom         format "x(70)"        /* 071-140 */
        estab.etbnom         format "x(70)"        /* 141-210 */
        estab.endereco       format "x(50)"        /* 211-280 */
        " "                  format "x(10)"       
        " "                  format "x(10)"       
        " "                  format "x(20)"        /* 281-300 */
        estab.munic          format "x(50)"        /* 301-350 */
        estab.ufecod         format "x(02)"        /* 351-352 */
        " "                  format "x(08)"        /* 353-360 */
        " "                  format "x(20)"        /* 361-380 */
        " "                  format "x(12)"        /* 381-392 */
        cod-ibge             format "x(07)"        /* 393-397 */
        " "                  format "x(10)"        /* 398-407 */
        " "                  format "x(10)"        /* 408-417 */
        " "                  format "x(02)"        /* 418-419 */
        skip.
             
             
end.
output close.
              
              
