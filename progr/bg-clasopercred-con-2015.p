/****
prodevdu
GClasCTB
connect ninja -H db2 -S sdrebninja -N tcp.
connect sensei -H 10.2.0.134 -S 60001 -N tcp.
****/


{admcab.i}
{setbrw.i}

def input parameter vdatref as date.

def temp-table tt-pdvd2015 like pdvd2015.

def var vtitnum like titulo.titnum.
def var vtitvlcob like titulo.titvlcob.
def var vdatraso as int.
def var vclinom like clien.clinom.
def var vciccgc like clien.ciccgc.
def var vdtven  like titulo.titdtven.

form vclinom column-label "Nome"
     vciccgc column-label "CPF"
     vtitnum column-label "Contrato"
     vtitvlcob format ">>>,>>>,>>9.99" column-label "Valor"
     vdtven     column-label "Vencimento"
     vdatraso   format "->>>>>>>9"         column-label "Dias Atraso"
     with frame fd2 down width 120
     .

def var vi as int.
def var vcobcod as int.
def var vtipo_visao as char.
def var vmodo_visao as char.
vtipo_visao = "GERENCIAL".
vmodo_visao = "CLIENTE".
vcobcod = 2.


def var vtipo as char extent 3 format "x(15)". 
def var vcobra as char extent 3 format "x(15)".
def var vcateg as char extent 5 format "x(14)".
vtipo[1] = "  CONTRATO".
vtipo[2] = "  CLIENTE".
/*vtipo[3] = "  OUTROS".*/

vcobra[1] = "  GERAL".
vcobra[2] = "  DREBES".
vcobra[3] = "  FINANCEIRA".
  
vcateg[1] = "  GERAL".
vcateg[2] = "  MOVEIS".
vcateg[3] = "  MODA".
vcateg[4] = "  NOVACAO".
vcateg[5] = "  OUTROS"
.

def var vcatcod as int init 0.
def var vplano as int init 0.

repeat:
disp vtipo with frame f-tipo no-label centered.
choose field vtipo with frame f-tipo.
vmodo_visao = trim(vtipo[frame-index]).


repeat:

assign
    a-seeid = -1 a-recid = -1 a-seerec = ?.
if vmodo_visao = "OUTROS"
THEN assign
        vtipo_visao = "CONTABIL"
        vmodo_visao = "CLIENTE".
ELSE vtipo_visao = "GERENCIAL".
form pdvd2015.Faixa_risco column-label "Faixa" format "x(5)"
     pdvd2015.descricao_faixa no-label format "x(12)"  
     pdvd2015.saldo_curva column-label "Curva"      format ">>>>>>>>9.99"
     pdvd2015.pctprovisao column-label "%"          format ">>>9.99"
     pdvd2015.provisao    column-label "Provisao"   format ">>>>>>>>9.99"
     pdvd2015.principal   column-label "Principal"  format ">>>>>>>>9.99"
     pdvd2015.renda       column-label "Renda"      format ">>>>>>>>9.99"
     with frame f-linha 13 down width 80
     overlay row 4 
     title " " + string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
            vmodo_visao + " ".
            /* + " - " + trim(vcobra[vindex]) + " - " +
            trim(vcateg[frame-index]) + " ".*/

def var tsaldo_curva as dec.
def var tprovisao as dec.
def var tprincipal as dec.
def var trenda as dec.

assign tsaldo_curva = 0 tprovisao    = 0 tprincipal   = 0 trenda = 0.

vtipo_visao = "GERENCIAL".
vtipo_visao = "GERENCIAL" + string(month(vdatref),"99")
                          + string(year(vdatref),"9999").

/*vtipo_visao = "CONTABIL" + string(month(vdatref),"99")
                         + string(year(vdatref),"9999").
  */                       
/*vmodo_visao = "CLIENTE".  */
def var vtpfaixa as char.
/*
vtpfaixa = "CONTABIL" + string(month(vdatref),"99")
                       + string(year(vdatref),"9999").
  */                     
vtpfaixa = "GERENCIAL" + string(month(vdatref),"99")
                       + string(year(vdatref),"9999").
                       
vtpfaixa = "CTBECDCL" + string(month(vdatref),"99")
                       + string(year(vdatref),"9999").

