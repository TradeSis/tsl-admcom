/* helio 25052022 - pacote melhorias cobranca */

{admcab.i}

run fin/cre02.p.

/************desabilitada versao anterior
{setbrw.i}

def var vdt  like plani.pladat.
def var i as int.
def var vdtini      like titulo.titdtemi    label "Data Inicial".
def var vdtfin      like titulo.titdtemi    label "Data Final".
def var sresumo     as   log format "Resumo/Geral" initial yes.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var wpar        as int format ">>9" .
def var vjuro       like titulo.titjuro.
def var vdesc       like titulo.titdesc.

def temp-table tt-titulo like titulo.
def temp-table tt-jurcli 
    field clifor like titulo.clifor
    field titjuro like titulo.titjuro
    index i1 clifor.
    

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

def temp-table wfresumo
    field etbcod    like estab.etbcod       column-label "Loja"
    field compra    like titulo.titvlcob    column-label "Tot.Compra"
                                                  format "->>,>>>,>>9.99"
    field repar    like titulo.titvlcob    column-label "Reparc."
                                                  format ">>,>>>,>>9.99"
    field vista    like titulo.titvlcob    column-label "Tot. Vista"
                                                  format ">,>>>,>>9.99"
    field entrada   like titulo.titvlcob    column-label "Tot.Entrada"
                                                  format ">,>>>,>>9.99"
    field entmoveis   like titulo.titvlcob    column-label "Ent.Movais"
                                                  format ">,>>>,>>9.99"
    field entmoda   like titulo.titvlcob    column-label "Ent.Moda"
                                                  format ">,>>>,>>9.99"             field entrep    like titulo.titvlcob    column-label "Tot.Entrada"
                                                  format ">,>>>,>>9.99"
    field vlpago    like titulo.titvlpag    column-label "Valor Pago"
                                                  format ">>,>>>,>>9.99"
    field vlpago1    like titulo.titvlpag format ">>,>>>,>>9.99"
    field vltotal   like titulo.titvlpag    column-label "Valor Total"
                                                  format ">>,>>>,>>9.99"
    field qtdcont   as   int column-label "Qtd.Cont" format ">>>,>>9"
    field juros     like titulo.titjuro     column-label "Juros"
    field qtdparcial as int format ">>>>>9"  column-label "Parcial"   
    field valparcial as dec             
    index i1 etbcod.

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

    create tt-modalidade-padrao.
    assign tt-modalidade-padrao.modcod = profin.modcod.
        
end.

repeat with 1 down side-label width 80 row 3:

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
    update sresp label "Seleciona Modalidades?" colon 25
           help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
           with side-label width 80.
              
    if sresp
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

    sresp = no.
    message "Confirma relatorio?" update sresp.
    if not sresp then next.
    
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
    
    for each tt-titulo: delete tt-titulo. end.
    
    for each estab no-lock:
        if vetbcod > 0 and
        estab.etbcod <> vetbcod then next.
        do vdt = vdtini to vdtfin:
            for each tt-modalidade-selec,
            
                each contrato where contrato.dtinicial = vdt and
                            contrato.etbcod = estab.etbcod and 
                            contrato.modcod = tt-modalidade-selec.modcod
                            no-lock,    /*#2*/
                first titulo
                     where titulo.empcod = 19
                       and titulo.titnat = no
                       and titulo.modcod = contrato.modcod
                       and titulo.etbcod = contrato.etbcod
                       and titulo.clifor = contrato.clicod
                       and titulo.titnum = string(contrato.contnum)
                       and titulo.titdtemi = contrato.dtinicial
                                        no-lock. /*#2*/
                                              
                if avail titulo
                    and titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
                                                   
                if v-consulta-parcelas-LP = yes
                   and v-parcela-lp = no
                then next.

                {filtro-feiraonl.i}

                i = i  + 1.
                display contrato.dtinicial i
                        with frame f1 no-label 1 down
                            title " Contratos ". pause 0.

                if vcre = no
                then do:
                    find first tt-cli where 
                               tt-cli.clicod = contrato.clicod no-error.
                    if not avail tt-cli
                    then next.
                end.

                find first wfresumo where 
                    wfresumo.etbcod = contrato.etbcod no-error.
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
            end.
            for each plani where plani.datexp = vdt and
                        plani.etbcod = estab.etbcod no-lock.
            
                if plani.movtdc <> 5
                then next.
            
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
                            wfresumo.etbcod = plani.etbcod no-error.
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
                            wfresumo.etbcod = plani.etbcod no-error.
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
        
            for each tt-modalidade-selec,
            
                each titulo where titulo.etbcobra = estab.etbcod and
                                  titulo.titdtpag = vdt and 
                                  titulo.modcod = tt-modalidade-selec.modcod
                                   no-lock.
                if titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                   and v-parcela-lp = yes
                then next.
                                        
                if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
                then next.
                
                if titulo.modcod <> "CRE"
                then next.

                {filtro-feiraonl.i}

                if titulo.titpar = 0
                then do:
                    find first wfresumo where 
                                wfresumo.etbcod = estab.etbcod no-error.
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
            
            run pr-pagamento.
                    
            for each tt-modalidade-selec,
            
                each titulo where titulo.empcod = 19 and
                                  titulo.titnat = no and
                                  titulo.modcod = tt-modalidade-selec.modcod and
                                  titulo.titdtpag = vdt and
                                  titulo.etbcod = estab.etbcod no-lock:
                
                if titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                   and v-parcela-lp = yes
                then next.
                                        
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

                find first wfresumo where 
                                    wfresumo.etbcod = estab.etbcod no-error.
                if not avail wfresumo
                then do: 
                    create wfresumo.
                    assign wfresumo.etbcod = estab.etbcod.
                end.
                
                if titulo.clifor > 1
                then wfresumo.vlpago1  = wfresumo.vlpago1 + titulo.titvlcob.
            end.
        end.
    end.
    for each tt-jurcli: delete tt-jurcli. end.
    def var vp as log.
    def var vforma as char.
    def var vmoenom like moeda.moenom.
    def var varquivo as char.
    varquivo = "/admcom/relat/cre02a-" + string(time) + ".csv". 
    output to value(varquivo).
    put "Emissor;Cliente;Modalidade;Numero;Parcela;Emissao;Valor;Vencimento;Cobrador;Pagamento;Parcial;Moeda;DescMoeda;Pago;Juro"
