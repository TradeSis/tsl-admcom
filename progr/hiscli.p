{admcab.i}

def workfile wacum
    field mes as int format "99"
    field ano as int format "9999"
    field acum       like plani.platot.

/*********** DATA DA ULTIMA COMPRA                       ***************/
/*********** LIMITE DE CREDITO DO CADASTRO               ***************/
/*********** QUANTIDADE DE CONTRATO                      ***************/
/*********** QTD DE PARCELAS                             ***************/
/*********** QTD DE PARCELAS PAGAS MENOS DE 15 DE ATRASO ***************/
/*********** QTD DE PARCELAS PAGAS DE 16 ATE 45 DIAS     ***************/
/*********** QTD DE PARCELAS ACIMA DE 46 DIAS            ***************/
/*********** SE TEM REPARCELAMENTO   (SIM/NAO)           ***************/
/*********** MAIOR ACUMULO MENSAL (VALOR / MES E ANO)    ***************/
/*********** SALDO EM ABERTO                             ***************/
/*********** MEDIA DE PRESTACOES LIQUIDADAS              ***************/
/*********** PRESTACOES DO PROXIMO MES                   ***************/


def var maior-atraso like plani.pladat.
def var vencidas like clien.limcrd.
def var v-mes as int format "99".
def var v-ano as int format "9999".
def var v-acum like clien.limcrd.
def var qtd-contrato as int format ">>>9".
def var parcela-paga    as int format ">>>>9".
def var parcela-aberta  as int format ">>>>9".
def var qtd-15       as int format ">>>>9".
def var qtd-45       as int format ">>>>9".
def var qtd-46       as int format ">>>>9".
def var vrepar       as log format "Sim/Nao".
def var v-media      like clien.limcrd.
def var ult-compra   like plani.pladat.
def var sal-aberto   like clien.limcrd.
def var lim-calculado like clien.limcrd format "->>,>>9.99".
def var vtotal like plani.platot.
def var vqtd   as int.
def var proximo-mes like clien.limcrd.
def var vdata1 like plani.pladat.
def var vdata2 like plani.pladat.
def var vclicod like clien.clicod.

repeat:
    update vclicod label "Codigo" with frame f-cli side-label width 80.
    find clien where clien.clicod = vclicod no-lock no-error.
    display clien.clinom no-label with frame f-cli.
    

    for each wacum:
        delete wacum.
    end.

    qtd-contrato = 0.
    ult-compra   = ?.
    vtotal = 0.
    vqtd = 0.
    for each contrato where contrato.clicod = clien.clicod
                                                no-lock by contrato.dtinicial.
        qtd-contrato = qtd-contrato + 1.
        ult-compra   = contrato.dtinicial.
    end.

    v-acum = 0.
    v-mes  = 0.
    v-ano  = 0.

    qtd-15  = 0.
    qtd-45  = 0.
    qtd-46  = 0.
    parcela-paga = 0.
    parcela-aberta = 0.
    vencidas = 0.

    proximo-mes = 0.
    sal-aberto = 0.
    vrepar  = no.

    if month(today) = 12
    then vdata1 = date(1,1,year(today) + 1).
    else vdata1 = date(month(today) + 1,1,year(today)).


    if month(vdata1) = 12
    then vdata2 = date(1,1,year(vdata1) + 1) - 1.
    else vdata2 = date(month(vdata1) + 1,1,year(vdata1)) - 1.


    maior-atraso = today.
    for each titulo where titulo.clifor = clien.clicod no-lock:

        if titulo.titnat = yes
        then next.
        if titulo.titpar <> 0
        then do:
            if titulo.titsit = "LIB"
            then do:
                parcela-aberta  = parcela-aberta + 1.
                if titulo.titdtven < today
                then do:
                    vencidas = vencidas + titulo.titvlcob.
                    if titulo.titdtven < maior-atraso
                    then maior-atraso = titulo.titdtven.
                end.
            end.
            else parcela-paga = parcela-paga + 1.
        end.

        if titulo.titpar >= 51
        then vrepar = yes.

        if titulo.titpar <> 0 and titulo.titdtpag <> ?
        then do:
            if (titulo.titdtpag - titulo.titdtven) <= 15
            then qtd-15 = qtd-15 + 1.

            if (titulo.titdtpag - titulo.titdtven) >= 16 and
               (titulo.titdtpag - titulo.titdtven) <= 45
            then qtd-45 = qtd-45 + 1.

            if (titulo.titdtpag - titulo.titdtven) >= 46
            then qtd-46 = qtd-46 + 1.
            
            v-media = v-media + titulo.titvlcob.

            find first wacum where wacum.mes = month(titulo.titdtpag) and
                                   wacum.ano = year(titulo.titdtpag) no-error.
            if not avail wacum
            then do:
                create wacum.
                assign wacum.mes = month(titulo.titdtpag)
                       wacum.ano = year(titulo.titdtpag).
            end.
            wacum.acum = wacum.acum + titulo.titvlcob.
        end.

        if titulo.titsit = "LIB"
        then do:
            sal-aberto = sal-aberto + titulo.titvlcob.
            if titulo.titdtven >= vdata1 and
               titulo.titdtven <= vdata2
            then proximo-mes = proximo-mes + titulo.titvlcob.
        end.
        
    end.

    for each wacum by wacum.acum:
        assign v-mes = wacum.mes
               v-ano = wacum.ano
               v-acum = wacum.acum.
        vtotal = vtotal + wacum.acum.
        vqtd   = vqtd + 1.
    end.

    v-media = v-media / (qtd-15 + qtd-45 + qtd-46).

    lim-calculado = (clien.limcrd - sal-aberto).


    disp clien.limcrd label "Limite"
         sal-aberto   label "Saldo Aberto"
         lim-calculado label "Limite Calculado"
            with frame f1 side-label width 80
                    title "L I M I T E" row 6.

    disp ult-compra      label "Ult. Compra"
         qtd-contrato    label "Contratos"
         parcela-paga    label "    Pagas "
         parcela-aberta  label "Abertas"
            with frame f2 side-label width 80
                title "  C O M P R A S              P R E S T A C O E S " row 9.

    disp qtd-15       label "(ate 15 dias)"  COLON 20
         ((qtd-15 * 100) / parcela-paga) format ">>9.99%"
         (vtotal / vqtd) label "Media Mensal" format ">,>>9.99"
         qtd-45       label "(16 ate 45 dias)"  COLON 20
         ((qtd-45 * 100) / parcela-paga) format ">>9.99%"
         v-acum          label "Maior Acum. "
         v-mes        label "Mes/Ano" "/"
         v-ano        no-label
         qtd-46       label "(acima de 45 dias)" COLON 20
         ((qtd-46 * 100) / parcela-paga) format ">>9.99%"
         v-media      label "Prest. Media"
         vrepar       label "Reparcelamento " colon 20
         proximo-mes  label "Proximo Mes " colon 48
            with frame f4 side-label width 80 row 12
         title "A T R A S O               P A R C E L A S                    ".


    disp
         (today - maior-atraso) label "Maior Atraso " colon 21
                format ">>>9 dias"
         vencidas     label "Vencidas    " colon 49
            with frame f5 color white/red side-label no-box width 80.

    /* vdia = (today - maior-atraso). */
end.
