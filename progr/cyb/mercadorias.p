/*  cyber/mercadorias.p                                                       */

function formatatexto returns char
    (input par-texto as char).

    def var vtexto as char.
    def var vi     as int.
    def var vletra as char.

    if par-texto = ?
    then return "".
    par-texto = trim(par-texto).

    do vi = 1 to length(par-texto).
        vletra = substring(par-texto, vi, 1).

        find tab_asc where tab_asc.dec = asc(vletra) no-lock no-error.
        if avail tab_asc and
           tab_asc.usa <> ""
        then do:
            vletra = tab_asc.usa.
            vtexto = vtexto + vletra.
        end.
        if length(vletra) = 1 and
           asc(vletra) > 31   and
           asc(vletra) < 123
        then vtexto = vtexto + vletra.
    end.
        
    return vtexto.

end function.



def var vtipo as char.
vtipo = "MERCA".
def var varquivo as char.

{cyb/cybcab.i}

def shared var v-today as date.
def shared var v-time as int.


def  shared temp-table t_contrato no-undo
    field contnum like cyber_controle.contnum
    field tipo as char
    index c is unique primary contnum asc tipo asc
    index t tipo asc.


def var vsequencia                  as int.
def var vqtd_registros              as int.
def var vchave_contrato             as char.
def var vstatus         as char.
def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer setclase for clase.
def buffer depto    for clase.
def var vpronom        as char                         format "x(80)" .
def var vDepartamento  as char                         format "x(50)" .
def var vSetor         as char                         format "x(50)" .
def var vGrupo         as char                         format "x(50)" .
def var vClasse        as char                         format "x(50)" .

{cyb/sequencias.i vtipo vsequencia}

{cyb/arquivo.i ""mercadorias""}

output to value(varq).

/* HEADER */
put unformatted
    "H"               format "x"          /* TIPO              0001 - 0001 */ 
    "2"               format "x"          /* PRODUTO           0002 - 0031 */
    "CYBER"           format "x(8)"       /* EMPRESA           0032 - 0039 */ 
    "MERCADORIAS"     format "x(30)"      /* ARQUIVO           0040 - 0069 */
    vdata_geracao     format "xxxxxxxx"   /* DATA DE GERACAO   0070 - 0077 */ 
    vsequencia        format "9999999999" /* SEQUENCIA ARQUIVO 0078 - 0087 */
    fill(" ",254)     format "x(282)"     /* FILLER            0088 - 3208 */
    skip.

vqtd_registros = vqtd_registros + 1.


for each t_contrato where t_contrato.tipo = vtipo.

    find cyber_controle of t_contrato no-lock.
    find contrato of cyber_controle no-lock no-error.   
    
    
    vchave_contrato = string(cyber_controle.loja ,"999") +                       string(cyber_controle.contnum,"99999999999"). 
 
    find contnf where contnf.etbcod  = cyber_controle.loja and
                      contnf.contnum = cyber_controle.contnum 
        no-lock no-error.
    if avail contnf 
    then do.  
        find plani where plani.etbcod = contnf.etbcod and
                                 plani.placod = contnf.placod no-lock no-error.
        if avail plani
        then  for each movim where movim.etbcod = plani.etbcod 
                                      and movim.placod = plani.placod
                                      and movim.movtdc = plani.movtdc
                                    no-lock.


            assign vpronom          = ""  
                   vDepartamento    = ""   
                   vSetor           = ""   
                   vGrupo           = ""   
                   vClasse          = "".
            find produ of movim no-lock no-error.
            if avail produ
            then do.
                vpronom = formatatexto(produ.pronom).
            find sClase where sClase.clacod = produ.clacod no-lock no-error.
                if avail sClase
                then do.
                find Clase where Clase.clacod = sClase.clasup no-lock no-error.
                    if avail clase
                    then do.
                        vClasse = formatatexto(Clase.clanom).
                        find grupo where grupo.clacod = Clase.clasup 
                                                            no-lock no-error.
                        if avail grupo
                        then do.
                            vGrupo = formatatexto(grupo.clanom).
                            find setClase where setClase.clacod = grupo.clasup 
                                                            no-lock no-error.
                            if avail setclase
                            then do.
                                vSetor = formatatexto(setClase.clanom).
                            find depto where depto.clacod = setclase.clasup  
                                                            no-lock no-error.
                                if avail depto
                            then vDepartamento = formatatexto(depto.clanom).
                            end.
                        end.
                    end.
                end.
            end.
            put unformatted
            ""     /* tipo registro */    format "x(3)"    /* Obrigatorio */
            "2"    /* grupo */            format "x(1)"    /* Obrigatorio */
            vchave_contrato               format "x(25)"   /* obrigatorio */
            string(movim.procod)          format "x(20)"                
            vpronom                       format "x(80)" 
            vDepartamento                 format "x(50)" 
            vSetor                        format "x(50)" 
            vGrupo                        format "x(50)"
            vClasse                       format "x(50)"
            int(movim.movqtm)             format "999"
            formatadata(plani.pladat)     format "xxxxxxxx"
            skip.
        
            vqtd_registros = vqtd_registros + 1.
        
        end.
    end.    
end.

/* TRAILER */
vqtd_registros = vqtd_registros + 1.
put unformatted
    "T"               format "x"          /* TIPO              0001 - 0001 */ 
    vdata_geracao     format "xxxxxxxx"   /* DATA DE GERACAO   0002 - 0009 */ 
    vqtd_registros    format "9999999999" /* QUANTIDADE DE REGISTROS ARQUIVO
                                                               0010 - 0019 */
    vsequencia        format "9999999999" /* SEQUENCIA ARQUIVO 0020 - 0029 */
    fill(" ",311)     format "x(311)"    /* FILLER            0030 - 3208 */
    skip.

output close.
{cyb/arquivozip.i}

/**
do on error undo.
    find current lotcretp exclusive.
    lotcretp.ultimo = lotcretp.ultimo + 1.
    
    find lotcre where recid(lotcre) = par-reclotcre exclusive.
    assign
        lotcre.ltdtenvio = vtoday
        lotcre.lthrenvio = vtime
        lotcre.ltfnenvio = sfuncod
        lotcre.arqenvio  = varq.
end.
find lotcre where recid(lotcre) = par-reclotcre no-lock.
**/

