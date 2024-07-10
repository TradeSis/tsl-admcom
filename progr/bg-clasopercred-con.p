/****
connect ninja -H db2 -S sdrebninja -N tcp.
connect sensei -H 10.2.0.134 -S 60001 -N tcp.
****/

{admcab.i}
{setbrw.i}

def temp-table tt-prodevdu like prodevdu.

def var vi as int.
def var vdatref as date format "99/99/9999".
def var vcobcod as int.
def var vtipo_visao as char.
def var vmodo_visao as char.
vdatref = 12/31/16.
vtipo_visao = "GERENCIAL".
vmodo_visao = "CLIENTE".
vcobcod = 2.

find last prodevdu no-lock no-error.
if avail prodevdu
then vdatref = prodevdu.data_visao.

update vdatref label "Data referencia" with frame f-dat side-label 1 down
width 80 row 4.
if vdatref < 01/01/18
then do:
    if vdatref < 01/01/14 
    then run bg-clasopercred-con-2013.p(vdatref).
    else if vdatref < 01/01/15 
    then run bg-clasopercred-con-2014.p(vdatref).
    else if vdatref < 01/01/16 
    then run bg-clasopercred-con-2015.p(vdatref).
    else if vdatref < 01/01/17
    then run bg-clasopercred-con-2016.p(vdatref).
    else if vdatref < 01/01/18
    then run bg-clasopercred-con-2017.p(vdatref).
    return.
end.
find first prodevdu where prodevdu.data_visao = vdatref and
                          prodevdu.tipo_visao = vtipo_visao 
                          no-lock no-error.
