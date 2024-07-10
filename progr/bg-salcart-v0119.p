
{admcab.i}
{setbrw.i}

def temp-table tt-pdvd2018 like pdvd2018.

def var vi as int.
def var vdatref as date format "99/99/9999".
def var vcobcod as int.
def var vtipo_visao as char.
def var vmodo_visao as char.
vtipo_visao = "GERENCIAL".
vmodo_visao = "CLIENTE".
vcobcod = 2.

find last pdvd2018 no-lock no-error.
if avail pdvd2018
then vdatref = pdvd2018.data_visao.

update vdatref label "Data referencia" with frame f-dat side-label 1 down
width 80 row 4.
if vdatref > 10/01/18 and
   vdatref < 12/01/18
then return.
  
/*********
if vdatref < 01/01/18
then do:
    if vdatref < 01/01/15 
    then run bg-clasopercred-con-2014.p(vdatref).
    else if vdatref < 01/01/16 
    then run bg-clasopercred-con-2015.p(vdatref).
    else if vdatref < 01/01/17
    then run bg-clasopercred-con-2016.p(vdatref).
    else if vdatref < 01/01/18
    then run bg-clasopercred-con-2017.p(vdatref).
    return.
end.
****/

find first pdvd2018 where pdvd2018.data_visao = vdatref and
                          pdvd2018.tipo_visao = vtipo_visao 
                          no-lock no-error.
if not avail pdvd2018 or sfuncod = 698 or sfuncod = 101
then do:
    /*
    run bg-clasopercred-v0117.p(vdatref).
    */
end.

def var vtipo as char extent 3 format "x(15)". 
def var vcobra as char extent 3 format "x(15)".
def var vcateg as char extent 5 format "x(14)".
vtipo[1] = "  CONTRATO".
vtipo[2] = "  CLIENTE".
vtipo[3] = "  OUTROS".

vcobra[1] = "  GERAL".
vcobra[2] = "  DREBES".
vcobra[3] = "  FINANCEIRA".
  
vcateg[1] = "  GERAL".
vcateg[2] = "  MOVEIS".
vcateg[3] = "  MODA".
vcateg[4] = "  NOVACAO".
vcateg[5] = "  OUTROS"
.

repeat:
disp vtipo with frame f-tipo no-label centered.
choose field vtipo with frame f-tipo.
vmodo_visao = trim(vtipo[frame-index]).

def var vindex as int.

if vmodo_visao = "OUTROS"
then assign
        vindex = 1
        vcobcod = 2.
else do:
disp vcobra with frame f-cobra no-label centered.
choose field vcobra with frame f-cobra.
if trim(vcobra[frame-index]) = "GERAL"
then assign
        vindex = 1
        vcobcod = ?.
else if trim(vcobra[frame-index]) = "DREBES"
    then assign
            vindex = 1
            vcobcod = 2.
    else if trim(vcobra[frame-index]) = "FINANCEIRA"
        THEN assign
                vindex = 2
                vcobcod = 10.

disp vcateg with frame f-categ no-label centered.
end.

repeat:
view frame f-dat.
view frame f-tipo.
view frame f-cobra.
def var vcatcod as int init 0.
def var vplano as int init 0.
vcatcod = 0.
vplano  = 0.
if vmodo_visao = "OUTROS"
then.
else do:
disp vcateg with frame f-categ no-label centered.
choose field vcateg with frame f-categ.
if frame-index = 1
then vcatcod = ?.
else if frame-index = 2
    then vcatcod = 31.
    else if frame-index = 3
        then vcatcod = 41.
        else if frame-index = 4
            then vcatcod = 500.
            else if frame-index = 5
                then vcatcod = 99.    

end.
assign
    a-seeid = -1 a-recid = -1 a-seerec = ?.
if vmodo_visao = "OUTROS"
THEN assign
        vtipo_visao = "CONTABIL"
        vmodo_visao = "CLIENTE".
ELSE vtipo_visao = "GERENCIAL".
form pdvd2018.Faixa_risco column-label "Faixa" format "x(5)"
     pdvd2018.descricao_faixa no-label format "x(12)"  
     pdvd2018.saldo_curva column-label "Curva"      format ">>>>>>>>9.99"
     pdvd2018.pctprovisao column-label "%"          format ">>>9.99"
     pdvd2018.provisao    column-label "Provisao"   format ">>>>>>>>9.99"
     pdvd2018.principal   column-label "Principal"  format ">>>>>>>>9.99"
     pdvd2018.renda       column-label "Renda"      format ">>>>>>>>9.99"
     with frame f-linha 13 down width 80
     overlay row 4  
     title " " + string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
            vmodo_visao + " - " + trim(vcobra[vindex]) + " - " +
            trim(vcateg[frame-index]) + " ".

def var tsaldo_curva as dec.
def var tprovisao as dec.
def var tprincipal as dec.
def var trenda as dec.

assign tsaldo_curva = 0 tprovisao    = 0 tprincipal   = 0 trenda = 0.

for each pdvd2018 where pdvd2018.data_visao = vdatref     and
                        pdvd2018.tipo_visao = vtipo_visao and
                        pdvd2018.modo_visao = vmodo_visao and
                        pdvd2018.modalidade = "CRE" and
                        pdvd2018.cobcod     = vcobcod and
                        pdvd2018.categoria  = vcatcod and
                        pdvd2018.etbcod = 0
                        no-lock:
    assign
        tsaldo_curva = tsaldo_curva + pdvd2018.saldo_curva
        tprovisao    = tprovisao + pdvd2018.provisao
        tprincipal   = tprincipal + pdvd2018.principal
        trenda       = trenda + pdvd2018.renda
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
    initial ["","IMPRIME TELA","ANALITICO FAIXA","    POR FILIAL","    AVP"].
*/

def var esqcom1         as char format "x(15)" extent 5
    initial ["","IMPRIME TELA","","","    AVP"].

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

