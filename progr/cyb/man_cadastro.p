/*  cyber/man_cadastro.p                                                */

/* #1 18.09.2017 - Projeto Boletos, Envio do ID Acordo recebido pelo WS dos boleto */ 
def var vidAcordoOrigem as int64.


def var vtipo as char.
vtipo = "CADAS".
def var varquivo as char.

{cyb/cybcab.i}

def shared var v-today as date.
def shared var v-time as int.

/**
def  shared temp-table c_contrato no-undo
    field contnum like cyber_controle.contnum
    index c is unique primary contnum asc.
**/

def  shared temp-table t_contrato no-undo
    field contnum like cyber_controle.contnum
    field tipo as char
    index c is unique primary contnum asc tipo asc
    index t tipo asc.
/**
def  shared temp-table t_interface no-undo
    field tipo as char
    field qtd  as int
    index t is unique primary tipo asc.
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

/**
def input parameter par-reclotcre as recid.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.
**/

def var vsequencia                  as int.
def var vqtd_registros              as int.
def var vestado_civil               as char.
def var vchave_contrato             as char.
def var vgrau_instrucao             as char.
def var vplano_saude                as char.    
def var vseguros                    as char.
def var vtempo_residencia           as char.
def var vcpfconj                    like clien.ciccgc.
def var vnatconj                    as char.
def var vdat-spc                    as date.
def var vlimite_credito             as int.
def var vmedia_atraso               as int.

def new shared var vvalor_atraso               as dec.
def new shared var vvalor_a_vencer             as dec.
def new shared var vvalor_total_divida         as dec.
def new shared var vdata_vencimento_contrato   as char.
def new shared var vdata_ultimo_pagamento      as char.
def new shared var vdata_ultimo_vencimento     as char.
def new shared var vvalor_ultimo_pagamento     as dec.
def new shared var vvalor_vencido              as dec.
def new shared var vRisco                      as char. 
def new shared var vvalor_juro                 as dec.
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

{cyb/arquivo.i ""man_cad""}

def temp-table ttcli no-undo
    field clicod as int
    index c is unique primary clicod asc.
     

output to value(varq).

/* HEADER */
put unformatted
    "H"               format "x"          /* TIPO              0001 - 0001 */ 
    "2"               format "x"          /* PRODUTO           0002 - 0031 */
    "CYBER"           format "x(8)"       /* EMPRESA           0032 - 0039 */ 
    "MANCAD"          format "x(30)"      /* ARQUIVO           0040 - 0069 */
    vdata_geracao     format "xxxxxxxx"   /* DATA DE GERACAO   0070 - 0077 */ 
    vsequencia        format "9999999999" /* SEQUENCIA ARQUIVO 0078 - 0087 */
    fill(" ",2819)    format "x(2847)"    /* FILLER            0088 - 3208 */
    skip.
vqtd_registros = vqtd_registros + 1.

for each t_contrato where t_contrato.tipo = vtipo.

    
    find cyber_controle where 
                cyber_controle.contnum = t_contrato.contnum no-lock.
    find contrato of cyber_controle no-lock no-error.
    
    
    find clien  where clien.clicod = cyber_controle.cliente no-lock no-error.
    if not avail clien then do:
        delete t_contrato.
        next.
    end.
         
    /** um MANCAD por cliente **/
    find ttcli where ttcli.clicod = clien.clicod no-error.
    if avail ttcli
    then do:
        delete t_contrato.
        next.
    end.    
    create ttcli.
    ttcli.clicod = clien.clicod.
    
    
    
    find cpclien of clien no-lock no-error. 

    {cyb/man_cadastro.i}

    /* #1 */
    find first cybacparcela where
        cybacparcela.contnum = cyber_controle.contnum
        no-lock no-error.
    if avail cybacparcela
    then vidAcordoOrigem = cybacparcela.idacordo.
    else vidacordoOrigem = 0.     
    

put unformatted    
    vSubset                             format "999"          /* */
        0 format "9999999" /** percentuais de pagamento */
        0 format "9999999"
        0 format "9999999"    
        vidAcordoOrigem format "9999999999999"    
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
    fill(" ",2876)    format "x(2876)"    /* FILLER            0030 - 3208 */
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
        lotcre.arqenvio  = varq.
end.
find lotcre where recid(lotcre) = par-reclotcre no-lock.
    
*/

def var vaux as int.

procedure grau-instrucao:
    DEF VAR AUX-instrucao AS CHAR EXTENT 5 FORMAT "X(20)".
    DEF VAR MARCA-instrucao AS CHAR EXTENT 5 FORMAT "(X)".
    def var v1 as int.
    def var vcompleto as log format "Sim/Nao".
    def var vincompleto as log format "Sim/Nao".
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

