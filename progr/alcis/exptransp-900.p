/*  alcis/exptransp.p                                                        */
/* exportacao de transportadoras para o WMS Alcis                             */
def input parameter par-rec as recid.
def var par-arq as char.

find frete where recid(frete) = par-rec no-lock no-error.
if not avail frete
then leave.

find forne of frete no-lock no-error.

def var vendereco as char.
if avail forne
then 
    vendereco = caps(  trim(forne.forrua  + " " +
                     string(forne.fornum) + " " +
                            forne.forcomp )).
/*****/
def shared var vALCIS-ARQ-TRANSP   as int.
if vALCIS-ARQ-TRANSP = 0
then do on error undo.
    find first tab_ini where tab_ini.parametro = "ALCIS-ARQ-TRANSP" no-error.
    if not avail tab_ini
    then do.
        create tab_ini. 
        ASSIGN tab_ini.etbcod    = 0
               tab_ini.cxacod    = 0
               tab_ini.parametro = "ALCIS-ARQ-TRANSP"
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
                               "ALCIS-ARQ-TRANSP", OUTPUT p-valor) .
par-arq = vdiretorio-ant + "TRSP" + string(int(p-valor),"99999999") + ".DAT".   
vALCIS-ARQ-TRANSP = vALCIS-ARQ-TRANSP + 1.

/*****/



output to value(par-arq) append.
put unformatted 
    "LEBES"                 format "x(10)"  /*Remetente   FIXO(10)*/
    "TRSP"                  format "x(4)"   /*Nome do Arquivo FIXO(4)*/
    "TRSPH"                 format "x(8)"   /*Nome da Interface   FIXO(8)*/
    string(frete.frecod)    format "x(12)"
    frete.frenom            format "x(40)"
    frete.frenom            format "x(30)"
    vendereco               format "x(46)"  /*Endereço    VARCHAR(46)*/
    if not avail forne
    then ""
    else forne.forbairro    format "x(30)"  /*Bairro  VARCHAR(30)*/
    if not avail forne
    then ""
    else forne.formunic     format "x(30)"  /*Município   VARCHAR(30)*/
    if not avail forne
    then ""
    else forne.ufecod       format "x(10)"  /*UF  VARCHAR(10)*/
    if not avail forne
    then ""
    else forne.forcep       format "x(10)"  /*CEP VARCHAR(10)*/
    if not avail forne
    then ""
    else forne.forcgc       format "x(30)"  /*CNPJ    VARCHAR(30)*/
    if not avail forne
    then ""
    else forne.forinest     format "x(30)"  /*Inscrição Estadual  VARCHAR(30)*/
    skip.    
output close.


