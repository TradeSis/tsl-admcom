/* helio 07072022 - ajuste performance e leitura somente LP */
/* helio 25052022 - pacote melhorias cobranca */
/* #1 - 02.06.2017 - Voltou a testar pela acha do titobs[1] se é parcial */
/* #2 - 21.02.2020 - TP 35920071 - Titulo não disponível*/
{admcab.i}
{setbrw.i}

def var vtime as int.
def var varquivo as char.
 
def var smodal as log format "Sim/Nao".
def buffer opdvdoc for pdvdoc.
def buffer xpdvdoc for pdvdoc.
def buffer bpdvdoc for pdvdoc.

def var precestorno as recid.

def var vdt  like plani.pladat.
def var i as int.
def var vdtini      like titulo.titdtemi    label "Data Inicial".
def var vdtfin      like titulo.titdtemi    label "Data Final".
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var wpar        as int format ">>9" .
def var vjuro       like titulo.titjuro.
def var vdesc       like titulo.titdesc.

def temp-table ttpagamento no-undo
    field etbcod    as int
    field datamov as date
    field contnum as int
    field titpar  as int
    field pdvdoc as recid
    field titulo as recid
     index x is unique primary etbcod asc datamov asc contnum asc titpar asc pdvdoc asc.
     
def temp-table ttcliente no-undo
    field clicod like titulo.clifor
    field titvlcob   as dec
    field juros             as dec
    field valor_total as dec
    index i1 is unique primary clicod asc.
    

def temp-table tt-cartpre  no-undo
    field seq    as int
    field numero as int
    field valor as dec.

def new shared var vqtdcart       as   int.
def new shared var vconta         as   int.
def new shared var vachatextonum  as char.
def new shared var vachatextoval  as char.
def new shared var vvalor-cartpre as int.

def var vcre as log format "Geral/Facil" initial yes.

def temp-table tt-cli
    field clicod like clien.clicod.

def temp-table wfresumoctm no-undo
    field etbcod    like estab.etbcod       column-label "Loja"
    field ctmcod    like pdvdoc.ctmcod
    field vlpago_etbcobra    like titulo.titvlpag    column-label "Valor Pago"
                                                  format "->>,>>>,>>9.99"
    field juros     like titulo.titjuro     column-label "Juros"
    field vlpago_total    like titulo.titvlpag    column-label "Total Pago"
                                                  format "->>,>>>,>>9.99"

    index i1 is unique primary etbcod asc ctmcod asc.

def temp-table wfresumo no-undo
    field etbcod    like estab.etbcod       column-label "Loja"
    field compra    like titulo.titvlcob    column-label "Tot.Compra"
                                                  format "->>,>>>,>>9.99"
    field repar    like titulo.titvlcob    column-label "Reparc."
                                                  format ">>,>>>,>>9.99"
    field vista    like titulo.titvlcob    column-label "Tot. Vista"
                                                  format "->,>>>,>>9.99"
    field entrada   like titulo.titvlcob    column-label "Tot.Entrada"
                                                  format ">,>>>,>>9.99"
    field entmoveis   like titulo.titvlcob    column-label "Ent.Movais"
                                                  format ">,>>>,>>9.99"
    field entmoda   like titulo.titvlcob    column-label "Ent.Moda"
                                                  format ">,>>>,>>9.99"             
    field entrep    like titulo.titvlcob    column-label "Tot.Entrada"
                                                  format ">,>>>,>>9.99"
    field vlpago_etbcobra    like titulo.titvlpag    column-label "Valor Pago"
                                                  format "->>,>>>,>>9.99"
    field vlpago_total    like titulo.titvlpag    column-label "Total Pago"
                                                  format "->>,>>>,>>9.99"
                                                  
    field vlpago_etborigem    like titulo.titvlpag format "->>,>>>,>>9.99" column-label "Pgto.Orig." 
    field vltotal   like titulo.titvlpag    column-label "Valor Total"
                                                  format "->>>,>>>,>>9.99"
    field qtdcont   as   int column-label "Qtd.Cont" format ">>>,>>9"
    field juros     like titulo.titjuro     column-label "Juros"
    field qtdparcial as int format ">>>>>9"  column-label "Parcial"   
    field valparcial as dec             
    index i1 is unique primary etbcod asc.

def var vetbcod like estab.etbcod.

def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-parcela-lp as log.

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.
def var vetbaux like vetbcod.

def temp-table tt-modalidade-padrao
    field modcod as char
    index pk modcod.
            
def temp-table tt-modalidade-selec
    field modcod as char
    index pk modcod.

