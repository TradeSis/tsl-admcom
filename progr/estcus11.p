{admcab.i}

def var vtipo as log format "Windows/Linux".

def temp-table tthiest like hiest
    index i-ano-mes hieano hiemes.

def var vi as int.

def var vctomed as dec.
def var varquivo as char.
def var dtfim as date.
def var vok as log.
def var vqtd as dec.
def var vtot31 as dec.
def var vtot41 as dec.
def var vtot35 as dec.
def var vmed31 as dec.
def var vmed41 as dec.
def var vmed35 as dec.
def var wnp as i.
def var vvltotal as dec.
def var vvlcont  as dec.
def var wacr     as dec.
def var wper     as dec.
def var valortot as dec.
def var vval     as dec.
def var vval1    as dec.
def var vsal     as dec.
def var vlfinan  as dec.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vvlcusto    like plani.platot column-label "Vl.Custo".
def var vvlvenda    like plani.platot column-label "Vl.Venda".
def var vvlmarg     like plani.platot column-label "Margem".
def var vvlperc     as dec format ">>9.99 %" column-label "Perc".
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def var vacrepre    like plani.acfprod column-label "Acr.Previsto".
def var vcatcod     like produ.catcod.
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.
def var vmes like hiest.hiemes.
def var vano like hiest.hieano.
def temp-table tt-estoq
    field etbcod like estoq.etbcod
    field est41  like estoq.estatual
    field est31  like estoq.estatual
    field est35  like estoq.estatual
    field med41  like estoq.estatual
    field med31  like estoq.estatual
    field med35  like estoq.estatual.

def temp-table tt-invpro
    field etbcod like estab.etbcod 
    field procod like produ.procod
    field qtdest as dec
    field valest as dec
    field valtot as dec
    index i1 etbcod procod
    .

def var vindex as int.
def var vesc as char extent 2 format "x(20)".
vesc[1] = "   Analitico".
vesc[2] = "   Sintetico".


