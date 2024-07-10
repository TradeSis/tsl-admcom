{admcab.i}

message color red/with
    " USAR GERA BASE DE SLADO PARA PROCESSAR" skip
    " E LISTARGEM BASE DE SLADO PARA RELATORIO"
    view-as alert-box.
return.
      
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
def var vtot31-1 as dec.
def var vtot41 as dec.
def var vtot35 as dec.
def var vmed31 as dec.
def var vmed31-1 as dec.
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
    field est31-1  like estoq.estatual
    field est35  like estoq.estatual
    field med41  like estoq.estatual
    field med31  like estoq.estatual
    field med31-1  like estoq.estatual
    field med35  like estoq.estatual.
    

def temp-table tt-clase like clase.
/**
run gera-ttclase.
*/

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

    /*
    update skip
           vtipo label "Saida........."
           with frame f-etb.
    */
    if opsys = "UNIX"
    then vtipo = no.
    else vtipo = yes.
    
    if not vtipo
    then
        varquivo = "/admcom/relat/estinl" + string(vmes) + "." + string(time).
    else
        varquivo = "l:\relat\estinw" + string(vmes) + "." + string(time).

    
    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "120"
            &Page-Line = "66"
            &Nom-Rel   = ""ESTCUSME""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """CONTROLE DE ESTOQUE """
            &Width     = "120"
            &Form      = "frame f-cabcab"}

    disp vmes
         vano with frame ffff side-labels centered.
    
    for each produ no-lock:

        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf no-lock.

            vtot35 = 0.
            vtot31 = 0.
            vtot31-1 = 0.
            vtot41 = 0.
            vmed35 = 0.
            vmed31 = 0.
            vmed31-1 = 0.
            vmed41 = 0.


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

                    if hiest.hieano > vano 
                    then next.
                       
                    if hiest.hiemes > vmes and
                       hiest.hieano = vano
                    then next. 
                    
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

                find last tthiest use-index i-ano-mes 
                                  no-lock no-error.
                if avail tthiest
                then do:
                    find hiest where hiest.etbcod = tthiest.etbcod 
                                 and hiest.procod = tthiest.procod 
                                 and hiest.hiemes = tthiest.hiemes 
                                 and hiest.hieano = tthiest.hieano 
                                 no-lock no-error.
                    if avail hiest 
                    then do: 

                     /*   message tthiest.etbcod
                                tthiest.procod
                                tthiest.hiemes
                                tthiest.hieano 
                                tthiest.hiestf
                                view-as alert-box.*/
                        
                        assign vqtd = hiest.hiestf 
                        vok = yes. 
                    end.
                end.
                
            end.

            if vqtd < 0
            then vqtd = 0.
            
            if vqtd = 0 then next.
            
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.
            
            find last ctbhie where
                 ctbhie.etbcod = 0 and
                 ctbhie.procod = produ.procod and
                 ctbhie.ctbano = vano and
                 ctbhie.ctbmes = vmes 
                 no-lock no-error.
            if not avail ctbhie
            then do vi = 1 to 10:
                find last ctbhie use-index ind-2 where
                     ctbhie.etbcod = 0 and
                     ctbhie.procod = produ.procod and
                     ctbhie.ctbano = vano - vi 
                     no-lock no-error.
                if avail ctbhie
                then do:
                    leave.
                end.
            end.     
            if avail ctbhie and ctbhie.ctbcus <> ?
            then vctomed = ctbhie.ctbcus.
            else vctomed = hiest.hiepcf.
            
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
            then do:
                find first tt-clase where
                           tt-clase.clacod = produ.clacod no-lock no-error.
                if avail tt-clase
                then assign
                    vtot31-1 = (vqtd * estoq.estcusto)
                    vmed31-1 = vqtd * vctomed.
                else assign
                    vtot31 = (vqtd * estoq.estcusto)
                    vmed31 = vqtd * vctomed.
            end.
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
                   tt-estoq.est31-1 = tt-estoq.est31-1 + vtot31-1
                   tt-estoq.est35 = tt-estoq.est35 + vtot35
                   tt-estoq.med41 = tt-estoq.med41 + vmed41
                   tt-estoq.med31 = tt-estoq.med31 + vmed31
                   tt-estoq.med31-1 = tt-estoq.med31-1 + vmed31-1
                   tt-estoq.med35 = tt-estoq.med35 + vmed35
                   .
        end.
    end.
    
    def var vtpcus as char.
    def var t31 as dec.
    def var t41 as dec.
    def var t35 as dec.
    def var vtt as dec.
    
    for each tt-estoq by tt-estoq.etbcod:
        disp "Filial - " 
             tt-estoq.etbcod column-label "Filial" 
             /**
             tt-estoq.est31(total) column-label "Vl.Custo Moveis" 
                                format "->>,>>>,>>9.99" 
             tt-estoq.est41(total) column-label "Vl.Custo Confeccoes" 
                                format "->>,>>>,>>9.99" 
             tt-estoq.est35(total) column-label "Vl.Custo Outros"
                                format "->>,>>>,>>9.99"    
             (tt-estoq.est31 + tt-estoq.est41 + tt-estoq.est35)(total) 
                            column-label "Vl.Custo Total" 
                         format "->>,>>>,>>9.99"
             **/
             tt-estoq.med31(total) column-label "CtoMedio Moveis" 
                                format "->>,>>>,>>9.99" 
             tt-estoq.med31-1(total) column-label "CtoMedio Eletro" 
                                format "->>,>>>,>>9.99" 
             tt-estoq.med41(total) column-label "CtoMedio Confeccoes" 
                                format "->>,>>>,>>9.99" 
             tt-estoq.med35(total) column-label "CtoMedio Outros"
                                format "->>,>>>,>>9.99"    
             (tt-estoq.med31 + tt-estoq.med31-1 + 
                tt-estoq.med41 + tt-estoq.med35)(total) 
                            column-label "CtoMedio Total" 
                         format "->>,>>>,>>9.99"                
             with frame f-imp width 200 down.
 
    end.
    
    output close.     
    
    if not vtipo
    then DO: 
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}.
    end.    
end.

