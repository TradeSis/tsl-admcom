/*  cyber/pagamentos.p                                                 */

{admcab.i}

def input parameter par-reclotcre as recid.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.

def var vsequencia                  as int.
def var vqtd_registros              as int.
def var vchave_contrato             as char.
def var vtitdtpag                   as char.
def var vtitvlpag                   as dec.
def var vcod_transacao as char.

vsequencia = lotcre.ltseqcyber.

{cyber/arquivo.i ""pagamentos""}

output to value(varq).
/* HEADER */
put unformatted
    "H"               format "x"          /* TIPO              0001 - 0001 */ 
    "2"               format "x"          /* PRODUTO           0002 - 0031 */
    "CYBER"           format "x(8)"       /* EMPRESA           0032 - 0039 */ 
    "PGTO"            format "x(30)"      /* ARQUIVO           0040 - 0069 */
    vdata_geracao     format "xxxxxxxx"   /* DATA DE GERACAO   0070 - 0077 */ 
    vsequencia        format "9999999999" /* SEQUENCIA ARQUIVO 0078 - 0087 */
    fill(" ",18  )    format "x(46)"    /* FILLER            0088 - 3208 */
    skip.
vqtd_registros = vqtd_registros + 1.

for each cyber_contrato_h of lotcre no-lock.
    find cyber_contrato of cyber_contrato_h no-lock.
    vtitdtpag = formatadata(cyber_contrato_h.titdtpag).
    vtitvlpag = cyber_contrato_h.titvlpag.
    run cyber/chave_contrato.p (input  recid(cyber_contrato),
                                output vchave_contrato).
    put unformatted
        "500"  /* tipo registro */           format "x(3)"    /* Obrigatorio */
        "2"    /* grupo */                   format "x(1)"    /* Obrigatorio */
        vchave_contrato                      format "x(25)"   /* obrigatorio */
    
        vtitdtpag                            format "x(8)"    /* obrigatorio */
        vtitdtpag                            format "x(8)"    /* obrigatorio */
        vtitvlpag  * 100              format "999999999999999"
        vtitvlpag  * 100              format "999999999999999"
        ""                                   format "x(15)"
        vcod_transacao                       format "x(6)"
        
        ""                                   format "x(8)"
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
    fill(" ",75)    format "x(75)"    /* FILLER            0030 - 3208 */
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

