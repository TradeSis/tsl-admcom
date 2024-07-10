/* helio 31082023 - ID 34606 - Erro no envio de alteração de limite para o motor 
    * A tabela antiga pode ser descontinuada, validado junto área de credito, aprovado pela Patrica
    */
/* helio 15082023 - 499799 - SEPARAÇÃO DE DATA DE ÚLTIMA COMPRA E DE ÚLTIMA NOVAÇÃO INTEGRAÇÃO PMWEB E 513689 - DATA NOVAÇÃO */
/* helio 10082023 - SEPARAÇÃO DO VALOR DE SERVIÇOS DAS DEMAIS PROPS ENVIADAS AO MOTOR LIBERAÇÃO DE LIMITE - ID 311551 */
/* helio 06062023 Avaliação de regra campo "SALDOLIMITE". */
/* HUBSEG 19/10/2021 */

/*
15042021 helio ID 68725 
#1 30.11.18 - TP 27480628
#2 03.01.19 - TP 28689564
#3 22.01.19 - Helio Neto - Reformulado Leituras e Calculos Conforme hiscliWG.p (TP 28874469 - TRELLO) 
#4 18.03.19 = Helio Neto - Comportamentos novos - FeiraoAberto, DTPROXVCTOABE
#5 25.07.19 - Titulos indevidos VVI
#6 06.08.19 = Novo calculo limite disponivel
*/

def input parameter par-clicod as int.
def input parameter par-contnum as int.
def output parameter var-propriedades as char.

def new global shared var setbcod    like estab.etbcod.

/*#4*/
{/admcom/progr/acha.i}
def var vano as int.
def var vmes as int.
def var vloop as int.
def var v-media as dec.
def var vtotal as dec.
def var vqtd   as int.

def buffer xtitulo for titulo.
def temp-table tp-titulo NO-UNDO like titulo 
    field vliof as dec
    field vlcet as dec
    field vltfc as dec
    index dt-ven titdtven 
    index titnum /*is primary unique*/ 
                                   empcod  
                                   titnat  
                                   modcod  
                                   etbcod 
                                   clifor 
                                   titnum  
                                   titpar.

def var vperc15 as dec decimals 2.
def var vperc45 as dec decimals 2.
def var vperc46 as dec decimals 2.
def var vencidas as dec.

/* #4 */
def var vfeirao-novo as log.
def var vfeirao-antigo as log.
def var var-saldofeiraoaberto   as dec.

/*#4*/

def var var-limite as dec.
def var var-limiteEP as dec.
def var var-salabPrincEP as dec.

def var var-qtdtit     as int.
def var var-salaberto  as dec.
def var var-salabertoEP as dec.
def var var-chdevolv   as char. 
def var var-dtdevolv   as char.
def var var-vldevolv   as char.
def var var-vlrcontrato as dec.
def var var-totcontrato as dec.
def var var-mediacontrato as dec decimals 2.
def var var-mediaprestacao as dec decimals 2.

def var var-SALDOTOTNOV as dec.
def var var-SALDOVENCNOV as dec.
def var var-ATRASONOV as dec.
def var var-QTDENOV as dec.
def var var-sallimite as dec.
def var var-sallimiteEP as dec.
def var var-QTDECONT as int.
def var var-PARCPAG as int.
def var var-PARCPAGdb as int.

def var var-PARCABERT as int.
def var var-DTULTCPA as date.
def var var-DTULTNOV as date.  /* helio 15082023 */

def var var-DTPROXVCTOABE as date. /* #4 */
/**def var var-atrasoparcela as int.**/
/*def var var-totatrasoparc as int.*/
def var var-ATRASOPARC as char.
def var var-ATRASOPARCate15 as int init 0.
def var var-ATRASOPARCate45 as int init 0.
def var var-ATRASOPARCmaior45 as int init 0.
def var var-ATRASOPARCPERC as char.
def var var-ATRASOATUAL as int.
def var var-DTMAIORATRASO as date.
def var var-VLRPARCVENC as dec.
def var var-VLRPAGO as dec.
def var var-PONTUAL as int.
def var var-MAIORATRASO as int.
def var var-DTULTPAGTO as date.
def var var-contrato100 as int.
def var var-contrato350 as int.
def var var-contrato800 as int.
def var var-contrato1500 as int.
def var var-contratomaior as int.
def var var-maioracum as dec.
def var var-dtmaioracum as char.
def var var-maiorcont as dec.
def var var-lstcompromet as char.
def var var-vi-lstcompromet as int.
def var var-totalnov as dec.
def var vetblimdisp as int.
def var var-salabprinc as dec.
def var var-salabHUBSEG as dec.

