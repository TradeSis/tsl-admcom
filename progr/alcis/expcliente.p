/*  alcis/expcliente.p                                                     */
/* exportacao de clientes (ESTAB) para o WMS Alcis                         */
def input parameter par-rec as recid.
def var par-arq as char.

find estab where recid(estab) = par-rec no-lock no-error.
if not avail estab
then leave.

def shared var vALCIS-ARQ-ESTAB   as int.
if vALCIS-ARQ-ESTAB = 0
then do on error undo.
    find first tab_ini where tab_ini.parametro = "ALCIS-ARQ-ESTAB" no-error.
    if not avail tab_ini
    then do.
        create tab_ini. 
        ASSIGN tab_ini.etbcod    = 0
               tab_ini.cxacod    = 0
               tab_ini.parametro = "ALCIS-ARQ-ESTAB"
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
                               "ALCIS-ARQ-ESTAB", OUTPUT p-valor) .
par-arq = vdiretorio-ant + "CLIE" + string(int(p-valor),"99999999") + ".DAT".     
    

vALCIS-ARQ-ESTAB = vALCIS-ARQ-ESTAB + 1.
def var vendereco as char.
def var vPROPRIETaRIO as char init "995".
def var vCliente as char.
def var vnome as char.
def var vbairro as char.
def var vcep as char.

vCliente = string(estab.etbcod).
vnome  = estab.etbnom.
vendereco = caps(  trim(estab.endereco)).
find tabaux where 
                     tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                     tabaux.nome_campo = "BAIRRO" no-lock no-error.
                if avail tabaux
                then vbairro = tabaux.valor_campo.
                else vbairro = "".
find tabaux where 
                     tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                     tabaux.nome_campo = "CEP" no-error.
                if avail tabaux
                then vcep = (tabaux.valor_campo).
                else vcep = "00000000".                                      
def var vetbcgc like estab.etbcgc.
vetbcgc = replace(estab.etbcgc,"/","").
vetbcgc = replace(vetbcgc,"-","").
vetbcgc = replace(vetbcgc,".","").
def var vetbinsc like estab.etbinsc.
vetbinsc = replace(estab.etbinsc,"/","").
vetbinsc = replace(vetbinsc,"-","").
vetbinsc = replace(vetbinsc,".","").
output to value(par-arq) append.
put unformatted 
    "LEBES"             format  "x(10)"
    "CLIE"              format "x(4)"
    "CLIEH"             format "x(8)"
    vPROPRIETarIO       format "x(12)"
    vCliente            format "x(12)"
    vNome               format "x(40)"
    vnome               format "x(30)"
    vEndereco           format "x(46)"
    vBairro             format "x(30)"
    estab.munic         format "x(30)"
    estab.ufecod        format "x(10)"
    vcep                format "x(10)"
    vetbcgc             format "x(30)"
    vetbinsc            format "x(30)"
    skip.                            
output close.
