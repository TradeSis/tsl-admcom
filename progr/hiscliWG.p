def input parameter v-clicod like clien.clicod.

def new global shared var setbcod    like estab.etbcod.

def var i as int.

def shared temp-table tp-titulo like fin.titulo
    field vliof as dec
    field vlcet as dec
    field vltfc as dec
    index dt-ven titdtven
    index titnum empcod
                 titnat 
                 modcod 
                 etbcod 
                 clifor 
                 titnum 
                 titpar.

def shared temp-table tp-cheque like fin.cheque.

def workfile wacum
    field mes  as int format "99"
    field ano  as int format "9999"
    field acum like plani.platot.

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
def var cheque_devolvido like plani.platot.
def var vclicod like clien.clicod.
def var vtotal like plani.platot.
def var vqtd        as int.
def var proximo-mes like clien.limcrd.
def var vdata1      like plani.pladat.
def var vdata2      like plani.pladat.
def var var-salabprinc as dec.

for each wacum:
    delete wacum.
end.

def var vqtdpagcred as int.

/*
run le_link.p(output v-conecta).
*/
qtd-contrato = 0.
ult-compra   = ?.
vtotal = 0.
vqtd = 0.
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

find clien where clien.clicod = v-clicod no-lock no-error.
if avail clien
then do:

    find first fin.titulo where titulo.clifor = clien.clicod  no-lock no-error.

    cheque_devolvido = 0.
    for each tp-cheque where tp-cheque.chesit = "LIB":
        cheque_devolvido = cheque_devolvido + tp-cheque.cheval.
    end.    
    
    qtd-contrato = 0.
    for each tp-titulo where tp-titulo.modcod <> "CHQ" 
                         and tp-titulo.modcod <> "DEV"
                         and tp-titulo.modcod <> "BON"
                       break by tp-titulo.titnum
                             by tp-titulo.titdtemi:
    
        if last-of(tp-titulo.titnum)
        then qtd-contrato = qtd-contrato + 1.
            
        assign ult-compra   = if ult-compra = ?
                              then  tp-titulo.titdtemi
                              else max(ult-compra,tp-titulo.titdtemi).
    end.
    parcela-aberta = 0.
    sal-aberto     = 0.
    vencidas = 0.
    var-salabprinc = 0.
    
    def var n-disponivel as char init "".
    run /admcom/progr/le_tabini.p(input setbcod,
                                  input 0,
                                  input "NOVO-LIMITE-DISPONIVEL",
                                  output n-disponivel).

    for each tp-titulo where tp-titulo.modcod <> "CHQ"
                         and tp-titulo.modcod <> "DEV"
                         and tp-titulo.modcod <> "BON"
                             break by tp-titulo.titnum.
        if tp-titulo.titpar <> 0
        then do:
            if tp-titulo.titsit = "LIB"
            then do:
                parcela-aberta  = parcela-aberta + 1.
    
                if tp-titulo.titdtven < today
                then do:
                    vencidas = vencidas + tp-titulo.titvlcob.
    
                    if tp-titulo.titdtven < maior-atraso
                    then maior-atraso = tp-titulo.titdtven.
                end.
            end.
            else  parcela-paga = parcela-paga + 1.
        end.    

        if tp-titulo.titpar > 30 
        then vrepar = yes.
         
        if tp-titulo.titpar <> 0 and tp-titulo.titdtpag <> ?
        then do:
            
            if (tp-titulo.titdtpag - tp-titulo.titdtven) <= 15
            then qtd-15 = qtd-15 + 1.
            
            if (tp-titulo.titdtpag - tp-titulo.titdtven) >= 16 and
               (tp-titulo.titdtpag - tp-titulo.titdtven) <= 45
            then qtd-45 = qtd-45 + 1.
            
            if (tp-titulo.titdtpag - tp-titulo.titdtven) >= 46
            then qtd-46 = qtd-46 + 1.

            v-media = v-media + tp-titulo.titvlcob.

            find first wacum where wacum.mes = month(tp-titulo.titdtpag) and
                                   wacum.ano = year(tp-titulo.titdtpag) 
                         no-error.
            if not avail wacum
            then do:
                create wacum.
                assign wacum.mes = month(tp-titulo.titdtpag)
                       wacum.ano = year(tp-titulo.titdtpag).
            end.
            wacum.acum = wacum.acum + tp-titulo.titvlcob.
        end.

        if tp-titulo.titsit = "LIB"
        then do:
            sal-aberto = sal-aberto + tp-titulo.titvlcob.
            if n-disponivel = "SIM" and tp-titulo.vlf_principal > 0
            then do:
                var-salabprinc = 
                        var-salabprinc + tp-titulo.vlf_principal.
                /*if tp-titulo.modcod begins "CP"
                then*/ var-salabprinc = var-salabprinc - 
                        (tp-titulo.titdes + 
                         tp-titulo.vltfc +
                         tp-titulo.vliof).

            end.
            else var-salabprinc = var-salabprinc + tp-titulo.titvlcob.

            if tp-titulo.titdtven >= vdata1 and
               tp-titulo.titdtven <= vdata2
            then proximo-mes = proximo-mes + tp-titulo.titvlcob.
        end.
    end.

    for each wacum by wacum.acum:
        assign v-mes = wacum.mes
               v-ano = wacum.ano
               v-acum = wacum.acum.
        vtotal = vtotal + wacum.acum.
        vqtd   = vqtd + 1.
    end.

    /*lim-calculado = (clien.limcrd - sal-aberto).
    */
    lim-calculado = (clien.limcrd - var-salabprinc).

    /*******************SOMA CREDSCOR******************/
    vqtdpagcred = 0.
    find first credscor where credscor.clicod = clien.clicod no-lock no-error.
    if avail credscor
    then do:
    
        if credscor.dtultc > ult-compra
        then ult-compra = credscor.dtultc.
        
        qtd-contrato = qtd-contrato + credscor.numcon.
        parcela-paga = parcela-paga + credscor.numpcp.
        vqtdpagcred = credscor.numpcp.
        qtd-15 = qtd-15 + credscor.numa15.
        qtd-45 = qtd-45 + credscor.numa16.
        qtd-46 = qtd-46 + credscor.numa45.
        vtotal = (vala15 + vala16 + vala45).
        vqtd = credscor.numcon.
        if credscor.valacu > v-acum
        then do:
            v-mes = credscor.mesacu.
            v-ano = credscor.anoacu.
            v-acum = credscor.valacu.
        end.    
    
        v-media = v-media + (vala15 + vala16 + vala45).
    
    end.    
    
    v-media = v-media / (qtd-15 + qtd-45 + qtd-46).

    def shared temp-table tp-historico
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

    create tp-historico.
    assign   
        tp-historico.clicod           = v-clicod
        tp-historico.sal-aberto       = sal-aberto
        tp-historico.lim-credito      = lim-credito
        tp-historico.lim-calculado    = lim-calculado
        tp-historico.ult-compra       = ult-compra
        tp-historico.qtd-contrato     = qtd-contrato
        tp-historico.parcela-paga     = parcela-paga
        tp-historico.parcela-aberta   = parcela-aberta
        tp-historico.qtd-15           = qtd-15
        tp-historico.vtotal           = vtotal
        tp-historico.media-contrato   = (vtotal / vqtd)
        tp-historico.qtd-45           = qtd-45
        tp-historico.vqtd             = vqtd
        tp-historico.v-acum           = v-acum
        tp-historico.v-mes            = v-mes
        tp-historico.v-ano            = v-ano
        tp-historico.qtd-46           = qtd-46
        tp-historico.pct-pago2        = ((qtd-46 * 100) / parcela-paga)
        tp-historico.v-media          = v-media
        tp-historico.vrepar           = vrepar
        tp-historico.proximo-mes      = proximo-mes
        tp-historico.maior-atraso     = maior-atraso
        tp-historico.vencidas         = vencidas
        tp-historico.cheque_devolvido = cheque_devolvido
        tp-historico.sal-abertopr     = var-salabprinc.
    
    find first posicli where
               posi.clicod = v-clicod no-lock no-error.
    if avail posicli
    then assign
            tp-historico.qtd-contrato   = 
                    tp-historico.qtd-contrato + posicli.qtdconpg
            tp-historico.pagas-posicli  = posicli.qtdparpg 
            /*tp-historico.parcela-paga   =  
            tp-historico.parcela-paga + posicli.qtdparpg*/.

    /***
    disp clien.limcrd label "Credito"
         tp-historico.sal-aberto   label "Saldo Aberto"
         tp-historico.lim-calculado label "Credito Calculado"
            with frame f1 side-label width 80
                    title "C R E D I T O" row 6.

    disp tp-historico.ult-compra      label "Ult. Compra"
         tp-historico.qtd-contrato    label "Contratos"
         tp-historico.parcela-paga    label "    Pagas "
         tp-historico.parcela-aberta  label "Abertas"
            with frame f2 side-label width 80
                title "  C O M P R A S              P R E S T A C O E S " row 9.

    disp tp-historico.qtd-15       label "(ate 15 dias)"  COLON 20
         ((tp-historico.qtd-15 * 100) / tp-historico.parcela-paga) format ">>9.99%"
         (tp-historico.vtotal / tp-historico.vqtd) label "Media por Contrato" format ">,>>9.99"
         tp-historico.qtd-45       label "(16 ate 45 dias)"  COLON 20
         ((tp-historico.qtd-45 * 100) / tp-historico.parcela-paga) format ">>9.99%"
         tp-historico.v-acum          label "Maior Acum. "
         tp-historico.v-mes        label "Mes/Ano" "/"
         tp-historico.v-ano        no-label
         tp-historico.qtd-46       label "(acima de 45 dias)" COLON 20
         ((tp-historico.qtd-46 * 100) / tp-historico.parcela-paga) format ">>9.99%"
         tp-historico.v-media      label "Prest. Media"
         tp-historico.vrepar       label "Reparcelamento " colon 20
         tp-historico.proximo-mes  label "Proximo Mes " colon 48
            with frame f4 side-label width 80 row 12
         title "A T R A S O               P A R C E L A S                    ".


    disp
         (today - tp-historico.maior-atraso) label "Maior Atraso " 
                format ">>>9 dias"
         tp-historico.vencidas     label "Vencidas    " colon 40
         tp-historico.cheque_devolvido label "Chq Devolvidos"
            with frame f5 color white/red side-label no-box width 80.
    ***/
    /*
    vdia = (today - tp-historico.maior-atraso).
    */
end.
