{admcab.i}
{setbrw.i}

def var vi as int.
def var vdatref as date format "99/99/9999".
def var vcobcod as int.
def var vtipo_visao as char.
def var vmodo_visao as char.
vdatref = 12/31/16.
vtipo_visao = "GERENCIAL".
vmodo_visao = "CLIENTE".
vcobcod = 2.


update vdatref label "Data referencia" with frame f-dat side-label 1 down
width 80 row 4.

find first gprodevdu where gprodevdu.data_visao = vdatref no-lock no-error.
if not avail gprodevdu
then do:
    run pro-clasopercred-bg.p(vdatref).
end.

def var vtipo as char extent 2 format "x(15)". 
def var vcobra as char extent 2 format "x(15)".
vtipo[1] = "  CONTRATO".
vtipo[2] = "  CLIENTE".
vcobra[1] = "  DREBES".
VCOBRA[2] = "  FINANCEIRA".

disp vtipo with frame f-tipo no-label centered.
choose field vtipo with frame f-tipo.
vmodo_visao = trim(vtipo[frame-index]).

def var vindex as int.
disp vcobra with frame f-cobra no-label centered.
choose field vcobra with frame f-cobra.
if trim(vcobra[frame-index]) = "DREBES"
then assign
        vindex = 1
        vcobcod = 2.
else assign
        vindex = 2
        vcobcod = 10.

assign
    a-seeid = -1 a-recid = -1 a-seerec = ?.

form gprodevdu.Faixa_risco column-label "Faixa" format "x(5)"
     gprodevdu.descricao_faixa no-label format "x(12)"  
     gprodevdu.saldo_curva column-label "Curva"      format ">>>>>>>>9.99"
     gprodevdu.pctprovisao column-label "%"          format ">>>9.99"
     gprodevdu.provisao    column-label "Provisao"   format ">>>>>>>>9.99"
     gprodevdu.principal   column-label "Principal"  format ">>>>>>>>9.99"
     gprodevdu.renda       column-label "Renda"      format ">>>>>>>>9.99"
     with frame f-linha 13 down width 80
     overlay row 4 
     title " " + string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
            vmodo_visao + " - " + trim(vcobra[vindex]) + " ".

def var tsaldo_curva as dec.
def var tprovisao as dec.
def var tprincipal as dec.
def var trenda as dec.
for each gprodevdu where gprodevdu.data_visao = vdatref     and
                        gprodevdu.tipo_visao = vtipo_visao and
                        gprodevdu.modo_visao = vmodo_visao and
                        gprodevdu.cobcod     = vcobcod
                        no-lock:
    assign
        tsaldo_curva = tsaldo_curva + gprodevdu.saldo_curva
        tprovisao    = tprovisao + gprodevdu.provisao
        tprincipal   = tprincipal + gprodevdu.principal
        trenda       = trenda + gprodevdu.renda
        .                
end.                    

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
/*
def var esqcom1         as char format "x(15)" extent 5
    initial ["","IMPRIME TELA","ANALITICO FAIXA","",""].
*/

def var esqcom1         as char format "x(15)" extent 5
    initial ["","IMPRIME TELA","","",""].

def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var i as int.

hide frame f-dat no-pause.
hide frame f-tipo no-pause.
hide frame f-cobra no-pause.

