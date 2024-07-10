/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/vendi.p                                  Vendas por Dia     */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 29/09/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var wdtven as da initial today.
def var wtotav as de format ">,>>>,>>>,>>9.99".
def var wtotap as de format ">,>>>,>>>,>>9.99".
def var wtot as de format ">,>>>,>>>,>>9.99".
def var wicms as de format ">,>>>,>>>,>>9.99".
def var wmovndc like nota.movndc.
l1:
repeat with 1 column width 80 title " Dados para Consulta " 1 down frame f1:
    prompt-for estab.etbcod.
    find estab using etbcod.
    update wdtven label "Data de Venda".
/*  find first nota where (movtdc = 3 or movtdc = 4) and notdat = wdtven.
    display skip(1) nota.movndc skip
            nota.movsdc with frame fi title " Nota Inicial " side-labels.
    find last nota where nota.movtdc = 3 and
                         nota.etbcod = estab.etbcod and
                         nota.movsdc = etbserie and
                         nota.notdat = wdtven no-error.
    if available nota
        then wmovndc = nota.movndc.
    find last nota where nota.movtdc = 4 and
                         nota.etbcod = estab.etbcod and
                         nota.movsdc = etbserie and
                         nota.notdat = wdtven no-error.
    if available nota
        then if wmovndc < nota.movndc
            then wmovndc = nota.movndc.
    display skip(1) wmovndc skip
            nota.movsdc with frame ff title " Nota Final "
                             side-labels column 25.
    assign wtotav = 0
           wtotap = 0.
    for each nota where (movtdc = 3 or movtdc = 4) and notdat = wdtven:
        if nota.notpag
            then wtotav = wtotav + notval.
            else wtotap = wtotap + notval.
    end.
    display wtotav label "A Vista"
            wtotap label "A Prazo"
            wtotav + wtotap format ">,>>>,>>>,>>9.99" label "Total"
            with title " Vendas " column 45 frame fv 1 column.
    for each movim where (movtdc = 3 or movtdc = 4) and movdat = wdtven,
        estoq of movim,
        nota of movim
        break by movicms by ctrcod:
        if notdes = 0
            then wtot = wtot + movpc * movqtm.
            else wtot = wtot + (movpc * movqtm - movpc * movqtm /
                               (notval + notdes) * notdes).
        wicms = wicms + movicmsval.
        if last-of(ctrcod)
            then do:
            find ctrib of estoq.
            display space(4) ctrnom space(2)
                    movicms space(2)
                    wtot (total) column-label "Valor Base" space(2)
                    wicms (total) column-label "Valor ICMS" space(2)
                    with title " Tributacao " width 80 frame ft down.
            assign wtot = 0
                   wicms = 0.
            end.
    end.                                                                      */
    {confir.i 1 "Impressao da Venda no Dia"}
    message "Emitindo Venda no Dia.".
    output to printer page-size 60.
    display "Vendas no Dia :"
            wdtven no-label
            with side-labels centered frame f2.
    find first nota where nota.movtdc = 3 and
                          nota.etbcod = estab.etbcod and
                          nota.movsdc = etbserie and
                          nota.notdat = wdtven no-error.
    if available nota
        then wmovndc = nota.movndc.
    find first nota where nota.movtdc = 4 and
                          nota.etbcod = estab.etbcod and
                          nota.movsdc = etbserie and
                          nota.notdat = wdtven no-error.
    if available nota
        then if wmovndc > nota.movndc
            then wmovndc = nota.movndc.
    display wmovndc
            nota.movsdc with frame fpi title " Nota Inicial " 1 column centered.
    find last nota where nota.movtdc = 3 and
                         nota.etbcod = estab.etbcod and
                         nota.movsdc = etbserie and
                         nota.notdat = wdtven no-error.
    if available nota
        then wmovndc = nota.movndc.
    find last nota where nota.movtdc = 4 and
                         nota.etbcod = estab.etbcod and
                         nota.movsdc = etbserie and
                         nota.notdat = wdtven no-error.
    if available nota
        then if wmovndc < nota.movndc
            then wmovndc = nota.movndc.
    display wmovndc
            nota.movsdc with frame fpf title " Nota Final " 1 column centered.
    assign wtotav = 0
           wtotap = 0.
    for each nota where (nota.movtdc = 3 or nota.movtdc = 4) and
             notdat = wdtven:
        if nota.notpag
            then wtotav = wtotav + notval.
            else wtotap = wtotap + notval.
    end.
    display wtotav label "A Vista" skip
            wtotap label "A Prazo" skip
            wtotav + wtotap format ">,>>>,>>>,>>9.99" label "Total"
            with title " Vendas " frame fpv 1 column centered.
    define temp-table icm
        field icmuf like unfed.ufecod
        field icmicmsp like movim.movicms
        field icmctrnom like ctrib.ctrnom
        field icmtot as de format ">,>>>,>>>,>>9.99"
        field icmicmsv as de format ">,>>>,>>>,>>9.99".
    for each movim where (movtdc = 3 or movtdc = 4) and movdat = wdtven,
        estoq of movim,
        nota of movim,
        ctrib of estoq:
        create icm.
        if nota.clicod <> 0
            then do:
            find clien of nota.
            icmuf = clien.ufecod[1].
            end.
            else icmuf = "RS".

        if notdes > 0
            then icmtot = (movpc * movqtm - (movpc * movqtm /
                               (notval + notdes)) * notdes).
        else
        if notacr > 0
            then icmtot = (movpc * movqtm + (movpc * movqtm /
                               (notval - notacr)) * notacr).

            else icmtot = movpc * movqtm.

        assign icmicmsp = movim.movicms
               icmicmsv = movicmsval
               icmctrnom = ctrib.ctrnom.
    end.
    for each icm break by icmuf by icmicmsp by icmctrnom:
        assign wicms = wicms + icmicmsv
               wtot = wtot + icmtot.
        if last-of(icmctrnom)
            then do:
            display space(4) icmctrnom space(2)
                    icmuf space(2)
                    icmicmsp space(2)
                    wtot (total) column-label "Valor Base" space(2)
                    wicms (total) column-label "Valor ICMS" space(2)
                    with title " Tributacao " width 80 frame fpt down.
            assign wtot = 0
                   wicms = 0.
            end.
    end.
    hide message no-pause.
    output close.
    message "Emissao de Vendas no Dia encerrada.".
end.
