/* não colocar admcab.i */

def var sresp as log format "Sim/Nao".
def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
 
if opsys = "unix" and sparam = "AniTA"
then do:
    sresp = no.
    message "Confirma gerar arquivo de FILIAIS?" update sresp.
    if not sresp then return.
end. 

def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
vdtf = today - 1.
vdti = vdtf  - 60.

def var varq as char.
def var vcod as char format "x(18)".

if opsys = "unix" and sparam = "AniTA" 
then varq = "/admcom/decision/estab.txt".
else varq = "/file_server/estab.txt".

def var cod-ibge as char.
def var vok-desti as log.

output to value(varq).

for each estab no-lock:
    
    if today < 01/01/17 and estab.etbcod = 150 
    then next.
    
    if estab.etbcgc = ""
    then next.
    if estab.endereco = ""
    then next.
    if estab.etbcgc = "00000000000000"
    then next.

    vok-desti = no.    

    find first plani where plani.etbcod = estab.etbcod and
                           plani.pladat > vdti
                           no-lock no-error.
    if not avail plani 
    then do:
        for each tipmov no-lock:
            find first plani where  plani.movtdc = tipmov.movtdc and
                                plani.desti = estab.etbcod and
                        plani.pladat > vdti
                        no-lock no-error.
            if avail plani then vok-desti = yes.
        end.
    end.    
    else vok-desti = yes.
    
    if not vok-desti then  next.
     
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
    
if opsys = "unix" and sparam = "AniTA"     
then do:         
    message color red/with
        "Arquivo gerado:" skip
        varq
        view-as alert-box
        .
end.        
              