def var vval-carteira as dec.                                
             
def temp-table ttpdvdoc no-undo
    field pdvdoc    as recid
        field emissao   as log.
        
           def temp-table ttforma
               field seqforma like  pdvforma.seqforma
                   field seqfp    like  pdvmoeda.seqfp
                       field titpar   like  pdvmoeda.titpar
                           field primeiraf as log.
                           
form
   a-seelst format "x" column-label "*"
   tt-modalidade-padrao.modcod no-label
   with frame f-nome
       centered down title "Modalidades"
       color withe/red overlay.    
                                                        
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CRE".
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CPN".

for each profin no-lock.
    find modal of profin no-lock no-error.
    if not avail modal
    then next.
    create tt-modalidade-padrao.
    assign tt-modalidade-padrao.modcod = profin.modcod.
        
end.

repeat with 1 down side-label width 80 row 3:

    empty temp-table ttpagamento    .
    empty temp-table ttcliente.
    empty temp-table wfresumoctm.
    empty temp-table wfresumo.
    empty temp-table ttforma.
    empty temp-table ttpdvdoc.
    empty temp-table tt-cli.    
    
    update vetbcod label "Filial" colon 25.
    update vcre label "Cliente" colon 25 with side-label.

    update vdtini colon 25
           vdtfin colon 25.
           
    for each tt-modalidade-selec: delete tt-modalidade-selec. end.
           
    update v-relatorio-geral as log format "Sim/Nao" label 
                    "Relatorio GERAL"
                    colon 25.
    if not v-relatorio-geral
    then do:
        update smodal label "Seleciona Modalidades?" colon 25
               help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
               with side-label width 80.
        if smodal
        then do:
            bl_sel_filiais:
            repeat:
                run p-seleciona-modal.
                                                      
                if keyfunction(lastkey) = "end-error"
                then leave bl_sel_filiais.
            end.
        end.
        else do:
            create tt-modalidade-selec.
            assign tt-modalidade-selec.modcod = "CRE".
        end.
        assign vmod-sel = "  ".
        for each tt-modalidade-selec.
            assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
        end.
        display vmod-sel format "x(40)" no-label.

        update v-consulta-parcelas-LP label " Considera apenas LP"
             help "'Sim' = Parcelas acima de 51 / 'Nao' = Parcelas abaixo de 51"   ~       colon 25.
    
        update v-feirao-nome-limpo label "Considerar apenas feirao" colon 25.
    end.
    else do:
        for each tt-modalidade-padrao:
            create tt-modalidade-selec.
            buffer-copy tt-modalidade-padrao to tt-modalidade-selec.
        end.
        assign vmod-sel = "  ".
        for each tt-modalidade-selec.
            assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
        end.
        
        display vmod-sel format "x(40)" no-label.
    end.
    
    i = 0.
    for each wfresumo. delete wfresumo. end.

    sresp = yes.
    message "Confirma relatorio?" update sresp.
    if not sresp then next.

    vtime = time.
    
    if vcre = no
    then do:
    
        for each tt-cli:
            delete tt-cli.
        end.

        for each clien where clien.classe = 1 no-lock:
    
            display clien.clicod
                    clien.clinom
                    clien.datexp format "99/99/9999" with 1 down. pause 0.
        
            create tt-cli.
            assign tt-cli.clicod = clien.clicod.
        end.
    
    end.
    
    for each estab no-lock:
        if vetbcod > 0 and
        estab.etbcod <> vetbcod then next.
        do vdt = vdtini to vdtfin:
           
            hide message no-pause. message "aguarde... " estab.etbcod vdt.
             
            for each contrato use-index mala
                    where contrato.dtinicial = vdt and
                            contrato.etbcod = estab.etbcod 
                            no-lock:
                
                find first tt-modalidade-selec no-error.
                if avail tt-modalidade-selec
                then do:
                    find first tt-modalidade-selec where
                        tt-modalidade-selec.modcod = contrato.modcod
                        no-error.
                    if not avail tt-modalidade-selec
                    then next.
                end.    
                                                            
                                            
                                            
                find last titulo
                     where titulo.empcod = 19
                       and titulo.titnat = no
                       and titulo.modcod = contrato.modcod
                       and titulo.etbcod = contrato.etbcod
                       and titulo.clifor = contrato.clicod
                       and titulo.titnum = string(contrato.contnum)
                                        no-lock no-error.
                                              
                if avail titulo
                    and titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = yes
                   and v-parcela-lp = no
                then next.

                {filtro-feiraonl.i}

                i = i  + 1.
                /*display estab.etbcod contrato.dtinicial i
                        with frame f1 no-label 1 down
                            title " Contratos ". pause 0.
                  */
                if vcre = no
                then do:
                    find first tt-cli where 
                               tt-cli.clicod = contrato.clicod no-error.
                    if not avail tt-cli
                    then next.
                end.

                find first wfresumo where 
                    wfresumo.etbcod = contrato.etbcod 
                    no-error.
                if not avail wfresumo
                then do:
                    create wfresumo.
                    assign wfresumo.etbcod  = contrato.etbcod.
                end.    
 
                if contrato.banco = 999
                then assign wfresumo.repar   = 
                            wfresumo.repar  + contrato.vltotal
                    wfresumo.entrep  = wfresumo.entrep + contrato.vlentra.
                else wfresumo.compra  = wfresumo.compra  + contrato.vltotal.

                wfresumo.qtdcont = wfresumo.qtdcont + 1.
                
                find first titulo
                     where titulo.empcod = 19
                       and titulo.titnat = no
                       and titulo.modcod = contrato.modcod
                       and titulo.etbcod = contrato.etbcod
                       and titulo.clifor = contrato.clicod
                       and titulo.titnum = string(contrato.contnum)
                       and titulo.titpar = 0
                                        no-lock no-error.
                

                if avail titulo
                then do:
                    find first wfresumo where 
                                wfresumo.etbcod = estab.etbcod 
                                no-error.
                    if not avail wfresumo
                    then do:
                        create wfresumo.
                        assign wfresumo.etbcod = estab.etbcod.  
                    end.
    
                    if titulo.etbcod   = estab.etbcod 
                    then do:
                        wfresumo.entrada = wfresumo.entrada + titulo.titvlpag.
                        run partilha-entrada.
                    end.
                end.
                
            end.
            
            if v-consulta-parcelas-LP = no
            then for each plani where 
                    plani.movtdc = 5 and
                    plani.pladat = vdt and
                    plani.etbcod = estab.etbcod no-lock.
            
            
                if vcre = no
                then do:
                    find first tt-cli where tt-cli.clicod = plani.desti 
                    no-error.
                    if not avail tt-cli
                    then next.
                end.
        
                if plani.crecod = 1
                then do:
                    find first wfresumo where 
                            wfresumo.etbcod = plani.etbcod 
                            no-error.
                    if not avail wfresumo
                    then do:
                        create wfresumo.
                        wfresumo.etbcod = estab.etbcod.
                    end.    
                    wfresumo.vista = wfresumo.vista +
                        (plani.protot /* + plani.frete */
                        + plani.acfprod - plani.descprod) - plani.vlserv.

                    for each tt-cartpre.
                        delete tt-cartpre.
                    end.    
                    assign vqtdcart = 0
                           vconta   = 0
                           vachatextonum = ""
                           vachatextoval = ""
                           vvalor-cartpre = 0.
                 
                    if plani.notobs[3] <> ""
                    then do:
                        if acha("QTDCHQUTILIZADO",plani.notobs[3]) <> ? 
                        then vqtdcart =
                             int(acha("QTDCHQUTILIZADO",plani.notobs[3])).
                    
                        if vqtdcart > 0 
                        then do: 
                        
                            do vconta = 1 to vqtdcart:  
                                vachatextonum = "". 
                                vachatextonum = "NUMCHQPRESENTEUTILIZACAO" 
                                              + string(vconta).
        
                                vachatextoval = "". 
                                vachatextoval = "VALCHQPRESENTEUTILIZACAO" 
                                              + string(vconta).

                                if acha(vachatextonum,plani.notobs[3]) <> ? and
                                   acha(vachatextoval,plani.notobs[3]) <> ?
                                then do: 
                                    find tt-cartpre where tt-cartpre.numero = 
                                     int(acha(vachatextonum,plani.notobs[3]))
                                         no-error. 
                                    if not avail tt-cartpre 
                                    then do:  
                                        create tt-cartpre. 
                                        assign tt-cartpre.numero =
                                        int(acha(vachatextonum,plani.notobs[3]))
                                           tt-cartpre.valor  =
                                       dec(acha(vachatextoval,plani.notobs[3])).
                                    end.
                                end.
                            end.
                        end.
                    end.
                    vvalor-cartpre = 0.
                    find first tt-cartpre no-lock no-error.
                    if avail tt-cartpre 
                    then do:
                        for each tt-cartpre.
                            vvalor-cartpre = vvalor-cartpre + tt-cartpre.valor.
                        end.
                    end.
                     
                    wfresumo.vista = wfresumo.vista - vvalor-cartpre.
                    /*vlauxt = vlauxt - vvalor-cartpre.
                    run Pi-Cria-Anali(input "plani", input 2, 
                                       input plani.modcod, input vlauxt,
                                       input 1).
                    vlauxt = 0. */
                 end.
                 else do:
                    
                    if plani.vlserv > 0
                    then do:
                        find first wfresumo where
                            wfresumo.etbcod = plani.etbcod 
                            no-error.
                        if not avail wfresumo
                        then do:
                            create wfresumo.
                            wfresumo.etbcod = estab.etbcod.
                        end.
                        if (wfresumo.compra - plani.vlserv) > 0
                        then wfresumo.compra = wfresumo.compra - plani.vlserv.
                        else wfresumo.compra = 0.
                    end.
                 end.   
            end.
            
            /*
            for each titulo where titulo.etbcobra = estab.etbcod and
                                  titulo.titdtpag = vdt 
                                   no-lock.
                
                find first tt-modalidade-selec no-error.
                if avail tt-modalidade-selec
                then do:
                    find first tt-modalidade-selec where
                        tt-modalidade-selec.modcod = titulo.modcod
                        no-error.
                    if not avail tt-modalidade-selec
                    then next.
                end.        

                if titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
                then next.
                
                {filtro-feiraonl.i}

                if titulo.titpar = 0
                then do:
                    find first wfresumo where 
                                wfresumo.etbcod = estab.etbcod 
                                no-error.
                    if not avail wfresumo
                    then do:
                        create wfresumo.
                        assign wfresumo.etbcod = estab.etbcod.  
                    end.
    
                    if titulo.etbcod   = estab.etbcod 
                    then do:
                        wfresumo.entrada = wfresumo.entrada + titulo.titvlpag.
                        run partilha-entrada.
                    end.
                    next.
                end.

                if vcre = no
                then do:
                    find first tt-cli where tt-cli.clicod = titulo.clifor 
                                                                no-error.
                    if not avail tt-cli
                    then next.
                end.

            end.
            */
            
            run pr-pagamento.
                    
            /*
            for each tt-modalidade-selec,
            
                each titulo where  titulo.titnat = no and
                                  titulo.modcod = tt-modalidade-selec.modcod and
                                  titulo.titdtpag = vdt and
                                  titulo.etbcod = estab.etbcod no-lock:
                
                if titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
                then next.
                              
                if titulo.titpar = 0
                then next.

                {filtro-feiraonl.i}

                if vcre = no
                then do:
                    find first tt-cli where tt-cli.clicod = titulo.clifor
                                                                no-error.
                    if not avail tt-cli
                    then next.
                end.

                if titulo.titpar = 0
                then do:
                    find first wfresumo where 
                                wfresumo.etbcod = estab.etbcod 
                                no-error.
                    if not avail wfresumo
                    then do:
                        create wfresumo.
                        assign wfresumo.etbcod = estab.etbcod.  
                    end.
    
                    if titulo.etbcod   = estab.etbcod 
                    then do:
                        wfresumo.entrada = wfresumo.entrada + titulo.titvlpag.
                        run partilha-entrada.
                    end.
                    next.
                end.

                find first wfresumo where 
                                    wfresumo.etbcod = estab.etbcod 
                                    no-error.
                if not avail wfresumo
                then do: 
                    create wfresumo.
                    assign wfresumo.etbcod = estab.etbcod.
                     
                end.
                
                if titulo.clifor > 1
                then wfresumo.vlpago_etborigem  = wfresumo.vlpago_etborigem + titulo.titvlcob.
            end.
            */
            
        end.
    end.
    
    
    hide message no-pause.
    message "gerando relatorios...".
        
    
    for each ttcliente: delete ttcliente. end.
    /*
    def var vp as log.
    def var vforma as char.
    def var vmoenom like moeda.moenom.
    */
    
    def var varqpagamentos as char.

    varqpagamentos = "../relat/cre02_resumomensal_pagamentos_" + string(today,"99999999") + "_" + replace(string(vtime,"HH:MM:SS"),":","") + ".csv".
    
    output to value(varqpagamentos).
    put unformatted
 "Emissor;Cliente;Modalidade;Tp;Numero;" 
