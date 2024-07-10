/* Fechamento de Gaiola          WMS Alcis                              */
def input parameter par-rec as recid.
def var par-arq as char.

def var vqtditens as int format "999".
def var vgaiola     as char format "x(11)".
def var vPROPRIETaRIO       as char init "995".
def shared var vALCIS-ARQ-FCGL   as int.
vALCIS-ARQ-FCGL = 0.

find plani where recid(plani) = par-rec no-lock no-error.
if not avail plani
then leave.

if vALCIS-ARQ-FCGL = 0
then do on error undo.
    find first tab_ini where tab_ini.parametro = "ALCIS-ARQ-FCGL" no-error.
    if not avail tab_ini
    then do.
        create tab_ini. 
        ASSIGN tab_ini.etbcod    = 0
               tab_ini.cxacod    = 0
               tab_ini.parametro = "ALCIS-ARQ-FCGL"
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
                               "ALCIS-ARQ-FCGL", OUTPUT p-valor) .
par-arq = vdiretorio-ant + "FCGL" + string(int(p-valor),"99999999") + ".DAT". vALCIS-ARQ-FCGL = vALCIS-ARQ-FCGL + 1.

output to value(par-arq) append.

vqtditens = 0.
for each movim where movim.etbcod = plani.etbcod
                 and movim.placod = plani.placod no-lock.
    vqtditens = vqtditens + movim.movqtm.
end.                     

vgaiola = plani.NotPed.

put unformatted
        "WMS"                   format "x(10)"
        "FCGL"                  format "x(4)"
        "FCGLH"                 format "x(8)"
        "CD2"                   format "x(3)"
        vPROPRIETaRIO           format "x(12)"
        string(plani.etbcod)    format "x(12)"
        vgaiola                 format "x(11)"
        vqtditens               format "999"
        skip.
        
        
for each movim where movim.etbcod = plani.etbcod
                 and movim.placod = plani.placod no-lock.
                 
    find produ of movim no-lock.

    put unformatted 
        "WMS"                   format "x(10)"
        "FCGL"                  format "x(4)"
        "FCGLI"                 format "x(8)"
        "CD2"                   format "x(3)"
        vPROPRIETaRIO           format "x(12)"
        string(plani.etbcod)    format "x(12)"
        vgaiola                 format "x(11)"
        movim.movseq            format "999"
        string(movim.procod)    format "x(40)"
        movim.movqtm * 1000000000
                                format "999999999999999999"
        produ.prouncom          format "x(6)"
        skip.                     
                     
end.

output close.

unix silent value("mv " + par-arq +  " " + vdiretorio-apos).
