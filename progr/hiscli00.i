def workfile wacum
    field mes as int format "99"
    field ano as int format "9999"
    field acum       like plani.platot.

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


    vclicod = p-clicod.
    
    find clien where clien.clicod = vclicod no-lock no-error.
    
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