"Parcela;Emissao;Valor;Vencimento;Cobrador;" "Pagamento;Parcial;TBai;DescTipobaixa;Pago;Juro"
            skip.

    for each ttpagamento
        break by ttpagamento.etbcod by ttpagamento.datamov by ttpagamento.contnum by ttpagamento.titpar.
    
        find pdvdoc where recid(pdvdoc) = ttpagamento.pdvdoc no-lock.
        find titulo where recid(titulo) = ttpagamento.titulo no-lock. 
        
        find pdvtmov of pdvdoc no-lock.
        
        put unformatted titulo.etbcod ";"
                        titulo.clifor ";"
                        titulo.modcod ";"
                        titulo.tpcontrato ";"
                        titulo.titnum ";"
                        titulo.titpar ";"
                        titulo.titdtemi ";" 
                        pdvdoc.titvlcob ";"  
                        titulo.titdtven ";"    
                        pdvdoc.etbcod ";"
                        pdvdoc.datamov ";"
                        pdvdoc.pago_parcial ";"
                        pdvdoc.ctmcod ";"
                        pdvtmov.ctmnom ";"
                        pdvdoc.valor ";"
                        pdvdoc.valor_encargo
                        skip.
    
         find first ttcliente where ttcliente.clicod = titulo.clifor no-lock no-error.
         if not avail ttcliente
         then do:
            create ttcliente.
            ttcliente.clicod = titulo.clifor.
         end.
         ttcliente.titvlcob = ttcliente.titvlcob + pdvdoc.titvlcob.
         ttcliente.juros    = ttcliente.juros    + pdvdoc.valor_encargo.
         ttcliente.valor_total = ttcliente.valor_total + pdvdoc.valor.
    end.
    
    def var vclinom like clien.clinom.
    def var varqjuro as char.
    
    varqjuro = "../relat/cre02_resumomensal_porcliente_" + string(today,"99999999") + "_" + replace(string(vtime,"HH:MM:SS"),":","") + ".csv".
    
    output to value(varqjuro).
    put "Codigo;Nome;Valor Prest;Juros Cobrado;Valor Pago;" skip.

    for each ttcliente .
        find clien where clien.clicod = ttcliente.clicod no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = "".
        put unformatted ttcliente.clicod ";"
                        vclinom ";"
                        trim(string(ttcliente.titvlcob,"->>>>>>>>>>>>>>>>>>>>>>>>>9.99")) ";"
                        trim(string(ttcliente.juros,"->>>>>>>>>>>>>>>>>>>>>>>>>9.99")) ";"
                        trim(string(ttcliente.valor_total,"->>>>>>>>>>>>>>>>>>>>>>>>>9.99")) ";"
            skip.            
    end.
    output close.
    
        

    varquivo = "../relat/cre02_resumomensal_" + string(today,"99999999") + "_" + replace(string(vtime,"HH:MM:SS"),":","") + ".txt".

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "120"
        &Page-Line = "0"
        &Nom-Rel   = """DREB031"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """RESUMO MENSAL DE CAIXA  -  PERIODO DE "" +
                        string(vdtini)  + "" A "" + string(vdtfin) "
        &Width     = "200"
        &Form      = "frame f-cab"}
    
    
    for each wfresumo use-index i1:
    
        wfresumo.vltotal = wfresumo.vlpago_etbcobra +
                           wfresumo.juros +
                           wfresumo.entrada +
                           wfresumo.vista -
                           wfresumo.entrep.
        wfresumo.vlpago_total = wfresumo.vlpago_etbcobra + wfresumo.juros.
        
        find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
        
        display wfresumo.etbcod     column-label "Etb."
                wfresumo.vlpago_etbcobra     column-label "Pgto!vlr!Prestacao"   (total)
                wfresumo.vlpago_etborigem    column-label "Pgto!vlr!Fil Origem"   (total)
                wfresumo.juros                column-label "juros!cobrado"                     (TOTAL)
                wfresumo.vlpago_total       column-label "total!pago" (total)
                wfresumo.qtdcont                                (total)
                wfresumo.compra     column-label "Contratos"    (total)
                wfresumo.repar      column-label "Reparc."    (total)
                wfresumo.entrada    column-label "Entradas"     (total)
                wfresumo.entmoveis  column-label "Entrada!Moveis"   (total)
                wfresumo.entmoda    column-label "Entrada!Moda"     (total)
                wfresumo.vista      column-label "V. Vista"     (total)
                wfresumo.vltotal    column-label "TOTAL"        (total)
                wfresumo.qtdparcial column-label "QtdParcial"   (total)
                wfresumo.valparcial column-label "ValParcial"   (total)
                    with frame flin width 390 down no-box.
    end.

    put skip(2).
    for each wfresumoctm use-index i1:
    
        wfresumoctm.vlpago_total = wfresumoctm.vlpago_etbcobra + wfresumoctm.juros.
        
        find pdvtmov where pdvtmov.ctmcod = wfresumoctm.ctmcod no-lock no-error.
        
        display wfresumoctm.etbcod     column-label "Etb."
                wfresumoctm.ctmcod  column-label "TBai"
                pdvtmov.ctmnom
                wfresumoctm.vlpago_etbcobra     column-label "Pgto!vlr!Prestacao"   (total)
                wfresumoctm.juros                column-label "juros!cobrado"                     (TOTAL)
                wfresumoctm.vlpago_total       column-label "total!pago" (total)
                    with frame flin2 width 390 down no-box.
    end.

    view frame f1.

    output close.
    
    message color red/with
        "Arquivo relatorio gerado" skip
        varquivo  skip(1)

        "Arquivo pagamentos analitico por documento gerado" skip
        varqpagamentos  skip(1)
        "Arquivo Juros por cliente gerado" skip
        varqjuro
        view-as alert-box.
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end.

