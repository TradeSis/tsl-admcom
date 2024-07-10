/*  alcis/expforne.p                                                        */
/* exportacao de fornecedores para o WMS Alcis                              */
def input parameter par-rec as recid.
def var par-arq as char.

find forne where recid(forne) = par-rec no-lock no-error.
if not avail forne
then leave.

/*****/
def shared var vALCIS-ARQ-FORNE   as int.
if vALCIS-ARQ-FORNE = 0
then do on error undo.
    find first tab_ini where tab_ini.parametro = "ALCIS-ARQ-FORNE" no-error.
    if not avail tab_ini
    then do.
        create tab_ini. 
        ASSIGN tab_ini.etbcod    = 0
               tab_ini.cxacod    = 0
               tab_ini.parametro = "ALCIS-ARQ-FORNE"
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
                               "ALCIS-ARQ-FORNE", OUTPUT p-valor) .
par-arq = vdiretorio-ant + "FORN" + string(int(p-valor),"99999999") + ".DAT".     
    

vALCIS-ARQ-FORNE = vALCIS-ARQ-FORNE + 1.




/*****/

def var vendereco as char.
vendereco = caps(  trim(forne.forrua  + " " +
                 string(forne.fornum) + " " +
                        forne.forcomp )).
def var vPROPRIETaRIO as char init "900".

output to value(par-arq) append.                                      
put unformatted 
    "LEBES"                 format "x(10)"  /*Remetente   FIXO(10)*/
    "FORN"                  format "x(4)"   /*Nome do Arquivo FIXO(4)*/
    "FORNH"                 format "x(8)"   /*Nome da Interface   FIXO(8)*/
    vPROPRIETaRIO           format "x(12)"  /*Código PROPRIETÁRIO VARCHAR(12)*/
    string(forcod)          format "x(12)"  /*Código Fornecedor   VARCHAR(12)*/
    forne.forfant           format "x(40)"  /*Nome    VARCHAR(40)*/
    forne.fornom            format "x(30)"  /*Razão   VARCHAR(30)*/
    vendereco               format "x(46)"  /*Endereço    VARCHAR(46)*/
    forne.forbairro         format "x(30)"  /*Bairro  VARCHAR(30)*/
    forne.formunic          format "x(30)"  /*Município   VARCHAR(30)*/
    forne.ufecod            format "x(10)"  /*UF  VARCHAR(10)*/
    forne.forcep            format "x(10)"  /*CEP VARCHAR(10)*/
    forne.forcgc            format "x(30)"  /*CNPJ    VARCHAR(30)*/
    forne.forinest          format "x(30)"  /*Inscrição Estadual  VARCHAR(30)*/
    skip.                            
output close.
