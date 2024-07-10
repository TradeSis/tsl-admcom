/*  alcis/orech.p                                                       */
/* Ordem de recebimento          WMS Alcis                              */
def input parameter par-rec as recid.
def input parameter tp-recebe as char.

def var par-arq as char.
find first plani where recid(plani) = par-rec no-lock no-error.
if not avail plani
then leave.
/*****/
def shared var vALCIS-ARQ-ORECH   as int.
vALCIS-ARQ-ORECH = 0.

if vALCIS-ARQ-ORECH = 0
then do on error undo.
    find first tab_ini where tab_ini.parametro = "ALCIS-ARQ-ORECH" 
      no-error.
     
     
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
    else do on error undo.
        def var v as int.
        v = int(tab_ini.valor).
        v = v + 1.
        tab_ini.valor = string(v).
    end.
    find current tab_ini no-lock.
end. 

def var vdiretorio-ant  as char.
def var vdiretorio-apos as char.
def var vdiretorio-bkp as char.
def var p-valor as char. 

vdiretorio-ant = "/admcom/tmp/alcis/MOVEIS/".
vdiretorio-bkp = "/admcom/tmp/alcis/MOVEIS/bkp".
vdiretorio-apos = "/usr/ITF_CELL/dat/in".

p-valor = "".  
run /admcom/progr/le_tabini.p (0, 0, 
                               "ALCIS-ARQ-ORECH", OUTPUT p-valor) .
par-arq = vdiretorio-ant + "OREC" + string(int(p-valor),"99999999") + ".DAT".   
vALCIS-ARQ-ORECH = vALCIS-ARQ-ORECH + 1.

/*****/

def var vPROPRIETaRIO       as char init "900".
def var vpeso               as char.
def var v-qtd-movims        as int.                                      
def var vvolume             as char.
def var v-notafiscal        as char.
def var v-pladat            as date. 
def var v-forne             as char.
def var v-transportadora    as char.
def var v-placa             as char.
def var v-quantidade        as dec.
def var v-unidadedecompra   as char.
def var v-lote              as char.

find first com.frete where frete.forcod = plani.cxacod no-lock no-error.

def var v-serie as char.

if length(plani.serie) = 1
then v-serie = "00" + string(plani.serie).
else if length(plani.serie) = 2
then v-serie = "0" + string(plani.serie).
else if length(plani.serie) = 3
then v-serie = string(plani.serie).

assign 
    vpeso               = string(0,"999999999999999999")
    vvolume             = string(0,"999999999999999999")
    v-qtd-movims        = 0
    v-notafiscal        = string(plani.numero) + v-serie
    v-pladat            = plani.pladat
    v-forne             = string(plani.emite)
    v-transportadora    = if avail frete
                          then string(frete.frecod)
                          else ""
    v-placa             = "AAA9999"
    .
    if tp-recebe = "PE"
    then v-lote              = v-notafiscal.
    else v-lote = "".
    

for each movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod no-lock.
    v-qtd-movims = v-qtd-movims + 1.
end.

output to value(par-arq) append.
put unformatted 
    "LEBES"                 format "x(10)" 
    "OREC"                  format "x(4)" 
    "ORECH"                 format "x(8)" 
    "CD3"                   format "x(3)" 
    vPROPRIETaRIO           format "x(12)" 
    v-notafiscal            format "x(12)" 
    v-pladat                format "99999999" 
    v-forne                 format "x(12)" 
    v-transportadora        format "x(12)" 
    ""                      format "x(12)"
    tp-recebe               format "x(2)"
    v-placa                 format "x(15)" 
    v-qtd-movims            format "999"
    .

if tp-recebe = "PE"
then put plani.notobs[2] format "x(12)".

put skip.

for each movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod no-lock.
    find produ of movim no-lock.
    v-unidadedecompra = produ.prouncom.
    v-quantidade      = movim.movqtm * 1000000000.
    put unformatted 
        "LEBES"                 format "x(10)" 
        "OREC"                  format "x(4)" 
        "ORECI"                 format "x(8)" 
        "CD3"                   format "x(3)" 
        vPROPRIETaRIO           format "x(12)" 
        v-notafiscal            format "x(12)" 
        string(movim.procod)    format "x(40)"
        v-quantidade            format "999999999999999999"
        caps(v-unidadedecompra) format "x(06)" 
        v-lote                  format "x(20)" 
        v-forne                 format "x(12)" 
        skip.
end.
output close.

unix silent value("cp " + par-arq + " " + vdiretorio-bkp).

unix silent value("mv " + par-arq + " " + vdiretorio-apos).

{mens-interface-wms-alcis.i}    
