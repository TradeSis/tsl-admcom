/*
    #1 05.08.19 helio.neto - Titulos indevidos VVI
*/    

def input parameter par-clicod like clien.clicod.

def shared temp-table tp-titulo like titulo
    field vliof as dec
    field vlcet as dec
    field vltfc as dec
    index dt-ven titdtven 
    index titnum /*is primary unique*/ empcod  
                                   titnat  
                                   modcod  
                                   etbcod 
                                   clifor 
                                   titnum  
                                   titpar.

/***def temp-table tt-titulo like titulo.***/

/***
     /u/bsweb/progr/ws/p2k/ConsultaCliente.p.
***/
def NEW shared temp-table tp-cheque like cheque.
def NEW shared temp-table tp-historico
        field clicod like clien.clicod
        field sal-aberto like clien.limcrd
        field lim-credito as dec
        field lim-calculado like clien.limcrd format "->>,>>9.99"
        field ult-compra like plani.pladat
        field qtd-contrato as int format ">>>9"
        field parcela-paga as int format ">>>>9"
        field parcela-aberta as int format ">>>>9"
        field qtd-15 as int format ">>>>9"
        field vtotal as dec
        field media-contrato as dec
        field qtd-45  as int format ">>>>9"
        field vqtd as dec
        field v-acum like clien.limcrd
        field v-mes as int format "99"
        field v-ano as int format "9999"
        field qtd-46 as int format ">>>>9"
        field pct-pago2 as dec
        field v-media like clien.limcrd
        field vrepar as log format "Sim/Nao"
        field proximo-mes  as dec
        field maior-atraso as date
        field vencidas like clien.limcrd
        field cheque_devolvido like plani.platot
        field pagas-posicli as int format ">>>>9"
        field sal-abertopr like clien.limcrd.

    for each contrato where contrato.clicod = par-clicod no-lock,
        each titulo where titulo.empcod = 19        and
                           titulo.titnat = no        and
                           titulo.modcod = contrato.modcod and
                           titulo.etbcod = contrato.etbcod and
                           titulo.clifor = contrato.clicod and
                           titulo.titnum = string(contrato.contnum)
                           no-lock:

        if titulo.modcod = "CHQ" or
           titulo.modcod = "DEV" or
           titulo.modcod = "BON" or
           titulo.modcod = "VVI" /*#1*/ or
           length(titulo.titnum) > 11 /* Sujeira de banco */
        then next. /*** ***/

        find first tp-titulo where tp-titulo.empcod = titulo.empcod and
                                   tp-titulo.titnat = titulo.titnat and
                                   tp-titulo.modcod = titulo.modcod and
                                   tp-titulo.etbcod = titulo.etbcod and
                                   tp-titulo.clifor = titulo.clifor and
                                   tp-titulo.titnum = titulo.titnum and
                                   tp-titulo.titpar = titulo.titpar
                                   no-error.
        if not avail tp-titulo
        then do: 
            create tp-titulo.
            buffer-copy titulo to tp-titulo.

            if contrato.vliof > 0
            then tp-titulo.vliof = contrato.vliof / contrato.nro_parcela.
            if contrato.cet > 0
            then tp-titulo.vlcet = contrato.cet / contrato.nro_parcela.
            if contrato.vlseguro > 0 and
               tp-titulo.titdes = 0
            then tp-titulo.titdes = contrato.vlseguro / contrato.nro_parcela.  
            if contrato.vltaxa > 0
            then tp-titulo.vltfc = contrato.vltaxa / contrato.nro_parcela. 
            
        end.

/***
        if titulo.titdtpag <> ? and
                titulo.titsit = "PAG" and
                titulo.titdtpag < today - 60
        then next. 

        if titulo.modcod = "CHQ" then next.
        
        find first tt-titulo where tt-titulo.empcod = titulo.empcod and
                                   tt-titulo.titnat = titulo.titnat and
                                   tt-titulo.modcod = titulo.modcod and
                                   tt-titulo.etbcod = titulo.etbcod and
                                   tt-titulo.clifor = titulo.clifor and
                                   tt-titulo.titnum = titulo.titnum and
                                   tt-titulo.titpar = titulo.titpar
                                   no-error.
        if not avail tt-titulo
        then do:                                        
             create tt-titulo.
             buffer-copy titulo to tt-titulo.
        end.
***/
    end.
        
    run /admcom/progr/hiscliWG.p(par-clicod).

/***
    /usr/admcom/progr/hiscli2.p (filial 189)
***/

def SHARED var pagas-db as int.
def SHARED var maior-atraso as int /***like plani.pladat***/.
def SHARED var vencidas like clien.limcrd.
def SHARED var v-mes as int format "99".
def SHARED var v-ano as int format "9999".
def SHARED var v-acum like clien.limcrd.
def SHARED var qtd-contrato as int format ">>>9".
def SHARED var parcela-paga    as int format ">>>>9".
def SHARED var parcela-aberta  as int format ">>>>9".
def SHARED var qtd-15       as int format ">>>>9".
def SHARED var qtd-45       as int format ">>>>9".
def SHARED var qtd-46       as int format ">>>>9".
def SHARED var vrepar       as log format "Sim/Nao".
def SHARED var v-media      like clien.limcrd.
def SHARED var ult-compra   like plani.pladat.
def SHARED var sal-aberto   like clien.limcrd.
def SHARED var sal-abertopr like clien.limcrd.
def SHARED var lim-calculado like clien.limcrd format "->>,>>9.99".
def SHARED var cheque_devolvido like plani.platot.
def SHARED var vtotal like plani.platot.
def SHARED var vqtd        as int.
def SHARED var proximo-mes like clien.limcrd.

    find first tp-historico where tp-historico.clicod = par-clicod no-error.
    if avail tp-historico
    then assign
            sal-aberto = tp-historico.sal-aberto
            sal-abertopr = tp-historico.sal-abertopr
            lim-calculado = tp-historico.lim-calculado
            ult-compra = tp-historico.ult-compra
            qtd-contrato = tp-historico.qtd-contrato
            parcela-paga = tp-historico.parcela-paga
            pagas-db = tp-historico.parcela-paga
            parcela-aberta = tp-historico.parcela-aberta
            qtd-15 = tp-historico.qtd-15
            vtotal = tp-historico.vtotal
            vqtd   = tp-historico.vqtd
            qtd-45 = tp-historico.qtd-45
            v-acum = tp-historico.v-acum
            v-mes  = tp-historico.v-mes
            v-ano  = tp-historico.v-ano
            qtd-46 = tp-historico.qtd-46
            v-media = tp-historico.v-media
            vrepar  = tp-historico.vrepar
            proximo-mes = tp-historico.proximo-mes
            maior-atraso = today - tp-historico.maior-atraso
            vencidas = tp-historico.vencidas
            cheque_devolvido = tp-historico.cheque_devolvido.
            parcela-paga =  parcela-paga + tp-historico.pagas-posicli. 

    v-media = v-media / (qtd-15 + qtd-45 + qtd-46).

