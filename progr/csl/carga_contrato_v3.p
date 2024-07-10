/*  cyber/carga_contrato.p
#1 18.09.17 - Projeto Boletos, Envio do ID Acordo recebido pelo WS dos boleto #4            Atualiza Percentuais de Pagamento
#5 TP 32028114 18.07.19
*/

def var vidAcordoOrigem as int64.

def var vtipo as char.
vtipo = "CONTR".
def var varquivo as char.

{csl/cybcab.i}

def shared var v-today as date.
def shared var v-time as int.

/**
def  shared temp-table t_contrato no-undo
    field contnum like cslog_controle.contnum
    field tipo as char
    index c is unique primary contnum asc tipo asc
    index t tipo asc.
**/ 

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


def var vsequencia          as int.
def var vqtd_registros      as int.
def var vestado_civil       as char.
def var vchave_contrato     as char.
def var vgrau_instrucao     as char.
def var vplano_saude        as char.    
def var vseguros            as char.
def var vtempo_residencia   as char.
def var vcpfconj            like clien.ciccgc.
def var vnatconj            as char.
def var vdat-spc            as date.
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

{csl/sequencias.i vtipo vsequencia}
{csl/arquivo.i ""carga""}

message vtipo varq vsequencia.
output to value(varq).
/* HEADER */
put unformatted
    "H"               format "x"          /* TIPO              0001 - 0001 */ 
    "2"               format "x"          /* GRUPO             0002 - 0001 */
    "CYBER"           format "x(8)"       /* EMPRESA           0003 - 0010 */ 
    "CARGA"           format "x(30)"      /* ARQUIVO           0011 - 0040 */
    vdata_geracao     format "xxxxxxxx"   /* DATA DE GERACAO   0041 - 0048 */ 
    vsequencia        format "9999999999" /* SEQUENCIA ARQUIVO 0049 - 0058 */
    fill(" ",3122)    format "x(3150)"    /* FILLER            0059 - 3208 */
    skip.

vqtd_registros = 1.

for each cslog_controle  where
    situacao =  "ENVIAR" or
    situacao =  "ARRASTAR" or
    situacao =  "ATUALIZAR"
    no-lock.
     
                   

    find contrato of cslog_controle no-lock no-error.
 
    assign
        vcxacod = 0
        vvencod = 0.

    find clien where clien.clicod = cslog_controle.cliente no-lock.     
    find cpclien of clien no-lock no-error. 
    find fin.contnf where contnf.etbcod  = cslog_controle.loja and
                          contnf.contnum = cslog_controle.contnum
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
    {csl/man_cadastro.i}
    if vcxacod > 99 then vcxacod = 1. /* #5 */

    /* #1 */
    find first cybacparcela where cybacparcela.contnum = cslog_controle.contnum
        no-lock no-error.
    if avail cybacparcela
    then vidAcordoOrigem = cybacparcela.idacordo.
    else vidacordoOrigem = 0.     
 
    /* #4 */ 
    find cyber_clien where cyber_clien.clicod = cslog_controle.cliente
        no-lock no-error.

    /* helio 22062021 https://trello.com/c/NbjHq7qD/375-cliente-com-erro-nas-cargas-cslog */
    if vvencod > 99999 then vvencod = 0.
 
 put unformatted    
    /* dados contrato */
    vvalor_atraso * 100            format "999999999999999"   /* 2303 obrig */
    vvalor_a_vencer * 100          format "999999999999999"   /* 2919 obrig */
    vvalor_total_divida * 100      format "999999999999999"   /* 2933 obrig */
    vdata_vencimento_contrato                format "x(8)"    /* 2948 obrig */
    vdata_ultimo_pagamento                   format "x(8)"    /* 2956 obrig */
    vvalor_ultimo_pagamento * 100  format "999999999999999"   /* 2964 obrig */
    vvalor_vencido          * 100  format "999999999999999"   /* 2979 obrig */
    vRisco                                   format "x(2)"    /* 2994       */
    vvalor_juros            * 100  format "999999999999999"   /* 2996 obrig */
    vvalor_multa            * 100  format "999999999999999"   /* 3011 obrig */
    "CRE"                                    format "x(3)"    /* 3026       */
    vqtd_parcelas                            format "999"     /* 3029 obrig */
    vqtd_parcelas_a_vencer                   format "999"     /* 3032 obrig */
    vqtd_parcelas_vencidas                   format "999"     /* 3035 obrig */
    vqtd_parcelas_pagas                      format "999"     /* 3038 obrig */
    vverificar_se_teve_parcelamento          format "x(3)"    /* 3041 ##### */
    cslog_controle.loja                    format "9999"    /* 3044       */
    formatadata(cslog_controle.dtemissao)    format "x(8)"    /* 3048       */
    vcobranca                                format "99"      /* 3056       */
    vcxacod                        format "99"      /* 3058        */
    vvencod                        format "99999"   /* 3060        */
    vvalor_entrada  * 100          format "999999999999999"   /* 3065       */
    tipo_contrato  /*(1=cre, 2=31 3=51)*/    format "x(1)"    /* 3080 ##### */
    vcontrato_gerado_na_novacao              format "x(25)"   /* 3081 ##### */
    0        /* score */                format "9999999999"   /* 3106        */
    0        /* score */                format "9999999999"   /* 3116        */
    0        /* score */                format "9999999999"   /* 3126        */
    0        /* score */                format "9999999999"   /* 3136        */
    0        /* score */                format "9999999999"   /* 3146        */
    0        /* score */                format "9999999999"   /* 3156        */
    0        /* score */                format "9999999999"   /* 3166        */
    0        /* score */                format "9999999999"   /* 3176        */
    0        /* score */                format "9999999999"   /* 3186        */
    0        /* score */                format "9999999999"   /* 3196        */
    vSubset                             format "999"          /* 3206 */
    vdata_ultimo_vencimento             format "x(8)" /*** 3209 20/05/2015 ***/

        (if avail cyber_clien and cyber_clien.perc15 <> ?
        then cyber_clien.perc15 * 100
        else 0) format "9999999" /** percentuais de pagamento */
        (if avail cyber_clien and cyber_clien.perc45 <> ?
        then cyber_clien.perc45 * 100
        else 0) format "9999999" /** percentuais de pagamento */
        (if avail cyber_clien and cyber_clien.perc46 <> ?
        then cyber_clien.perc46 * 100
        else 0) format "9999999" /** percentuais de pagamento */
    
        vidAcordoOrigem format "9999999999999"    

    skip.

    vqtd_registros = vqtd_registros + 1.
    
