/*  alcis/pedch.p                                                     */
/* Pedidos de Compra           WMS Alcis                              */

def input parameter par-rec as recid.

find pedid where recid(pedid) = par-rec no-lock no-error.
if not avail pedid
then leave.

def var par-arq         as char.
def var v               as int.
def var vdiretorio-ant  as char.
def var vdiretorio-apos as char.
def var p-valor         as char. 
def var vstatus         as char.

/*** HOMOLOGACAO
do on error undo.
    find first tab_ini where tab_ini.parametro = "ALCIS-ARQ-ORECH" no-error.
    if not avail tab_ini
    then do.
        create tab_ini. 
        ASSIGN tab_ini.etbcod    = 0
               tab_ini.cxacod    = 0
               tab_ini.parametro = "ALCIS-ARQ-ORECH"
               tab_ini.valor     = "0"
               tab_ini.dtinclu   = today
               tab_ini.dtexp     = today
               tab_ini.exportar  = no.
    end.
    else do.
        v = int(tab_ini.valor).
        v = v + 1.
        tab_ini.valor = string(v).
    end.
end. 
***/

vdiretorio-ant  = "/admcom/tmp/alcis/INS/".
vdiretorio-apos = "/usr/ITF/dat/in/".

/*** HOMOLOGACAO
run /admcom/progr/le_tabini.p (0, 0, 
                               "ALCIS-ARQ-ORECH", OUTPUT p-valor) .
***/
par-arq = vdiretorio-ant + "PEDC" + string(int(p-valor),"99999999") + ".DAT".   

if pedid.sitped = "A"
then vstatus = "00".
else if pedid.sitped = "P"
then vstatus = "11".
else if pedid.sitped = "F"
then vstatus = "90".

output to value(par-arq) /*append*/.
put unformatted 
    "ERP"                   format "x(10)" 
    "PEDC"                  format "x(4)" 
    "PEDCH"                 format "x(8)" 
    "CD2"                   format "x(3)" 
    "995"                   format "x(12)" /* Proprietario */
    string(pedid.pednum)    format "x(12)"
    string(pedid.clfcod)    format "x(12)"
    "NORM"                  format "x(6)"
    pedid.peddti            format "99999999"
    pedid.peddtf            format "99999999"
    vstatus                 format "x(2)"    
    skip.

output close.

/*** HOMOLOGACAO
unix silent value("mv " + par-arq + " " + vdiretorio-apos).
***/