def var var-COMPROMETIMENTO_MENSAL as dec init 0.

/**def var var-contrato_aberto  as log.**/
def var var-contrato_novacao     as log.

def temp-table tt-mes no-undo
    field TIPOOPER  as char
    field ano   as int
    field mes   as int
    field titvlcob  like titulo.titvlcob
    index anomes is unique primary TIPOOPER asc ano asc mes asc.

    var-qtdtit    = 0.
    var-salaberto = 0.        
    var-salabertoEP = 0.
    var-saldofeiraoaberto = 0. 
    vtotal = 0.
    vqtd   = 0.
    
var-propriedades =   
    "QTDPARC="      + string(var-qtdtit)

    + "#CHDEVOLV="      + var-chdevolv
    + "#DTCHDEVOL="     + var-dtdevolv 
    + "#VALORCHDEVOLV=" + var-vldevolv
    + "#SALDOTOTNOV="   + string(var-SALDOTOTNOV)
    + "#SALDOVENCNOV="  + string(var-SALDOVENCNOV)
    + "#ATRASONOV="     + string(var-ATRASONOV)
    + "#QTDENOV="       + string(var-QTDENOV)

/*    pega_prop("DTCADASTRO")     vsep */
    + "#LIMITE="       + trim(string(var-limite,"->>>>>>>>>9.99"))
    + "#LIMITETOM="    + trim(string(var-salaberto,"->>>>>>>>>9.99"))
    + "#LIMITETOMPR="  + trim(string(ROUND(var-salabprinc, 2),"->>>>>>>>>9.99"))
    + "#LIMITEDISP="   + trim(string(var-sallimite,"->>>>>>>>>9.99"))

    + "#LIMITEEP="     + trim(string(var-limiteEP,"->>>>>>>>>9.99")) /* helio 14042021 - a pedido aline - chamado 68725 */
    + "#LIMITETOMEP="  + trim(string(var-salabertoEP,"->>>>>>>>>9.99"))
    + "#LIMITETOMPREP="  + trim(string(var-salabPrincEP,"->>>>>>>>>9.99"))
    + "#LIMITEDISPEP=" + trim(string(var-sallimiteEP,"->>>>>>>>>9.99"))
    + "#LIMITETOMHUBSEG="  + trim(string(ROUND(var-salabhubseg, 2),"->>>>>>>>>9.99"))
    
    + "#QTDECONT="   + string(var-QTDECONT)
    + "#PARCPAG="    + string(var-PARCPAG)
    + "#PARCABERT="  + string(var-PARCABERT)
    + "#DTULTCPA="   + (if var-DTULTCPA = ? 
                             then "" 
                             else string(var-dtultcpa,"99/99/9999"))
    + "#DTULTNOV="   + (if var-DTULTNOV = ? 
                             then "" 
                             else string(var-dtultnov,"99/99/9999"))
                             
    + "#ATRASOPARC="   + var-ATRASOPARC
    + "#ATRASOPARCPERC=" + var-ATRASOPARCPERC
    + "#MEDIACONT="    + string(var-mediacontrato)
    + "#MAIORACUM="    + string(var-maioracum)
    + "#DTMAIORACUM="  + var-dtmaioracum
    + "#PARCMEDIA="    + string(var-mediaprestacao)
    + "#ATRASOATUAL="  + string(var-ATRASOATUAL)
    + "#DTMAIORATRASO=" + (if var-DTMAIORATRASO = ?
                                  then ""
                                  else string(var-DTMAIORATRASO))
    + "#VLRPARCVENC="  + string(var-VLRPARCVENC)
    + "#VLRPAGO="    + string(var-VLRPAGO)
    + "#PONTUAL="    + string(var-PONTUAL)
/*
    pega_prop("ATRASOMEDIO")     vsep    
**/
    
    + "#MAIORATRASO="    + string(var-MAIORATRASO)
/**    
    pega_prop("DTNASCCLI")     vsep  
**/
/**
    pega_prop("JUROVENDA")     vsep  
    pega_prop("JUROATRASO")     vsep 
**/
    
    + "#CONTRATO100="   + string(var-contrato100)
    + "#CONTRATO350="   + string(var-contrato350)
    + "#CONTRATO800="   + string(var-contrato800)
    + "#CONTRATO1500="  + string(var-contrato1500)
    + "#CONTMAIOR1500=" + string(var-contratomaior)
