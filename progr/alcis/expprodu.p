/*  alcis/expprodu.p                                                        */
/* exportacao de produtos para o WMS Alcis                              */
def input parameter par-rec as recid.
def var par-arq as char.

find produ where recid(produ) = par-rec no-lock no-error.
if not avail produ
then leave.

/*****/
def shared var vALCIS-ARQ-PRODU   as int.
if vALCIS-ARQ-PRODU = 0
then do on error undo.
    find first tab_ini where tab_ini.parametro = "ALCIS-ARQ-PRODU" no-error.
    if not avail tab_ini
    then do.
        create tab_ini. 
        ASSIGN tab_ini.etbcod    = 0
               tab_ini.cxacod    = 0
               tab_ini.parametro = "ALCIS-ARQ-PRODU"
               tab_ini.valor     = "0"
               tab_ini.dtinclu   = today
               tab_ini.dtexp     = today
               tab_ini.exportar  = no.
    end.
    else do.
        def var v as int.
        v = int(tab_ini.valor).
        v = v + 1.
        tab_ini.valor = string(v).
    end.
end. 

def var vdiretorio-ant  as char.
vdiretorio-ant = "/admcom/tmp/alcis/INS/".
def var vdiretorio-apos as char.
vdiretorio-apos = "/usr/ITF/dat/in/".


def var p-valor as char. 
p-valor = "".  
run /admcom/progr/le_tabini.p (0, 0, 
                               "ALCIS-ARQ-PRODU", OUTPUT p-valor) .
par-arq = vdiretorio-ant + "PROD" + string(int(p-valor),"99999999") + ".DAT".   
vALCIS-ARQ-PRODU = vALCIS-ARQ-PRODU + 1.

/*****/



def var vPROPRIETaRIO as char init "995".
def var vpeso as char.
def var vvolume as char.
vpeso = string(0,"999999999999999999").
vvolume = string(0,"999999999999999999").
                                      
output to value(par-arq) append.                                      
put unformatted 
    "LEBES"                 format "x(10)"
    "PROD"                  format "x(4)"
    "PRODH"                 format "x(8)" 
    vPROPRIETaRIO           format "x(12)"
    string(produ.procod)    format "x(40)"
    produ.pronom            format "x(40)"
    produ.prouncom          format "x(6)"
    vPeso                   format "x(18)"
    vvolume                 format "x(18)"
    string(produ.procod)    format "x(30)"
    skip.

output close.