def var vtpvisao as char.
vtpvisao = "RECEITA".
vtpfaixa = "CTBRECEITA". 
vtpfaixa = vtpvisao.
vcobcod = ?.
vcatcod = ?.

for each pdvd2015 where pdvd2015.data_visao = vdatref     and
                        pdvd2015.tipo_visao = vtpfaixa /*vtipo_visao*/ and
                        pdvd2015.modo_visao = vmodo_visao and
                        pdvd2015.modalidade = "CRE" and
                        pdvd2015.cobcod     = ? and
                        pdvd2015.categoria  = ? and
                        pdvd2015.etbcod = 0
                        no-lock:
    assign
        tsaldo_curva = tsaldo_curva + pdvd2015.saldo_curva
        tprovisao    = tprovisao + pdvd2015.provisao
        tprincipal   = tprincipal + pdvd2015.principal
        trenda       = trenda + pdvd2015.renda
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

def var esqcom1         as char format "x(15)" extent 5
    initial ["","IMPRIME TELA","ANALITICO FAIXA","    POR FILIAL","   AVP"].

/*
def var esqcom1         as char format "x(15)" extent 5
    initial ["","IMPRIME TELA","","",""].
*/

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
hide frame f-categ no-pause.
vcobcod = ?.
vcatcod = ?.

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
        &file  = pdvd2015  
        &help  = " "
        &cfield = pdvd2015.faixa_risco
        &noncharacter = /* */  
        &ofield = " pdvd2015.descricao_faixa
                    pdvd2015.saldo_curva
                    pdvd2015.pctprovisao
                    pdvd2015.provisao
                    pdvd2015.principal
                    pdvd2015.renda
                    "  
        &aftfnd1 = " "
        &where  = " pdvd2015.data_visao = vdatref and
                    pdvd2015.tipo_visao = vtpfaixa  and
                    pdvd2015.modo_visao = vmodo_visao and 
                    pdvd2015.modalidade = ""CRE"" and
                    pdvd2015.cobcod = vcobcod and
                    pdvd2015.categoria = vcatcod and
                    pdvd2015.etbcod = 0 "
        &aftselect1 = " 
                        run aftselect.
                        if esqcom1[esqpos1] = ""IMPRIME TELA"" or
                           esqcom1[esqpos1] = ""ANALITICO FAIXA"" or
                           esqcom1[esqpos1] = ""    POR FILIAL""  or
                           esqcom1[esqpos1] = ""   AVP""
                        then leave l1.
                        else next l1.
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
hide frame f-tot no-pause.

IF vtipo_visao = "CONTABIL"
THEN LEAVE.
return.

