/*  alcis/orech.p                                                       */
/* Ordem de recebimento          WMS Alcis                              */
def input parameter par-rec as recid.

def var par-arq as char.

find plani where recid(plani) = par-rec no-lock no-error.
if not avail plani
then leave.

/*****/
def shared var vALCIS-ARQ-ORECH   as int.
vALCIS-ARQ-ORECH = 0.

if vALCIS-ARQ-ORECH = 0
then do on error undo.
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
        def var v as int.
        v = int(tab_ini.valor).
        v = v + 1.
        tab_ini.valor = string(v).
    end.
end. 

def var vdiretorio-ant  as char.
def var vdiretorio-apos as char.
def var p-valor as char. 

vdiretorio-ant = "/admcom/tmp/alcis/INS/".
vdiretorio-apos = "/usr/ITF/dat/in/".

p-valor = "".  
run /admcom/progr/le_tabini.p (0, 0, 
                               "ALCIS-ARQ-ORECH", OUTPUT p-valor) .
par-arq = vdiretorio-ant + "OREC" + string(int(p-valor),"99999999") + ".DAT".   
vALCIS-ARQ-ORECH = vALCIS-ARQ-ORECH + 1.

/*****/

def var vPROPRIETaRIO       as char init "995".
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

find first frete where frete.forcod = plani.cxacod no-lock no-error.

assign 
    vpeso               = string(0,"999999999999999999")
    vvolume             = string(0,"999999999999999999")
    v-qtd-movims        = 0
    v-notafiscal        = string(plani.numero)
    v-pladat            = plani.pladat
    v-forne             = string(plani.emite)
    v-transportadora    = if avail frete
                          then string(frete.frecod)
                          else ""
    v-placa             = "".

for each movimpack where movimpack.etbcod = plani.etbcod and
                     movimpack.placod = plani.placod no-lock.
    v-qtd-movims = v-qtd-movims + 1.
end.

output to value(par-arq) append.
put unformatted 
    "LEBES"                 format "x(10)" 
    "OREC"                  format "x(4)" 
    "ORECH"                 format "x(8)" 
    "CD2"                   format "x(3)" 
    vPROPRIETaRIO           format "x(12)" 
    v-notafiscal            format "x(12)" 
    v-pladat                format "99999999" 
    v-forne                 format "x(12)" 
    v-transportadora        format "x(12)" 
    v-placa                 format "x(12)" 
    "LI"                    format "x(2)"
    v-placa                 format "x(15)"
    v-qtd-movims            format "999"
    skip.
for each movimpack where movimpack.etbcod = plani.etbcod and
                     movimpack.placod = plani.placod no-lock.
    find pack of movimpack no-lock.
    find first packprod of pack.
    find produ of packprod no-lock.
    v-unidadedecompra = produ.prouncom.
    v-quantidade      = movimpack.movqtm * 1000000000.
    put unformatted 
        "LEBES"                 format "x(10)" 
        "OREC"                  format "x(4)" 
        "ORECI"                 format "x(8)" 
        "CD2"                   format "x(3)" 
        vPROPRIETaRIO           format "x(12)" 
        v-notafiscal            format "x(12)" 
        string(movimpack.paccod) format "x(40)"
        v-quantidade            format "999999999999999999"
        v-unidadedecompra       format "x(06)" 
        v-lote                  format "x(20)" 
        v-forne                 format "x(12)" 
        skip.
end.
output close.

unix silent value("mv " + par-arq + " " + vdiretorio-apos).