if vmodo_visao <> "CLIENTE"
then esqcom1[5] = "".

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
        &file  = pdvd2018  
        &help  = " "
        &cfield = pdvd2018.faixa_risco
        &noncharacter = /* */  
        &ofield = " pdvd2018.descricao_faixa
                    pdvd2018.saldo_curva
                    pdvd2018.pctprovisao
                    pdvd2018.provisao
                    pdvd2018.principal
                    pdvd2018.renda
                    "  
        &aftfnd1 = " "
        &where  = " pdvd2018.data_visao = vdatref and
                    pdvd2018.tipo_visao = vtipo_visao and
                    pdvd2018.modo_visao = vmodo_visao and 
                    pdvd2018.modalidade = ""CRE"" and
                    pdvd2018.cobcod = vcobcod and
                    pdvd2018.categoria = vcatcod and
                    pdvd2018.etbcod = 0 "
        &aftselect1 = " 
                        run aftselect.
                        if esqcom1[esqpos1] = ""IMPRIME TELA"" or
                           esqcom1[esqpos1] = ""ANALITICO FAIXA"" or
                           esqcom1[esqpos1] = ""    POR FILIAL""  or
                           esqcom1[esqpos1] = ""    AVP""
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
        if vtipo_visao = "CONTABIL"
        then run relatorio-faixa-analitico-outros(pdvd2018.faixa_risco).
        else run relatorio-faixa-analitico(pdvd2018.faixa_risco).
    END.
    if esqcom1[esqpos1] = "    POR FILIAL"
    THEN DO:
        if vtipo_visao = "GERENCIAL" /*"CONTABIL"*/
        then run relatorio-faixa-filial.
    END.
    if esqcom1[esqpos1] = "    AVP"
    THEN DO:
        run reltroio-AVP-txt.
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
    def var vencer90 like pdvd2018.vencer_90 .
    def var vencer360 like pdvd2018.vencer_360.
    def var vencer1080 like pdvd2018.vencer_1080.
    def var vencer1800 like pdvd2018.vencer_1800 .
    def var vencer5400 like pdvd2018.vencer_5400  .
    def var vencer9999 like pdvd2018.vencer_9999   .
     
    varquivo = "/admcom/relat/bga-cliente-" 
                + string(vdatref,"99999999") + "-" + string(time).
    varqcsv = "l:\relat\bga-cliente-"
                    + string(vdatref,"99999999") + "-" + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "80"  
        &Page-Line = "66"
        &Nom-Rel   = ""pdvd2018v""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "80"
        &Form      = "frame f-cabcab"}

    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao + " - " + trim(vcobra[vindex]) + " "
                skip.
                
    vi = 0. 

    for each pdvd2018 where 
             pdvd2018.data_visao = vdatref and
             pdvd2018.tipo_visao = vtipo_visao and
             pdvd2018.modo_visao = vmodo_visao and
             pdvd2018.modalidade = "CRE" and
             pdvd2018.cobcod     = vcobcod and
             pdvd2018.categoria  = vcatcod and
             pdvd2018.faixa_risco <> "" no-lock:
        
        /*
        find first tbcntgen where
                   tbcntgen.tipcon = 13 and
                   tbcntgen.campo1[1] = pdvd2018.faixa_risco 
                   no-lock no-error.
        if avail tbcntgen
        then pdvd2018.descricao_faixa = tbcntgen.numini + "-" +
                            tbcntgen.numfim.
        */

        if pdvd2018.faixa_risco < "H"
        then assign
            vencidos = pdvd2018.vencido
            vencer90 = pdvd2018.vencer_90
            vencer360 = pdvd2018.vencer_360
            vencer1080 = pdvd2018.vencer_1080
            vencer1800 = pdvd2018.vencer_1800
            vencer5400 = pdvd2018.vencer_5400 
            vencer9999 = pdvd2018.vencer_9999
            .
        else assign
            vencidos = pdvd2018.vencido +
                       pdvd2018.vencer_90 + pdvd2018.vencer_360 +
                       pdvd2018.vencer_1080 + pdvd2018.vencer_1800 +
                       pdvd2018.vencer_5400 + pdvd2018.vencer_9999
            vencer90 = 0
            vencer360 = 0
            vencer1080 = 0
            vencer1800 = 0
            vencer5400 = 0
            vencer9999 = 0
            .

        disp pdvd2018.faixa_risco column-label "Faixa"
             pdvd2018.descricao_faixa no-label   format "x(12)"
             /*
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
             */
             pdvd2018.saldo_curva  column-label "Saldo Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             pdvd2018.pctprovisao column-label "%"
             pdvd2018.provisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             pdvd2018.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             pdvd2018.renda(total) column-label "Renda"
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
             /*fn-risco.ven-90  column-label "Vencer!Ate 3 meses"
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
             format ">>>,>>>,>>9.99"  (total) */
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

/*****************************************************

procedure relatorio-faixa-analitico:
    def input parameter p-risco as char.
    def var varquivo as char.
    def var varqcsv as char.
    def var sld-curva as dec.
    def var vprovisao as dec.
    def var vclinom like clien.clinom.
    def var vtotal as dec.
    def var vindex as int.
    def var vdtven as date.
    def var valaberto as dec.
    def var vciccgc like clien.ciccgc.
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
    "Filial;Codigo;CPF/CGC;Nome;Contrato;Emissao;Vencimento;Total;Vencido;Vencer;;Provisao;Parcelas" 
    skip.
    if vindex = 1
    then
    for each visdev18 where
                   visdev18.data_visao = vdatref and
                   visdev18.tipo_visao = vtipo_visao and
                   visdev18.cobcod  = 2 and
                   /*visdev18.catcod  = 0 and*/
                   visdev18.modcod  = "CRE" and
                   visdev18.risco_contrato  = pdvd2018.faixa_risco and
                   visdev18.situacao = ""
                   no-lock:

        find clien where clien.clicod = visdev18.clifor no-lock no-error.
        if avail clien
        then assign
                vclinom = clien.clinom
                vciccgc = clien.ciccgc.
        else assign
                vclinom = "NOME"
                vciccgc = "CPF".
        find first titulo where
                   titulo.clifor = visdev18.clifor and
                   titulo.titnum = visdev18.titnum and
                   (titulo.titsit = "LIB" or
                   (titulo.titsit = "PAG" and
                    titulo.titdtpag > vdatref))
                   no-lock no-error.
        if avail titulo
        then vdtven = titulo.titdtven.
        else do:
            find first sc2015 where
                   sc2015.clifor = visdev18.clifor and
                   sc2015.titnum = visdev18.titnum and
                   (sc2015.titsit = "LIB" or
                   (sc2015.titsit = "PAG" and
                    sc2015.titdtpag > vdatref))
                   no-lock no-error.
            if avail sc2015
            then vdtven = sc2015.titdtven.
        end.
        vprovisao = (visdev18.total_vencido + visdev18.total_vencer) *                             (pdvd2018.pctprovisao / 100).
        valaberto = visdev18.total_vencido + visdev18.total_vencer.
        put unformatted
            visdev18.etbcod format ">>9"
            ";" 
            visdev18.clifor format ">>>>>>>>>9"
            ";"
            vciccgc
            ";"
            Vclinom 
            ";"
            visdev18.titnum 
            ";"
            visdev18.titdtemi
            ";"
            vdtven
            ";"
            valaberto         format ">>>>>>>>9.99"
            ";"
            visdev18.total_vencido  format ">>>>>>>>9.99"
            ";"
            visdev18.total_vencer   format ">>>>>>>>9.99"
            ";"
            vprovisao         format ">>>>>>>>9.99"
            /*";"
            visdev18.qtdparab*/
            skip
            .
    end.
    else if vindex = 2
    then
    for each visdev18 where
                   visdev18.data_visao = vdatref and
                   visdev18.tipo_visao = vtipo_visao and
                   visdev18.cobcod  = 2 and
                   /*visdev18.catcod  => 0 and*/
                   visdev18.modcod  = "CRE" and
                   visdev18.risco_cliente  = pdvd2018.faixa_risco and
                   visdev18.situacao = ""
                   no-lock:
        find clien where clien.clicod = visdev18.clifor no-lock no-error.
        if avail clien
        then assign
                vclinom = clien.clinom
                vciccgc = clien.ciccgc.
        else assign
                vclinom = "NOME"
                vciccgc = "CPF".
        vdtven = ?.
        find first titulo where
                   titulo.clifor = visdev18.clifor and
                   titulo.titnum = visdev18.titnum and
                   (titulo.titsit = "LIB" or
                   (titulo.titsit = "PAG" and
                    titulo.titdtpag > vdatref))
                   no-lock no-error.
        if avail titulo
        then vdtven = titulo.titdtven.
        else do:
            find first sc2015 where
                   sc2015.clifor = visdev18.clifor and
                   sc2015.titnum = visdev18.titnum and
                   (sc2015.titsit = "LIB" or
                   (sc2015.titsit = "PAG" and
                    sc2015.titdtpag > vdatref))
                   no-lock no-error.
            if avail sc2015
            then vdtven = sc2015.titdtven.
        end.
        vprovisao = (visdev18.total_vencido + visdev18.total_vencer) *
                                    (pdvd2018.pctprovisao / 100).
                                    
        put unformatted
            visdev18.etbcod format ">>9"
            ";" 
            visdev18.clifor format ">>>>>>>>>9"
            ";"
            vciccgc
            ";"
            Vclinom 
            ";"
            visdev18.titnum 
            ";"
            visdev18.titdtemi
            ";"
            vdtven
            ";"
            valaberto         format ">>>>>>>>9.99"
            ";"
            visdev18.total_vencido  format ">>>>>>>>9.99"
            ";"
            visdev18.total_vencer   format ">>>>>>>>9.99"
            ";"
            vprovisao         format ">>>>>>>>9.99"
            /*";"
            visdev18.qtdparab*/
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
    {md-adm-cab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "190"  
        &Page-Line = "66"
        &Nom-Rel   = ""pdvd2018v""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "190"
        &Form      = "frame f-cabcab"}

    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao + " - " + trim(vcobra[vindex]) 
                + " - risco " + p-risco
                skip.
                
   if vindex = 1
    then
    for each visdev18 where
                   visdev18.dtvisao = vdatref and
                   visdev18.tpvisao = vtipo_visao and
                   visdev18.cobcod  = 2 and
                   /*visdev18.catcod  = 0 and*/
                   visdev18.modcod  = "CRE" and
                   visdev18.riscon  = pdvd2018.faixa_risco and
                   visdev18.situacao = "" 
                   no-lock:

        find clien where clien.clicod = visdev18.clifor no-lock no-error.
        if avail clien
        then assign
                vclinom = clien.clinom
                vciccgc = clien.ciccgc.
        else assign
                vclinom = "NOME"
                vciccgc = "CPF".
   
        find first titulo where
                   titulo.clifor = visdev18.clifor and
                   titulo.titnum = visdev18.titnum and
                   (titulo.titsit = "LIB" or
                   (titulo.titsit = "PAG" and
                    titulo.titdtpag > vdatref))
                   no-lock no-error.
        if avail titulo
        then vdtven = titulo.titdtven.
        else do:
            find first sc2015 where
                   sc2015.clifor = visdev18.clifor and
                   sc2015.titnum = visdev18.titnum and
                   (sc2015.titsit = "LIB" or
                   (sc2015.titsit = "PAG" and
                    sc2015.titdtpag > vdatref))
                   no-lock no-error.
            if avail sc2015
            then vdtven = sc2015.titdtven.
        end.

        vprovisao = (visdev18.vencido + visdev18.vencer) *
                                    (pdvd2018.pctprovisao / 100).
         
        vtotal = visdev18.vencido + visdev18.vencer.


        disp visdev18.etbcod format ">>9"        column-label "Fil"
            visdev18.clifor format ">>>>>>>>>9"  column-label "Cliente"
            vciccgc                              column-label "CPF/CGC"
            Vclinom                              column-label "Nome"
            visdev18.titnum                      column-label "Documento"
            visdev18.titdtemi                    column-label "Emissao"
            vdtven                               column-label "Vencimento"
            vtotal(total)              column-label "Total"
            format ">>>,>>>,>>9.99"
            visdev18.vencido(total)              column-label "Vencido"
            format ">>>,>>>,>>9.99"
            visdev18.vencer(total)  column-label "Vencer"
            format ">>>,>>>,>>9.99"
            vprovisao(total)                     column-label "Provisao"
            format ">>>,>>>,>>9.99"
            visdev18.qtdparab                    column-label "Par.Aberta"
            with frame fd1 down width 200
            .
        down with frame fd1.
    end.
    else if vindex = 2
    then
    for each visdev18 where
                   visdev18.dtvisao = vdatref and
                   visdev18.tpvisao = vtipo_visao and
                   visdev18.cobcod  = 2 and
                   /*visdev18.catcod = 0 and */
                   visdev18.modcod  = "CRE" and
                   visdev18.riscli  = pdvd2018.faixa_risco and
                   visdev18.situacao = ""
                   no-lock:
        find clien where clien.clicod = visdev18.clifor no-lock no-error.
        if avail clien
        then assign
                vclinom = clien.clinom
                vciccgc = clien.ciccgc.
        else assign
                vclinom = "NOME"
                vciccgc = "CPF".
        find first titulo where
                   titulo.clifor = visdev18.clifor and
                   titulo.titnum = visdev18.titnum and
                   (titulo.titsit = "LIB" or
                   (titulo.titsit = "PAG" and
                    titulo.titdtpag > vdatref))
                   no-lock no-error.
        if avail titulo
        then vdtven = titulo.titdtven.
        else do:
            find first sc2015 where
                   sc2015.clifor = visdev18.clifor and
                   sc2015.titnum = visdev18.titnum and
                   (sc2015.titsit = "LIB" or
                   (sc2015.titsit = "PAG" and
                    sc2015.titdtpag > vdatref))
                   no-lock no-error.
            if avail sc2015
            then vdtven = sc2015.titdtven.
        end.

        vprovisao = (visdev18.vencido + visdev18.vencer) *
                                    (pdvd2018.pctprovisao / 100).
        vtotal = visdev18.vencido + visdev18.vencer.
        
        disp visdev18.etbcod format ">>9"        column-label "Fil"
            visdev18.clifor format ">>>>>>>>>9"  column-label "Cliente"
            vciccgc                              column-label "CPF/CGC"
            Vclinom                              column-label "Nome"
            visdev18.titnum                      column-label "Documento"
            visdev18.titdtemi                    column-label "Emissao"
            vdtven                               column-label "Vencimento"
            vtotal(total)                        column-label "Total"
            format ">>>,>>>,>>9.99"
            visdev18.vencido(total)              column-label "Vencido"
            format ">>>,>>>,>>9.99"
            visdev18.vencer(total)               column-label "Vencer"
            format ">>>,>>>,>>9.99"
            vprovisao(total)                     column-label "Provisao"
            format ">>>,>>>,>>9.99" 
            visdev18.qtdparab                    column-label "Par.Aberta"
            with frame fd2 down width 200
            .
        down with frame fd2.
    end.
    output close.
    
    run visurel.p(input varquivo,"").
    