l1: repeat:
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    
    hide frame f-linha no-pause.
    clear frame f-linha all.

    disp "TOTAL" to 15
         tsaldo_curva to 32 format ">>>>>>>>9.99"
         tprovisao to 53 format ">>>>>>>>9.99"
         tprincipal format ">>>>>>>>9.99"
         trenda format ">>>>>>>>9.99"
         with frame f-tot 1 down no-label no-box
         row 21 overlay color message width 80.
    
    {sklclstb.i  
        &color = with/cyan
        &file  = gprodevdu  
        &help  = " "
        &cfield = gprodevdu.faixa_risco
        &noncharacter = /* */  
        &ofield = " gprodevdu.descricao_faixa
                    gprodevdu.saldo_curva
                    gprodevdu.pctprovisao
                    gprodevdu.provisao
                    gprodevdu.principal
                    gprodevdu.renda
                    "  
        &aftfnd1 = " "
        &where  = " gprodevdu.data_visao = vdatref and
                    gprodevdu.tipo_visao = vtipo_visao and
                    gprodevdu.modo_visao = vmodo_visao and 
                    gprodevdu.cobcod = vcobcod "
        &aftselect1 = " run aftselect.
                        next l1.
                        " 
        &go-on = F4 
        &naoexiste1 = " bell.
                        message color red/with
                        ""Nenhum registro encontrado""
                        view-as alert-box.
                        leave l1.
                        " 
        &otherkeys1 = " run controle. "
        &locktype = " no-lock "
        &form   = " frame f-linha "
    }   
    
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.

hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "IMPRIME TELA"
    THEN DO on error undo:
        run relatorio.    
    END.
    if esqcom1[esqpos1] = "ANALITICO FAIXA"
    THEN DO:
        run relatorio-faixa-analitico(gprodevdu.faixa_risco).
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
    END.
    if esqcom2[esqpos2] = "    "
    THEN DO on error undo:
    
    END.

end procedure.

procedure controle:
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
end procedure.

