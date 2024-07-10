/*  cyber/dados_contrato.p                                                   */
/*  retorna variaveis de valores corrigidos do contrato                      */
def input  parameter par-rec-contrato   as recid.

def shared var vvalor_atraso               as dec.  /* ok */
def shared var vvalor_a_vencer             as dec.  /* ok */
def shared var vvalor_total_divida         as dec.  /* ok */
def shared var vdata_vencimento_contrato   as char. /* ok */
def shared var vdata_ultimo_pagamento      as char. /* ok */
def shared var vdata_ultimo_vencimento     as char.
def shared var vvalor_ultimo_pagamento     as dec.  /* ok */
def shared var vvalor_vencido              as dec.  /* ok */
def shared var vvalor_multa                as dec.  /* ok */
def shared var vqtd_parcelas               as int.  /* ok */
def shared var vqtd_parcelas_a_vencer      as int.  /* ok */
def shared var vqtd_parcelas_vencidas      as int.  /* ok */
def shared var vqtd_parcelas_pagas         as int.  /* ok */
def shared var vverificar_se_teve_parcelamento as char.     
def shared var vvalor_juros                as dec.
def shared var vcobranca                   as int.
def shared var tipo_contrato               as char.
def shared var vcontrato_gerado_na_novacao as char.
def shared var vvalor_entrada              as dec.  /*ok*/

def var vdtprivcto as date.
def var vdtultvcto as date.
def var vdtultpgto as date.
def var par-juros  as dec.
def var vtitpar31  as log.
def var vtitpar51  as log.

function formatadata returns character
    (input par-data  as date). 
    
    def var vdata as char.  
    if par-data <> ? 
    then 
        vdata = string(month(par-data), "99") + 
                string(day  (par-data), "99") +
                string(year (par-data), "9999"). 
    else 
        vdata = "00000000". 
    return vdata. 
end function.

find cyber_contrato where recid(cyber_contrato) = par-rec-contrato no-lock.
assign 
    vvalor_entrada      = cyber_contrato.vlentra.

for each titulo where titulo.empcod = 19
                      and titulo.titnat = no
                      and titulo.modcod = "CRE"
                      and titulo.etbcod = cyber_contrato.etbcod
                      and titulo.clifor = cyber_contrato.clicod
                      and titulo.titnum = string(cyber_contrato.contnum)
                      and titulo.titvlcob > 0.01
                    no-lock.
    if titulo.titsit = "LIB"
    then do.
        if titulo.titdtven < today 
        then
            assign vvalor_atraso  = vvalor_atraso  + titulo.titvlcob
                   vvalor_vencido = vvalor_vencido + titulo.titvlcob
                   vqtd_parcelas_vencidas = vqtd_parcelas_vencidas + 1.
        else
            assign vvalor_a_vencer = vvalor_a_vencer + titulo.titvlcob
                   vqtd_parcelas_a_vencer = vqtd_parcelas_a_vencer + 1.

        vvalor_total_divida = vvalor_total_divida + titulo.titvlcob.
        run juro_titulo.p (titulo.titdtven,
                           titulo.titvlcob,
                           output par-juros).
        vvalor_juros = vvalor_juros + par-juros.

        if vdtprivcto = ? or titulo.titdtven < vdtultvcto
        then vdtprivcto = titulo.titdtven.
    end.
    else do.
        vqtd_parcelas_pagas = vqtd_parcelas_pagas + 1.

        if vdtultpgto = ? or titulo.titdtpag > vdtultpgto
        then assign
                vvalor_ultimo_pagamento = titulo.titvlpag
                vdtultpgto = titulo.titdtpag.
    end.

    vqtd_parcelas = vqtd_parcelas + 1.

    if vdtultvcto = ? or titulo.titdtven > vdtultvcto
    then vdtultvcto = titulo.titdtven.

    if titulo.titpar = 31
    then vtitpar31 = yes.
    else if titulo.titpar = 51
    then vtitpar51 = yes.
end.

vdata_vencimento_contrato = formatadata(vdtprivcto).
vdata_ultimo_vencimento   = formatadata(vdtultvcto).
vdata_ultimo_pagamento    = formatadata(vdtultpgto).

if vtitpar31
then tipo_contrato = "2".
else if vtitpar51
then tipo_contrato = "3".
else tipo_contrato = "1".