end procedure.

procedure relatorio-faixa-analitico-outros:
    def input parameter p-risco as char.
    def var varquivo as char.
    def var varqcsv as char.
    def var sld-curva as dec.
    def var vprovisao as dec.
    def var vclinom like clien.clinom.
    def var vtotal as dec.
    def var vindex as int.
    def var vdtven as date.
    def var valaberto as dec.
    def var vciccgc like clien.ciccgc.
    /*if vmodo_visao = "CONTRATO"
    then vindex = 1.
    else 
    */
    vindex = 2.
    
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
    "Filial;Codigo;CPF/CGC;Nome;Contrato;Emissao;Vencimento;Total;Vencido;
    Vencer;;Provisao" /*;Parcelas"*/ 
    skip.
    if vindex = 1
    then
    for each GClasCTB where
                   GClasCTB.dtvisao = vdatref and
                   GClasCTB.tpvisao = vtipo_visao and
                   GClasCTB.cobcod  = 2 and
                   /*GClasCTB.catcod  = 0 and*/
                   GClasCTB.modcod  = "CRE" and
                   GClasCTB.riscon  = pdvd2018.faixa_risco and
                   GClasCTB.situacao = ""
                   no-lock:

        find clien where clien.clicod = GClasCTB.clifor no-lock no-error.
        if avail clien
        then assign
                vclinom = clien.clinom
                vciccgc = clien.ciccgc.
        else assign
                vclinom = "NOME"
                vciccgc = "CPF".
        find first titulo where
                   titulo.clifor = GClasCTB.clifor and
                   titulo.titnum = GClasCTB.titnum and
                   (titulo.titsit = "LIB" or
                   (titulo.titsit = "PAG" and
                    titulo.titdtpag > vdatref))
                   no-lock no-error.
        if avail titulo
        then vdtven = titulo.titdtven.
        else do:
            find first sc2015 where
                   sc2015.clifor = GClasCTB.clifor and
                   sc2015.titnum = GClasCTB.titnum and
                   (sc2015.titsit = "LIB" or
                   (sc2015.titsit = "PAG" and
                    sc2015.titdtpag > vdatref))
                   no-lock no-error.
            if avail sc2015
            then vdtven = sc2015.titdtven.
        end.
        vprovisao = (GClasCTB.vencido + GClasCTB.vencer) *                            (pdvd2018.pctprovisao / 100).
        valaberto = GClasCTB.vencido + GClasCTB.vencer.
        put unformatted
            GClasCTB.etbcod format ">>9"
            ";" 
            GClasCTB.clifor format ">>>>>>>>>9"
            ";"
            vciccgc
            ";"
            Vclinom 
            ";"
            GClasCTB.titnum 
            ";"
            GClasCTB.titdtemi
            ";"
            vdtven
            ";"
            valaberto         format ">>>>>>>>9.99"
            ";"
            GClasCTB.vencido  format ">>>>>>>>9.99"
            ";"
            GClasCTB.vencer   format ">>>>>>>>9.99"
            ";"
            vprovisao         format ">>>>>>>>9.99"
            ";"
            GClasCTB.qtdparab
            skip
            .
    end.
    else if vindex = 2
    then
    for each GClasCTB where
                   GClasCTB.dtvisao = vdatref and
                   /*GClasCTB.tpvisao = vtipo_visao and */
                   GClasCTB.tpvisao  = "CTBOUTROS" and
                   /*GClasCTB.cobcod  = 2 and*/
                   /*GClasCTB.catcod  => 0 and*/
                   /*GClasCTB.modcod  = "CRE" and */
                   GClasCTB.riscli  = pdvd2018.faixa_risco /*and
                   GClasCTB.situacao = ""                  */
                   no-lock:
        find clien where clien.clicod = GClasCTB.clifor no-lock no-error.
        if avail clien
        then assign
                vclinom = clien.clinom
                vciccgc = clien.ciccgc.
        else assign
                vclinom = "NOME"
                vciccgc = "CPF".
        vdtven = ?.
        vdtven = GClasCTB.dtfaixa.
        /***
        find first titulo where
                   titulo.clifor = GClasCTB.clifor and
                   titulo.titnum = GClasCTB.titnum and
                   (titulo.titsit = "LIB" or
                   (titulo.titsit = "PAG" and
                    titulo.titdtpag > vdatref))
                   no-lock no-error.
        if avail titulo
        then vdtven = titulo.titdtven.
        else do:
            find first sc2015 where
                   sc2015.clifor = GClasCTB.clifor and
                   sc2015.titnum = GClasCTB.titnum and
                   (sc2015.titsit = "LIB" or
                   (sc2015.titsit = "PAG" and
                    sc2015.titdtpag > vdatref))
                   no-lock no-error.
            if avail sc2015
            then vdtven = sc2015.titdtven.
        end.
        ***/
        
        vprovisao = (GClasCTB.vencido + GClasCTB.vencer) *
                                    (pdvd2018.pctprovisao / 100).
                                    
        put unformatted
            GClasCTB.etbcod format ">>9"
            ";" 
            GClasCTB.clifor format ">>>>>>>>>9"
            ";"
            vciccgc
            ";"
            Vclinom 
            ";"
            GClasCTB.titnum 
            ";"
            GClasCTB.titdtemi
            ";"
            vdtven
            ";"
            valaberto         format ">>>>>>>>9.99"
            ";"
            GClasCTB.vencido  format ">>>>>>>>9.99"
            ";"
            GClasCTB.vencer   format ">>>>>>>>9.99"
            ";"
            vprovisao         format ">>>>>>>>9.99"
            /*";"
            GClasCTB.qtdparab*/
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
    
    /**************
    varquivo = "/admcom/relat/" + lc(vtipo_visao) + "-" + lc(vmodo_visao) + "-"
                + lc(trim(vcobra[vindex])) + "-"
                + string(vdatref,"99999999") + "-risco-" 
                + p-risco + ".txt".   
    {md-adm-cab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "190"  
        &Page-Line = "66"
        &Nom-Rel   = ""pdvd2018v""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "190"
        &Form      = "frame f-cabcab"}

    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao + " - " + trim(vcobra[vindex]) 
                + " - risco " + p-risco
                skip.
                
   if vindex = 1
    then
    for each GClasCTB where
                   GClasCTB.dtvisao = vdatref and
                   GClasCTB.tpvisao = vtipo_visao and
                   GClasCTB.cobcod  = 2 and
                   /*GClasCTB.catcod  = 0 and*/
                   GClasCTB.modcod  = "CRE" and
                   GClasCTB.riscon  = pdvd2018.faixa_risco and
                   GClasCTB.situacao = "" 
                   no-lock:

        find clien where clien.clicod = GClasCTB.clifor no-lock no-error.
        if avail clien
        then assign
                vclinom = clien.clinom
                vciccgc = clien.ciccgc.
        else assign
                vclinom = "NOME"
                vciccgc = "CPF".
   
        find first titulo where
                   titulo.clifor = GClasCTB.clifor and
                   titulo.titnum = GClasCTB.titnum and
                   (titulo.titsit = "LIB" or
                   (titulo.titsit = "PAG" and
                    titulo.titdtpag > vdatref))
                   no-lock no-error.
        if avail titulo
        then vdtven = titulo.titdtven.
        else do:
            find first sc2015 where
                   sc2015.clifor = GClasCTB.clifor and
                   sc2015.titnum = GClasCTB.titnum and
                   (sc2015.titsit = "LIB" or
                   (sc2015.titsit = "PAG" and
                    sc2015.titdtpag > vdatref))
                   no-lock no-error.
            if avail sc2015
            then vdtven = sc2015.titdtven.
        end.

        vprovisao = (GClasCTB.vencido + GClasCTB.vencer) *
                                    (pdvd2018.pctprovisao / 100).
         
        vtotal = GClasCTB.vencido + GClasCTB.vencer.


        disp GClasCTB.etbcod format ">>9"        column-label "Fil"
            GClasCTB.clifor format ">>>>>>>>>9"  column-label "Cliente"
            vciccgc                              column-label "CPF/CGC"
            Vclinom                              column-label "Nome"
            GClasCTB.titnum                      column-label "Documento"
            GClasCTB.titdtemi                    column-label "Emissao"
            vdtven                               column-label "Vencimento"
            vtotal(total)              column-label "Total"
            format ">>>,>>>,>>9.99"
            GClasCTB.vencido(total)              column-label "Vencido"
            format ">>>,>>>,>>9.99"
            GClasCTB.vencer(total)  column-label "Vencer"
            format ">>>,>>>,>>9.99"
            vprovisao(total)                     column-label "Provisao"
            format ">>>,>>>,>>9.99"
            GClasCTB.qtdparab                    column-label "Par.Aberta"
            with frame fd1 down width 200
            .
        down with frame fd1.
    end.
    else if vindex = 2
    then
    for each GClasCTB where
                   GClasCTB.dtvisao = vdatref and
                   /*GClasCTB.tpvisao = vtipo_visao and */
                   GClasCTB.tpvisao  = "CTBOUTROS" and
                   /*GClasCTB.cobcod  = 2 and*/
                   /*GClasCTB.catcod = 0 and */
                   /*GClasCTB.modcod  = "CRE" and*/
                   GClasCTB.riscli  = pdvd2018.faixa_risco /*and
                   GClasCTB.situacao = ""                    */
                   no-lock:
        find clien where clien.clicod = GClasCTB.clifor no-lock no-error.
        if avail clien
        then assign
                vclinom = clien.clinom
                vciccgc = clien.ciccgc.
        else assign
                vclinom = "NOME"
                vciccgc = "CPF".
        find first titulo where
                   titulo.clifor = GClasCTB.clifor and
                   titulo.titnum = GClasCTB.titnum and
                   (titulo.titsit = "LIB" or
                   (titulo.titsit = "PAG" and
                    titulo.titdtpag > vdatref))
                   no-lock no-error.
        if avail titulo
        then vdtven = titulo.titdtven.
        else do:
            find first sc2015 where
                   sc2015.clifor = GClasCTB.clifor and
                   sc2015.titnum = GClasCTB.titnum and
                   (sc2015.titsit = "LIB" or
                   (sc2015.titsit = "PAG" and
                    sc2015.titdtpag > vdatref))
                   no-lock no-error.
            if avail sc2015
            then vdtven = sc2015.titdtven.
        end.

        vprovisao = (GClasCTB.vencido + GClasCTB.vencer) *
                                    (pdvd2018.pctprovisao / 100).
        vtotal = GClasCTB.vencido + GClasCTB.vencer.
        
        disp GClasCTB.etbcod format ">>9"        column-label "Fil"
            GClasCTB.clifor format ">>>>>>>>>9"  column-label "Cliente"
            vciccgc                              column-label "CPF/CGC"
            Vclinom                              column-label "Nome"
            GClasCTB.titnum                      column-label "Documento"
            GClasCTB.titdtemi                    column-label "Emissao"
            vdtven                               column-label "Vencimento"
            vtotal(total)                        column-label "Total"
            format ">>>,>>>,>>9.99"
            GClasCTB.vencido(total)              column-label "Vencido"
            format ">>>,>>>,>>9.99"
            GClasCTB.vencer(total)               column-label "Vencer"
            format ">>>,>>>,>>9.99"
            vprovisao(total)                     column-label "Provisao"
            format ">>>,>>>,>>9.99" 
            /*GClasCTB.qtdparab                    column-label "Par.Aberta"
            */
            with frame fd2 down width 200
            .
        down with frame fd2.
    end.
    output close.
    
    run visurel.p(input varquivo,"").
    ***************/