procedure relatorio:
    def var varquivo as char.
    def var varqcsv as char .
    def var sld-curva as dec.
    def var vprovisao as dec.
    varquivo = "/admcom/relat/bga-cliente-" 
                + string(vdatref,"99999999") + "-" + string(time).
    varqcsv = "l:\relat\bga-cliente-"
                    + string(vdatref,"99999999") + "-" + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "80"  
        &Page-Line = "66"
        &Nom-Rel   = ""gprodevduv""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "80"
        &Form      = "frame f-cabcab"}

    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao + " - " + trim(vcobra[vindex]) + " "
                skip.
                
    vi = 0. 

    for each gprodevdu where 
             gprodevdu.data_visao = vdatref and
             gprodevdu.tipo_visao = vtipo_visao and
             gprodevdu.modo_visao = vmodo_visao and
             gprodevdu.cobcod     = vcobcod and
             gprodevdu.faixa_risco <> "" no-lock:
        
        /*
        find first tbcntgen where
                   tbcntgen.tipcon = 13 and
                   tbcntgen.campo1[1] = gprodevdu.faixa_risco 
                   no-lock no-error.
        if avail tbcntgen
        then gprodevdu.descricao_faixa = tbcntgen.numini + "-" +
                            tbcntgen.numfim.
        */
        disp gprodevdu.faixa_risco column-label "Faixa"
             gprodevdu.descricao_faixa no-label   format "x(12)"
             gprodevdu.vencido column-label "Vencidos"
             format ">>>,>>>,>>9.99" (total)
             gprodevdu.vencer_90  column-label "Vencer!Ate 3 meses"
             format ">>>,>>>,>>9.99" (total)
             gprodevdu.vencer_360 column-label "Vencer!3 a 12 meses"
             format ">>>,>>>,>>9.99"  (total)
             gprodevdu.vencer_1080 column-label "Vencer!1 a 3 anos"
             format ">>>,>>>,>>9.99"  (total) 
             gprodevdu.vencer_1800 column-label "Vencer!3 a 5 anos"
             format ">>>,>>>,>>9.99"  (total)
             gprodevdu.vencer_5400 column-label "Vencer!5 a 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             gprodevdu.vencer_9999 column-label "Vencer!+ 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             gprodevdu.saldo_curva  column-label "Saldo Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             gprodevdu.provisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             gprodevdu.pctprovisao column-label "%"
             gprodevdu.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             gprodevdu.renda(total) column-label "Renda"
             format ">>>,>>>,>>9.99"
             with frame f-disp1 down width 220.
            .
        down with frame f-disp1.
    end.
    vi = 0.
    /**************
    put skip(1) "CARTEIRA FINANCEIRA" skip.
    for each fn-risco NO-LOCK:
        find first tt-tbcntgen where
                   tt-tbcntgen.nivel = fn-risco.risco 
                   no-error.
        if avail tt-tbcntgen
        then fn-risco.des = tt-tbcntgen.numini + "-" +
                            tt-tbcntgen.numfim.
        fn-risco.total = fn-risco.vencido + fn-risco.vencer.
        /***
        disp fn-risco.risco column-label "Faixa"
             fn-risco.des no-label   format "x(12)"
             fn-risco.vencido(total) column-label "Vencidos"
             fn-risco.vencer(total)  column-label "Vencer"
             fn-risco.total(total)   column-label "Total"
             fn-risco.principal(total) column-label "Principal"
             fn-risco.acrescimo(total) column-label "Renda"
             with frame f-disp2 down width 120.
        ****/
        vi = vi + 1.    
        sld-curva = fn-risco.vencido +
                    fn-risco.ven-90 + fn-risco.ven-360 +
                    fn-risco.ven-1080 + fn-risco.ven-1800 +
                    fn-risco.ven-5400 + fn-risco.ven-9999
                    .
        vprovisao = sld-curva * (v-pct[vi] / 100).
        disp fn-risco.risco column-label "Faixa"
             fn-risco.des no-label   format "x(12)"
             fn-risco.vencido column-label "Vencidos"
             format ">>>,>>>,>>9.99" (total)
             fn-risco.ven-90  column-label "Vencer!Ate 3 meses"
             format ">>>,>>>,>>9.99" (total)
             fn-risco.ven-360 column-label "Vencer!3 a 12 meses"
             format ">>>,>>>,>>9.99"  (total)
             fn-risco.ven-1080 column-label "Vencer!1 a 3 anos"
             format ">>>,>>>,>>9.99"  (total) 
             fn-risco.ven-1800 column-label "Vencer!3 a 5 anos"
             format ">>>,>>>,>>9.99"  (total)
             fn-risco.ven-5400 column-label "Vencer!5 a 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             fn-risco.ven-9999 column-label "Vencer!+ 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             sld-curva  column-label "Sld Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             vprovisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             v-pct[vi] column-label "%"
             fn-risco.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             fn-risco.acrescimo(total) column-label "Renda"
             format ">>>,>>>,>>9.99"
             with frame f-disp2 down width 220.
            .
        down with frame f-disp2.

    end.   
    vi = 0.  
    put skip(1) "CARTEIRA GERAL" skip.
    for each tt-risco where tt-risco.risco <> "" NO-LOCK:
        find first tt-tbcntgen where
                   tt-tbcntgen.nivel = tt-risco.risco 
                   no-error.
        if avail tt-tbcntgen
        then tt-risco.des = tt-tbcntgen.numini + "-" +
                            tt-tbcntgen.numfim.
        tt-risco.total = tt-risco.vencido + tt-risco.vencer.
        
        /*******
        disp tt-risco.risco column-label "Faixa"
             tt-risco.des no-label   format "x(12)"
             tt-risco.vencido(total) column-label "Vencidos"
             tt-risco.vencer(total)  column-label "Vencer"
             tt-risco.total(total)   column-label "Total"
             tt-risco.principal(total) column-label "Principal"
             tt-risco.acrescimo(total) column-label "Renda"
             with frame f-disp3 down width 120.
        ***********/
        
        vi = vi + 1.    
        sld-curva = tt-risco.vencido + 
                    tt-risco.ven-90 + tt-risco.ven-360 +
                    tt-risco.ven-1080 + tt-risco.ven-1800 +
                    tt-risco.ven-5400 + tt-risco.ven-9999
                    .
        vprovisao = sld-curva * (v-pct[vi] / 100).
        disp tt-risco.risco column-label "Faixa"
             tt-risco.des no-label   format "x(12)"
             tt-risco.vencido column-label "Vencidos"
             format ">>>,>>>,>>9.99" (total)
             tt-risco.ven-90  column-label "Vencer!Ate 3 meses"
             format ">>>,>>>,>>9.99" (total)
             tt-risco.ven-360 column-label "Vencer!3 a 12 meses"
             format ">>>,>>>,>>9.99"  (total)
             tt-risco.ven-1080 column-label "Vencer!1 a 3 anos"
             format ">>>,>>>,>>9.99"  (total) 
             tt-risco.ven-1800 column-label "Vencer!3 a 5 anos"
             format ">>>,>>>,>>9.99"  (total)
             tt-risco.ven-5400 column-label "Vencer!5 a 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             tt-risco.ven-9999 column-label "Vencer!+ 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             sld-curva  column-label "Sld Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             vprovisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             v-pct[vi] column-label "%"
             tt-risco.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             tt-risco.acrescimo(total) column-label "Renda"
             format ">>>,>>>,>>9.99"
             with frame f-disp3 down width 220.
            .
        down with frame f-disp3.

    end.     
    ****************/
    output close.

    run visurel.p(varquivo,"").
    