procedure pr-pagamento.
    for each pdvtmov where pdvtmov.pagamento = yes no-lock,
     each pdvdoc where 
            pdvdoc.ctmcod = pdvtmov.ctmcod and
            pdvdoc.pstatus = yes and 
            pdvdoc.etbcod = estab.etbcod and 
            pdvdoc.datamov = vdt 
            no-lock.
            
        find first tt-modalidade-selec no-error.
        if avail tt-modalidade-selec
        then do:
            find first tt-modalidade-selec where tt-modalidade-selec.modcod  = pdvdoc.modcod no-lock no-error.
            if not avail tt-modalidade-selec
            then next.
        end.
        if pdvdoc.ctmcod = "P48" then next. /* novacao */
        if contnum = ? then next. /* nao crediario */

        find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock.
        find first  titulo where 
                titulo.empcod = 19 and titulo.titnat = no and titulo.modcod = contrato.modcod and titulo.etbcod = contrato.etbcod and 
                titulo.clifor = contrato.clicod and 
                titulo.titnum = string(contrato.contnum) and 
                titulo.titpar = pdvdoc.titpar
                no-lock.
         
        if v-consulta-parcelas-LP = yes 
        then if titulo.tpcontrato = "L"
             then.
             else next.
                 
        
        precestorno = ?.

        run pesquisaEstorno (recid(pdvdoc), output precestorno).
        if precestorno = ? and pdvdoc.valor > 0
        then.
        else next. 

        /*
        if titulo.titvltot = pdvdoc.titvlcob * -1 then next. /* estorno */
        */

        
        create ttpagamento.
        ttpagamento.pdvdoc = recid(pdvdoc).
        ttpagamento.titulo =  recid(titulo).
        ttpagamento.etbcod = pdvdoc.etbcod.            
        ttpagamento.datamov = pdvdoc.datamov.
        ttpagamento.contnum = int(pdvdoc.contnum).
        ttpagamento.titpar  = pdvdoc.titpar.
                    
        find first wfresumo where  
                wfresumo.etbcod = pdvdoc.etbcod 
            no-error. 
        if not avail wfresumo 
        then do: 
            create wfresumo. 
            assign wfresumo.etbcod = pdvdoc.etbcod.
        end.  
        wfresumo.vlpago_etbcobra    = wfresumo.vlpago_etbcobra + pdvdoc.titvlcob.
        wfresumo.juros              = wfresumo.juros           + pdvdoc.valor_encargo.
        wfresumo.qtdparcial         = wfresumo.qtdparcial  + (if pdvdoc.pago_parcial = "S" then 1 else 0).
        wfresumo.valparcial         = wfresumo.valparcial  + (if pdvdoc.pago_parcial = "S" then pdvdoc.titvlcob else 0).

        if pdvdoc.etbcod = 999
        then do:
            find first wfresumoctm where  
                wfresumoctm.etbcod = pdvdoc.etbcod and 
                wfresumoctm.ctmcod = pdvdoc.ctmcod 
                no-error. 
            if not avail wfresumoctm 
            then do: 
                create wfresumoctm. 
                assign wfresumoctm.etbcod = pdvdoc.etbcod.
                wfresumoctm.ctmcod = pdvdoc.ctmcod. 
            end.  
            wfresumoctm.vlpago_etbcobra    = wfresumoctm.vlpago_etbcobra + pdvdoc.titvlcob.
            wfresumoctm.juros              = wfresumoctm.juros           + pdvdoc.valor_encargo.
        end.    
        
        
                find first wfresumo where 
                                    wfresumo.etbcod = titulo.etbcod 
                                    no-error.
                if not avail wfresumo
                then do: 
                    create wfresumo.
                    assign wfresumo.etbcod = titulo.etbcod.
                     
                end.
                
                if titulo.clifor > 1
                then wfresumo.vlpago_etborigem  = wfresumo.vlpago_etborigem + pdvdoc.titvlcob.
        
        
    end.            


