/*  cyber/man_finan.p
#1 TP 32028114 18.07.19
*/

def var vtipo as char.
def var varquivo as char.

vtipo = "FINAN".

{cyb/cybcab.i}

def shared var v-today as date.
def shared var v-time as int.

def  shared temp-table t_contrato no-undo
    field contnum like cyber_controle.contnum
    field tipo as char
    index c is unique primary contnum asc tipo asc
    index t tipo asc.

def var vsequencia          as int.
def var vqtd_registros      as int.
def var vchave_contrato     as char.
def var vlimite_credito     as int.
def var vmedia_atraso       as int.
def var vcxacod             like plani.cxacod.
def var vvencod             like plani.vencod.

def new shared var vvalor_atraso               as dec.
def new shared var vvalor_a_vencer             as dec.
def new shared var vvalor_total_divida         as dec.
def new shared var vdata_vencimento_contrato   as char.
def new shared var vdata_ultimo_pagamento      as char.
def new shared var vdata_ultimo_vencimento     as char.
def new shared var vvalor_ultimo_pagamento     as dec.
def new shared var vvalor_vencido              as dec.
def new shared var vRisco                      as char. 
def new shared var vvalor_multa                as dec.
def new shared var vqtd_parcelas               as int.
def new shared var vqtd_parcelas_a_vencer      as int.
def new shared var vqtd_parcelas_vencidas      as int.
def new shared var vqtd_parcelas_pagas         as int.
def new shared var vverificar_se_teve_parcelamento as char.     
def new shared var vvalor_juros                as dec.
def new shared var vcobranca                   as int.
def new shared var tipo_contrato               as char.
def new shared var vcontrato_gerado_na_novacao as char.
def new shared var vvalor_entrada              as dec.
def var vSubset                     as int.
def var vciccgc                     as char.

{cyb/sequencias.i vtipo vsequencia}
{cyb/arquivo.i ""man_fin""}

output to value(varq).
/* HEADER */
put unformatted
    "H"               format "x"          /* TIPO              0001 - 0001 */ 
    "2"               format "x"          /* PRODUTO           0002 - 0031 */
    "CYBER"           format "x(8)"       /* EMPRESA           0032 - 0039 */ 
    "MANFIN"          format "x(30)"      /* ARQUIVO           0040 - 0069 */
    vdata_geracao     format "xxxxxxxx"   /* DATA DE GERACAO   0070 - 0077 */ 
    vsequencia        format "9999999999" /* SEQUENCIA ARQUIVO 0078 - 0087 */
    fill(" ",265)     format "x(293)"    /* FILLER            0088 - 3208 */
    skip.
vqtd_registros = 1.


for each t_contrato where t_contrato.tipo = vtipo.

    find cyber_controle of t_contrato no-lock.
    find contrato of cyber_controle no-lock no-error.
 
    assign   
        vchave_contrato             = ""
        vmedia_atraso               = 0
        vvalor_atraso               = 0
        vvalor_a_vencer             = 0
        vvalor_total_divida         = 0
        vdata_vencimento_contrato   = ""
        vdata_ultimo_pagamento      = ""
        vvalor_ultimo_pagamento     = 0
        vvalor_vencido              = 0
        vRisco                      = "" 
        vvalor_multa                = 0
        vqtd_parcelas               = 0
        vqtd_parcelas_a_vencer      = 0
        vqtd_parcelas_vencidas      = 0
        vqtd_parcelas_pagas         = 0
        vverificar_se_teve_parcelamento = ""     
        vvalor_juros                = 0
        vcobranca                   = 0
        tipo_contrato               = "1"
        vcontrato_gerado_na_novacao = ""
        vvalor_entrada              = 0
        vSubset                     = 0
        vcxacod = 0
        vvencod = 0.

    find clien where clien.clicod = cyber_controle.cliente no-lock.     
    find cpclien of clien no-lock no-error. 
    find contnf where contnf.etbcod  = cyber_controle.loja and
                      contnf.contnum = cyber_controle.contnum
                    no-lock no-error.
    if avail contnf
    then do.
        find plani where plani.etbcod = contnf.etbcod and
                         plani.placod = contnf.placod no-lock no-error.
        if avail plani
        then assign
                vcxacod = plani.cxacod
                vvencod = plani.vencod.
    end.
    if vcxacod > 99 then vcxacod = 1. /* #1 */

    vciccgc = trata-numero(clien.ciccgc).
    if length(vciccgc) = 11
    then do.
        vsubset = int(substr(vciccgc, 11, 1)).
        if vsubset = 0
        then vsubset = 10.
    end.