end procedure.

procedure relatorio-faixa-analitico:
    def input parameter p-risco as char.
    def var varquivo as char.
    def var varqcsv as char.
    def var sld-curva as dec.
    def var vprovisao as dec.
    def var vclinom like clien.clinom.
    def var vindex as int.
    if vmodo_visao = "CONTRATO"
    then vindex = 1.
    else vindex = 2.
    
    varquivo = "/admcom/relat/" + lc(vtipo_visao) + "-" + lc(vmodo_visao) + "-"
                + lc(trim(vcobra[vindex])) + "-"
                + string(vdatref,"99999999") + "-risco-" 
                + p-risco + ".csv".    
    varqcsv = "l:~\relat~\" + lc(vtipo_visao) + "-" + lc(vmodo_visao) + "-"
                + lc(trim(vcobra[vindex])) + "-"
                + string(vdatref,"99999999") + "-risco-"
                + p-risco + ".csv".

    disp "Gerando relatorio... Aguarde!" skip
         varquivo format "x(70)"
        with frame f-dd 1 down centered overlay color message
        row 10 no-label.
    pause 0.
 
    output to value(varquivo).
    put 
    "Filial;Codigo;Nome;Contrato;Emissao;Vencido;Vencer;Valaberto;Parcelas" 
    skip.
    if vindex = 1
    then
    for each clasoper where
                   clasoper.dtvisao = vdatref and
                   clasoper.tpvisao = vtipo_visao and
                   clasoper.cobcod  = gprodevdu.cobcod and
                   clasoper.catcod  = 0 and
                   clasoper.modcod  = "CRE" and
                   clasoper.riscon  = gprodevdu.faixa_risco 
                   no-lock:

        find clien where clien.clicod = clasoper.clifor no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = "NOME".
        put unformatted
            clasoper.etbcod format ">>9"
            ";" 
            clasoper.clifor format ">>>>>>>>>9"
            ";"
            Vclinom 
            ";"
            clasoper.titnum 
            ";"
            clasoper.titdtemi
            ";"
            clasoper.vencido
            ";"
            clasoper.vencer 
            ";"
            /*clasoper.valaberto
            ";"*/
            clasoper.qtdparab
            skip
            .
    end.
    else if vindex = 2
    then
    for each clasoper where
                   clasoper.dtvisao = vdatref and
                   clasoper.tpvisao = vtipo_visao and
                   clasoper.cobcod  = gprodevdu.cobcod and
                   clasoper.catcod = 0 and
                   clasoper.modcod  = "CRE" and
                   clasoper.riscli  = gprodevdu.faixa_risco 
                   no-lock:
        find clien where clien.clicod = clasoper.clifor no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = "NOME".
        put unformatted
            clasoper.etbcod format ">>9"
            ";" 
            clasoper.clifor format ">>>>>>>>>9"
            ";"
            Vclinom 
            ";"
            clasoper.titnum 
            ";"
            clasoper.titdtemi
            ";"
            clasoper.vencido
            ";"
            clasoper.vencer 
            ";"
            /*clasoper.valaberto
            ";"*/
            clasoper.qtdparab
            skip
            .
    end.
    
    /*****************
    else if vindex = 3
    then
    for each tt-con where tt-con.risco = p-risco and
                          tt-con.cobcod = 10  :
        find clien where clien.clicod = tt-con.clicod no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = "NOME".
        put unformatted
            tt-con.etbcod format ">>9"
            ";" 
            tt-con.clicod format ">>>>>>>>>9"
            ";"
            Vclinom 
            ";"
            tt-con.titnum 
            ";"
            tt-con.titdtemi
            ";"
            tt-con.vencido
            ";"
            tt-con.vencer 
            ";"
            tt-con.valaberto
            ";"
            tt-con.qtdparab
            skip
            .
    end.
    ***********/
    
    hide message no-pause.


    output close.

    message color red/with
        "Arquivo csv gerado:" skip
        varqcsv
        view-as alert-box
        .
    
    varquivo = "/admcom/relat/" + lc(vtipo_visao) + "-" + lc(vmodo_visao) + "-"
                + lc(trim(vcobra[vindex])) + "-"
                + string(vdatref,"99999999") + "-risco-" 
                + p-risco + ".txt".   
    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "80"  
        &Page-Line = "66"
        &Nom-Rel   = ""gprodevduv""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "80"
        &Form      = "frame f-cabcab"}

    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao + " - " + trim(vcobra[vindex]) 
                + " - risco " + p-risco
                skip.
                
   if vindex = 1
    then
    for each clasoper where
                   clasoper.dtvisao = vdatref and
                   clasoper.tpvisao = vtipo_visao and
                   clasoper.cobcod  = gprodevdu.cobcod and
                   clasoper.catcod  = 0 and
                   clasoper.modcod  = "CRE" and
                   clasoper.riscon  = gprodevdu.faixa_risco 
                   no-lock:

        find clien where clien.clicod = clasoper.clifor no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = "NOME".
        disp clasoper.etbcod format ">>9"        column-label "Fil"
            clasoper.clifor format ">>>>>>>>>9"  column-label "Cliente"
            Vclinom                              column-label "Nome"
            clasoper.titnum                      column-label "Documento"
            clasoper.titdtemi                    column-label "Emissao"
            clasoper.vltotal(total)              column-label "Total"
            clasoper.vencido(total)              column-label "Vencido"
            clasoper.vencer(total)               column-label "Vencer"
            clasoper.qtdparab                    column-label "Par.Aberta"
            with frame fd1 down width 120
            .
        down with frame fd1.
    end.
    else if vindex = 2
    then
    for each clasoper where
                   clasoper.dtvisao = vdatref and
                   clasoper.tpvisao = vtipo_visao and
                   clasoper.cobcod  = gprodevdu.cobcod and
                   clasoper.catcod = 0 and
                   clasoper.modcod  = "CRE" and
                   clasoper.riscli  = gprodevdu.faixa_risco 
                   no-lock:
        find clien where clien.clicod = clasoper.clifor no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = "NOME".
        disp clasoper.etbcod format ">>9"        column-label "Fil"
            clasoper.clifor format ">>>>>>>>>9"  column-label "Cliente"
            Vclinom                              column-label "Nome"
            clasoper.titnum                      column-label "Documento"
            clasoper.titdtemi                    column-label "Emissao"
            clasoper.vltotal                     column-label "Total"
            clasoper.vencido(total)              column-label "Vencido"
            clasoper.vencer(total)               column-label "Vencer"
            clasoper.qtdparab                    column-label "Par.Aberta"
            with frame fd2 down width 120
            .
        down with frame fd2.
    end.
    output close.
    
    run visurel.p(input varquivo,"").
    

end procedure.