end procedure.

***************************************************************/





procedure relatorio-faixa-filial:
    def var vindex as int.
    vindex = 2.
    for each tt-pdvd2018: delete tt-pdvd2018. end.
    for each pdvd2018 where pdvd2018.data_visao = vdatref     and
                        pdvd2018.tipo_visao = vtipo_visao and
                        pdvd2018.modo_visao = vmodo_visao and
                        pdvd2018.modalidade = "CRE" and
                        pdvd2018.cobcod     = vcobcod and
                        pdvd2018.categoria  = vcatcod and
                        pdvd2018.etbcod > 0
                        no-lock:
        find first tt-pdvd2018 where
                   tt-pdvd2018.data_visao = pdvd2018.data_visao and
                   tt-pdvd2018.tipo_visao = pdvd2018.tipo_visao and
                   tt-pdvd2018.modo_visao = pdvd2018.modo_visao and
                   tt-pdvd2018.modalidade = pdvd2018.modalidade and
                   tt-pdvd2018.cobcod     = pdvd2018.cobcod and 
                   tt-pdvd2018.categoria  = pdvd2018.categoria and
                   tt-pdvd2018.etbcod     = pdvd2018.etbcod 
                   no-error.
        if not avail tt-pdvd2018
        then do:
            create tt-pdvd2018.
            assign
                tt-pdvd2018.data_visao = pdvd2018.data_visao
                tt-pdvd2018.tipo_visao = pdvd2018.tipo_visao
                tt-pdvd2018.modo_visao = pdvd2018.modo_visao
                tt-pdvd2018.modalidade = pdvd2018.modalidade
                tt-pdvd2018.cobcod     = pdvd2018.cobcod
                tt-pdvd2018.categoria  = pdvd2018.categoria
                tt-pdvd2018.etbcod     = pdvd2018.etbcod
                .
        end.
        assign
            tt-pdvd2018.saldo_curva = tt-pdvd2018.saldo_curva +
                                        pdvd2018.saldo_curva
            tt-pdvd2018.provisao    = tt-pdvd2018.provisao +
                                        pdvd2018.provisao
            tt-pdvd2018.principal   = tt-pdvd2018.principal +
                                        pdvd2018.principal
            tt-pdvd2018.renda       = tt-pdvd2018.renda +
                                        pdvd2018.renda
            .
    end.     
    def var varquivo as char.
    varquivo = "/admcom/relat/" + lc(vtipo_visao) + "-" + lc(vmodo_visao) + "-"
                + lc(trim(vcobra[vindex])) + "-"
                + string(vdatref,"99999999") 
                + ".txt".   
    {md-adm-cab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "100"  
        &Page-Line = "66"
        &Nom-Rel   = ""pdvd2018v""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "100"
        &Form      = "frame f-cabcab"}

    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao + " - " + trim(vcobra[vindex])
                 + " - " trim(esqcom1[esqpos1])
                skip.

    for each tt-pdvd2018 where tt-pdvd2018.etbcod > 0 no-lock:
        disp tt-pdvd2018.etbcod column-label "Filial" 
        tt-pdvd2018.saldo_curva(total) format ">>>,>>>,>>9.99"
        tt-pdvd2018.provisao(total)  format ">>>,>>>,>>9.99"
        tt-pdvd2018.principal(total) format ">>>,>>>,>>9.99"
        tt-pdvd2018.renda(total)     format ">>>,>>>,>>9.99"
            with down width 100.
            . 
    end.  
    output close.
    
    run visurel.p(input varquivo,"").
                      