/**    
    pega_prop("PROFISSAO")     vsep  
    pega_prop("RENDAMES")     vsep   
    pega_prop("LOGRADCLI")     vsep  
    pega_prop("NUMERO")     vsep 
    pega_prop("CEP")     vsep    
    pega_prop("BAIRROCLI")     vsep  
    pega_prop("CIDADE")     vsep 
    pega_prop("UF")     vsep 
    pega_prop("NOTA")     vsep   
**/
/**    
    pega_prop("ATRASO4MESES")     vsep   
**/

    + "#DTULTPAGTO="   +   if var-dtultpagto = ?
                                then ""
                                else string(var-DTULTPAGTO)
    + "#MAIORCONT="    + string(var-maiorcont)
    + "#LSTCOMPROMET=" + string(var-lstcompromet)
    + "#TOTALNOV="     + string(var-totalnov)
    + "#SALDOFEIRAOABERTO="     + string(var-SALDOFEIRAOABERTO) /* #4 */
    + "#DTPROXVCTOABE="   +   if var-DTPROXVCTOABE = ?
                                then ""
                                else string(var-DTPROXVCTOABE)
    + "#COMPROMETIMENTO_MENSAL=" + string(var-COMPROMETIMENTO_MENSAL) /* helio 11042022 - ajuste painel de credito */       
    + "#FIM=".
    
    find first neuclien where neuclien.clicod = par-clicod no-lock no-error.
    if not avail neuclien
    then next.

    var-parcpag = 0.
    var-parcpagdb = 0.
    vetblimdisp = ?.
/**    def var n-disponivel as char init "NAO". helio 15042021 - ID 68725 - Aline - Todas as lojas */
    /*for each xtitulo use-index iclicod where 
             xtitulo.empcod = 19        and
             xtitulo.titnat = no        and
             xtitulo.clifor = par-clicod no-lock:
    */
    for each contrato where contrato.clicod = par-clicod no-lock,
        each xtitulo where xtitulo.empcod = 19        and
                           xtitulo.titnat = no        and
                           xtitulo.modcod = contrato.modcod and
                           xtitulo.etbcod = contrato.etbcod and
                           xtitulo.clifor = contrato.clicod and
                           xtitulo.titnum = string(contrato.contnum)
                           no-lock:
        
        if xtitulo.modcod = "CHQ" or
           xtitulo.modcod = "DEV" or
           xtitulo.modcod = "BON" or
           xtitulo.modcod = "VVI" or   /* #5 Sujeira de banco */
           length(xtitulo.titnum) > 11 /* Sujeira de banco */
        then next. /*** ***/

        find first tp-titulo where tp-titulo.empcod = xtitulo.empcod and
                                   tp-titulo.titnat = xtitulo.titnat and
                                   tp-titulo.modcod = xtitulo.modcod and
                                   tp-titulo.etbcod = xtitulo.etbcod and
                                   tp-titulo.clifor = xtitulo.clifor and
                                   tp-titulo.titnum = xtitulo.titnum and
                                   tp-titulo.titpar = xtitulo.titpar
                                   no-error.
        if not avail tp-titulo
        then do: 
            create tp-titulo.
            buffer-copy xtitulo to tp-titulo.


            /** ID 68725 
            if setbcod = 999 and n-disponivel = "NAO"
            then do:
                run /admcom/progr/le_tabini.p(0,
                            input 0,
                            input "NOVO-LIMITE-DISPONIVEL",
                            output n-disponivel).
                if vetblimdisp <> tp-titulo.etbcod and
                      n-disponivel = "NAO"
                then do: 
                    vetblimdisp = tp-titulo.etbcod.
                    run /admcom/progr/le_tabini.p(input vetblimdisp,
                                      input 0,
                                      input "NOVO-LIMITE-DISPONIVEL",
                                      output n-disponivel).
                end.
            end.
            **/
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
    end.

    
