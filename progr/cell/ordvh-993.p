/* Ordem de Venda          WMS Alcis                              */
def input parameter par-rec as recid.
def input parameter tip-ped as char.
def var par-arq as char.

def var vPROPRIETaRIO       as char init "900".
def shared var vALCIS-ARQ-ORDVH   as int.
vALCIS-ARQ-ORDVH = 0.
/**
find pedid where recid(pedid) = par-rec no-lock no-error.
if not avail pedid
then leave.
**/

find tdocbase where recid(tdocbase) = par-rec no-error.
if not avail tdocbase
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
vdiretorio-ant = "/admcom/tmp/alcis/MOVEIS/".
def var vdiretorio-bkp as char.
vdiretorio-bkp = "/admcom/tmp/alcis/MOVEIS/bkp/".
def var vdiretorio-apos as char.
vdiretorio-apos = "/usr/ITF_CELL/dat/in".

def var p-valor as char. 
p-valor = "".  
run /admcom/progr/le_tabini.p (0, 0, 
                               "ALCIS-ARQ-ORDVH", OUTPUT p-valor) .
par-arq = vdiretorio-ant + "ORDVH" + string(int(p-valor),"99999999") + ".DAT". vALCIS-ARQ-ORDVH = vALCIS-ARQ-ORDVH + 1.
def var vqtdtot as dec.
/****
for each liped where liped.etbcod = pedid.etbcod
                 and liped.pedtdc = pedid.pedtdc
                 and liped.pednum = pedid.pednum no-lock.
  vqtdtot  = vqtdtot + 1.
end.
****/
for each tdocbpro of tdocbase no-lock:
    vqtdtot  = vqtdtot + 1.
end.    
def var Transportadora as char init "999".
output to value(par-arq) append.

    put unformatted 
        "LEBES"                 format "x(10)"                  
        "ORDV"                  format "x(4)"                   
        "ORDVH"                 format "x(8)"                   
        "CD3"                   format "x(3)"                   
        vPROPRIETaRIO           format "x(12)"                  

        (string(tdocbase.etbdes,   "999") +
        string(tdocbase.dcbcod,"999999999"))     format "x(12)"                
        (string(tdocbase.etbdes,   "999") +
        string(tdocbase.dcbcod,"999999999"))     format "x(12)"                
        Transportadora          format "x(12)"
        string(tdocbase.dtdoc,"99999999")    format "xxxxxxxx"
        string(tdocbase.etbdes)    format "x(12)"
        ""                      format "x(10)"
        tip-ped                  format "x(4)"
        tdocbase.ordem          format ">>>"
        string(vqtdtot)         format "xxxx"
        string(tdocbase.box,"99") format "x(5)"
        skip.                     

for each tdocbpro of tdocbase :

    find produ of tdocbpro no-lock.
    def var vseq as int.
    vseq = vseq + 1.

    put unformatted 
        "LEBES"                 format "x(10)"                  
        "ORDV"                  format "x(4)"                   
        "ORDVI"                 format "x(8)"                   
        "CD3"                   format "x(3)"                   
        vPROPRIETaRIO           format "x(12)"                  
        (string(tdocbase.etbdes,   "999") +
        string(tdocbase.dcbcod,"999999999"))     format "x(12)"                
        (string(tdocbase.etbdes,   "999") +
        string(tdocbase.dcbcod,"999999999"))     format "x(12)"  
        string(vseq)    format "9999" 
        string(tdocbpro.procod)    format "x(40)"                  
        tdocbpro.movqtm * 1000000000           format "999999999999999999"     
        produ.prouncom          format "x(06)"                  
        ""                      format "x(20)"
        skip.                 
            
    tdocbpro.situacao = "L".            
                     
end.
tdocbase.situacao = "L".

output close.

unix silent value("cp " + par-arq +  " " + vdiretorio-bkp).
unix silent value("mv " + par-arq +  " " + vdiretorio-apos).
