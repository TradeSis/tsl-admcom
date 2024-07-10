{admcab.i}
{setbrw.i}

def var vi as int.
def var vdatref as date format "99/99/9999".
def var vcobcod as int.
def var vcatcod as log format "Sim/Nao".
def var vtipo_visao as char.
def var vmodo_visao as char.
vdatref = 01/31/16.
if vdatref > 05/31/16
then return.
vtipo_visao = "CONTABIL".
vmodo_visao = "CLIENTE".
vcobcod = 2.


update vdatref label "Data referencia" with frame f-dat side-label 1 down
width 80 row 4.

find first prodevdu where prodevdu.data_visao = vdatref no-lock no-error.
if not avail prodevdu
then do:
    return.
    /*
    run pro-clasopercred-bc.p(vdatref).
    */
end.

def var vtipo as char extent 2 format "x(15)". 
def var vcobra as char extent 2 format "x(15)".
vtipo[1] = "  CONTRATO".
vtipo[2] = "  CLIENTE".
vcobra[1] = "  DREBES".
/*VCOBRA[2] = "  FINANCEIRA".
  */
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
            vmodo_visao + " - " + trim(vcobra[vindex]) + " ".

def var tsaldo_curva as dec.
def var tprovisao as dec.
def var tprincipal as dec.
def var trenda as dec.
def var tsperda as dec.
for each prodevdu where prodevdu.data_visao = vdatref     and
                        prodevdu.tipo_visao = vtipo_visao and
                        prodevdu.modo_visao = vmodo_visao and
                        prodevdu.categoria = 0 and
                        prodevdu.cobcod     = vcobcod
                        no-lock:
    assign
        tsaldo_curva = tsaldo_curva + prodevdu.saldo_curva
        tprovisao    = tprovisao + prodevdu.provisao
        tprincipal   = tprincipal + prodevdu.principal
        trenda       = trenda + prodevdu.renda
        .              
   /*if faixa_risco < "I"
          then*/ 
          tsperda = tsperda + prodevdu.saldo_curva.
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
    initial ["","IMPRIME TELA","ANALITICO FAIXA","",""].

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
                    prodevdu.categoria = 0 and
                    prodevdu.cobcod = vcobcod "
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
        run relatorio-faixa-analitico(prodevdu.faixa_risco).
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
    vcatcod = no.
    
    if vmodo_visao = "CONTRATO"
    then do on error undo:
        message "Separar por setor ?" update vcatcod.
    end.
    
    varquivo = "/admcom/relat/bga-cliente-" 
                + string(vdatref,"99999999") + "-" + string(time).
    varqcsv = "l:\relat\bga-cliente-"
                    + string(vdatref,"99999999") + "-" + string(time).

    /*
    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "0" 
        &Cond-Var  = "80"  
        &Page-Line = "66"
        &Nom-Rel   = ""prodevduv""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "80"
        &Form      = "frame f-cabcab"}
    */
    
    output to value(varquivo) page-size 0.
    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao + " - " + trim(vcobra[vindex]) + " "
                skip.
           
                
    vi = 0. 
    if vcatcod 
    then do:
        put skip(1) " *** M O V E I S ***" skip.
        for each prodevdu where 
             prodevdu.data_visao = vdatref and
             prodevdu.tipo_visao = vtipo_visao and
             prodevdu.modo_visao = vmodo_visao and
             prodevdu.cobcod     = vcobcod and
             prodevdu.categoria  = 31 and
             prodevdu.faixa_risco <> "" no-lock:
        
        disp prodevdu.faixa_risco column-label "Faixa"
             prodevdu.descricao_faixa no-label   format "x(12)"
             prodevdu.vencido column-label "Vencidos"
             format ">>>,>>>,>>9.99" (total)
             prodevdu.vencer_90  column-label "Vencer!Ate 3 meses"
             format ">>>,>>>,>>9.99" (total)
             prodevdu.vencer_360 column-label "Vencer!3 a 12 meses"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.vencer_1080 column-label "Vencer!1 a 3 anos"
             format ">>>,>>>,>>9.99"  (total) 
             prodevdu.vencer_1800 column-label "Vencer!3 a 5 anos"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.vencer_5400 column-label "Vencer!5 a 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.vencer_9999 column-label "Vencer!+ 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.saldo_curva  column-label "Saldo Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             (prodevdu.saldo_curva / tsperda) * 100
             format ">>9.99%"
             prodevdu.provisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.pctprovisao column-label "%"
             prodevdu.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             prodevdu.renda(total) column-label "Renda"
             format ">>>,>>>,>>9.99"
             with frame f-disp1 down width 230.
            .
        down with frame f-disp1.
        end.
        put skip(1) " *** M O D A ***" skip.
        for each prodevdu where 
             prodevdu.data_visao = vdatref and
             prodevdu.tipo_visao = vtipo_visao and
             prodevdu.modo_visao = vmodo_visao and
             prodevdu.cobcod     = vcobcod and
             prodevdu.categoria  = 41 and
             prodevdu.faixa_risco <> "" no-lock:
        
        disp prodevdu.faixa_risco column-label "Faixa"
             prodevdu.descricao_faixa no-label   format "x(12)"
             prodevdu.vencido column-label "Vencidos"
             format ">>>,>>>,>>9.99" (total)
             prodevdu.vencer_90  column-label "Vencer!Ate 3 meses"
             format ">>>,>>>,>>9.99" (total)
             prodevdu.vencer_360 column-label "Vencer!3 a 12 meses"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.vencer_1080 column-label "Vencer!1 a 3 anos"
             format ">>>,>>>,>>9.99"  (total) 
             prodevdu.vencer_1800 column-label "Vencer!3 a 5 anos"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.vencer_5400 column-label "Vencer!5 a 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.vencer_9999 column-label "Vencer!+ 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.saldo_curva  column-label "Saldo Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             (prodevdu.saldo_curva / tsperda) * 100
             format ">>9.99%"
             prodevdu.provisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.pctprovisao column-label "%"
             prodevdu.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             prodevdu.renda(total) column-label "Renda"
             format ">>>,>>>,>>9.99"
             with frame f-disp2 down width 230.
            .
        down with frame f-disp2.
        end.
        put skip(1) " *** N O V A C A O ***" skip.
        for each prodevdu where 
             prodevdu.data_visao = vdatref and
             prodevdu.tipo_visao = vtipo_visao and
             prodevdu.modo_visao = vmodo_visao and
             prodevdu.cobcod     = vcobcod and
             prodevdu.categoria  = 99 and
             prodevdu.faixa_risco <> "" no-lock:
        
        disp prodevdu.faixa_risco column-label "Faixa"
             prodevdu.descricao_faixa no-label   format "x(12)"
             prodevdu.vencido column-label "Vencidos"
             format ">>>,>>>,>>9.99" (total)
             prodevdu.vencer_90  column-label "Vencer!Ate 3 meses"
             format ">>>,>>>,>>9.99" (total)
             prodevdu.vencer_360 column-label "Vencer!3 a 12 meses"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.vencer_1080 column-label "Vencer!1 a 3 anos"
             format ">>>,>>>,>>9.99"  (total) 
             prodevdu.vencer_1800 column-label "Vencer!3 a 5 anos"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.vencer_5400 column-label "Vencer!5 a 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.vencer_9999 column-label "Vencer!+ 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.saldo_curva  column-label "Saldo Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             (prodevdu.saldo_curva / tsperda) * 100
             format ">>9.99%"
             prodevdu.provisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.pctprovisao column-label "%"
             prodevdu.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             prodevdu.renda(total) column-label "Renda"
             format ">>>,>>>,>>9.99"
             with frame f-disp3 down width 230.
            .
        down with frame f-disp3.
        end.
    end.
        
    vi = 0.
    put skip(1) " *** G E R A L ***" skip.
    for each prodevdu where 
             prodevdu.data_visao = vdatref and
             prodevdu.tipo_visao = vtipo_visao and
             prodevdu.modo_visao = vmodo_visao and
             prodevdu.cobcod     = vcobcod and
             prodevdu.categoria = 0 and
             prodevdu.faixa_risco <> "" no-lock:
        
        disp prodevdu.faixa_risco column-label "Faixa"
             prodevdu.descricao_faixa no-label   format "x(12)"
             prodevdu.vencido column-label "Vencidos"
             format ">>>,>>>,>>9.99" (total)
             prodevdu.vencer_90  column-label "Vencer!Ate 3 meses"
             format ">>>,>>>,>>9.99" (total)
             prodevdu.vencer_360 column-label "Vencer!3 a 12 meses"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.vencer_1080 column-label "Vencer!1 a 3 anos"
             format ">>>,>>>,>>9.99"  (total) 
             prodevdu.vencer_1800 column-label "Vencer!3 a 5 anos"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.vencer_5400 column-label "Vencer!5 a 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.vencer_9999 column-label "Vencer!+ 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.saldo_curva  column-label "Saldo Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             (prodevdu.saldo_curva / tsperda) * 100
             format ">>9.99%"
             prodevdu.provisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             prodevdu.pctprovisao column-label "%"
             prodevdu.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             prodevdu.renda(total) column-label "Renda"
             format ">>>,>>>,>>9.99"
             with frame f-disp4 down width 230.
            .
        down with frame f-disp4.
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
    def var vtotal as dec.
    def var v-vencido as char.
    def var v-vencer as char.
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
    "Filial;Codigo;Nome;Contrato;Emissao;Vencido;Vencer;Parcelas" 
    skip.
    if vindex = 1
    then
    for each clasoper use-index indx3 where
                   clasoper.dtvisao = vdatref and
                   clasoper.tpvisao = vtipo_visao and
                   clasoper.cobcod  = prodevdu.cobcod and
                   clasoper.catcod  >= 0 and
                   clasoper.modcod  = "CRE" and
                   clasoper.riscon  = prodevdu.faixa_risco 
                   no-lock:

        find first clien where clien.clicod = clasoper.clifor no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = "NOME".
        vtotal = clasoper.vencido + clasoper.vencer.
        v-vencido = replace(string(clasoper.vencido,">>>>>>>>9.99"),".",",").
        v-vencer  = replace(string(clasoper.vencer,">>>>>>>>9.99"),".",",").
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
            v-vencido
            ";"
            v-vencer 
            ";"
            clasoper.qtdparab
            skip
            .
    end.
    else if vindex = 2
    then
    for each clasoper use-index indx4 where
                   clasoper.dtvisao = vdatref and
                   clasoper.tpvisao = vtipo_visao and
                   clasoper.cobcod  = prodevdu.cobcod and
                   clasoper.catcod >= 0 and
                   clasoper.modcod  = "CRE" and
                   clasoper.riscli  = prodevdu.faixa_risco 
                   no-lock:
        find first clien where clien.clicod = clasoper.clifor no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = "NOME".
        vtotal = clasoper.vencido + clasoper.vencer.
        v-vencido = replace(string(clasoper.vencido,">>>>>>>>9.99"),".",",").
        v-vencer  = replace(string(clasoper.vencer,">>>>>>>>9.99"),".",",").
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
            v-vencido  
            ";"
            v-vencer   
            ";"
            clasoper.qtdparab
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


    /***************
    varquivo = "/admcom/relat/" + lc(vtipo_visao) + "-" + lc(vmodo_visao) + "-"
                + lc(trim(vcobra[vindex])) + "-"
                + string(vdatref,"99999999") + "-risco-" 
                + p-risco + ".txt".   
    /*
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
    */
    output to value(varquivo) .
    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao + " - " + trim(vcobra[vindex]) 
                + " - risco " + p-risco
                skip.
                
   if vindex = 1
    then
    for each clasoper use-index indx3 where
                   clasoper.dtvisao = vdatref and
                   clasoper.tpvisao = vtipo_visao and
                   clasoper.cobcod  = prodevdu.cobcod and
                   clasoper.catcod  = 0 and
                   clasoper.modcod  = "CRE" and
                   clasoper.riscon  = prodevdu.faixa_risco 
                   no-lock:

        find first clien where clien.clicod = clasoper.clifor no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = "NOME".
        vtotal = clasoper.vencido + clasoper.vencer.
        disp clasoper.etbcod format ">>9"        column-label "Fil"
            clasoper.clifor format ">>>>>>>>>9"  column-label "Cliente"
            Vclinom                              column-label "Nome"
            clasoper.titnum                      column-label "Documento"
            clasoper.titdtemi                    column-label "Emissao"
            vtotal(total)              column-label "Total"
            format ">>>,>>>,>>9.99"
            clasoper.vencido(total)              column-label "Vencido"
            format ">>>,>>>,>>9.99"
            clasoper.vencer(total)               column-label "Vencer"
            format ">>>,>>>,>>9.99"
            clasoper.qtdparab                    column-label "Par.Aberta"
            with frame fd1 down width 160
            .
        down with frame fd1.
    end.
    else if vindex = 2
    then
    for each clasoper use-index indx4 where
                   clasoper.dtvisao = vdatref and
                   clasoper.tpvisao = vtipo_visao and
                   clasoper.cobcod  = prodevdu.cobcod and
                   clasoper.catcod = 0 and
                   clasoper.modcod  = "CRE" and
                   clasoper.riscli  = prodevdu.faixa_risco 
                   no-lock:
        find clien where clien.clicod = clasoper.clifor no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = "NOME".
        vtotal = clasoper.vencido + clasoper.vencer.
        disp clasoper.etbcod format ">>9"        column-label "Fil"
            clasoper.clifor format ">>>>>>>>>9"  column-label "Cliente"
            Vclinom                              column-label "Nome"
            clasoper.titnum                      column-label "Documento"
            clasoper.titdtemi                    column-label "Emissao"
            vtotal(total)              column-label "Total"
            format ">>>,>>>,>>9.99"
            clasoper.vencido(total)              column-label "Vencido"
            format ">>>,>>>,>>9.99"
            clasoper.vencer(total)               column-label "Vencer"
            format ">>>,>>>,>>9.99"
            clasoper.qtdparab                    column-label "Par.Aberta"
            with frame fd2 down width 160
            .
        down with frame fd2.
    end.
    output close.
    
    run visurel.p(input varquivo,"").
    *************/
    
end procedure.