/* helio 31082023 - RETIRADO    
* /* 10.11.2017, descoberto que ADMCOM tem tabelas para somar coisas velhas */     
*    find first credscor where 
*               credscor.clicod = neuclien.clicod no-lock no-error.
*        if avail credscor
*        then do:
*            var-dtultcpa = credscor.dtultc.
*        
*            var-qtdecont = credscor.numcon.
*            var-parcpagdb  = credscor.numpcp.
*            var-qtdtit   = credscor.numpcp.
*            var-ATRASOPARCate15 = credscor.numa15.
*            var-ATRASOPARCate45 = credscor.numa16.
*            var-ATRASOPARCmaior45 = credscor.numa45.
*            var-vlrcontrato = (credscor.vala15 + credscor.vala16 + 
*                                        credscor.vala45).
*    
*            vtotal = (vala15 + vala16 + vala45). 
*            vqtd = credscor.numcon.
*
*            v-media = (vala15 + vala16 + vala45).
*                            
*        end.     
*
*        find first posicli  where posicli.clicod  = neuclien.clicod no-lock no-error.
*        if avail posicli
*        then do:
*            var-qtdecont = var-qtdecont + posicli.qtdconpg.
*            var-parcpag  = var-parcpag  + posicli.qtdparpg.
*            /*
*            var-qtdtit   = var-qtdtit   + posicli.qtdparpg.
*            */
*        end.
*
**/
        /* #3 Calcula Percentuais */

        var-vlrcontrato = 0.
        var-maiorcont   = 0.
        var-MAIORATRASO = 0.
        var-atrasoatual = 0.
        var-atrasonov   = 0.
            var-contrato_novacao = no. 
            
        /** ID 68725 
        if setbcod <> 999
        then do:
            n-disponivel = "NAO".
            run /admcom/progr/le_tabini.p(input setbcod,
                                      input 0,
                                      input "NOVO-LIMITE-DISPONIVEL",
                                      output n-disponivel).
        end.
        **/

        for each tp-titulo where tp-titulo.modcod <> "CHQ" 
                         and tp-titulo.modcod <> "DEV"
                         and tp-titulo.modcod <> "BON"
                       break by tp-titulo.titnum
                             by tp-titulo.titdtemi:

            /* helio 10082023 - SEPARAÇÃO DO VALOR DE SERVIÇOS DAS DEMAIS PROPS ENVIADAS AO MOTOR LIBERAÇÃO DE LIMITE - ID 311551 */
            if tp-titulo.vlf_hubseg > 0     
            then do:
                next.
            end.

            var-qtdtit =  var-qtdtit + 1.        
            var-vlrcontrato = var-vlrcontrato + tp-titulo.titvlcob.
            

            
            if tp-titulo.titpar <> 0
            then do:    
                if tp-titulo.tpcontrato = "N"
                then do:
                    var-contrato_novacao = yes. 
                    var-totalnov = var-totalnov + tp-titulo.titvlcob.
                    /*  helio 15082023 */
                    if tp-titulo.modcod <> "RFN" /* helio 05062024 - refin rfn */
                    then assign var-DTULTNOV = if var-DTULTNOV = ?
                                      then tp-titulo.titdtemi
                                      else max(var-DTULTNOV,tp-titulo.titdtemi).
                end.       
                else do: /* normal */
                    assign var-DTULTCPA = if var-DTULTCPA = ?
                                          then tp-titulo.titdtemi
                                          else max(var-DTULTCPA,tp-titulo.titdtemi).
                end.
            
                if tp-titulo.titsit = "LIB"
                then do:
                    /*#4*/    
                    vfeirao-antigo = acha("FEIRAO-NOME-LIMPO",tp-titulo.titobs[1]) = "SIM".
                    vfeirao-novo   = acha("FEIRAO-NOVO"      ,tp-titulo.titobs[1]) = "SIM". 
                    if vfeirao-antigo or
                       vfeirao-novo
                    then do:
                        var-saldofeiraoaberto = var-saldofeiraoaberto + tp-titulo.titvlcob.
                    end.      
                    /*#4*/
                
                    if var-contrato_novacao
                    then do:
                        if tp-titulo.modcod <> "RFN"
                        then var-saldototnov = var-saldototnov + tp-titulo.titvlcob.
                        if tp-titulo.titdtven < today
                        then do:
                            var-saldovencnov = var-saldovencnov + 
                                    tp-titulo.titvlcob.
                            var-ATRASONOV = 
                            max(var-ATRASONOV,today - tp-titulo.titdtven).
                        end.    
                    end.
                    
                    var-PARCABERT = var-PARCABERT + 1.
                    
                    var-salaberto = var-salaberto + tp-titulo.titvlcob.

                    if tp-titulo.modcod begins "CP"
                    then var-salabertoEP = var-salabertoEP + tp-titulo.titvlcob.

                        
                    if tp-titulo.vlf_hubseg > 0     
                    then do:
                        var-salabhubseg =  var-salabhubseg + tp-titulo.vlf_hubseg.
                    end.
                
                    /*#6*/
                    if /** ID 68725 n-disponivel = "SIM" and **/ tp-titulo.vlf_principal > 0
                    then do:
                        var-salabprinc =  var-salabprinc + tp-titulo.vlf_principal.
                        if tp-titulo.titdtemi < 04/20/2021         /* versao anterior a mudanca na integracao */
                        then var-salabprinc =  var-salabprinc - tp-titulo.titdes . /* retira o seguro */
                        
                        if tp-titulo.modcod begins "CP"
                        then do:
                            var-salabprincEP =  var-salabprincEP + tp-titulo.vlf_principal.
                            if tp-titulo.titdtemi < 04/20/2021         /* versao anterior a mudanca na integracao */
                            then var-salabprincEP =  var-salabprincEP - tp-titulo.titdes . /* retira o seguro */
                        end.        
                          
                                  
                    end.
                    else do:
                        var-salabprinc   = var-salabprinc   + tp-titulo.titvlcob.
                        if tp-titulo.modcod begins "CP"
                        then var-salabprincEP = var-salabprincEP + tp-titulo.titvlcob.

                    end.    

                    if tp-titulo.titdtven < today
                    then do: 
                        /*vencidas*/
                        var-VLRPARCVENC = var-VLRPARCVENC + tp-titulo.titvlcob.
                        if tp-titulo.titdtven < var-DTMAIORATRASO or
                           var-DTMAIORATRASO = ?
                        then var-DTMAIORATRASO = tp-titulo.titdtven.
                        /*if tp-titulo.titdtven = var-DTMAIORATRASO 
                        *then var-VLRPARCVENC = tp-titulo.titvlcob.            
                         */
                                                 var-ATRASOATUAL = today - var-dtmaioratraso. 
                    end.         
                    else do: /* #4*/
                        if var-DTPROXVCTOABE = ?
                        then var-DTPROXVCTOABE = tp-titulo.titdtven.
                        var-DTPROXVCTOABE =  min(var-DTPROXVCTOABE,tp-titulo.titdtven).
                        
                        vano = year(today).
                        vmes = month(today).
                        if vmes = 12
                        then do:
                            vmes = 01.
                            vano = vano + 1.
                        end.
                        else do:
                            vmes = vmes + 1.
                        end.
                            
                        if year(tp-titulo.titdtven)  = vano and
                           month(tp-titulo.titdtven) = vmes
                        then do:
                            var-COMPROMETIMENTO_MENSAL = var-COMPROMETIMENTO_MENSAL + tp-titulo.titvlcob.                       
                        end.
                        
                        
                    end. /* #4 */
                    find first tt-mes where
                        tt-mes.TIPOOPER = "ABERTO" and
                        tt-mes.ano = year(tp-titulo.titdtven) and
                        tt-mes.mes = month(tp-titulo.titdtven)
                        no-error.
                    if not avail tt-mes
                    then do:
                        create tt-mes.
                        tt-mes.TIPOOPER = "ABERTO".
                        tt-mes.ano = year(tp-titulo.titdtven).
                        tt-mes.mes = month(tp-titulo.titdtven).
                    end.
                    tt-mes.titvlcob = tt-mes.titvlcob + tp-titulo.titvlcob.
                    
                end.
                else do: 
                    var-parcpagdb = var-parcpagdb + 1. 
                    var-DTULTPAGTO = if var-dtultpagto = ?
                                     then tp-titulo.titdtpag   
                                     else max(var-DTULTPAGTO,tp-titulo.titdtpag).
                   
                    if tp-titulo.titdtpag > tp-titulo.titdtven
                    then do:
                        var-MAIORATRASO = max(var-MAIORATRASO,
                                      tp-titulo.titdtpag - tp-titulo.titdtven).
                    end.                
                    if tp-titulo.titvlpag = ? then tp-titulo.titvlpag = 0.
                    if tp-titulo.titjuro  = ? then tp-titulo.titjuro  = 0.
                    
                    var-VLRPAGO = var-VLRPAGO + (tp-titulo.titvlpag - tp-titulo.titjuro).
                    if  tp-titulo.titdtpag <= tp-titulo.titdtven or
                        (year(tp-titulo.titdtpag)   = year(tp-titulo.titdtven) and
                        month(tp-titulo.titdtpag)  = month(tp-titulo.titdtven))
                    then var-PONTUAL = var-PONTUAL + 1.    
                    
                end.  
            end. 
            if tp-titulo.titpar <> 0 and tp-titulo.titdtpag <> ? 
            then do:  
                if (tp-titulo.titdtpag - tp-titulo.titdtven) <= 15 
                then var-ATRASOPARCate15 = var-ATRASOPARCate15 + 1.  
                if (tp-titulo.titdtpag - tp-titulo.titdtven) >= 16 and 
                    (tp-titulo.titdtpag - tp-titulo.titdtven) <= 45 
                then var-ATRASOPARCate45 = var-ATRASOPARCate45 + 1.  
                if (tp-titulo.titdtpag - tp-titulo.titdtven) >= 46 
                then var-ATRASOPARCmaior45 = var-ATRASOPARCmaior45 + 1.

                find first tt-mes where
                    tt-mes.TIPOOPER = "PAGAMENTO" and
                    tt-mes.ano = year(tp-titulo.titdtpag) and
                    tt-mes.mes = month(tp-titulo.titdtpag)
                    no-error.
                if not avail tt-mes
                then do:
                    create tt-mes.
                    tt-mes.TIPOOPER = "PAGAMENTO".
                    tt-mes.ano = year(tp-titulo.titdtpag).
                    tt-mes.mes = month(tp-titulo.titdtpag).
                end.
                tt-mes.titvlcob = tt-mes.titvlcob + tp-titulo.titvlcob.
                
            end.

            var-totcontrato = var-totcontrato + tp-titulo.titvlcob.

            if last-of(tp-titulo.titnum)
            then do:
                var-qtdecont = var-qtdecont + 1.
                if var-contrato_novacao and
                   tp-titulo.modcod <> "RFN" /* helio 05062024 - refin rfn */
                then var-qtdenov = var-qtdenov + 1. 
                var-maiorcont = max(var-maiorcont,var-vlrcontrato).
                if var-vlrcontrato < 100
                then var-contrato100 = var-contrato100 + 1.
                else if var-vlrcontrato < 350
                     then var-contrato350 = var-contrato350 + 1.
                     else if var-vlrcontrato < 800
                          then var-contrato800 = var-contrato800 + 1.
                          else if var-vlrcontrato < 1500
                               then var-contrato1500 = var-contrato1500 + 1.
                               else var-contratomaior = var-contratomaior + 1. 

                var-vlrcontrato = 0.
                var-contrato_novacao = no.
            end.    
            

            find first tt-mes where
                tt-mes.TIPOOPER = "GERAL" and
                tt-mes.ano = year(tp-titulo.titdtven) and
                tt-mes.mes = month(tp-titulo.titdtven)
                no-error.
            if not avail tt-mes
            then do:
                create tt-mes.
                tt-mes.TIPOOPER = "GERAL".
                tt-mes.ano = year(tp-titulo.titdtven).
                tt-mes.mes = month(tp-titulo.titdtven).
            end.
            tt-mes.titvlcob = tt-mes.titvlcob + tp-titulo.titvlcob.
        end.

        var-parcpag = var-parcpag + var-parcpagdb.
        vperc15 = var-ATRASOPARCate15   * 100 / var-parcpagdb.    
        vperc45 = var-ATRASOPARCate45   * 100 / var-parcpagdb.    
        vperc46 = var-ATRASOPARCmaior45 * 100 / var-parcpagdb.    
    
        if var-ATRASOPARCate15 = ? then var-ATRASOPARCate15 = 0.
        if var-ATRASOPARCate45 = ? then var-ATRASOPARCate45 = 0.
        if var-ATRASOPARCmaior45 = ? then var-ATRASOPARCmaior45 = 0.
    
    var-atrasoparc = string(var-ATRASOPARCate15) + "|"  +
                     string(var-ATRASOPARCate45) + "|"  +
                     string(var-ATRASOPARCmaior45).
    
    var-ATRASOPARCPERC = 
            (if vperc15 <> ?
             then trim(string(vperc15,">>99.99")) + "%|"  
             else "0" + "%|"
             )
            +
            (if vperc45 <> ?
             then 
                trim(string(vperc45,">>99.99")) + "%|"  
             else "0" + "%|"
                     )
            + 
            (if vperc46 <> ?
             then             
             trim(string(vperc46,">>99.99")) + "%"
             else  "0" + "%|") .

    var-limite     = if avail neuclien and 
                        neuclien.vctolimite >= today and
                        neuclien.vctolimite <> ? 
                     then neuclien.vlrlimite
                     else 0.
    var-limiteEP = 0.
    var-salabprinc = round(var-salabprinc,2).
    var-salabhubseg = round(var-salabhubseg,2).
    
    var-sallimite = var-limite - (var-salabprinc - var-salabhubseg) . /* helio 06062023 */
    if var-sallimite < 0 then var-sallimite = 0.
    var-sallimiteEP = 0.
    
        find first profin where profin.situacao no-lock no-error.
        if avail profin
        then do:
             find first profinparam where profinparam.fincod = profin.fincod
                                 and profinparam.etbcod  = 0
                                 and profinparam.dtinicial <= today
                                 and (profinparam.dtfinal = ? or
                                      profinparam.dtfinal >= today)
                              no-lock no-error.
            if avail profinparam
            then do:
                var-limiteEP = (var-sallimite + var-salabprincEP) * (profinparam.perclimite / 100).
                var-limiteEP = if var-limiteEP > profinparam.vlmaximo
                               then profinparam.vlmaximo
                               else var-limiteEP.
                var-sallimiteEP = var-limiteEP - /* 12/05/2021 mudou  var-salabprinc -> */ var-salabprincEP.
                if var-sallimiteEP < 0  then var-sallimiteEP = 0.
            end.
        end.    

    var-dtdevolv = "".
    var-vldevolv = "".    
    for each cheque use-index clien
                        where cheque.clicod = neuclien.clicod and
                              cheque.chesit = "LIB"
            no-lock.                              
        var-dtdevolv = (if var-dtdevolv = "" then "" else " | ")
                        + string(cheque.cheven,"99/99/9999") .           
        var-vldevolv = (if var-vldevolv = "" then "" else " | ")
                        + string(cheque.cheval) .           
    end.                            

    var-maioracum = 0.
    var-dtmaioracum = "".
    for each tt-mes
        where tt-mes.TIPOOPER = "PAGAMENTO"
        break by tt-mes.titvlcob desc.
        if first(tt-mes.titvlcob)
        then do:
            var-maioracum   = tt-mes.titvlcob.
            var-dtmaioracum = string(tt-mes.mes,"99") + "/" +
                              string(tt-mes.ano,"9999").
        end.
        vtotal = vtotal + tt-mes.titvlcob.
        v-media = v-media + tt-mes.titvlcob.
        vqtd   = vqtd   + 1.        
    end.     
    
    var-mediacontrato  = vtotal / vqtd. 
    if var-mediacontrato = ? then var-mediacontrato = 0.

    var-mediaprestacao = v-media / (var-ATRASOPARCate15 +
                                    var-ATRASOPARCate45 +
                                    var-ATRASOPARCmaior45).
    if var-mediaprestacao = ? then var-mediaprestacao = 0.

     
    var-lstcompromet = "".
    var-vi-lstcompromet = 0. 
    
    
    vano = year(today).
    vmes = month(today).
    do vloop = 1 to 4. 
        find first tt-mes where 
                tt-mes.TIPOOPER = "ABERTO" and
                tt-mes.ano      = vano     and
                tt-mes.mes      = vmes
            no-error.
        if not avail tt-mes
        then do:
            create tt-mes.
            tt-mes.TIPOOPER = "ABERTO".
            tt-mes.ano      = vano.
            tt-mes.mes      = vmes.
            tt-mes.titvlcob = 0.
        end.
        vmes = vmes + 1.
        if vmes > 12
        then do:
            vmes = 1.
            vano = vano + 1.
        end.
    end.
    
    for each tt-mes
        where tt-mes.TIPOOPER = "ABERTO"
        break by tt-mes.ano by tt-mes.mes.
        if tt-mes.ano = year(today) and
           tt-mes.mes = month(today)
        then do:
            var-vi-lstcompromet = 1.
            var-lstcompromet = trim(string(tt-mes.titvlcob,">>>>>>>99.99")).
            next.
        end.
        if var-vi-lstcompromet >= 1 and
           var-vi-lstcompromet <= 3
        then do:
            var-lstcompromet = var-lstcompromet + "|" +
                trim(string(tt-mes.titvlcob,">>>>>>>>9.99")).
            var-vi-lstcompromet = var-vi-lstcompromet + 1.
        end.      
        /*
        if var-vi-lstcompromet >= 4
        then leave.
        */
    end.    
    
