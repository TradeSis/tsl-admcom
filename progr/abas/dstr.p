def input parameter par-rec as recid.
def input parameter par-diretorio   as char.
def input parameter par-arquivo     as char.

def var par-bkp as char.
def var par-sai as char.

def var vPROPRIETaRIO      as char init "900".
def var vdiretorio-bkp  as char.

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

vdiretorio-bkp = "/admcom/tmp/dstrh/".

par-sai = par-diretorio  +       par-arquivo.
par-bkp = vdiretorio-bkp +       par-arquivo.
                             
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
        string(tdocbase.dcbcod,"999999999999999") +
          string(tdocbpro.dcbpseq,"99999") format "x(32)" /* ID */
          
        /*13.01.2020*/
        trim(string(tdocbpro.pednum))  format "x(12)" /* pedido */ 
        /*13.01.2020*/   
        skip.                     

            
    tdocbpro.situacao = "L".            
                     
end.
output close.
tdocbase.campo_char1 = tdocbase.campo_char1 +
                    "DATAENVIOORDVWMS=" + string(today,"99/99/9999") +
                   "|HORAENVIOORDVWMS=" + string(time,"hh:mm:ss") +
                   "|ARQUIVOORDVWMS=" + par-bkp.
tdocbase.situacao = "L".

hide message no-pause.
unix silent value("cp " + par-bkp +  " " + par-sai). /* #4 */


hide message no-pause.
message color normal "GERADO MODA " par-sai.
do on endkey undo , leave.
pause 1 no-message.
end.
    
