def var varq as char.
def var vetbcod like estab.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vcod as char format "x(18)".


output to /admcom/audit/estab.txt.


for each estab no-lock:

    if estab.etbcgc = ""
    then next.

    vcod = "E" + string(estab.etbcod,"9999999") + "          ". 
    
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
        " "                  format "x(05)"        /* 393-397 */
        " "                  format "x(10)"        /* 398-407 */
        " "                  format "x(10)"        /* 408-417 */
        " "                  format "x(02)"        /* 418-419 */
        skip.
             
             
end.
output close.

output to /admcom/audit/forne.txt.

for each forne no-lock:

    if forne.forcgc = ""
    then next.

    find first frete where frete.forcod = forne.forcod no-lock no-error.
    if avail frete
    then vcod = "T" + string(forne.forcod,"9999999") + "          ". 
    else vcod = "F" + string(forne.forcod,"9999999") + "          ". 

    put unformatted
        vcod                 format "x(18)"        /* 001-018 */
        forne.forcgc         format "x(18)"        /* 019-036 */
        forne.forinest       format "x(20)"        /* 037-056 */
        " "                  format "x(14)"        /* 057-070 */
        forne.fornom         format "x(70)"        /* 071-140 */
        forne.forfant        format "x(70)"        /* 141-210 */
        forne.forrua         format "x(50)"        /* 211-280 */
        string(forne.fornum) format "x(10)"       
        forne.forcomp        format "x(10)"       
        forne.forbairro      format "x(20)"        /* 281-300 */
        forne.formunic       format "x(50)"        /* 301-350 */
        forne.ufecod         format "x(02)"        /* 351-352 */
        forne.forcep         format "x(08)"        /* 353-360 */
        forne.forpais        format "x(20)"        /* 361-380 */
        " "                  format "x(12)"        /* 381-392 */
        " "                  format "x(05)"        /* 393-397 */
        " "                  format "x(10)"        /* 398-407 */
        " "                  format "x(10)"        /* 408-417 */
        " "                  format "x(02)"        /* 418-419 */
        skip.
             
             
end.
output close.

output to /admcom/audit/produto.txt.

for each produ no-lock:

    put unformatted
        "1" format "x(1)"                          /* 001-001 */
        string(produ.procod) format "x(20)"        /* 002-021 */
        produ.pronom         format "x(45)"        /* 022-066 */
        produ.prouncom       format "x(03)"        /* 067-069 */
        " "                  format "x(10)"        /* 070-079 */
        " "                  format "x(03)"        /* 080-082 */
        "0000.00"                                  /* 083-089 */
        "0000.00"                                  /* 090-096 */
        "0000.00"                                  /* 097-103 */
        " "                  format "x(02)"        /* 104-105 */ skip.
             
             
end.
output close.

output to /admcom/audit/ecf.txt.
for each tabecf no-lock:

    put tabecf.etbcod format ">99"
        tabecf.equipa format ">>9"
        dec(tabecf.serie)  format ">>>>>>>>>>>>>>>>>>>9"
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

      
    
    run ecf_aud2.p.
    run entaud02.p.
    run sai_aud.p.
                        
                    
  
         
           
