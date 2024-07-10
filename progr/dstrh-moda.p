/* Ordem de Venda          WMS Alcis                              */
/** 31/05/2017 - #3 Projeto Moda no ecommerce, se for ecommerce, rodara interface para moda, e dentro da interface somente ira exportar produtos nmoda. a interface para moveis nao ira exportar produtos moda.
#4 14/07/2017 - somente diretorio alcis /usr/ITF/dat/in/ 
*/

def input parameter par-rec as recid.

def var par-bkp as char.
def var par-arq as char.
def var vPROPRIETaRIO      as char init "900".
def var v as int.
def var vdiretorio-alcis as char.
def var vdiretorio-bkp  as char.

def var p-valor as char. 


find tdocbase where recid(tdocbase) = par-rec no-error.
if not avail tdocbase
then leave.

/* #3 */
def var vmoda_ecommerce as log.
vmoda_ecommerce = no.
for each tdocbpro of tdocbase no-lock.  /* #3 */
    find produ of tdocbpro no-lock.
    if produ.catcod = 41  
    then vmoda_ecommerce = yes.
end.
if vmoda_ecommerce = no
then return. /* #3 se nao ha produtos moda */

do on error undo.
    find first tab_ini where tab_ini.parametro = "ALCIS-ARQ-DSTRH" no-error.
    v = int(tab_ini.valor) + 1.
    tab_ini.valor = string(v).
    p-valor = string(v).
end. 

pause 1 no-message.

vdiretorio-bkp = "/admcom/tmp/dstrh/".

/*vdiretorio-ant = "/admcom/tmp/alcis/INS/".*/

vdiretorio-alcis = "/usr/ITF/dat/in/". /* #4 */

/*
par-arq = vdiretorio-ant + "DSTRH" + string(int(p-valor),"99999999") + ".DAT".
*/
/* #4 */
par-arq = vdiretorio-alcis + "DSTRH" + string(int(p-valor),"99999999") + ".DAT".

par-bkp = vdiretorio-bkp + "DSTRH" + string(int(p-valor),"99999999") +
                             ".HORA" +  replace(string(time,"HH:MM:SS"),":","")                            + ".DAT".
                             
message "Arquivo" par-arq.
hide message no-pause.

output to value(par-bkp).

for each tdocbpro of tdocbase :

    find produ of tdocbpro no-lock.
    if produ.catcod <> 41 then next. /* #3 somente produtos moda */
    
    def var vseq as int.
    vseq = vseq + 1.


    put unformatted 
        "LEBES"                 format "x(10)"                  
        "DSTR"                  format "x(4)"                   
        "DSTRH"                 format "x(8)"                   
        "CD3"                   format "x(3)"                   
        vPROPRIETaRIO           format "x(12)"                  
        string(tdocbase.etbdes)   format "x(12)"                  
        string(tdocbpro.procod)   format "x(40)"                  
      tdocbpro.movqtm * 1000000000     format "999999999999999999"     
        produ.prouncom          format "x(6)"
        fill("0",20)            format "x(32)" /* ID */
        skip.                     

            
    tdocbpro.situacao = "L".            
                     
end.
tdocbase.campo_char1 = tdocbase.campo_char1 +
                    "DATAENVIOORDVWMS=" + string(today,"99/99/9999") +
                   "|HORAENVIOORDVWMS=" + string(time,"hh:mm:ss") +
                   "|ARQUIVOORDVWMS=" + par-arq.
tdocbase.situacao = "L".


output close.


hide message no-pause.


/*
unix silent value("cp " + par-bkp +  " " + par-arq).
*/

unix silent value("cp " + par-bkp +  " " + par-arq). /* #4 */


hide message no-pause.
message "#4 GERADO MODA " par-arq.

do on endkey undo , leave.
pause 1 no-message.
end.


/**
unix silent value("rm -rf " + par-arq +  " " ).
**/

/** {mens-interface-wms-alcis.i} **/
hide message no-pause.
    
