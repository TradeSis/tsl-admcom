{admcab.i}
def temp-table tt
    field procod like produ.procod.
    
repeat on error undo with frame f1 title " gerar interface produtos ":
    create tt.
    update tt.procod
    help "Informe o codigo do produto ou F4 para gerar interface."
    .
    find produ where produ.procod = tt.procod no-lock no-error.
    if not avail produ then undo.
    disp produ.pronom.
end.

find first tt where tt.procod > 0 no-error.
if not avail tt
then return.

sresp = no.
message "Confirma gerar interface?" update sresp.
if not sresp then return.

def var vdiretorio-ant  as char.
vdiretorio-ant = "/admcom/tmp/alcis/MOVEIS/".
def var vdiretorio-bkp as char.
vdiretorio-bkp = "/admcom/tmp/alcis/MOVEIS/bkp/".
def var vdiretorio-apos as char.
vdiretorio-apos = "/usr/ITF_CELL/dat/in".
def var par-arq as char.

def var p-valor as char. 
p-valor = "".  
run /admcom/progr/le_tabini.p (0, 0, 
                               "ALCIS-ARQ-PRODU", OUTPUT p-valor) .
par-arq = vdiretorio-ant + "PROD" + string(int(p-valor),"99999999") + ".DAT".   
def var vALCIS-ARQ-PRODU as int.
vALCIS-ARQ-PRODU = vALCIS-ARQ-PRODU + 1.

def var vPROPRIETaRIO as char init "900".
def var vpeso as char.
def var vvolume as char.
vpeso = string(0,"999999999999999999").
vvolume = string(0,"999999999999999999").
  
for each tt where tt.procod > 0:
    find produ where produ.procod = tt.procod no-lock no-error.
    if not avail produ then next.
                                      
    output to value(par-arq) append.                                      
    put unformatted 
        "LEBES"                 format "x(10)"
        "PROD"                  format "x(4)"
        "PRODH"                 format "x(8)" 
        vPROPRIETaRIO           format "x(12)"
        string(produ.procod)    format "x(40)"
        produ.pronom            format "x(40)"
        caps(produ.prouncom)          format "x(6)"
        vPeso                   format "x(18)"
        vvolume                 format "x(18)"
        string(produ.procod)    format "x(30)"
        skip.

    output close.

end.

unix silent value("cp " + par-arq +  " " + vdiretorio-bkp).
unix silent value("mv " + par-arq +  " " + vdiretorio-apos).


{mens-interface-wms-alcis.i}
    

