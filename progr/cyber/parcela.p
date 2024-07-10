/*  cyber/parcela.p                                                          */
{admcab.i}
def input parameter par-reclotcre as recid.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.

def var vsequencia      as int.
def var vqtd_registros  as int.
def var vchave_contrato as char.
def var par-juros       as dec.
def var vstatus         as char.

vsequencia = lotcre.ltseqcyber.

{cyber/arquivo.i ""parcelas""}

output to value(varq).

/* HEADER */
put unformatted
    "H"               format "x"          /* TIPO              0001 - 0001 */ 
    "2"               format "x"          /* PRODUTO           0002 - 0031 */
    "CYBER"           format "x(8)"       /* EMPRESA           0032 - 0039 */ 
    "PARCELAS"        format "x(30)"      /* ARQUIVO           0040 - 0069 */
    vdata_geracao     format "xxxxxxxx"   /* DATA DE GERACAO   0070 - 0077 */ 
    vsequencia        format "9999999999" /* SEQUENCIA ARQUIVO 0078 - 0087 */
    fill(" ",102)     format "x(159)"     /* FILLER            0088 - 3208 */
    skip.
vqtd_registros = vqtd_registros + 1.

for each LotCreTit of lotcre no-lock.
    vchave_contrato             = "".   

    find FIRST titulo where 
                titulo.empcod = 19
            and titulo.titnat = no
            and titulo.modcod = lotCreTit.modcod
            and titulo.etbcod = LotCreTit.etbcod
            and titulo.clifor = LotCreTit.clfcod
            and titulo.titnum = LotCreTit.titnum
            and titulo.titpar = LotCreTit.titpar
            and titulo.titvlcob > 0.01 /*** 02.08.16 ***/
            no-lock no-error.
    if not avail titulo
    then next.

    find cyber_contrato where cyber_contrato.contnum = int(LotCreTit.titnum)
                        no-lock.
    find clien of cyber_contrato no-lock.
    run cyber/chave_contrato.p (input recid(cyber_contrato),
                                output vchave_contrato).
    run juro_titulo.p (0, input titulo.titdtven, titulo.titvlcob,
                       output par-juros).
    if titulo.titdtpag <> ?
    then vstatus = "PAG". /* Pago */
    else if titulo.titdtven >= today
    then vstatus = "LIB". /* A vencer */
    else vstatus = "ATR". /* Em atraso */
    
    put unformatted
        ""     /* tipo registro */       format "x(3)"    /* 1 Obrigatorio */
        "2"    /* grupo */               format "x(1)"    /* 4 Obrigatorio */
        vchave_contrato                  format "x(25)"   /* 5 obrigatorio */
        clien.ciccgc    /* cpf/cnpj */   format "x(25)"   /* 30 Obrigatorio */
        LotCreTit.titpar                 format "999"     /* 55 */
        titulo.titvlcob                  format "999999999999999" /* 58 */
        vstatus                          format "x(20)"   /* 73 */
        formatadata(titulo.titdtven)     format "xxxxxxxx" /* 93 */
        formatadata(titulo.titdtpag)     format "xxxxxxxx" /* 101 */
        formatadata(titulo.titdtemi)     format "xxxxxxxx" /* 109 */
        LotCreTit.etbcod                 format "9999"     /* 117 */
        formatadata(today)               format "xxxxxxxx" /* 121 */
        titulo.titvlpag                  format "999999999999999" /* 129 */
        par-juros                        format "999999999999999" /* 144 */
        0                                format "999999999999999" /* 159 */
        if titulo.etbcobra <> ?
        then titulo.etbcobra else 0      format "9999"  /* 174 */
        lotCreTit.modcod                 format "x(40)" /* 178 */
        skip.
    vqtd_registros = vqtd_registros + 1.
end.

/* TRAILER */
vqtd_registros = vqtd_registros + 1.
put unformatted
    "T"              format "x"          /* TIPO              0001 - 0001 */ 
    vdata_geracao    format "99999999"   /* DATA DE GERACAO   0002 - 0009 */ 
    vqtd_registros   format "9999999999" /* QUANTIDADE DE REGISTROS ARQUIVO
                                                              0010 - 0019 */
    vsequencia       format "9999999999" /* SEQUENCIA ARQUIVO 0020 - 0029 */
    fill(" ",159)    format "x(159)"     /* FILLER            0030 - 3208 */
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
        lotcre.arqenvio  = varq.
end.
find lotcre where recid(lotcre) = par-reclotcre no-lock.

