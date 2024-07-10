/* Ordem de Venda          WMS Alcis                              */
def input parameter par-rec as recid.
def var par-arq as char.

def var vPROPRIETaRIO       as char init "995".
def shared var vALCIS-ARQ-ORDVH   as int.
vALCIS-ARQ-ORDVH = 0.

find pedid where recid(pedid) = par-rec no-lock no-error.
if not avail pedid
then leave.

if vALCIS-ARQ-ORDVH = 0
then do on error undo.
    find first tab_ini where tab_ini.parametro = "ALCIS-ARQ-ORDVH" no-error.
    if not avail tab_ini
    then do.
        create tab_ini. 
        ASSIGN tab_ini.etbcod    = 0
               tab_ini.cxacod    = 0
               tab_ini.parametro = "ALCIS-ARQ-ORDVH"
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
                               "ALCIS-ARQ-ORDVH", OUTPUT p-valor) .
par-arq = vdiretorio-ant + "ORDVH" + string(int(p-valor),"99999999") + ".DAT". vALCIS-ARQ-ORDVH = vALCIS-ARQ-ORDVH + 1.
def var vqtdtot as dec.
for each liped where liped.etbcod = pedid.etbcod
                 and liped.pedtdc = pedid.pedtdc
                 and liped.pednum = pedid.pednum no-lock.
  vqtdtot  = vqtdtot + 1.
end.
def var Transportadora as char init "999".
output to value(par-arq) append.

    put unformatted 
        "LEBES"                 format "x(10)"                  
        "ORDV"                  format "x(4)"                   
        "ORDVH"                 format "x(8)"                   
        "CD2"                   format "x(3)"                   
        vPROPRIETaRIO           format "x(12)"                  

        (string(pedid.etbcod,   "999") +
        string(pedid.pednum,"999999"))     format "x(12)"                  

        (string(pedid.etbcod,   "999") +
        string(pedid.pednum,"999999"))     format "x(12)"                  

        Transportadora          format "x(12)"
        string(pedid.peddat,"99999999")    format "xxxxxxxx"
        string(pedid.etbcod)    format "x(12)"
        ""                      format "x(10)"
        "NORM"                  format "x(4)"
        1                       format ">>>"
        string(vqtdtot)         format "xxxx"
        skip.                     


for each liped where liped.etbcod = pedid.etbcod
                 and liped.pedtdc = pedid.pedtdc
                 and liped.pednum = pedid.pednum no-lock.

    find produ of liped no-lock.
    def var vseq as int.
    vseq = vseq + 1.
    put unformatted 
        "LEBES"                   format "x(10)"                  
        "ORDV"                  format "x(4)"                   
        "ORDVI"                 format "x(8)"                   
        "CD2"                   format "x(3)"                   
        vPROPRIETaRIO           format "x(12)"                  

        (string(pedid.etbcod,   "999") +
        string(pedid.pednum,"999999"))    format "x(12)"                  

        (string(pedid.etbcod,   "999") +
        string(pedid.pednum,"999999"))    format "x(12)"                 
        
        string(vseq)    format "9999" 
        string(liped.procod)    format "x(40)"                  
        liped.lipqtd * 1000000000           format "999999999999999999"     
        produ.prouncom          format "x(06)"                  
        ""                      format "x(20)"
        skip.                     
                     
end.

output close.

unix silent value("mv " + par-arq +  " " + vdiretorio-apos).