var-chdevolv = if var-dtdevolv = "" then "N" else "S".
var-propriedades =   
    "QTDPARC="      + string(var-qtdtit)

    + "#CHDEVOLV="      + var-chdevolv
    + "#DTCHDEVOL="     + var-dtdevolv 
    + "#VALORCHDEVOLV=" + var-vldevolv
    + "#SALDOTOTNOV="   + string(var-SALDOTOTNOV)
    + "#SALDOVENCNOV="  + string(var-SALDOVENCNOV)
    + "#ATRASONOV="     + string(var-ATRASONOV)
    + "#QTDENOV="       + string(var-QTDENOV)

/*    pega_prop("DTCADASTRO")     vsep */
    + "#LIMITE="       + trim(string(var-limite,"->>>>>>>>>9.99"))
    + "#LIMITETOM="    + trim(string(var-salaberto,"->>>>>>>>>9.99"))
    + "#LIMITETOMPR="  + trim(string(ROUND(var-salabprinc, 2),"->>>>>>>>>9.99"))
    + "#LIMITEDISP="   + trim(string(var-sallimite,"->>>>>>>>>9.99"))

    + "#LIMITEEP="     + trim(string(var-limiteEP,"->>>>>>>>>9.99")) /* helio 14042021 - a pedido aline - chamado 68725 */
    + "#LIMITETOMEP="  + trim(string(var-salabertoEP,"->>>>>>>>>9.99"))
    + "#LIMITETOMPREP="  + trim(string(var-salabPrincEP,"->>>>>>>>>9.99"))
    + "#LIMITEDISPEP=" + trim(string(var-sallimiteEP,"->>>>>>>>>9.99"))
    + "#LIMITETOMHUBSEG="  + trim(string(ROUND(var-salabhubseg, 2),"->>>>>>>>>9.99"))
    
    + "#QTDECONT="   + string(var-QTDECONT)
    + "#PARCPAG="    + string(var-PARCPAG)
    + "#PARCABERT="  + string(var-PARCABERT)
    + "#DTULTCPA="   + (if var-DTULTCPA = ? 
                             then "" 
                             else string(var-dtultcpa,"99/99/9999"))
    + "#DTULTNOV="   + (if var-DTULTNOV = ? 
                             then "" 
                             else string(var-dtultnov,"99/99/9999"))
                             
    + "#ATRASOPARC="   + var-ATRASOPARC
    + "#ATRASOPARCPERC=" + var-ATRASOPARCPERC
    + "#MEDIACONT="    + string(var-mediacontrato)
    + "#MAIORACUM="    + string(var-maioracum)
    + "#DTMAIORACUM="  + var-dtmaioracum
    + "#PARCMEDIA="    + string(var-mediaprestacao)
    + "#ATRASOATUAL="  + string(var-ATRASOATUAL)
    + "#DTMAIORATRASO=" + (if var-DTMAIORATRASO = ?
                                  then ""
                                  else string(var-DTMAIORATRASO))
    + "#VLRPARCVENC="  + string(var-VLRPARCVENC)
    + "#VLRPAGO="    + string(var-VLRPAGO)
    + "#PONTUAL="    + string(var-PONTUAL)
