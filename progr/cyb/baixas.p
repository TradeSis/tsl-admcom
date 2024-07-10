/*  cyber/pagamentos.p                                                 */

def var vtipo as char.
vtipo = "BAIXA".
def var varquivo as char.


{cyb/cybcab.i}

def shared var v-today as date.
def shared var v-time as int.

def  shared temp-table c_contrato no-undo
    field contnum like cyber_controle.contnum
    index c is unique primary contnum asc.
def  shared temp-table t_contrato no-undo
    field contnum like cyber_controle.contnum
    field tipo as char
    index c is unique primary contnum asc tipo asc
    index t tipo asc.
def  shared temp-table t_interface no-undo
    field tipo as char
    field qtd  as int
    index t is unique primary tipo asc.
 
def var vsequencia                  as int.
def var vqtd_registros              as int.
def var vchave_contrato             as char.
def var vtitdtpag                   as char.

{cyb/sequencias.i vtipo vsequencia}

{cyb/arquivo.i ""baixa""}

output to value(varq).

/* HEADER */
put unformatted
    "H"               format "x"          /* TIPO              0001 - 0001 */ 
    "2"               format "x"          /* PRODUTO           0002 - 0031 */
    "CYBER"           format "x(8)"       /* EMPRESA           0032 - 0039 */ 
    "BAIXA"           format "x(30)"      /* ARQUIVO           0040 - 0069 */
    vdata_geracao     format "xxxxxxxx"   /* DATA DE GERACAO   0070 - 0077 */ 
    vsequencia        format "9999999999" /* SEQUENCIA ARQUIVO 0078 - 0087 */
    fill(" ",13  )    format "x(13)"      /* FILLER            0088 - 3208 */
    skip.
vqtd_registros = vqtd_registros + 1.


for each t_contrato where t_contrato.tipo = vtipo.

    find cyber_controle of t_contrato no-lock.
    find contrato of cyber_controle no-lock no-error.
 
    vtitdtpag = formatadata(cyber_controle.ultdtpag).
        
vchave_contrato = string(cyber_controle.loja ,"999") +
                  string(cyber_controle.contnum,"99999999999"). 
                            
 /**
    4run cyber/chave_contrato.p (input  recid(cyber_contrato),
                                output vchave_contrato).
    **/
    
    put unformatted
        "302"  /* tipo registro */           format "x(3)"    /* Obrigatorio */
        "2"    /* grupo */                   format "x(1)"    /* Obrigatorio */
        vchave_contrato                      format "x(25)"   /* obrigatorio */
        vtitdtpag                            format "x(8)"    /* obrigatorio */
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
    fill(" ",71)      format "x(71)"      /* FILLER            0030 - 3208 */
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