end procedure.


/*****************************************************************

procedure relatorio-AVP-analitico-outros:
    sresp = no.
    message "Confirma gerar arquivo CSV?" update sresp.
    if not sresp then return.
    
    /***********************************
    def var varquivo as char.
    def var varqcsv as char.
    def var sld-curva as dec.
    def var vprovisao as dec.
    def var vclinom like clien.clinom.
    def var vtotal as dec.
    def var vindex as int.
    def var vdtven as date.
    def var valaberto as dec.
    def var vciccgc like clien.ciccgc.
    
    /*************
    varquivo = "/admcom/relat/avp-devedores-"
                + string(vdatref,"99999999") 
                + ".txt".    

    disp "Gerando relatorio... Aguarde!" skip
         varquivo format "x(70)"
        with frame f-dd 1 down centered overlay color message
        row 10 no-label.
    pause 0.
 
    {md-adm-cab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "180"  
        &Page-Line = "66"
        &Nom-Rel   = ""pdvd2018v""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO AVP DEVEDORES "" +
                        string(vdatref,""99/99/9999"")"
        &Width     = "180"
        &Form      = "frame f-cabcab"}

    for each GClasCTB where
                   GClasCTB.dtvisao = vdatref and
                   GClasCTB.tpvisao  = "CTBOUTROS" and
                   /*GClasCTB.cobcod  = 2 and*/
                   GClasCTB.riscli >= "A" and
                   GClasCTB.riscli <= "I" and 
                   GClasCTB.situacao = "" /*and
                   GClasCTB.vencer > 0*/   
                   no-lock:
        find clien where clien.clicod = GClasCTB.clifor no-lock no-error.
        if avail clien
        then assign
                vclinom = clien.clinom
                vciccgc = clien.ciccgc.
        else assign
                vclinom = "NOME"
                vciccgc = "CPF".
        /***
        find first titulo where
                   titulo.clifor = GClasCTB.clifor and
                   titulo.titnum = GClasCTB.titnum and
                   (titulo.titsit = "LIB" or
                   (titulo.titsit = "PAG" and
                    titulo.titdtpag > vdatref))
                   no-lock no-error.
        if avail titulo
        then vdtven = titulo.titdtven.
        else do:
            find first sc2015 where
                   sc2015.clifor = GClasCTB.clifor and
                   sc2015.titnum = GClasCTB.titnum and
                   (sc2015.titsit = "LIB" or
                   (sc2015.titsit = "PAG" and
                    sc2015.titdtpag > vdatref))
                   no-lock no-error.
            if avail sc2015
            then vdtven = sc2015.titdtven.
        end.
        ******/
        
        vprovisao = (GClasCTB.vencido + GClasCTB.vencer) *
                                    (pdvd2018.pctprovisao / 100).
        vtotal = GClasCTB.vencido + GClasCTB.vencer.
        
        disp GClasCTB.etbcod format ">>9"        column-label "Fil"
            GClasCTB.clifor format ">>>>>>>>>9"  column-label "Cliente"
            vciccgc                              column-label "CPF/CGC"
            Vclinom                              column-label "Nome"
            GClasCTB.titnum                      column-label "Documento"
            GClasCTB.titdtemi                    column-label "Data Emissao"
            GClasCTB.crecod                      column-label "Plano credito"
            GClasCTB.vencido(total)              column-label "Val. Vencido"
            format ">>>,>>>,>>9.99"
            GClasCTB.vencer(total)               column-label "Val. Vencer"
            format ">>>,>>>,>>9.99"
            GClasCTB.valor-avp(total)            column-label "Val. AVP"
            format ">>>,>>>,>>9.99"
            with frame fd2 down width 180
            .
        down with frame fd2.
    end.
    output close.
    
    run visurel.p(input varquivo,"").
    ********/

    varquivo = "/admcom/relat/avp-devedores-"
                + string(vdatref,"99999999") 
                + ".csv".    

    disp "Gerando arquivo... Aguarde!" skip
         varquivo format "x(70)"
        with frame f-dd 1 down centered overlay color message
        row 10 no-label.
    pause 0.
 
    output to value(varquivo).
    
    put "Filial;Cliente;CPF;Nome;Documento;Emissao;PlanoCredito;".
    put "ValorVencido;ValorVencer;ValorAVP".
    put skip.

    for each GClasCTB where
                   GClasCTB.dtvisao = vdatref and
                   GClasCTB.tpvisao  = "CTBOUTROS" and
                   GClasCTB.riscli >= "A" and
                   GClasCTB.riscli <= "I" and 
                   GClasCTB.situacao = "" 
                   no-lock:
        find clien where clien.clicod = GClasCTB.clifor no-lock no-error.
        if avail clien
        then assign
                vclinom = clien.clinom
                vciccgc = clien.ciccgc.
        else assign
                vclinom = "NOME"
                vciccgc = "CPF".
        
        vprovisao = (GClasCTB.vencido + GClasCTB.vencer) *
                                    (pdvd2018.pctprovisao / 100).
        vtotal = GClasCTB.vencido + GClasCTB.vencer.
        
        put unformatted
            GClasCTB.etbcod 
            ";"
            GClasCTB.clifor 
            ";"
            vciccgc
             ";"
            Vclinom
            ";"
            GClasCTB.titnum 
            ";"
            GClasCTB.titdtemi
            ";"
            GClasCTB.crecod
            ";"
            GClasCTB.vencido
            ";"
            GClasCTB.vencer
            ";"
            GClasCTB.valor-avp
            skip.
    end.
    output close.
 
    message color red/with
    "Arquivo gerado " varquivo
    view-as alert-box.
    ***************************/
    
    def var ven-cido as char.
    def var ven-cer  as char.
    def var avp-dia  as char.
    def var varquivo as char.
    def var prin-cipal as char.
    def var acres-cimo as char.

    varquivo = "/admcom/relat/saldo-devedores-avp-dia"
           + string(vdatref,"99999999") + "_" +
            string(time) + ".csv".

    output to value(varquivo).    

    disp with frame f-top .
    put skip.
    put "Ano;Mes;Vencido;Vencer;Valor AVP;;Acrescimo" skip.

    for each sqmesavp where
             sqmesavp.tpvisao = vtipo_visao and
             sqmesavp.dtvisao = vdatref 
             no-lock:
        if sqmesavp.ano = 0 
        then next.
        if sqmesavp.avencer = 0 and
           sqmesavp.avpdia = 0
        then next.
    
        assign
            ven-cido = string(sqmesavp.vencido,">>>>>>>>9.99")
            ven-cido = replace(ven-cido,".",",")
            ven-cer  = string(sqmesavp.avencer,">>>>>>>>9.99")
            ven-cer  = replace(ven-cer,".",",")
            avp-dia  = string(sqmesavp.avpdia,">>>>>>>>9.99")
            avp-dia  = replace(avp-dia,".",",")
            /*prin-cipal = string(sqmesavp.principal,">>>>>>>>9.99")
            prin-cipal = replace(prin-cipal,".",",")
            acres-cimo = string(sqmesavp.acrescimo,">>>>>>>>9.99")
            acres-cimo = replace(acres-cimo,".",",")
            */
            /*prin-cipal = string(sqmesavp.principal_emissao_mes,">>>>>>>>9.99")
            prin-cipal = replace(prin-cipal,".",",")*/
            acres-cimo = string(sqmesavp.acrescimo_emissao_mes,">>>>>>>>9.99")
            acres-cimo = replace(acres-cimo,".",",")
             .

        put unformatted 
            sqmesavp.ano format ">>>9" ";"
            sqmesavp.mes ";"
            .
        if ven-cido <> "0,00"    
        then put ven-cido format "x(15)".
        put ";"
            ven-cer  format "x(15)" ";"
            avp-dia  format "x(15)" ";"
            .
        if acres-cimo <> "0,00"
        then put     
            /*prin-cipal format "x(15)"*/ ";"
            acres-cimo format "x(15)" 
            .
        put skip.
        
        prin-cipal = "".
        acres-cimo = "".
    end.
    output close.
    message color red/with
    varquivo
    view-as alert-box
    .