/*
    pega_prop("ATRASOMEDIO")     vsep    
**/
    
    + "#MAIORATRASO="    + string(var-MAIORATRASO)
/**    
    pega_prop("DTNASCCLI")     vsep  
**/
/**
    pega_prop("JUROVENDA")     vsep  
    pega_prop("JUROATRASO")     vsep 
**/
    
    + "#CONTRATO100="   + string(var-contrato100)
    + "#CONTRATO350="   + string(var-contrato350)
    + "#CONTRATO800="   + string(var-contrato800)
    + "#CONTRATO1500="  + string(var-contrato1500)
    + "#CONTMAIOR1500=" + string(var-contratomaior)
/**    
    pega_prop("PROFISSAO")     vsep  
    pega_prop("RENDAMES")     vsep   
    pega_prop("LOGRADCLI")     vsep  
    pega_prop("NUMERO")     vsep 
    pega_prop("CEP")     vsep    
    pega_prop("BAIRROCLI")     vsep  
    pega_prop("CIDADE")     vsep 
    pega_prop("UF")     vsep 
    pega_prop("NOTA")     vsep   
**/
/**    
    pega_prop("ATRASO4MESES")     vsep   
**/

    + "#DTULTPAGTO="   +   if var-dtultpagto = ?
                                then ""
                                else string(var-DTULTPAGTO)
    + "#MAIORCONT="    + string(var-maiorcont)
    + "#LSTCOMPROMET=" + string(var-lstcompromet)
    + "#TOTALNOV="     + string(var-totalnov)
    + "#SALDOFEIRAOABERTO="     + string(var-SALDOFEIRAOABERTO) /* #4 */
    + "#DTPROXVCTOABE="   +   if var-DTPROXVCTOABE = ?
                                then ""
                                else string(var-DTPROXVCTOABE)
    + "#COMPROMETIMENTO_MENSAL=" + trim(string(var-COMPROMETIMENTO_MENSAL,"->>>>>>>>>>>>>>>>>>>>>>>>>>9.99")) /* helio 11042022 - ajuste painel de credito */       
    
    + "#FIM=".


/* fim */