/**
run cyber/chave_contrato.p (input  recid(cyber_contrato),
                            output vchave_contrato).
**/

vchave_contrato = string(cyber_controle.loja ,"999") +
                  string(cyber_controle.contnum,"99999999999"). 
                            
run cyb/dados_contrato.p (input recid(cyber_controle)).


    put unformatted
        ""     /* tipo registro */       format "x(3)"    /* 1 Obrigatorio */
        "2"    /* grupo */               format "x(1)"    /* 4 Obrigatorio */
        vchave_contrato                  format "x(25)"   /* 5 obrigatorio */
        vdata_geracao                    format "x(8)"    /* 30 obrigatorio */
        vhora_geracao                    format "x(8)"    /* 38 obrigatorio */

        /* dados contrato */
        vvalor_atraso * 100       format "999999999999999" /* 46 obrigatorio */
        vvalor_a_vencer * 100     format "999999999999999" /* 61 obrigatorio */
        vvalor_total_divida * 100 format "999999999999999" /* 76 obrigatorio */
        vdata_vencimento_contrato         format "x(8)"    /* 91 obrigatorio */
        vdata_ultimo_pagamento            format "x(8)"    /* 99 obrigatorio */
        vvalor_ultimo_pagamento * 100 format "999999999999999" /*obrigatorio */
        vvalor_vencido      * 100  format "999999999999999"   /* obrigatorio */
        vRisco                               format "x(2)"    /*             */
        vvalor_juros        * 100  format "999999999999999"   /* obrigatorio */
        vvalor_multa        * 100  format "999999999999999"   /* obrigatorio */
        "CRE"                                format "x(3)"    /*             */
        vqtd_parcelas                        format "999"     /* obrigatorio */
        vqtd_parcelas_a_vencer               format "999"     /* obrigatorio */
        vqtd_parcelas_vencidas               format "999"     /* obrigatorio */
        vqtd_parcelas_pagas                  format "999"     /* obrigatorio */
        vverificar_se_teve_parcelamento      format "x(3)"    /* ########### */
        cyber_controle.loja                format "9999"    /*             */
        formatadata(cyber_controle.dtemissao) format "x(8)"    /*             */
        vcobranca                            format "99"      /*             */
        vcxacod                    format "99"    /*             */
        vvencod                    format "99999" /*           */
        vvalor_entrada  * 100      format "999999999999999"   /*             */
        tipo_contrato  /*(1=cre, 2=31 3=51)*/ format "x(1)"    /*########### */
        vcontrato_gerado_na_novacao          format "x(25)"   /* ########### */
        0        /* score */            format "9999999999"   /*             */
        0        /* score */            format "9999999999"   /*             */
        0        /* score */            format "9999999999"   /*             */
        0        /* score */            format "9999999999"   /*             */
        0        /* score */            format "9999999999"   /*             */
        0        /* score */            format "9999999999"   /*             */
        0        /* score */            format "9999999999"   /*             */
        0        /* score */            format "9999999999"   /*             */
        0        /* score */            format "9999999999"   /*             */
        0        /* score */            format "9999999999"   /*             */
        vSubset                         format "999"          /* */
        vdata_ultimo_vencimento         format "x(8)" /*** 20/05/2015 ***/
        skip.
    vqtd_registros = vqtd_registros + 1.
    
    delete t_contrato.
    
end.

/* TRAILER */
vqtd_registros = vqtd_registros + 1.
put unformatted
    "T"               format "x"          /* TIPO              0001 - 0001 */ 
    vdata_geracao     format "xxxxxxxx"   /* DATA DE GERACAO   0002 - 0009 */ 
    vqtd_registros    format "9999999999" /* QUANTIDADE DE REGISTROS ARQUIVO
                                                               0010 - 0019 */
    vsequencia        format "9999999999" /* SEQUENCIA ARQUIVO 0020 - 0029 */
    fill(" ",322)     format "x(322)"     /* FILLER            0030 - 3208 */
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