repeat:
    for each tt-estoq.
        delete tt-estoq.
    end.
    vtipo = yes.
    update vetbi label "Filial Inicial"
           vetbf label "Filial Final"
           with frame f-etb centered color blue/cyan side-labels
                    width 80.
           
    update skip
           vmes label "Mes..........."
           vano label "  Ano........."
           with frame f-etb.
    
    if vmes = 12
    then dtfim = date(1 , 1 , vano + 1).
    else dtfim = date(vmes + 1,1,vano).
    
    dtfim = dtfim - 1.

    disp vesc no-label with frame f-esc 1 down centered.
    choose field vesc with frame f-esc.
    
    vindex = frame-index.
    
    /*
    update skip
           vtipo label "Saida........."
           with frame f-etb.
    */
    if opsys = "UNIX"
    then vtipo = no.
    else vtipo = yes.
    
    if vindex = 1
    then
    varquivo = "/admcom/relat/estina" + string(vmes) + "." + string(time).
    else
    varquivo = "/admcom/relat/estins" + string(vmes) + "." + string(time).
    
    for each ctbhie where
                 ctbhie.etbcod >= vetbi and
                 ctbhie.etbcod <= vetbf and
                 ctbhie.ctbano = vano and
                 ctbhie.ctbmes = vmes 
                 no-lock :
        find estab where estab.etbcod = ctbhie.etbcod no-lock.
        find produ where produ.procod = ctbhie.procod no-lock.
            
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod
                             no-lock no-error.
            if not avail estoq then next.
                             
            vtot35 = 0.
            vtot31 = 0.
            vtot41 = 0.
            vmed35 = 0.
            vmed31 = 0.
            vmed41 = 0.

            assign
                vqtd = ctbhie.ctbqtd
                vctomed = ctbhie.ctbmed
                .
            if vqtd = 0 or
               vctomed = 0
            then next.    

            output stream stela to terminal.
            disp stream stela
                 estab.etbcod
                 produ.procod format ">>>>>>>>9" 
                 with frame fffpla centered color white/red.
            pause 0.
            output stream stela close.

            if produ.catcod = 31
            then assign
                    vtot31 = (vqtd * estoq.estcusto)
                    vmed31 = vqtd * vctomed.
            if produ.catcod = 41
            then assign
                    vtot41 = (vqtd * estoq.estcusto)
                    vmed41 = vqtd * vctomed.

            if produ.catcod <> 31 and
               produ.catcod <> 41
            then assign
                    vtot35 = (vqtd * estoq.estcusto)
                    vmed35 = vqtd * vctomed. 

            find first tt-estoq where tt-estoq.etbcod = estab.etbcod no-error.
            if not avail tt-estoq
            then do:
                create  tt-estoq.
                assign  tt-estoq.etbcod = estab.etbcod.
            end.
            assign tt-estoq.est41 = tt-estoq.est41 + vtot41
                   tt-estoq.est31 = tt-estoq.est31 + vtot31
                   tt-estoq.est35 = tt-estoq.est35 + vtot35
                   tt-estoq.med41 = tt-estoq.med41 + vmed41
                   tt-estoq.med31 = tt-estoq.med31 + vmed31
                   tt-estoq.med35 = tt-estoq.med35 + vmed35
                   .
            find first tt-invpro where
                       tt-invpro.etbcod = estab.etbcod and
                       tt-invpro.procod = produ.procod
                       no-error.
            if not avail tt-invpro
            then do:
                create tt-invpro.
                assign
                    tt-invpro.etbcod = estab.etbcod 
                    tt-invpro.procod = produ.procod
                    tt-invpro.qtdest = vqtd
                    tt-invpro.valest = vctomed
                    tt-invpro.valtot = (vctomed * vqtd)
                    .
            end.
    end.
    
    def var vtpcus as char.
    def var t31 as dec.
    def var t41 as dec.
    def var t35 as dec.
    def var vtt as dec.
    def var vtotal as dec init 0.
    
    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "120"
            &Page-Line = "66"
            &Nom-Rel   = ""ESTCUSME""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """CONTROLE DE ESTOQUE CUSTO MEDIO CONTABIL"""
            &Width     = "120"
            &Form      = "frame f-cabcab"}

    disp vmes
         vano with frame ffff side-labels centered.

    if vindex = 2
    then do:
    for each tt-estoq by tt-estoq.etbcod:
        disp "Filial - " 
             tt-estoq.etbcod column-label "Filial" 
             tt-estoq.med31(total) column-label "CtoMedio Moveis" 
                                format "->>,>>>,>>9.99" 
             tt-estoq.med41(total) column-label "CtoMedio Confeccoes" 
                                format "->>,>>>,>>9.99" 
             tt-estoq.med35(total) column-label "CtoMedio Outros"
                                format "->>,>>>,>>9.99"    
             (tt-estoq.med31 + tt-estoq.med41 + tt-estoq.med35)(total) 
                            column-label "CtoMedio Total" 
                         format "->>,>>>,>>9.99"                
             with frame f-imp width 200 down.
 
        vtotal = vtotal + (tt-estoq.med31 + tt-estoq.med41 + tt-estoq.med35).
    end.
    end.
    else do:
        for each tt-invpro no-lock:
            find produ where produ.procod = tt-invpro.procod no-lock.
            disp tt-invpro.etbcod  column-label "Filial"
                 tt-invpro.procod  column-label "Produto"
                 produ.pronom      column-label "Descricao" format "x(40)"
                 tt-invpro.qtdest  column-label "Quantidade"
                 tt-invpro.valest  column-label "Custo" 
                                    format "->,>>>,>>9.99"
                 (tt-invpro.valest * tt-invpro.qtdest) 
                        format "->>>,>>>,>>9.99"
                    column-label "Total"
                 with frame f-dispa width 100 down
                 .
            vtotal = vtotal + (tt-invpro.valest * tt-invpro.qtdest).
        end.
    end.
    
    output close.     

    message color red/with
    "Arquivo gerado" varquivo
    "Total " vtotal
    view-as alert-box.
    
    if not vtipo
    then DO: 
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}.
    end.    
end.

