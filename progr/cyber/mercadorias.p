/*  cyber/mercadorias.p                                                       */
{admcab.i}

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


def input parameter par-reclotcre as recid.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.

def var vsequencia                  as int.
def var vqtd_registros              as int.
def var vchave_contrato             as char.
def var par-juros      as dec.
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

vsequencia = lotcre.ltseqcyber.

{cyber/arquivo.i ""mercadorias""}

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

for each cyber_movim of lotcre no-lock.
    vchave_contrato             = "".
    find movim of cyber_movim no-lock.
    find first plani where plani.etbcod = movim.etbcod and
                           plani.placod = movim.placod 
                           no-lock.
    find cyber_contrato of cyber_movim no-lock.
    
    run cyber/chave_contrato.p (input  recid(cyber_contrato),
                                output vchave_contrato).

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
{cyber/arquivozip.i}

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