end procedure.

***************************************************************/


procedure reltroio-AVP-csv:
    def var ven-cido as char.
    def var ven-cer  as char.
    def var ven-cersa  as char.
    def var tven-cersa  as char.
    def var ttven-cersa  as dec.
    def var ven-cerca  as char.
    def var tven-cerca  as char.
    def var ttven-cerca  as dec.
    def var avp-dia  as char.
    def var tavp-dia  as char.
    def var ttavp-dia  as dec.
    def var varquivo as char.
    def var prin-cipal as char.
    def var acres-cimo as char.
    def var principal-emissao as char.
    def var tprincipal-emissao as dec.
    def var acrescimo-emissao as char.
    def var tacrescimo-emissao as dec.
    def var principal-vencido as char.
    def var tprincipal-vencido as dec.
    def var acrescimo-vencido as char.
    def var tacrescimo-vencido as dec.
    def var principal-vencer  as char.
    def var tprincipal-vencer  as dec.
    def var acrescimo-vencer  as char.
    def var tacrescimo-vencer  as dec.
 
    varquivo = "/admcom/relat/saldo-devedores-avp-dia"
           + string(vdatref,"99999999") + "_" +
            string(time) + ".csv".
    
    output to value(varquivo).    

    disp with frame f-top .

    put skip.
    put "Ano;Mes;Vencido;Vencer s/a;Vencer c/a;Valor AVP" skip.
    for each sqmesavp where
             sqmesavp.tpvisao = vtipo_visao and
             sqmesavp.dtvisao = vdatref 
             no-lock:
        if sqmesavp.ano = 0 
        then next.
        if sqmesavp.avencer = 0 and
           sqmesavp.avpdia = 0
        then next.
        if sqmesavp.mes = 0 then next.
        assign
            ttven-cersa = ttven-cersa + sqmesavp.avencer-sacr
            ttven-cerca = ttven-cerca + sqmesavp.avencer
            ttavp-dia   = ttavp-dia   + sqmesavp.avpdia
            .
    end.
    assign
        tven-cersa = string(ttven-cersa,">>>>>>>>9.99")
        tven-cersa = replace(tven-cersa,".",",")
        tven-cerca = string(ttven-cerca,">>>>>>>>9.99")
        tven-cerca = replace(tven-cerca,".",",")
        tavp-dia   = string(ttavp-dia,">>>>>>>>9.99")
        tavp-dia   = replace(tavp-dia,".",",")
        .            

    for each sqmesavp where
             sqmesavp.tpvisao = vtipo_visao and
             sqmesavp.dtvisao = vdatref 
             no-lock:
        if sqmesavp.ano = 0 
        then next.
        if sqmesavp.avencer = 0 and
           sqmesavp.avpdia = 0
        then next.
    
        assign
            ven-cido = string(sqmesavp.vencido,">>>>>>>>9.99")
            ven-cido = replace(ven-cido,".",",").
        if sqmesavp.mes = 0   
        then assign 
            ven-cer  = string(sqmesavp.avencer,">>>>>>>>9.99")
            ven-cer  = replace(ven-cer,".",",")
            .
        else assign    
            ven-cer  = "0,00"
            ven-cersa = string(sqmesavp.avencer-sacr,">>>>>>>>9.99")
            ven-cersa  = replace(ven-cersa,".",",")
            ven-cerca = string(sqmesavp.avencer,">>>>>>>>9.99")
            ven-cerca  = replace(ven-cerca,".",",")
            avp-dia  = string(sqmesavp.avpdia,">>>>>>>>9.99")
            avp-dia  = replace(avp-dia,".",",")
            .
        assign
            prin-cipal = string(sqmesavp.principal,">>>>>>>>9.99")
            prin-cipal = replace(prin-cipal,".",",")
            acres-cimo = string(sqmesavp.acrescimo,">>>>>>>>9.99")
            acres-cimo = replace(acres-cimo,".",",")
            tprincipal-emissao = tprincipal-emissao +
                                 sqmesavp.principal_emissao_mes
            tacrescimo-emissao = tacrescimo-emissao +
                                 sqmesavp.acrescimo_emissao_mes
            /*                     
            principal-emissao =
                      string(sqmesavp.principal_emissao_mes,">>>>>>>>9.99")
            principal-emissao = replace(principal-emissao,".",",")
            acrescimo-emissao =
                      string(sqmesavp.acrescimo_emissao_mes,">>>>>>>>9.99")
            acrescimo-emissao = replace(acrescimo-emissao,".",",")
            */
            tprincipal-vencido = tprincipal-vencido +
                                 sqmesavp.principal_vencido
            tacrescimo-vencido = tacrescimo-vencido +
                                 sqmesavp.acrescimo_vencido
            /*                     
            principal-vencido =
                      string(sqmesavp.principal_vencido,">>>>>>>>9.99")
            principal-vencido = replace(principal-vencido,".",",")
            acrescimo-vencido =
                      string(sqmesavp.acrescimo_vencido,">>>>>>>>9.99")
            acrescimo-vencido = replace(acrescimo-vencido,".",",")
            */
            tprincipal-vencer = tprincipal-vencer +
                                sqmesavp.principal_vencer
            tacrescimo-vencer = tacrescimo-vencer +
                                sqmesavp.acrescimo_vencer
            /*                    
            principal-vencer =
                      string(sqmesavp.principal_vencer,">>>>>>>>9.99")
            principal-vencer = replace(principal-vencer,".",",")
            acrescimo-vencer =
                      string(sqmesavp.acrescimo_vencer,">>>>>>>>9.99")
            acrescimo-vencer = replace(acrescimo-vencer,".",",")
            */
             .

        put unformatted 
            sqmesavp.ano format ">>>9" ";"
            sqmesavp.mes ";"
            .

        if sqmesavp.mes = 0
        then put ven-cido format "x(15)" ";"
                 tven-cersa format "x(15)" ";"
                 tven-cerca  format "x(15)" ";"
                 tavp-dia  format "x(15)"
                 .
        else put ";"
             ven-cersa format "x(15)" ";"
             ven-cerca  format "x(15)" ";"
             avp-dia  format "x(15)" 
             .
        put skip.
       
        prin-cipal = "".
        acres-cimo = "".
    end.
    
    assign                     
        principal-emissao = string(tprincipal-emissao,">>>>>>>>9.99")
        principal-emissao = replace(principal-emissao,".",",")
        acrescimo-emissao = string(tacrescimo-emissao,">>>>>>>>9.99")
        acrescimo-emissao = replace(acrescimo-emissao,".",",")
        principal-vencido = string(tprincipal-vencido,">>>>>>>>9.99")
        principal-vencido = replace(principal-vencido,".",",")
        acrescimo-vencido = string(tacrescimo-vencido,">>>>>>>>9.99")
        acrescimo-vencido = replace(acrescimo-vencido,".",",")
        principal-vencer  = string(tprincipal-vencer,">>>>>>>>9.99")
        principal-vencer = replace(principal-vencer,".",",")
        acrescimo-vencer = string(tacrescimo-vencer,">>>>>>>>9.99")
        acrescimo-vencer = replace(acrescimo-vencer,".",",")
             .

    put skip(1).
    put ";;;Principal;Acrescimo;;" skip.
    put ";;Emissao;" principal-emissao format "x(15)"
        ";" acrescimo-emissao format "x(15)"
        ";;" skip.
    put ";;Vencidos;" principal-vencido format "x(15)"
        ";" acrescimo-vencido format "x(15)"
        ";;" skip.
    put ";;A Vencer;" principal-vencer format "x(15)"
        ";" acrescimo-vencer format "x(15)"
        ";;" skip.

    output close.
    message color red/with
    varquivo
    view-as alert-box
    .
    
