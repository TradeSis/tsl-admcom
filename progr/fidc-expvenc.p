/***
    Projeto FIDC: junho,julho/2018
    Exportar CNAB444: item 6.2 Envio de arquivo de vencimentos
***/
{admcab.i}
{fidc-exporta.i}

def var varquivo  as char.
def var vdata     as date.
def var vdtini    as date.
def var vdtfin    as date.
def var vlote     as int.
def var vlottip   as char init "ENVVENC".
def var vlotqtde  as int.
def var vlottotal as dec.
def var vfase     as char.
def var vlidos    as int.
def buffer blotefidc for lotefidc.
def buffer btitulo   for titulo.

def temp-table tt-titulo
    field rec as recid.

varquivo = "vencimento_fidc" + string(today,"99999999") + ".rem".

do on error undo, retry with frame f1 side-label centered
        title " FIDC - Exportar Vencimentos ".
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

do vdata = vdtini to vdtfin.
    /*
        Primeira selecao
    */
    vfase = "1".
    disp vdata label "Data" vfase label "Fase"
        with frame f-data side-label centered.
    for each titulo where titulo.titnat   = no
                      and titulo.titdtven = vdata
                      and titulo.modcod   = vmodcod
                    no-lock.
        vlidos = vlidos + 1.
        /*
        Caso o título tenha sido pago este pagamento somente será enviado 
        se o pagamento for realizado no dia do vencimento
        */
        if titulo.titdtpag <> ? and
           (titulo.titdtpag <> titulo.titdtven)
        then next.

        if vlidos + vlotqtde mod 1750 = 0
        then disp vlidos label "Lidos"
                 vlotqtde label "Selecionados"
                 with frame f-data.

        /* verifica se ja foi enviado pagamento */
        find first envfidc where envfidc.empcod = titulo.empcod
                             and envfidc.titnat = titulo.titnat
                             and envfidc.modcod = titulo.modcod
                             and envfidc.etbcod = titulo.etbcod
                             and envfidc.clifor = titulo.clifor
                             and envfidc.titnum = titulo.titnum
                             and envfidc.titpar = titulo.titpar
                             and envfidc.lottip = vlottip
                        no-lock no-error.
        if avail envfidc
        then next.

        create tt-titulo.
        tt-titulo.rec = recid(titulo).
        assign
            vlotqtde  = vlotqtde + 1
            vlottotal = vlottotal + titulo.titvlpag.
    end.

    /*
        Segunda leitura
    */
    vfase = "2".
    disp vdata vfase with frame f-data.
    for each titulo where titulo.titnat   = no
                      and titulo.titdtpag = vdata
                      and titulo.modcod   = vmodcod
                    no-lock:
        vlidos = vlidos + 1.
        /* somente pagamento antecipado */
        if titulo.titdtpag <= titulo.titdtven
        then next.

        if vlidos + vlotqtde mod 1750 = 0
        then disp vlidos vlotqtde with frame f-data.

        /* verifica se ja foi enviado pagamento */
        find first envfidc where envfidc.empcod = titulo.empcod
                             and envfidc.titnat = titulo.titnat
                             and envfidc.modcod = titulo.modcod
                             and envfidc.etbcod = titulo.etbcod
                             and envfidc.clifor = titulo.clifor
                             and envfidc.titnum = titulo.titnum
                             and envfidc.titpar = titulo.titpar
                             and envfidc.lottip = vlottip
                        no-lock no-error.
        if avail envfidc
        then next.

        create tt-titulo.
        tt-titulo.rec = recid(titulo).
        assign
            vlotqtde  = vlotqtde + 1
            vlottotal = vlottotal + titulo.titvlpag.
    end.
end.

find first tt-titulo no-lock no-error.
if not avail tt-titulo
then do.
    message "Sem titulos no periodo informado" view-as alert-box.
    return.
end.

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
for each tt-titulo no-lock.
    find titulo where recid(titulo) = tt-titulo.rec no-lock.

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
        run moedas.

        if acha("PAGAMENTO-PARCIAL", titulo.titobs[1]) = "SIM"
        then vocorrencia = 14.
        else vocorrencia = 77.

        for each tt-moeda no-lock.
            run exporta (tt-moeda.moecod, tt-moeda.titvlpag).
        end.
    end.

        /*
          arquivo de controle
        */
        find envfidc where envfidc.empcod = titulo.empcod
                       and envfidc.titnat = titulo.titnat
                       and envfidc.modcod = titulo.modcod
                       and envfidc.etbcod = titulo.etbcod
                       and envfidc.clifor = titulo.clifor
                       and envfidc.titnum = titulo.titnum
                       and envfidc.titpar = titulo.titpar

                       and envfidc.lottip = vlottip
                       and envfidc.lotnum = vlote
                    exclusive-lock no-error.
        if not avail envfidc
        then do: 
             create envfidc.
             assign envfidc.empcod = titulo.empcod
                    envfidc.titnat = titulo.titnat
                    envfidc.modcod = titulo.modcod
                    envfidc.etbcod = titulo.etbcod
                    envfidc.clifor = titulo.clifor
                    envfidc.titnum = titulo.titnum
                    envfidc.titpar = titulo.titpar
                    envfidc.lottip = vlottip
                    envfidc.lotnum = vlote
                    envfidc.lotseq = vseq.
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

message "Arquivo gerado:" varquivo view-as alert-box.