end.
end.
procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "IMPRIME TELA"
    THEN DO on error undo:
        run relatorio.    
    END.
    if esqcom1[esqpos1] = "ANALITICO FAIXA"
    THEN DO:
        sresp = no.
        message 
        "Confirma gerar relatorio analitico faixa" pdvd2015.faixa_risco 
        update sresp.
        if sresp
        then do: 
            /*if vtipo_visao = "CONTABIL"
            then run relatorio-faixa-analitico-outros(pdvd2015.faixa_risco).
            else*/ run relatorio-faixa-analitico(pdvd2015.faixa_risco).
        end.
    END.
    if esqcom1[esqpos1] = "    POR FILIAL"
    THEN DO:
        if vtipo_visao = "GERENCIAL" /*"CONTABIL"*/
        then run relatorio-faixa-filial.
    END.
    if esqcom1[esqpos1] = "   AVP"
    THEN DO:
        if vtipo_visao = "CONTABIL"
        then run relatorio-avp-analitico-outros.
    END.
    /*
    if esqcom2[esqpos2] = "    "
    THEN DO on error undo:
    
    END.
    **/
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
    def var vencidos as dec.
    def var vencer90 like pdvd2015.vencer_90 .
    def var vencer360 like pdvd2015.vencer_360.
    def var vencer1080 like pdvd2015.vencer_1080.
    def var vencer1800 like pdvd2015.vencer_1800 .
    def var vencer5400 like pdvd2015.vencer_5400  .
    def var vencer9999 like pdvd2015.vencer_9999   .
     
    varquivo = "/admcom/relat/bga-cliente-" 
                + string(vdatref,"99999999") + "-" + string(time).
    varqcsv = "l:\relat\bga-cliente-"
                    + string(vdatref,"99999999") + "-" + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "80"  
        &Page-Line = "66"
        &Nom-Rel   = ""pdvd2015v""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "80"
        &Form      = "frame f-cabcab"}

    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao /*+ " - " + trim(vcobra[vindex])*/ + " "
                skip.
                
    vi = 0. 

    for each pdvd2015 where 
             pdvd2015.data_visao = vdatref and
             pdvd2015.tipo_visao = vtipo_visao and
             pdvd2015.modo_visao = vmodo_visao and
             pdvd2015.modalidade = "CRE" and
             pdvd2015.cobcod     = vcobcod and
             pdvd2015.categoria  = vcatcod and
             pdvd2015.faixa_risco <> "" no-lock:
        
        /*
        find first tbcntgen where
                   tbcntgen.tipcon = 13 and
                   tbcntgen.campo1[1] = pdvd2015.faixa_risco 
                   no-lock no-error.
        if avail tbcntgen
        then pdvd2015.descricao_faixa = tbcntgen.numini + "-" +
                            tbcntgen.numfim.
        */

        if pdvd2015.faixa_risco < "H"
        then assign
            vencidos = pdvd2015.vencido
            vencer90 = pdvd2015.vencer_90
            vencer360 = pdvd2015.vencer_360
            vencer1080 = pdvd2015.vencer_1080
            vencer1800 = pdvd2015.vencer_1800
            vencer5400 = pdvd2015.vencer_5400 
            vencer9999 = pdvd2015.vencer_9999
            .
        else assign
            vencidos = pdvd2015.vencido +
                       pdvd2015.vencer_90 + pdvd2015.vencer_360 +
                       pdvd2015.vencer_1080 + pdvd2015.vencer_1800 +
                       pdvd2015.vencer_5400 + pdvd2015.vencer_9999
            vencer90 = 0
            vencer360 = 0
            vencer1080 = 0
            vencer1800 = 0
            vencer5400 = 0
            vencer9999 = 0
            .

        disp pdvd2015.faixa_risco column-label "Faixa"
             pdvd2015.descricao_faixa no-label   format "x(12)"
             vencidos column-label "Vencidos"
             format ">>>,>>>,>>9.99" (total)
             vencer90  column-label "Vencer!Ate 3 meses"
             format ">>>,>>>,>>9.99" (total)
             vencer360 column-label "Vencer!3 a 12 meses"
             format ">>>,>>>,>>9.99"  (total)
             vencer1080 column-label "Vencer!1 a 3 anos"
             format ">>>,>>>,>>9.99"  (total) 
             vencer1800 column-label "Vencer!3 a 5 anos"
             format ">>>,>>>,>>9.99"  (total)
             vencer5400 column-label "Vencer!5 a 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             vencer9999 column-label "Vencer!+ 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             pdvd2015.saldo_curva  column-label "Saldo Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             pdvd2015.provisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             pdvd2015.pctprovisao column-label "%"
             pdvd2015.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             pdvd2015.renda(total) column-label "Renda"
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
    def var vtotal as dec.
    def var vindex as int.
    def var valaberto as dec.
    if vmodo_visao = "CONTRATO"
    then vindex = 1.
    else vindex = 2.
    
    varquivo = "/admcom/relat/saldo-clientes-"
                + string(vdatref,"99999999") + "-risco-" 
                + p-risco + ".csv".    

    disp "Gerando relatorio... Aguarde!" skip
         varquivo format "x(70)"
        with frame f-dd 1 down centered overlay color message
        row 10 no-label.
    pause 0.
 
    /*************
    output to value(varquivo).
    put 
    "Filial;Codigo;CPF/CGC;Nome;Contrato;Emissao;Vencimento;Total;Vencido;Vencer;;Provisao;Parcelas" 
    skip.
    if vindex = 1
    then
    for each GClasOPC where
                   GClasOPC.dtvisao = vdatref and
                   GClasOPC.tpvisao = vtipo_visao and
                   GClasOPC.cobcod  = 2 and
                   /*GClasOPC.catcod  = 0 and*/
                   GClasOPC.modcod  = "CRE" and
                   GClasOPC.riscon  = pdvd2015.faixa_risco and
                   GClasOPC.situacao = ""
                   no-lock:

        find clien where clien.clicod = GClasOPC.clifor no-lock no-error.
        if avail clien
        then assign
                vclinom = clien.clinom
                vciccgc = clien.ciccgc.
        else assign
                vclinom = "NOME"
                vciccgc = "CPF".
        find first titulo where
                   titulo.clifor = GClasOPC.clifor and
                   titulo.titnum = GClasOPC.titnum and
                   (titulo.titsit = "LIB" or
                   (titulo.titsit = "PAG" and
                    titulo.titdtpag > vdatref))
                   no-lock no-error.
        if avail titulo
        then vdtven = titulo.titdtven.
        else do:
            find first sc2015 where
                   sc2015.clifor = GClasOPC.clifor and
                   sc2015.titnum = GClasOPC.titnum and
                   (sc2015.titsit = "LIB" or
                   (sc2015.titsit = "PAG" and
                    sc2015.titdtpag > vdatref))
                   no-lock no-error.
            if avail sc2015
            then vdtven = sc2015.titdtven.
        end.
        vprovisao = (GClasOPC.vencido + GClasOPC.vencer) *                             (pdvd2015.pctprovisao / 100).
        valaberto = GClasOPC.vencido + GClasOPC.vencer.
        put unformatted
            GClasOPC.etbcod format ">>9"
            ";" 
            GClasOPC.clifor format ">>>>>>>>>9"
            ";"
            vciccgc
            ";"
            Vclinom 
            ";"
            GClasOPC.titnum 
            ";"
            GClasOPC.titdtemi
            ";"
            vdtven
            ";"
            valaberto         format ">>>>>>>>9.99"
            ";"
            GClasOPC.vencido  format ">>>>>>>>9.99"
            ";"
            GClasOPC.vencer   format ">>>>>>>>9.99"
            ";"
            vprovisao         format ">>>>>>>>9.99"
            ";"
            GClasOPC.qtdparab
            skip
            .
    end.
    else if vindex = 2
    then
    
    for each GClasOPC where
                   GClasOPC.dtvisao = vdatref and
                   GClasOPC.tpvisao = vtipo_visao and
                   GClasOPC.cobcod  = 2 and
                   /*GClasOPC.catcod  => 0 and*/
                   GClasOPC.modcod  = "CRE" and
                   GClasOPC.riscli  = pdvd2015.faixa_risco and
                   GClasOPC.situacao = ""
                   no-lock:
        find clien where clien.clicod = GClasOPC.clifor no-lock no-error.
        if avail clien
        then assign
                vclinom = clien.clinom
                vciccgc = clien.ciccgc.
        else assign
                vclinom = "NOME"
                vciccgc = "CPF".
        vdtven = ?.
        find first titulo where
                   titulo.clifor = GClasOPC.clifor and
                   titulo.titnum = GClasOPC.titnum and
                   (titulo.titsit = "LIB" or
                   (titulo.titsit = "PAG" and
                    titulo.titdtpag > vdatref))
                   no-lock no-error.
        if avail titulo
        then vdtven = titulo.titdtven.
        else do:
            find first sc2015 where
                   sc2015.clifor = GClasOPC.clifor and
                   sc2015.titnum = GClasOPC.titnum and
                   (sc2015.titsit = "LIB" or
                   (sc2015.titsit = "PAG" and
                    sc2015.titdtpag > vdatref))
                   no-lock no-error.
            if avail sc2015
            then vdtven = sc2015.titdtven.
        end.
        vprovisao = (GClasOPC.vencido + GClasOPC.vencer) *
                                    (pdvd2015.pctprovisao / 100).
                                    
        put unformatted
            GClasOPC.etbcod format ">>9"
            ";" 
            GClasOPC.clifor format ">>>>>>>>>9"
            ";"
            vciccgc
            ";"
            Vclinom 
            ";"
            GClasOPC.titnum 
            ";"
            GClasOPC.titdtemi
            ";"
            vdtven
            ";"
            valaberto         format ">>>>>>>>9.99"
            ";"
            GClasOPC.vencido  format ">>>>>>>>9.99"
            ";"
            GClasOPC.vencer   format ">>>>>>>>9.99"
            ";"
            vprovisao         format ">>>>>>>>9.99"
            ";"
            GClasOPC.qtdparab
            skip
            .
    end.
    *************/
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
    
    hide message no-pause.


    output close.

    message color red/with
        "Arquivo csv gerado:" skip
        varqcsv
        view-as alert-box
        .
    **************/


    varquivo = "/admcom/relat/saldo-clientes-" 
                + string(vdatref,"99999999") + "-risco-" 
                + p-risco + ".txt".   

    /**************
    {md-adm-cab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "190"  
        &Page-Line = "66"
        &Nom-Rel   = ""pdvd2015v""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """ RELATORIO CLIENTES """
        &Width     = "120"
        &Form      = "frame f-cabcab"}

    
    
    put unformatted string(vdatref,"99/99/9999") 
                + " - risco " + p-risco
                skip.

    for each visdev15 where visdev15.data_visao = vdatref  and
                            visdev15.tipo_visao = vtpvisao and
                            visdev15.risco_cliente = p-risco and
                            visdev15.situacao = ""
                            no-lock:

        find clien where clien.clicod = visdev15.clifor no-lock no-error.
        if avail clien
        then assign
                vclinom = clien.clinom
                vciccgc = clien.ciccgc.
        else assign
                vclinom = "NOME"
                vciccgc = "CPF".

        for each titulo where
                 titulo.empcod = visdev15.empcod and
                 titulo.titnat = visdev15.titnat and
                 titulo.modcod = visdev15.modcod and
                 titulo.titdtemi = visdev15.titdtemi and
                 titulo.etbcod = visdev15.etbcod and
                 titulo.clifor = visdev15.clifor and
                 titulo.titnum = visdev15.titnum and
                 (titulo.titsit = "LIB" or
                 (titulo.titsit = "PAG" and
                  titulo.titdtpag > vdatref)) 
                 no-lock: 
            if visdev15.qtdatr > 0 /*220*/
            then vdtven = titulo.titdtven - visdev15.qtdat.
            else vdtven = titulo.titdtven.
            vtitnum = titulo.titnum.
            vtitvlcob = titulo.titvlcob.
            vdatraso = vdatref - vdtven.
            disp vclinom 
                 vciccgc 
                 vtitnum 
                 vtitvlcob 
                 vdtven         
                 vdatraso
                with frame fd2 .
            down with frame fd2.
            vtotal = vtotal + titulo.titvlcob.
        end.
        for each titadd15 where
                 titadd15.empcod = visdev15.empcod and
                 titadd15.titnat = visdev15.titnat and
                 titadd15.modcod = visdev15.modcod and
                 titadd15.titdtemi = visdev15.titdtemi and
                 titadd15.etbcod = visdev15.etbcod and
                 titadd15.clifor = visdev15.clifor and
                 titadd15.titnum = visdev15.titnum and
                 (titadd15.titsit = "LIB" or
                 (titadd15.titsit = "PAG" and
                  titadd15.titdtpag > vdatref)) 
                 no-lock: 
            if visdev15.qtdatr > 0 /*220*/
            then vdtven = titadd15.titdtven - visdev15.qtdat.
            else vdtven = titadd15.titdtven.
            vtitnum = titadd15.titnum.
            vtitvlcob = titadd15.titvlcob.
            vdatraso = vdatref - vdtven.
            disp vclinom 
                 vciccgc 
                 vtitnum 
                 vtitvlcob 
                 vdtven                  
                 vdatraso
                with frame fd2 .

            down with frame fd2.
            vtotal = vtotal + titadd15.titvlcob.
        end.

    end.    
  
    disp vtotal @ titulo.titvlcob with frame fd2. 
    output close.
    *********************/
    def var valchar as char.
    def var varq as char.
    def var vok as log.
    
    varq = "/admcom/relat/saldo-clientes-" 
                + string(vdatref,"99999999") + "-risco-" 
                + p-risco + ".csv". 
    
    /*
    varq = "/admcom/Contabilidade/clientes2015/saldo-clientes-"
                    + string(vdatref,"99999999") + "-risco-"
                                    + p-risco + ".csv".
    */                                
    output to value(varq).
    put "Nome;CPF;Numero;Valor;Vencimento;Atraso" skip.
    vtotal = 0.                  
    for each visdev15 where visdev15.data_visao = vdatref  and
                            visdev15.tipo_visao = vtpvisao and
                            visdev15.risco_cliente = p-risco and
                            visdev15.situacao <> "EXCECD"
                            no-lock:

        if visdev15.total_vencido = 0 and
           visdev15.total_vencer = 0
        then next.    
        /*find clien where clien.clicod = visdev15.clifor no-lock no-error.
        if avail clien
        then*/ assign
                vclinom = visdev15.nome
                vciccgc = visdev15.cpf.
        /*else assign
                vclinom = "NOME"
                vciccgc = "CPF".
        */
        vok = no.
        if visdev15.vencimento_arquivo = ?
        then do:
        for each titulo where
                 titulo.empcod = visdev15.empcod and
                 titulo.titnat = visdev15.titnat and
                 titulo.modcod = visdev15.modcod and
                 titulo.titdtemi = visdev15.titdtemi and
                 titulo.etbcod = visdev15.etbcod and
                 titulo.clifor = visdev15.clifor and
                 titulo.titnum = visdev15.titnum and
                 (titulo.titsit = "LIB" or
                 (titulo.titsit = "PAG" and
                  titulo.titdtpag > vdatref)) 
                 no-lock: 
            if titulo.titvlcob > 0  and
               titulo.titdtven <> ?  and
               titulo.titdtven < 01/01/2030 and
               titulo.titdtven > 01/01/1990
            then do:                                  
                if visdev15.qtdatr > 0 /*220*/
                then vdtven = titulo.titdtven - visdev15.qtdat.
                else vdtven = titulo.titdtven.
                valchar = string(titulo.titvlcob).
                valchar = replace(valchar,",","").
                valchar = replace(valchar,".",",").
                put unformatted 
                vclinom 
                ";"
                vciccgc 
                ";"
                titulo.titnum 
                ";"
                valchar
                ";"
                vdtven 
                ";"
                .
                if vdatref - vdtven > 0
                then put vdatref - vdtven .
                else put "" 
                    .

                put skip.

                vtotal = vtotal + titulo.titvlcob.
                vok = yes.
            end.
        end.
        if vok = no
        then for each titadd15 where
                 titadd15.empcod = visdev15.empcod and
                 titadd15.titnat = visdev15.titnat and
                 titadd15.modcod = visdev15.modcod and
                 titadd15.titdtemi = visdev15.titdtemi and
                 titadd15.etbcod = visdev15.etbcod and
                 titadd15.clifor = visdev15.clifor and
                 titadd15.titnum = visdev15.titnum and
                 (titadd15.titsit = "LIB" or
                 (titadd15.titsit = "PAG" and
                  titadd15.titdtpag > vdatref)) 
                 no-lock:
            if titadd15.titvlcob > 0  and
               titadd15.titdtven <> ?  and
               titadd15.titdtven < 01/01/2030 and
               titadd15.titdtven > 01/01/1990
            then do:       
                if visdev15.qtdatr > 0 /*220*/
                then vdtven = titadd15.titdtven - visdev15.qtdat.
                else vdtven = titadd15.titdtven.
                valchar = string(titadd15.titvlcob).
                valchar = replace(valchar,",","").
                valchar = replace(valchar,".",",").
                put unformatted 
                vclinom 
                ";"
                vciccgc 
                ";"
                titadd15.titnum 
                ";"
                valchar
                ";"
                vdtven 
                ";"
                .
                if vdatref - vdtven > 0
                then put vdatref - vdtven .
                else put "" 
                .

                put skip.

                vtotal = vtotal + titadd15.titvlcob.
            end.
        end.
        end.
        else do:
            vdtven = visdev15.vencimento_arquivo.
            valchar = string(visdev15.total_vencido + 
                             visdev15.total_vencer).
                valchar = replace(valchar,",","").
                valchar = replace(valchar,".",",").
                put unformatted 
                vclinom 
                ";"
                vciccgc 
                ";"
                visdev15.titnum 
                ";"
                valchar
                ";"
                vdtven 
                ";"
                .
                if vdatref - vdtven > 0
                then put vdatref - vdtven .
                else put "" 
                .

                put skip.

                vtotal = vtotal + 
                            visdev15.total_vencido + visdev15.total_vencer.
 
        end.
    end. 
    output close.

    message color red/with
    "Arquivo gerado"
    varq skip
    "Total:" vtotal
    view-as alert-box
    .
    
    /**********
    run visurel.p(input varquivo,"").
    *********/

end procedure.