skip.

    for each tt-titulo where tt-titulo.titvlcob > 0 no-lock:

        for each ttforma: delete ttforma. end.
        for each ttpdvdoc: delete ttpdvdoc. end.
        vmoenom = "".
        if tt-titulo.moecod = "PDM"
        then do:
            for each pdvdoc where pdvdoc.contnum = tt-titulo.titnum and
                                  pdvdoc.titpar = tt-titulo.titpar and
                                  pdvdoc.pstatus = yes
                                  no-lock:
        
                find pdvmov of pdvdoc no-lock.
                vp = yes.
                for each pdvforma of pdvmov no-lock
                        by pdvforma.seqforma desc.
                    create ttforma.
                    ttforma.seqforma = pdvforma.seqforma.
                    ttforma.primeiraf = yes.
                    vp = yes.
                    for each pdvmoeda of pdvforma no-lock.
                        if vp
                        then do:
                            ttforma.seqfp = pdvmoeda.seqfp.
                            ttforma.titpar = pdvmoeda.titpar.
                            ttforma.primeiraf = vp.
                            vp = no.
                        end.
                        else do:
                            create ttforma.
                            ttforma.seqforma = pdvforma.seqforma.
                            ttforma.seqfp    = pdvmoeda.seqfp.
                            ttforma.titpar   = pdvmoeda.titpar.
                            ttforma.primeiraf = no.
                        end.
                    end.
                end.
                for each ttforma where ttforma.primeiraf = yes.
                    find first pdvforma of pdvmov where                                 pdvforma.seqforma = ttforma.seqforma
                                no-lock no-error.
                    if avail pdvforma
                    then do:
                        find pdvtforma of pdvforma no-lock no-error.
                        vforma = pdvforma.pdvtfcod + "-" + 
                                    if avail pdvtforma
                                    then pdvtforma.pdvtfnom
                                    else "".
                        vmoenom = pdvtforma.pdvtfnom.
                    end.
                end.            
            end.
        end.
        else do:
            find first pdvtmov where
                       pdvtmov.ctmcod = trim(tt-titulo.moecod)  and
                       pdvtmov.pagamentos
                       no-lock no-error.
            if avail pdvtmov
            then vmoenom = pdvtmov.ctmnom.
            else do:
                find moeda where moeda.moecod = tt-titulo.moecod no-lock no-error.
                if avail moeda
                then vmoenom = moeda.moenom.
                        
            end.
        end.
        
        put unformatted tt-titulo.etbcod ";"
                        tt-titulo.clifor ";"
                        tt-titulo.modcod ";"
                        tt-titulo.titnum ";"
                        tt-titulo.titpar ";"
                        tt-titulo.titdtemi ";"
                        tt-titulo.titvlcob ";"                                                           tt-titulo.titdtven ";"
                        tt-titulo.etbcobra ";"
                        tt-titulo.titdtpag ";"
                        tt-titulo.dtultpgparcial ";"
                        tt-titulo.moecod ";"
                        vmoenom format "x(30)" ";"
                        tt-titulo.titvlpag ";"
                        tt-titulo.titjuro
                        skip.
        if tt-titulo.titjuro <> 0
        then do:
            find first tt-jurcli where
                   tt-jurcli.clifor = tt-titulo.clifor no-error. 
            if not avail tt-jurcli
            then do:
                create tt-jurcli.
                tt-jurcli.clifor = tt-titulo.clifor.
            end.
            tt-jurcli.titjuro = tt-jurcli.titjuro + tt-titulo.titjuro.
        end.        
    end.
    output close.
    def var vclinom like clien.clinom.
    def var varqjuro as char.
    varqjuro = "/admcom/relat/cre02jc-" + string(time) + ".csv". 
    output to value(varqjuro).
    put "Codigo;Nome;Valor Pago;Valor Juro" skip.
    for each tt-jurcli where tt-jurcli.titjuro <> 0 no-lock:
        find clien where clien.clicod = tt-jurcli.clifor no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = "".
        put unformatted
            tt-jurcli.clifor ";"
            vclinom ";"
            tt-jurcli.titjuro
            skip.
    end.
    output close.        
    message color red/with
        "Arquivo pagamentos analitico por documento gerado" skip
        varquivo  skip(1)
        "Arquivo Juros por cliente gerado" skip
        varqjuro
        view-as alert-box.
        
        
    if opsys = "UNIX"
    then varquivo = "../relat/cre02l." + string(time).
    else varquivo = "..\relat\cre02w." + string(time).
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = """DREB031"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """RESUMO MENSAL DE CAIXA  -  PERIODO DE "" +
                        string(vdtini)  + "" A "" + string(vdtfin) "
        &Width     = "120"
        &Form      = "frame f-cab"}
    
    for each wfresumo use-index i1:
    
        wfresumo.vltotal = wfresumo.vlpago +
                           wfresumo.juros +
                           wfresumo.entrada +
                           wfresumo.vista -
                           wfresumo.entrep.
        find estab where estab.etbcod = wfresumo.etbcod no-lock no-error.
        
        display wfresumo.etbcod     column-label "Etb."
                wfresumo.vlpago     column-label "Pagamentos"   (total)
                wfresumo.vlpago1    column-label "Pgto.Orig."   (total)
                wfresumo.juros                                  (TOTAL)
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
                    with frame flin width 190 down no-box.
    end.

    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end.

