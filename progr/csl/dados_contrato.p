/*  cyber/dados_contrato.p                                                   */
/*  retorna variaveis de valores corrigidos do contrato                      */
/*#1*/ /* 22.02.18 Helio - 
    Considera pago titsit = PAG , 
    Considerar titsit NOV como pago 
     Considerar titsit EXC como pago 
    e todas as demais situ~acoes considera aberto */
/* #2 25.05.18 helio - acertado para CPN ser tipo_contrato 4, estava incorreto 
*/
{acha.i}

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
def var vfeirao    as log.
def var vfeirao-novo    as log.


function formatadata returns character
    (input par-data  as date). 
    
    def var vdata as char.  
    if par-data <> ? 
    then vdata = string(month(par-data), "99") + 
                string(day  (par-data), "99") +
                string(year (par-data), "9999"). 
    else vdata = "00000000". 

    return vdata. 
end function.


find cslog_controle where recid(cslog_controle) = par-rec-contrato no-lock.
find contrato of cslog_controle no-lock no-error.

assign 
    vvalor_entrada      = if avail contrato then contrato.vlentra else 0.
    
if vvalor_entrada < 0 then vvalor_entrada = 0. /* helio 21032023 */    

/**
    vvalor_atraso           = cslog_controle.vlratrasado.
    vvalor_vencido          = cslog_controle.vlratrasado.
    vqtd_parcelas_vencidas  = cslog_controle.qtdatrasado.
    vvalor_a_vencer         = cslog_controle.vlravencer.
    vqtd_parcelas_a_vencer  = cslog_controle.qtdavencer. 
    vvalor_total_divida     = cslog_controle.vlraberto.
    vvalor_juros            = cslog_controle.vlrjuros.
    vdtprivcto              = cslog_controle.privenab.
    vdtultvcto              = cslog_controle.ultvenab.
    vqtd_parcelas_pagas     = cslog_controle.qtdpagas.
    vqtd_parcelas           = cslog_controle.qtdatrasado +
                                 cslog_controle.qtdavencer.
    vvalor_ultimo_pagamento = cslog_controle.ultvlrpag.
    vdtultpgto              = cslog_controle.ultdtpag.
**/

    vtitpar31               = cslog_controle.novacao and
                              cslog_controle.lp = no.
    vtitpar51               = cslog_controle.novacao and
                              cslog_controle.lp.

    def var vclicod as int.
    def var vetbcod as int.
    def var vcontnum as int.
    def var vmodcod as char.

        vclicod = if avail contrato
                  then contrato.clicod
                  else cslog_controle.cliente.  
        vcontnum = cslog_controle.contnum.
        vetbcod  = cslog_controle.loja.

vmodcod = if avail contrato
    then if contrato.modcod <> ""
         then contrato.modcod
         else "CRE"
    else "CRE".
                                                
for each titulo where titulo.empcod = 19
                  and titulo.titnat = no
                  and titulo.modcod = vmodcod
                  and titulo.etbcod = vetbcod
                  and titulo.clifor = vclicod
                  and titulo.titnum = string(vcontnum)
        no-lock
            by titulo.titpar.

            if titulo.clifor <= 1 or
               titulo.clifor = ? or
               titulo.titpar = 0 or
               titulo.titnum = "" or
               titulo.titvlcob <= 0.01 /*** 02.08.16 ***/
            then next.

    if titulo.titsit <> "PAG" and
       titulo.titsit <> "NOV" and /* #1 */
       titulo.titsit <> "EXC"     /* #1 */
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
        run juro_titulo.p (0,
                           titulo.titdtven,
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
                vdtultpgto = if titulo.titdtpag = ? /* #1 */
                             then today
                             else titulo.titdtpag.
    end.

    vqtd_parcelas = vqtd_parcelas + 1.

    if vdtultvcto = ? or titulo.titdtven > vdtultvcto
    then vdtultvcto = titulo.titdtven.

    if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
       acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
    then vfeirao = yes.

    if acha("FEIRAO-NOVO",titulo.titobs[1]) <> ? and
       acha("FEIRAO-NOVO",titulo.titobs[1]) = "SIM"
    then vfeirao-novo = yes.
    

    else if titulo.tpcontrato = "N" /*** titulo.titpar = 31 ***/
    then vtitpar31 = yes.

    else if titulo.tpcontrato = "L" /*** titulo.titpar = 51***/
    then vtitpar51 = yes.
end.

vdata_vencimento_contrato = formatadata(vdtprivcto).
vdata_ultimo_vencimento   = formatadata(vdtultvcto).
vdata_ultimo_pagamento    = formatadata(vdtultpgto).

/* #2 */
if vmodcod begins "CP" /* <> "CRE" */
then tipo_contrato = "4". /* #2 */
else if vfeirao-novo
then tipo_contrato = "6".
else if vfeirao
then tipo_contrato = "5".
else if vtitpar31
then tipo_contrato = "2".
else if vtitpar51
then tipo_contrato = "3".
else tipo_contrato = "1".

