/* Distribuicao          WMS Alcis                              */
def input parameter par-procod like produ.procod.

def var par-arq as char.
def var vPROPRIETaRIO      as char init "995".
def var v as int.
def var vdiretorio-ant  as char.
def var vdiretorio-apos as char.
def var p-valor as char. 

do on error undo.
    find first tab_ini where tab_ini.parametro = "ALCIS-ARQ-DSTRH" no-error.
    v = int(tab_ini.valor) + 1.
    tab_ini.valor = string(v).
    p-valor = string(v).
end. 

vdiretorio-ant = "/admcom/tmp/alcis/INS/".
vdiretorio-apos = "/usr/ITF/dat/in/".
par-arq = vdiretorio-ant + "DSTRH" + string(int(p-valor),"99999999") + ".DAT".

output to value(par-arq).

for each dispro where dispro.dtenvwms = ?       and
                      dispro.situacao = "WMS"   and
                      dispro.procod   = par-procod.
    find produ of dispro no-lock.

    put unformatted 
        "LEBES"                 format "x(10)"                  
        "DSTR"                  format "x(4)"                   
        "DSTRH"                 format "x(8)"                   
        "CD2"                   format "x(3)"                   
        vPROPRIETaRIO           format "x(12)"                  
        string(dispro.etbcod)   format "x(12)"                  
        string(dispro.procod)   format "x(40)"                  
        dispro.disqtd * 1000000000     format "999999999999999999"     
        produ.prouncom          format "x(6)"
        fill("0",20)            format "x(32)" /* ID */
        skip.                     

    dispro.dtenvwms = today.
end.

output close.

unix silent value("cp " + par-arq +  " " + vdiretorio-apos).
unix silent value("rm -rf " + par-arq +  " " ).
