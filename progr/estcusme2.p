{admcab.i}

def var vtipo as log format "Windows/Linux".

def temp-table tthiest like hiest
    index i-ano-mes hieano hiemes.


def var varquivo as char.
def var dtfim as date.
def var vok as log.
def var vqtd as dec.
def var vtot31 as dec.
def var vtot41 as dec.
def var vtot35 as dec.
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
    field est35  like estoq.estatual.
    

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

    update skip
           vtipo label "Saida........."
           with frame f-etb.
    
    if not vtipo
    then
        varquivo = "/admcom/relat/estinl" + string(vmes).
    else
        varquivo = "l:\relat\estinw" + string(vmes).

    
    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "147"
            &Page-Line = "66"
            &Nom-Rel   = ""ESTCUSME""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """CONTROLE DE ESTOQUE """
            &Width     = "147"
            &Form      = "frame f-cabcab"}

    disp vmes
         vano with frame ffff side-labels centered.
    
    for each produ where produ.procod = 2630 no-lock:

        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf no-lock.

            vtot35 = 0.
            vtot31 = 0.
            vtot41 = 0.

            vqtd = 0.
            vok = no.
            find hiest where hiest.etbcod = estab.etbcod and
                             hiest.procod = produ.procod and
                             hiest.hiemes = vmes and
                             hiest.hieano = vano no-lock no-error.
            if avail hiest
            then do:
                assign vqtd = hiest.hiestf
                       vok = yes.
            end.
            else do:
                for each tthiest: delete tthiest. end.
                
                for each hiest where hiest.etbcod = estab.etbcod 
                                 and hiest.procod = produ.procod no-lock:

                    find last tthiest where tthiest.etbcod = estab.etbcod 
                                        and tthiest.procod = produ.procod 
                                        and tthiest.hiemes = hiest.hiemes                                              and tthiest.hieano = hiest.hieano
                                        no-error.
                    if not avail tthiest 
                    then do:
                        create tthiest.
                        buffer-copy hiest to tthiest.
                    end.
        
                end.

                find last tthiest use-index i-ano-mes no-lock no-error.
                if avail tthiest
                then do:
                    find hiest where hiest.etbcod = tthiest.etbcod 
                                 and hiest.procod = tthiest.procod 
                                 and hiest.hiemes = tthiest.hiemes 
                                 and hiest.hieano = tthiest.hieano 
                                 no-lock no-error.
                    if avail hiest 
                    then do: 
                        assign vqtd = hiest.hiestf 
                        vok = yes. 
                    end.
                end.
                
            end.

            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.
            
            /*
            if estoq.estatual <= 0
            then next.
            */
            
            if estoq.estcusto = ? 
            then next.
            
            if vok = no
            then next.

            output stream stela to terminal.
            disp stream stela
                 estab.etbcod
                 produ.procod format ">>>>>>>>9" 
                 with frame fffpla centered color white/red.
            pause 0.
            output stream stela close.

            if produ.catcod = 31
            then vtot31 = (vqtd * estoq.estcusto).
            if produ.catcod = 41
            then vtot41 = (vqtd * estoq.estcusto).

            if produ.catcod <> 31 and
               produ.catcod <> 41
            then vtot35 = (vqtd * estoq.estcusto). 

            find first tt-estoq where tt-estoq.etbcod = estab.etbcod no-error.
            if not avail tt-estoq
            then do:
                create  tt-estoq.
                assign  tt-estoq.etbcod = estab.etbcod.
            end.
            assign tt-estoq.est41 = tt-estoq.est41 + vtot41
                   tt-estoq.est31 = tt-estoq.est31 + vtot31
                   tt-estoq.est35 = tt-estoq.est35 + vtot35.
        end.
    end.
    
    for each tt-estoq by tt-estoq.etbcod:

        disp space(10) "Filial - " 
             tt-estoq.etbcod column-label "Filial" space(10)
             tt-estoq.est31(total) column-label "Moveis" 
                                format "->>,>>>,>>9.99" space(10)
             tt-estoq.est41(total) column-label "Confeccoes" 
                                format "->>,>>>,>>9.99" space(10)
             tt-estoq.est35(total) column-label "Outros"
                                format "->>,>>>,>>9.99"    
             (tt-estoq.est31 + tt-estoq.est41 + tt-estoq.est35)(total) 
                            column-label "Total"  
             format "->>,>>>,>>9.99"   with frame f-imp width 200 down.
    end.
    
    output close.     
    
    if not vtipo
    then message "Arquivo gerado: " varquivo.
    else do:
        {mrod.i}.
    end.    
end.