/*    delete t_contrato.*/
    
end.

vqtd_registros = vqtd_registros + 1.
/* TRAILER */
put unformatted
    "T"               format "x"          /* TIPO              0001 - 0001 */ 
    vdata_geracao     format "xxxxxxxx"   /* DATA DE GERACAO   0002 - 0009 */ 
    vqtd_registros    format "9999999999" /* QUANTIDADE DE REGISTROS ARQUIVO
                                                               0010 - 0019 */
    vsequencia        format "9999999999" /* SEQUENCIA ARQUIVO 0020 - 0029 */
    fill(" ",3179)    format "x(3179)"    /* FILLER            0030 - 3208 */
    skip.

output close.
{csl/arquivozip.i}

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


procedure grau-instrucao:
    DEF VAR AUX-instrucao AS CHAR EXTENT 5 FORMAT "X(20)".
    DEF VAR MARCA-instrucao AS CHAR EXTENT 5 FORMAT "(X)".
    def var v1 as int.
    def var vcompleto as log format "Sim/Nao".
    def var vincompleto as log format "Sim/Nao".
    def var vaux as int.

    assign
        aux-instrucao[1] = "Fundamental"
        aux-instrucao[2] = "Primeiro grau"
        aux-instrucao[3] = "Segundo grau"
        aux-instrucao[4] = "Curso superior"
        aux-instrucao[5] = "Pos/Mestrado".

    if cpclien.var-log8 = yes
    then assign
             vcompleto = yes
             vincompleto = no.
    else assign
             vcompleto = no
             vincompleto = yes.   
    
    vgrau_instrucao = "".
    do vaux = 1 to 5:
        if aux-instrucao[vaux] = acha("INSTRUCAO",cpclien.var-char8)
        then marca-instrucao[vaux] = "X".
        if  marca-instrucao[vaux] = "X"
        then vgrau_instrucao = aux-instrucao[vaux].
    end.

end procedure.

procedure plano-saude:
    DEF VAR AUX-psaude AS CHAR EXTENT 4 FORMAT "X(20)".
    DEF VAR MARCA-psaude AS CHAR EXTENT 4 FORMAT "(X)" .
    def var vaux as int.

    assign
        aux-psaude[1] = "Nao Possui"
        aux-psaude[2] = "IPE"
        aux-psaude[3] = "UNIMED"
        aux-psaude[4] = "Outros" .
    
    if cpclien.var-log7 = yes
    then do:
        if acha("IPE",var-char7) <> ?
        then marca-psaude[2] = "X".
        if acha("UNIMED",var-char7) <> ?
        then marca-psaude[3] = "X".
        if acha("Outros",var-char7) <> ?
        then marca-psaude[4] = "X".
    end.
    else marca-psaude[1] = "X".       

    do vaux = 1 to 4.
        if marca-psaude[vaux] = "X"
        then vplano_saude = aux-psaude[vaux].
    end.
end procedure.


procedure seguro:
    DEF VAR AUX-seguro AS CHAR EXTENT 5 FORMAT "X(20)".
    DEF VAR MARCA-seguro AS CHAR EXTENT 5 FORMAT "(X)" .
    def var vaux as int.

    assign
        aux-seguro[1] = "Nao Possui"
        aux-seguro[2] = "De Saude"
        aux-seguro[3] = "De Vida"
        aux-seguro[4] = "Residencial" 
        aux-seguro[5] = "Automovel".
    
    if cpclien.var-log6 = yes
    then do:
        if acha("De Saude",var-char6) <> ?
        then marca-seguro[2] = "X".
        if acha("De Vida",var-char6) <> ?
        then marca-seguro[3] = "X".
        if acha("Residencial",var-char6) <> ?
        then marca-seguro[4] = "X".
        if acha("Automovel",var-char6) <> ?
        then marca-seguro[5] = "X".
    end.
    else marca-seguro[1] = "X".       

    do vaux = 1 to 5.
        if marca-seguro[vaux] = "X"
        then vseguros = aux-seguro[vaux].
    end.
end procedure.