if not avail prodevdu or sfuncod = 698 or sfuncod = 101
then do:
    run bg-clasopercred-v0117.p(vdatref).
    /*run bg-clasopercred-pro.p(vdatref).
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
form prodevdu.Faixa_risco column-label "Faixa" format "x(5)"
     prodevdu.descricao_faixa no-label format "x(12)"  
     prodevdu.saldo_curva column-label "Curva"      format ">>>>>>>>9.99"
     prodevdu.pctprovisao column-label "%"          format ">>>9.99"
     prodevdu.provisao    column-label "Provisao"   format ">>>>>>>>9.99"
     prodevdu.principal   column-label "Principal"  format ">>>>>>>>9.99"
     prodevdu.renda       column-label "Renda"      format ">>>>>>>>9.99"
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

for each prodevdu where prodevdu.data_visao = vdatref     and
                        prodevdu.tipo_visao = vtipo_visao and
                        prodevdu.modo_visao = vmodo_visao and
                        prodevdu.modalidade = "CRE" and
                        prodevdu.cobcod     = vcobcod and
                        prodevdu.categoria  = vcatcod and
                        prodevdu.etbcod = 0
                        no-lock:
    assign
        tsaldo_curva = tsaldo_curva + prodevdu.saldo_curva
        tprovisao    = tprovisao + prodevdu.provisao
        tprincipal   = tprincipal + prodevdu.principal
        trenda       = trenda + prodevdu.renda
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
        &file  = prodevdu  
        &help  = " "
        &cfield = prodevdu.faixa_risco
        &noncharacter = /* */  
        &ofield = " prodevdu.descricao_faixa
                    prodevdu.saldo_curva
                    prodevdu.pctprovisao
                    prodevdu.provisao
                    prodevdu.principal
                    prodevdu.renda
                    "  
        &aftfnd1 = " "
        &where  = " prodevdu.data_visao = vdatref and
                    prodevdu.tipo_visao = vtipo_visao and
                    prodevdu.modo_visao = vmodo_visao and 
                    prodevdu.modalidade = ""CRE"" and
                    prodevdu.cobcod = vcobcod and
                    prodevdu.categoria = vcatcod and
                    prodevdu.etbcod = 0 "
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
        then run relatorio-faixa-analitico-outros(prodevdu.faixa_risco).
        else run relatorio-faixa-analitico(prodevdu.faixa_risco).
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
    def var vencer90 like prodevdu.vencer_90 .
    def var vencer360 like prodevdu.vencer_360.
    def var vencer1080 like prodevdu.vencer_1080.
    def var vencer1800 like prodevdu.vencer_1800 .
    def var vencer5400 like prodevdu.vencer_5400  .
    def var vencer9999 like prodevdu.vencer_9999   .
     
    varquivo = "/admcom/relat/bga-cliente-" 
                + string(vdatref,"99999999") + "-" + string(time).
    varqcsv = "l:\relat\bga-cliente-"
                    + string(vdatref,"99999999") + "-" + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "80"  
        &Page-Line = "66"
        &Nom-Rel   = ""prodevduv""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "80"
        &Form      = "frame f-cabcab"}

    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao + " - " + trim(vcobra[vindex]) + " "
                skip.
                
    vi = 0. 

    for each prodevdu where 
             prodevdu.data_visao = vdatref and
             prodevdu.tipo_visao = vtipo_visao and
             prodevdu.modo_visao = vmodo_visao and
             prodevdu.modalidade = "CRE" and
             prodevdu.cobcod     = vcobcod and
             prodevdu.categoria  = vcatcod and
             prodevdu.faixa_risco <> "" no-lock:
        
        /*
        find first tbcntgen where
                   tbcntgen.tipcon = 13 and
                   tbcntgen.campo1[1] = prodevdu.faixa_risco 
                   no-lock no-error.
        if avail tbcntgen
        then prodevdu.descricao_faixa = tbcntgen.numini + "-" +
                            tbcntgen.numfim.
        */

        if prodevdu.faixa_risco < "H"
        then assign
            vencidos = prodevdu.vencido
            vencer90 = prodevdu.vencer_90
            vencer360 = prodevdu.vencer_360
            vencer1080 = prodevdu.vencer_1080
            vencer1800 = prodevdu.vencer_1800
            vencer5400 = prodevdu.vencer_5400 
            vencer9999 = prodevdu.vencer_9999
            .
        else assign
            vencidos = prodevdu.vencido +
                       prodevdu.vencer_90 + prodevdu.vencer_360 +
                       prodevdu.vencer_1080 + prodevdu.vencer_1800 +
                       prodevdu.vencer_5400 + prodevdu.vencer_9999
            vencer90 = 0
            vencer360 = 0
            vencer1080 = 0
            vencer1800 = 0
            vencer5400 = 0
            vencer9999 = 0
            .

        disp prodevdu.faixa_risco column-label "Faixa"
             prodevdu.descricao_faixa no-label   format "x(12)"
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
             prodevdu.saldo_curva  column-label "Saldo Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             prodevdu.provisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.pctprovisao column-label "%"
             prodevdu.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             prodevdu.renda(total) column-label "Renda"
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
    for each GClasOPC where
                   GClasOPC.dtvisao = vdatref and
                   GClasOPC.tpvisao = vtipo_visao and
                   GClasOPC.cobcod  = 2 and
                   /*GClasOPC.catcod  = 0 and*/
                   GClasOPC.modcod  = "CRE" and
                   GClasOPC.riscon  = prodevdu.faixa_risco and
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
        vprovisao = (GClasOPC.vencido + GClasOPC.vencer) *                             (prodevdu.pctprovisao / 100).
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
                   GClasOPC.riscli  = prodevdu.faixa_risco and
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
                                    (prodevdu.pctprovisao / 100).
                                    
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
        &Nom-Rel   = ""prodevduv""  
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
    for each GClasOPC where
                   GClasOPC.dtvisao = vdatref and
                   GClasOPC.tpvisao = vtipo_visao and
                   GClasOPC.cobcod  = 2 and
                   /*GClasOPC.catcod  = 0 and*/
                   GClasOPC.modcod  = "CRE" and
                   GClasOPC.riscon  = prodevdu.faixa_risco and
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

        vprovisao = (GClasOPC.vencido + GClasOPC.vencer) *
                                    (prodevdu.pctprovisao / 100).
         
        vtotal = GClasOPC.vencido + GClasOPC.vencer.


        disp GClasOPC.etbcod format ">>9"        column-label "Fil"
            GClasOPC.clifor format ">>>>>>>>>9"  column-label "Cliente"
            vciccgc                              column-label "CPF/CGC"
            Vclinom                              column-label "Nome"
            GClasOPC.titnum                      column-label "Documento"
            GClasOPC.titdtemi                    column-label "Emissao"
            vdtven                               column-label "Vencimento"
            vtotal(total)              column-label "Total"
            format ">>>,>>>,>>9.99"
            GClasOPC.vencido(total)              column-label "Vencido"
            format ">>>,>>>,>>9.99"
            GClasOPC.vencer(total)  column-label "Vencer"
            format ">>>,>>>,>>9.99"
            vprovisao(total)                     column-label "Provisao"
            format ">>>,>>>,>>9.99"
            GClasOPC.qtdparab                    column-label "Par.Aberta"
            with frame fd1 down width 200
            .
        down with frame fd1.
    end.
    else if vindex = 2
    then
    for each GClasOPC where
                   GClasOPC.dtvisao = vdatref and
                   GClasOPC.tpvisao = vtipo_visao and
                   GClasOPC.cobcod  = 2 and
                   /*GClasOPC.catcod = 0 and */
                   GClasOPC.modcod  = "CRE" and
                   GClasOPC.riscli  = prodevdu.faixa_risco and
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

        vprovisao = (GClasOPC.vencido + GClasOPC.vencer) *
                                    (prodevdu.pctprovisao / 100).
        vtotal = GClasOPC.vencido + GClasOPC.vencer.
        
        disp GClasOPC.etbcod format ">>9"        column-label "Fil"
            GClasOPC.clifor format ">>>>>>>>>9"  column-label "Cliente"
            vciccgc                              column-label "CPF/CGC"
            Vclinom                              column-label "Nome"
            GClasOPC.titnum                      column-label "Documento"
            GClasOPC.titdtemi                    column-label "Emissao"
            vdtven                               column-label "Vencimento"
            vtotal(total)                        column-label "Total"
            format ">>>,>>>,>>9.99"
            GClasOPC.vencido(total)              column-label "Vencido"
            format ">>>,>>>,>>9.99"
            GClasOPC.vencer(total)               column-label "Vencer"
            format ">>>,>>>,>>9.99"
            vprovisao(total)                     column-label "Provisao"
            format ">>>,>>>,>>9.99" 
            GClasOPC.qtdparab                    column-label "Par.Aberta"
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
                   GClasCTB.riscon  = prodevdu.faixa_risco and
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
        vprovisao = (GClasCTB.vencido + GClasCTB.vencer) *                            (prodevdu.pctprovisao / 100).
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
                   GClasCTB.riscli  = prodevdu.faixa_risco /*and
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
                                    (prodevdu.pctprovisao / 100).
                                    
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
        &Nom-Rel   = ""prodevduv""  
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
                   GClasCTB.riscon  = prodevdu.faixa_risco and
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
                                    (prodevdu.pctprovisao / 100).
         
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
                   GClasCTB.riscli  = prodevdu.faixa_risco /*and
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
                                    (prodevdu.pctprovisao / 100).
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

procedure relatorio-faixa-filial:
    def var vindex as int.
    vindex = 2.
    for each tt-prodevdu: delete tt-prodevdu. end.
    for each prodevdu where prodevdu.data_visao = vdatref     and
                        prodevdu.tipo_visao = vtipo_visao and
                        prodevdu.modo_visao = vmodo_visao and
                        prodevdu.modalidade = "CRE" and
                        prodevdu.cobcod     = vcobcod and
                        prodevdu.categoria  = vcatcod and
                        prodevdu.etbcod > 0
                        no-lock:
        find first tt-prodevdu where
                   tt-prodevdu.data_visao = prodevdu.data_visao and
                   tt-prodevdu.tipo_visao = prodevdu.tipo_visao and
                   tt-prodevdu.modo_visao = prodevdu.modo_visao and
                   tt-prodevdu.modalidade = prodevdu.modalidade and
                   tt-prodevdu.cobcod     = prodevdu.cobcod and 
                   tt-prodevdu.categoria  = prodevdu.categoria and
                   tt-prodevdu.etbcod     = prodevdu.etbcod 
                   no-error.
        if not avail tt-prodevdu
        then do:
            create tt-prodevdu.
            assign
                tt-prodevdu.data_visao = prodevdu.data_visao
                tt-prodevdu.tipo_visao = prodevdu.tipo_visao
                tt-prodevdu.modo_visao = prodevdu.modo_visao
                tt-prodevdu.modalidade = prodevdu.modalidade
                tt-prodevdu.cobcod     = prodevdu.cobcod
                tt-prodevdu.categoria  = prodevdu.categoria
                tt-prodevdu.etbcod     = prodevdu.etbcod
                .
        end.
        assign
            tt-prodevdu.saldo_curva = tt-prodevdu.saldo_curva +
                                        prodevdu.saldo_curva
            tt-prodevdu.provisao    = tt-prodevdu.provisao +
                                        prodevdu.provisao
            tt-prodevdu.principal   = tt-prodevdu.principal +
                                        prodevdu.principal
            tt-prodevdu.renda       = tt-prodevdu.renda +
                                        prodevdu.renda
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
        &Nom-Rel   = ""prodevduv""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "100"
        &Form      = "frame f-cabcab"}

    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao + " - " + trim(vcobra[vindex])
                 + " - " trim(esqcom1[esqpos1])
                skip.

    for each tt-prodevdu where tt-prodevdu.etbcod > 0 no-lock:
        disp tt-prodevdu.etbcod column-label "Filial" 
        tt-prodevdu.saldo_curva(total) format ">>>,>>>,>>9.99"
        tt-prodevdu.provisao(total)  format ">>>,>>>,>>9.99"
        tt-prodevdu.principal(total) format ">>>,>>>,>>9.99"
        tt-prodevdu.renda(total)     format ">>>,>>>,>>9.99"
            with down width 100.
            . 
    end.  
    output close.
    
    run visurel.p(input varquivo,"").
                      
end procedure.

procedure relatorio-AVP-analitico-outros:
    sresp = no.
    message "Confirma gerar arquivo CSV?" update sresp.
    if not sresp then return.
    
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
        &Nom-Rel   = ""prodevduv""  
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
                                    (prodevdu.pctprovisao / 100).
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
                                    (prodevdu.pctprovisao / 100).
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
    
end procedure.


