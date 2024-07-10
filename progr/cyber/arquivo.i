/*
  cyber/arquivo.i
  13/01/2015
*/
function formatadata returns character
    (input par-data  as date). 
    
    def var vdata as char.  
    if par-data <> ? 
    then 
        vdata = string(month(par-data), "99") + 
                string(day  (par-data), "99") +
                string(year (par-data), "9999"). 
    else 
        vdata = "00000000". 
    return vdata. 

end function.


function formatanumero returns int
    (input par-valor as int).

    if par-valor = ? /* valores invalidos */
    then return 0.
    else return int(par-valor).

end function.


function formatavalor returns dec
    (input par-valor as dec).

    if par-valor = ? or par-valor > 999999 /* valores invalidos */
    then return 0.
    else return par-valor * 100.

end function.


function trata-numero returns character
    (input par-num as char).

    def var par-ret as char.
    def var j as int.
    def var t as int.
    def var vletra as char.

    t = length(par-num).
    do j = 1 to t:
        vletra = substr(par-num,j,1).
        if vletra = "0" or
           vletra = "1" or
           vletra = "2" or
           vletra = "3" or
           vletra = "4" or
           vletra = "5" or
           vletra = "6" or
           vletra = "7" or
           vletra = "8" or
           vletra = "9"
        then assign par-ret = par-ret + vletra.
    end.
    return par-ret.

end function.

                    
def var vdata_geracao  as char.
def var vhora_geracao  as char.
def var cdata      as char.
def var vtoday     as date.
def var vtime      as int.
def var vdiretorio as char.
def var varq       as char.
def var vnomearq   as char.

vtoday = today.
vtime  = time.
if vtime < 18000 /* 05:00:00 */
then assign
        vtoday = vtoday - 1.

vdata_geracao = formatadata(vtoday).

if {1} <> "mercadorias" and
   {1} <> "parcelas"
then do.
    vhora_geracao = string(vtime,"HH:MM:SS").
    vhora_geracao = substr(vhora_geracao,1,2) +
                    substr(vhora_geracao,4,2) +
                    substr(vhora_geracao,7,2) + "_".
end.
   
cdata = string(year (vtoday), "9999") +
        string(month(vtoday), "99") +
        string(day  (vtoday), "99").

vnomearq = cdata + "_" + vhora_geracao + {1} + "_in".

find first tab_ini where tab_ini.etbcod     = 0 and
                         tab_ini.parametro  = "CYBER_DIRETORIO_ARQUIVOS"
                   no-lock no-error.
vdiretorio = if avail tab_ini
             then tab_ini.valor
             else "/admcom/tmp/".

vdiretorio = vdiretorio + cdata + "/".
unix silent value("mkdir " + vdiretorio).

varq = vdiretorio + "/" + vnomearq + ".txt".

