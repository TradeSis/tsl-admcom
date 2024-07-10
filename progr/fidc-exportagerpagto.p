/* 09022023 helio - ID 158541 - trocado f-troca por removeacento */
/* helio 31012023 - conversao numero de parcelas */   
/* helio - 12012023 - ajuste em performance */
/* helio - 20122022 - retirar testes de carteira */

{admcab.i}

{fidc-exporta.i}

def input parameter vs as int.
def input parameter vdest as int.
def output parameter varquivo as char.

def var vdata     as date.
def var vdtini    as date.
def var vdtfin    as date.
def var vlote     as int.
def var vlottip   as char init "ENVPAGTGER".
if vdest = 3 then vlottip = "ENVPAGTGER16".
def var vlotqtde  as int.
def var vlottotal as dec.
def var vlidos    as int.
def buffer blotefidc for lotefidc.

def shared temp-table tt-env no-undo
    field rectit as recid
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field titvlcob like titulo.titvlcob
    field encargos like titulo.titvljur
    field titvldes like titulo.titvldes
    field titvlpag like titulo.titvlpag
    field titdtmov like titulo.titdtpag
    field tp_baixa as char
    index i1 is unique primary clifor titnum titpar.
    
/*
def temp-table tt-titulo
    field rec as recid
    field pag  like titulo.titvlpag
    field cob  like titulo.titvlcob
    .
*/

vpasta = "/admcom/financeira/arqexport/".
varquivo = "cobranca_fidc_" + string(vdest,"9") + "_" + string(vs,"99") + "_"  
            + string(today,"99999999") + ".rem".


/*****
do on error undo, retry with frame f1 side-label centered
        title " FIDC - Exportar Cobranca ".
    disp vpasta   label "Diretorio" colon 15 format "x(35)"
         varquivo label "Arquivo"   colon 15 format "x(35)"
         vmodcod  colon 15.
    
    update
        vdtini label "Data Inicial" colon 15
        vdtfin label "Data Final"   colon 15.
    if vdtini > vdtfin or vdtini = ? or vdtfin = ?
    then do:
        message "Periodo inválido" view-as alert-box.
        undo.
    end.
end.

sresp = no.
message "Confirma processamento?" update sresp.
if sresp = no
then next.

****/


def var vlseg as dec.
def var vjseg as dec.

varquivo = vpasta + varquivo.
DO ON ERROR UNDO.
    find last blotefidc where blotefidc.lottip = vlottip no-lock no-error.
    create lotefidc.
    assign lotefidc.lotnum = (if avail blotefidc 
                             then blotefidc.lotnum + 1
                             else 1)
          lotefidc.lottip  = vlottip
          /*** lotefidc.aux-ch  = "FINANCEIRA - EXPORTA CONTRATOS"***/
          lotefidc.funcod  = sfuncod
          lotefidc.arquivo = varquivo
          lotefidc.dtinicial = vdtini
          lotefidc.dtfinal   = vdtfin.
    assign vlote = lotefidc.lotnum.
end.

output to value(varquivo) page-size 0.

vseq = 1.
/* Header */

put unformatted
    0           format "9"       /* 1 */
    1           format "9"       /* 2 */
    "REMESSA"   format "x(7)"    /* 3 */
    1           format "99"      /* 4 */
    "COBRANCA"  format "x(15)"   /* 5 */
    vcodorig    format "x(20)"   /* 6 "99999999999999999999"*/
    vnomorig    format "x(30)"   /* 7 */
    611         format "999"     /* 8 */
    "PAULISTA S.A." format "x(15)"
    today       format "999999"  /* 10 */
    ""          format "x(8)"    /* 11 */
    "MX"        format "x(2)"    /* 12 */
    vlote       format "9999999" /* 13 */
    ""          format "x(321)"  /* 14 */
    vseq        format "999999"  /* 15 */
    skip.
    
/* Detalhe */
for each tt-env no-lock.
    find titulo where recid(titulo) = tt-env.rectit no-lock.

    find clien where clien.clicod = titulo.clifor no-lock.

    vendereco = clien.endereco[1].
    if clien.numero[1] <> ?
    then vendereco = vendereco + " " + string(clien.numero[1]).
    if clien.compl[1] <> ?
    then vendereco = vendereco + " " + clien.compl[1].
    if vendereco = ?
    then vendereco = "".

    vtitpar = titulo.titpar.
    if acha("PARCIAL", titulo.titobs[1]) = "SIM" /*titulo gerado pelo parcial*/
    then vtitpar = titulo.titparger.
    
    /* helio 31012023 - conversao numero de parcelas */   
    vtitpar = if titulo.titpar >= 51 then titulo.titpar - 50 else if titulo.titpar >= 31 then titulo.titpar - 30 else titulo.titpar.

    assign
        /*vtitulo = titulo.titnum + string(vtitpar, "99")*/
        vtitulo = string(int(titulo.titnum), "9999999999")
        vcontrolpag = string(titulo.etbcod, "999") +
                      string(int(titulo.titnum), "9999999999") +
                      string(vtitpar, "999").
        vocorrencia = 0.

    if titulo.titdtpag = ?
    then run exporta ("", 0).
    else do.
        
        if acha("PAGAMENTO-PARCIAL", titulo.titobs[1]) = "SIM"
        then vocorrencia = 14.
        else vocorrencia = 77.

            run exporta (titulo.moecod, 
                         titulo.titvlpag).
                         /*,
                         tt-titulo.cob).*/

    end.

end.

/* Trailer */
vseq = vseq + 1.
put unformatted
    9           format "9"       /* 1 */
    ""          format "x(437)"  /* 2 */
    vseq        format "999999"  /* 3 */
    skip.

output close.

unix silent unix2dos -q value(varquivo).


do on error undo.
    find lotefidc where lotefidc.lottip = vlottip
                    and lotefidc.lotnum = vlote
                  exclusive-lock no-error.
    assign lotefidc.data   = today
           lotefidc.hora   = time
           lotefidc.lotqtd = vlotqtde
           lotefidc.lotvlr = vlottotal.
    find current lotefidc no-lock.
end.

/*
message "Arquivo gerado:" varquivo view-as alert-box.
*/