end procedure.

procedure reltroio-AVP-txt:
    def var ven-cido as dec.
    def var ven-cer  as dec.
    def var ven-cersa  as dec.
    def var tven-cersa  as dec.
    def var ven-cerca  as dec.
    def var tven-cerca  as dec.
    def var avp-dia  as dec.
    def var tavp-dia  as dec.
    def var varquivo as char.
    def var prin-cipal as dec.
    def var acres-cimo as dec.
    def var principal-emissao as dec.
    def var acrescimo-emissao as dec.
    def var principal-vencido as dec.
    def var acrescimo-vencido as dec.
    def var principal-vencer  as dec.
    def var acrescimo-vencer  as dec.
    
    form 
        sqmesavp.ano format ">>>9" column-label "Ano"
        sqmesavp.mes               column-label "Mes"
        ven-cido   format ">>>,>>>,>>9.99" column-label "Vencido"
        tven-cersa  format ">>>,>>>,>>9.99" column-label "Vencer!S/Acrescimo"
        tven-cerca  format ">>>,>>>,>>9.99" column-label "Vencer!C/Acrescimo"
        tavp-dia    format ">>>,>>>,>>9.99" column-label "Vencer!AVP"
        with frame f-disp down width 80 
            .
 
    varquivo = "/admcom/relat/saldo-devedores-avp-dia"
           + string(vdatref,"99999999") + "_" +
            string(time) + ".txt".
    
    output to value(varquivo).    

    disp "Sistema ADMCOM - " wempre.emprazsoc  format "x(40)"
         today string(time,"hh:mm:ss")
         "Data de Referencia:" vdatref with frame f-top no-label.
    
    for each sqmesavp where
             sqmesavp.tpvisao = vtipo_visao and
             sqmesavp.dtvisao = vdatref 
             no-lock:
        if sqmesavp.ano = 0 
        then next.
        if sqmesavp.avencer = 0 and
           sqmesavp.avpdia = 0
        then next.
        if sqmesavp.mes = 0 then next.
        assign
            tven-cersa = tven-cersa + sqmesavp.avencer-sacr
            tven-cerca = tven-cerca + sqmesavp.avencer
            tavp-dia   = tavp-dia   + sqmesavp.avpdia
            .
    end.
    for each sqmesavp where
             sqmesavp.tpvisao = vtipo_visao and
             sqmesavp.dtvisao = vdatref 
             no-lock by ano by mes:
        if sqmesavp.ano = 0 
        then next.
        if sqmesavp.avencer = 0 and
           sqmesavp.avpdia = 0
        then next.
    
        ven-cido = sqmesavp.vencido.
        if sqmesavp.mes = 0   
        then ven-cer  = sqmesavp.avencer.
        else assign    
            ven-cer  = 0
            ven-cersa = sqmesavp.avencer-sacr
            ven-cerca = sqmesavp.avencer
            avp-dia  = sqmesavp.avpdia
            .

        assign
            prin-cipal = prin-cipal + sqmesavp.principal
            acres-cimo = acres-cimo + sqmesavp.acrescimo
            principal-emissao = principal-emissao +
                                sqmesavp.principal_emissao_mes
            acrescimo-emissao = acrescimo-emissao +
                                sqmesavp.acrescimo_emissao_mes
            principal-vencido = principal-vencido +
                                sqmesavp.principal_vencido
            acrescimo-vencido = acrescimo-vencido + 
                                sqmesavp.acrescimo_vencido
            principal-vencer  = principal-vencer +
                                sqmesavp.principal_vencer
            acrescimo-vencer  = acrescimo-vencer +
                                sqmesavp.acrescimo_vencer
             .
       
        if sqmesavp.mes = 0
        then disp sqmesavp.ano
                  sqmesavp.mes  
                  ven-cido
                  tven-cersa
                  tven-cerca
                  tavp-dia
                  with frame f-disp.
        else disp           
              sqmesavp.ano
              sqmesavp.mes
              ven-cido
              ven-cersa @ tven-cersa
              ven-cerca @ tven-cerca
              avp-dia   @ tavp-dia
              with frame f-disp 
              .

        down with frame f-disp.
        prin-cipal = 0.
        acres-cimo = 0.
    end.

    down(1) with frame f-disp.
    disp "      Principal" format "x(15)" @ tven-cersa
         "      Acrescimo" format "x(15)" @ tven-cerca
         with frame f-disp.
    down with frame f-disp.     
    disp "Emissao" @ ven-cido 
         principal-emissao  @ tven-cersa
         acrescimo-emissao  @ tven-cerca
         with frame f-disp.
    down with frame f-disp.
    disp "Vencidos" @ ven-cido
         principal-vencido @ tven-cersa
         acrescimo-vencido @ tven-cerca
         with frame f-disp.
    down with frame f-disp.
    disp "A Vencer" @ ven-cido
         principal-vencer @ tven-cersa
         acrescimo-vencer @ tven-cerca
         with frame f-disp.
    down with frame f-disp.
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
    def var vclinom like clien.clinom.
    def var vciccgc like clien.ciccgc.
    def var vdtven as date.
    if vmodo_visao = "CONTRATO"
    then vindex = 1.
    else vindex = 2.
    
    disp "Gerando relatorio... Aguarde!" skip
         varquivo format "x(70)"
        with frame f-dd 1 down centered overlay color message
        row 10 no-label.
    pause 0.
 

    varquivo = "/admcom/relat/saldo-clientes-" 
                + string(vdatref,"99999999") + "-risco-" 
                + p-risco + ".txt".   

    def var valchar as char.
    def var varq as char.
    def var vok as log.
    
    varq = "/admcom/relat/saldo-clientes-" 
                + string(vdatref,"99999999") + "-risco-" 
                + p-risco + ".csv". 
    
    output to value(varq).
    put "Nome;CPF;Numero;Valor;Vencimento;Atraso" skip.
    vtotal = 0.                  
    if vindex = 1
    then do:
    for each visdev18 where visdev18.data_visao = vdatref  and
                            visdev18.tipo_visao = vtipo_visao and
                            visdev18.risco_contrato = p-risco and
                            visdev18.cobcod = vcobcod and
                            /*visdev18.catcod = vcatcod and*/
                            visdev18.situacao = ""
                            no-lock:

        if visdev18.total_vencido = 0 and
           visdev18.total_vencer = 0
        then next.    
        /*find clien where clien.clicod = visdev18.clifor no-lock no-error.
        if avail clien
        then*/ assign
                vclinom = visdev18.nome
                vciccgc = visdev18.cpf.
        /*else assign
                vclinom = "NOME"
                vciccgc = "CPF".
        */
        vok = no.
        /*if visdev18.vencimento_arquivo = ?
        then*/ do:
        for each titulo where
                 titulo.empcod = visdev18.empcod and
                 titulo.titnat = visdev18.titnat and
                 titulo.modcod = visdev18.modcod and
                 titulo.titdtemi = visdev18.titdtemi and
                 titulo.etbcod = visdev18.etbcod and
                 titulo.clifor = visdev18.clifor and
                 titulo.titnum = visdev18.titnum and
                 (titulo.titsit = "LIB" or
                 (titulo.titsit = "PAG" and
                  titulo.titdtpag > vdatref)) 
                 no-lock: 
            if titulo.titvlcob > 0  and
               titulo.titdtven <> ?  and
               titulo.titdtven < 01/01/2030 and
               titulo.titdtven > 01/01/1990
            then do:                                  
                if visdev18.qtdatr > 0 /*220*/
                then vdtven = titulo.titdtven - visdev18.qtdat.
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
        /***
        if vok = no
        then for each titadd15 where
                 titadd15.empcod = visdev18.empcod and
                 titadd15.titnat = visdev18.titnat and
                 titadd15.modcod = visdev18.modcod and
                 titadd15.titdtemi = visdev18.titdtemi and
                 titadd15.etbcod = visdev18.etbcod and
                 titadd15.clifor = visdev18.clifor and
                 titadd15.titnum = visdev18.titnum and
                 (titadd15.titsit = "LIB" or
                 (titadd15.titsit = "PAG" and
                  titadd15.titdtpag > vdatref)) 
                 no-lock:
            if titadd15.titvlcob > 0  and
               titadd15.titdtven <> ?  and
               titadd15.titdtven < 01/01/2030 and
               titadd15.titdtven > 01/01/1990
            then do:       
                if visdev18.qtdatr > 0 /*220*/
                then vdtven = titadd15.titdtven - visdev18.qtdat.
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
        ***/
        
        end.
        
        /*****
        else do:
            vdtven = visdev18.vencimento_arquivo.
            valchar = string(visdev18.total_vencido + 
                             visdev18.total_vencer).
                valchar = replace(valchar,",","").
                valchar = replace(valchar,".",",").
                put unformatted 
                vclinom 
                ";"
                vciccgc 
                ";"
                visdev18.titnum 
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
                            visdev18.total_vencido + visdev18.total_vencer.
 
        end.
        *****/
    end. 
    end.
    else do:
    for each visdev18 where visdev18.data_visao = vdatref  and
                            visdev18.tipo_visao = vtipo_visao and
                            visdev18.titnat = no and
                            visdev18.risco_cliente = p-risco and
                            visdev18.cobcod = vcobcod and
                            /*visdev18.catcod = vcatcod and*/
                            visdev18.situacao = ""
                            no-lock:

        if visdev18.clifor = 0 then next.
        if visdev18.clifor = 1 then next.
        if visdev18.clifor = ? then next.
 
        if visdev18.total_vencido = 0 and
           visdev18.total_vencer = 0
        then next.    
        /*find clien where clien.clicod = visdev18.clifor no-lock no-error.
        if avail clien
        then*/ assign
                vclinom = visdev18.nome
                vciccgc = visdev18.cpf.
        /*else assign
                vclinom = "NOME"
                vciccgc = "CPF".
        */
        vok = no.
        /*if visdev18.vencimento_arquivo = ?
        then*/ do:
        for each titulo where
                 titulo.empcod = visdev18.empcod and
                 titulo.titnat = visdev18.titnat and
                 titulo.modcod = visdev18.modcod and
                 titulo.titdtemi = visdev18.titdtemi and
                 titulo.etbcod = visdev18.etbcod and
                 titulo.clifor = visdev18.clifor and
                 titulo.titnum = visdev18.titnum and
                 (titulo.titsit = "LIB" or
                 (titulo.titsit = "PAG" and
                  titulo.titdtpag > vdatref)) 
                 no-lock: 
            if titulo.titvlcob > 0  and
               titulo.titdtven <> ?  and
               titulo.titdtven < 01/01/2030 and
               titulo.titdtven > 01/01/1990
            then do:                                  
                if visdev18.qtdatr > 0 /*220*/
                then vdtven = titulo.titdtven - visdev18.qtdat.
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
        /***
        if vok = no
        then for each titadd15 where
                 titadd15.empcod = visdev18.empcod and
                 titadd15.titnat = visdev18.titnat and
                 titadd15.modcod = visdev18.modcod and
                 titadd15.titdtemi = visdev18.titdtemi and
                 titadd15.etbcod = visdev18.etbcod and
                 titadd15.clifor = visdev18.clifor and
                 titadd15.titnum = visdev18.titnum and
                 (titadd15.titsit = "LIB" or
                 (titadd15.titsit = "PAG" and
                  titadd15.titdtpag > vdatref)) 
                 no-lock:
            if titadd15.titvlcob > 0  and
               titadd15.titdtven <> ?  and
               titadd15.titdtven < 01/01/2030 and
               titadd15.titdtven > 01/01/1990
            then do:       
                if visdev18.qtdatr > 0 /*220*/
                then vdtven = titadd15.titdtven - visdev18.qtdat.
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
        *****/
        
        end.
        
        /*****
        else do:
            vdtven = visdev18.vencimento_arquivo.
            valchar = string(visdev18.total_vencido + 
                             visdev18.total_vencer).
                valchar = replace(valchar,",","").
                valchar = replace(valchar,".",",").
                put unformatted 
                vclinom 
                ";"
                vciccgc 
                ";"
                visdev18.titnum 
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
                            visdev18.total_vencido + visdev18.total_vencer.
 
        end.
        *****/
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