end procedure.

procedure pr-pagamento_old : /* helio 26052022 - pacote de melhorias cobranca */ /* criei nova rotina*/
/*
    def var vlpres as dec.
    def var vljuro as dec.
    def var val-pago as dec.
    def var vdata as date.
    def var vcaixa as dec.
    def var vljurpre as dec.
    def var vlnov as dec.
    def var qtd-parcial as int init 0.
    def var val-parcial as dec init 0.
    def buffer bmoeda for moeda.
    vdata = vdt.
    for each tt-modalidade-selec,
    
        each titulo where titulo.etbcobra = estab.etbcod and
                          titulo.titdtpag = vdata and
                          titulo.modcod = tt-modalidade-selec.modcod
                          no-lock        .

            if vcaixa <> 0 and titulo.cxacod <> vcaixa then next.

            if titulo.titnat = yes then next.

            if titulo.titpar = 0 then next.
            if titulo.clifor = 1 then next.
            if titulo.moecod = "DEV" then next.
            /*if titulo.modcod <> "CRE" then next.*/
            if titulo.titnat = yes then next.

            if titulo.etbcobra <> estab.etbcod
            then next.
        
            if titulo.cxmdat <> vdata
                and titulo.cxmdat <> titulo.titdtemi
                and titulo.etbcobra <> 992
                and titulo.etbcobra <> 999
            then next.
            
            if titulo.titdtpag = ?
            then next.
            if titulo.titsit = "LIB"
            then next.
            if titulo.titdtpag <> vdata
            then next.
            if titulo.titpar    = 0
            then next.
            if titulo.clifor = 1
            then next.
            if titulo.modcod = "LUZ"
            then next.
            if titulo.modcod = "VVI" or titulo.modcod = "CHQ" or
               titulo.modcod = "CHP" 
            then next.
            if titulo.modcod = "CRE" and titulo.moecod = "DEV" then next.
            
            if titulo.tpcontrato = "L"
            then assign v-parcela-lp = yes.
            else assign v-parcela-lp = no.

            if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
            then next.

            vetbaux = estab.etbcod.
            if vetbcod = 999 
            then do:
                find first tabaux where
                       tabaux.tabela = "FBM_999" and
                       tabaux.nome_campo begins titulo.moecod
                       no-lock no-error.
                if avail tabaux
                then vetbaux = int(tabaux.valor_campo).
            end.            
            do:        
                
                if titulo.titvlcob > titulo.titvlpag
                then val-pago = titulo.titvlpag.
                else val-pago = titulo.titvlcob.

                /* #1 */
                if acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
                then val-pago = titulo.titvlpag.
                else val-pago = titulo.titvlcob.
                
                find bmoeda where 
                    bmoeda.moecod = titulo.moecod no-lock no-error.

                if avail bmoeda
                then do:
           
                    vlpres = vlpres + val-pago.
                    if bmoeda.moecod = "PRE"
                        then assign  vljurpre = vljurpre + titulo.titjuro.
                end.
                else do:
                    vlpres = vlpres + val-pago.
                    if titulo.moecod = "PRE"
                        then assign  vljurpre = vljurpre + titulo.titjuro.
                end.
                vljuro = vljuro + titulo.titjuro.    
            
            end.
            if titulo.moecod = "NOV"
            then assign vlnov  = vlnov + titulo.titvlcob .

            if acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
            then assign
                     qtd-parcial = qtd-parcial + 1
                     val-parcial = val-parcial + titulo.titvlpag.
            
            create tt-titulo.
            buffer-copy titulo to tt-titulo.
            assign
                tt-titulo.titvlpag = val-pago
                val-pago = 0
                tt-titulo.etbcobra = vetbaux.

            find first wfresumo where 
                                wfresumo.etbcod = vetbaux 
                                    /*estab.etbcod*/ 
                            and wfresumo.ctmcod = if vetbaux = 999 then titulo.moecod else ""
                                    no-error.
                if not avail wfresumo
                then do:
                    create wfresumo.
                    assign wfresumo.etbcod = vetbaux /*estab.etbcod*/.
                    wfresumo.ctmcod = if vetbaux = 999 then titulo.moecod else "".
                end.
    
                assign 
                        wfresumo.vlpago_etbcobra  = wfresumo.vlpago_etbcobra + vlpres
                        wfresumo.juros   = wfresumo.juros + vljuro
                        wfresumo.qtdparcial = wfresumo.qtdparcial
                                                + qtd-parcial
                        wfresumo.valparcial = wfresumo.valparcial 
                                                + val-parcial   
                        vlpres = 0
                        vljuro = 0
                        qtd-parcial = 0
                        val-parcial = 0
                        .
                                                                               
        end.