procedure pr-pagamento:
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

            if v-consulta-parcelas-LP = no
                and v-parcela-lp = yes
            then next.
                                        
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
            /*if titulo.moecod = "PDM"
            then do:
                for each titpag where
                           titpag.empcod = titulo.empcod and
                           titpag.titnat = titulo.titnat and
                           titpag.modcod = titulo.modcod and
                           titpag.etbcod = titulo.etbcod and
                           titpag.clifor = titulo.clifor and
                           titpag.titnum = titulo.titnum and
                           titpag.titpar = titulo.titpar
                           no-lock:
                    find bmoeda where bmoeda.moecod = titpag.moecod
                                no-lock no-error.
                    if avail bmoeda
                    then do:
                        do:
                            vlpres = vlpres +  titpag.titvlpag.
                            
                        end.
                        if bmoeda.moecod = "PRE"
                        then assign  vljurpre = vljurpre + titulo.titjuro.

                    end.
                    else do:
                        vlpres = vlpres +  titpag.titvlpag.
                        
                        if titpag.moecod = "PRE"
                        then assign  vljurpre = vljurpre + titulo.titjuro.

                    end.
                end.
                vljuro = vljuro + titulo.titjuro.
            end.
            else*/ do:        
                
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
                                    /*estab.etbcod*/ no-error.
                if not avail wfresumo
                then do:
                    create wfresumo.
                    assign wfresumo.etbcod = vetbaux /*estab.etbcod*/.
                end.
    
                assign 
                        wfresumo.vlpago  = wfresumo.vlpago + vlpres
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
    &noncharacter = / *
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
                                   plani.placod = contnf.placod and
                                   plani.movtdc = 5 and
                                   plani.serie  = contnf.notaser and
                                   plani.pladat = contrato.dtinicial
                                   no-lock no-error.
            if avail plani
            then do:
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
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



***********/