*/            
end procedure.


procedure p-seleciona-modal:
          
for each tt-modalidade-selec: delete tt-modalidade-selec. end.
release tt-modalidade-padrao.
clear frame f-nome all.
hide frame f-nome no-pause.            
            
assign
    a-seeid = -1
    a-recid = -1
    a-seerec = ?
    a-seelst = "".

l1: repeat:
    
{sklcls.i
    &File   = tt-modalidade-padrao
    &help   = "                ENTER=Marca F4=Retorna F8=Marca Tudo"
    &CField = tt-modalidade-padrao.modcod    
    &Ofield = " tt-modalidade-padrao.modcod"
    &Where  = " true"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "tt-modalidade-padrao.modcod" 
    &PickFrm = "x(4)" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            a-seelst = """".
            for each tt-modalidade-padrao no-lock:
                a-seelst = a-seelst + "","" + tt-modalidade-padrao.modcod.
                v-cont = v-cont + 1.
                disp ""* "" @ a-seelst
                    tt-modalidade-padrao.modcod
                    with frame f-nome.
                down with frame f-nome.
                
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""FILIAIS                                   ""
            .
            pause .
            a-recid = -1.
            next .
        end. 
        if keyfunction(lastkey) = ""end-error""    
        then leave keys-loop.
            "
    &Form = " frame f-nome" 
}. 

    leave l1.
end.
hide frame f-nome.
v-cont = 2.
repeat :
    v-cod = "".
    if num-entries(a-seelst) >= v-cont
    then v-cod = entry(v-cont,a-seelst).

    v-cont = v-cont + 1.

    if v-cod = ""
    then leave.
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = v-cod.
end.


end.
procedure partilha-entrada:
    
    find contrato where contrato.contnum = int(titulo.titnum) 
            no-lock no-error.
    if avail contrato
    then do:
        for each contnf where
                 contnf.etbcod = contrato.etbcod and
                 contnf.contnum = contrato.contnum
                 no-lock:
            find first plani where plani.etbcod = contnf.etbcod and
                                   plani.placod = contnf.placod 
                                   no-lock no-error.
            if avail plani
            then do:
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod 
                                     no-lock.
                    find produ where produ.procod = movim.procod 
                            no-lock no-error.
                    if not avail produ or produ.proipiper = 98
                    then next.
                    if produ.catcod = 31
                    then do:
                        wfresumo.entmoveis = 
                                wfresumo.entmoveis + titulo.titvlpag.
                        leave.
                    end.            
                    if produ.catcod = 41
                    then do:
                        wfresumo.entmoda = 
                                wfresumo.entmoda + titulo.titvlpag.
                        leave.
                    end.         
                end.                     
            end.                       
        end.
    end.        
end procedure.




 procedure pesquisaEstorno.
def input  param pmeurec as recid.
def output param pestrec as recid.
find bpdvdoc where recid(bpdvdoc) = pmeurec no-lock.
for each xpdvdoc where xpdvdoc.contnum = bpdvdoc.contnum and
                      xpdvdoc.titpar   = bpdvdoc.titpar and
                      xpdvdoc.pstatus  = yes
                no-lock:
    find pdvmov of xpdvdoc no-lock.
    
          if xpdvdoc.orig_loja <> 0
          then do:
                find first opdvdoc where
                    opdvdoc.etbcod = xpdvdoc.orig_loja and
                    opdvdoc.cmocod = xpdvdoc.orig_componente and
                    opdvdoc.datamov = xpdvdoc.orig_data and
                    opdvdoc.sequencia = xpdvdoc.orig_nsu and
                    opdvdoc.seqreg   = xpdvdoc.orig_vencod
                    no-lock no-error.
                if avail opdvdoc
                then do:
                    if recid(opdvdoc) = pmeurec
                    then pestrec  = recid(opdvdoc).
                end.                       
           end.
      
end.
end procedure.

