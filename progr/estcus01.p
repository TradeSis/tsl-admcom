{admcab.i new}

def var vtipo as log format "Windows/Linux".

def temp-table tthiest like hiest
    index i-ano-mes hieano hiemes.

def temp-table tt-est
    field etbcod like estab.etbcod
    field procod like produ.procod
    field estatual like estoq.estatual
    field estcusto like estoq.estcusto
    field ctomed   like estoq.estcusto
    index i1 etbcod procod
    .
    
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
    
def var vpis as dec.
def var vcofins as dec.
def var valicms as dec.
def var vestcusto as dec.

def var vctomed-atu as dec.
def var vctomed-ant as dec.
def var vqtdest-ant as dec.
def var vqtdest-atu as dec.
def var vdt-aux as date.
def var vsal-ant as dec.
def var vsal-ent as dec.
def var vsal-sai as dec.
def var vsal-atu as dec.
def var vest-atu as dec.
def var vicms as dec.
def var dtini as date.
def var vmes-aux as int.
def var vano-aux as int.

form with frame  fffpla.

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
    then undo.
    if vmes = 12
    then dtfim = date(1 , 1 , vano + 1).
    else dtfim = date(vmes + 1,1,vano).
    
    dtfim = dtfim - 1.
    dtini = date(vmes,1,vano).

    /*
    update skip
           vtipo label "Saida........."
           with frame f-etb.
    */
    for each tt-est:
        delete tt-est.
    end.
    if vmes = 1
    then vmes-aux = 12.
    else vmes-aux = vmes - 1.
    if vmes = 1
    then vano-aux = vano - 1.
    else vano-aux = vano.
    if opsys = "UNIX"
    then do:
    input from value("/admcom/custom/Claudir/est" + string(vmes-aux,"99")
                + string(vano-aux,"9999")).
    repeat:
        create tt-est.
        import tt-est.
    end.
    input close.
    end.
    else do:
    input from value("l:\custom\Claudir/est" + string(vmes-aux,"99")
                + string(vano-aux,"9999")).
    repeat:
        create tt-est.
        import tt-est.
    end.
    input close.
    end.
    if opsys = "UNIX"
    then
        varquivo = "/admcom/custom/Claudir/estinl" + string(vmes) + "." + string(time).
    else
        varquivo = "l:\relat\estinw" + string(vmes) + "." + string(time).

    
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
    
    for each produ no-lock:
        
        output stream stela to terminal.
            disp stream stela
                 produ.procod format ">>>>>>>>9" 
                 with frame fffpla centered color white/red.
            pause 0.
            output stream stela close.


        find first tt-est where
                   tt-est.etbcod = 993 and 
                   tt-est.procod = produ.procod
                   no-lock no-error.
        if avail tt-est
        then vctomed-ant = tt-est.ctomed.    
        else vctomed-ant = 0.       
        vdt-aux = dtini.
        for each movim where movim.movtdc = 4 and
                         movim.procod = produ.procod
                         and movim.movdat >= dtini and
                             movim.movdat <= dtfim 
                              no-lock:
            vqtdest-ant = 0.
            for each estab no-lock:
                output stream stela to terminal.
            disp stream stela
                 estab.etbcod
                 produ.procod format ">>>>>>>>9" 
                 with frame fffpla centered color white/red.
            pause 0.
            output stream stela close.


                find estoq where estoq.etbcod = estab.etbcod and
                        estoq.procod = produ.procod
                        no-lock no-error.
                if not avail estoq
                then next.

                assign vsal-ant = 0
                       vsal-ent = 0
                       vsal-sai = 0
                       vsal-atu = 0 
                       vest-atu = 0.
             
                run /admcom/custom/Claudir/extmovpr.p(input estab.etbcod,
                                      input vdt-aux,
                                      input movim.movdat,
                                      input produ.procod,
                                      output vsal-ant,
                                      output vsal-ent,
                                      output vsal-sai,
                                      output vsal-atu,
                                      output vest-atu).
                vqtdest-ant = vqtdest-ant + vsal-atu. 
            end.  
            if vqtdest-ant < 0
            then vqtdest-ant = 0.
    
            
            vqtdest-atu = vqtdest-ant + movim.movqtm.
        
            vpis = 0.
            vcofins = 0.
            run piscofal.p( input no, 
                        input movim.movtdc, 
                        input movim.procod, 
                        output vpis,
                        output vcofins).
        
            if vpis > 0
            then vpis = movim.movpc  * (vpis / 100).
            if vcofins > 0
            then vcofins = movim.movpc * (vcofins / 100).         
            if movim.movalicms > 0
            then vicms = movim.movpc * (movim.movalicms / 100).
            
            vctomed-atu =  movim.movpc - 
                                (vicms + movim.movdes + vpis + vcofins).
            vctomed-atu = vctomed-atu + (movim.movalipi / movim.movqtm).

            if vqtdest-ant = ? or vqtdest-ant < 0
            then vqtdest-ant = 0.            
            if vctomed-ant = ? or vctomed-ant < 0
            then vctomed-ant = 0.
        
            if vqtdest-ant > 0 and
               vctomed-ant > 0
            then vctomed-atu = (vctomed-atu * movim.movqtm) +
                      (vctomed-ant * vqtdest-ant).
               
            if vctomed-atu > 0 and
               vctomed-atu <> ? and
               vqtdest-atu > 0 and
               vqtdest-atu <> ?
            then vctomed-atu = vctomed-atu / vqtdest-atu.
            else vctomed-atu = vctomed-ant.
            
            vdt-aux = movim.movdat.
            vctomed-ant = vctomed-atu.
            /*
            vqtdest-ant = vqtdest-atu.
            */     
        end.
        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf no-lock.

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
                                        and tthiest.hiemes = hiest.hiemes 
                                        and tthiest.hieano = hiest.hieano
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
            
            /*
            if estoq.estatual <= 0
            then next.
            */

            if vok = no
            then next.

            vestcusto = hiest.hiepcf.
            if vestcusto = ? or vestcusto = 0
            then vestcusto = estoq.estcusto.
            if vestcusto = ?
            then next.
            /*
            if estoq.estcusto = ? 
            then next.
            */

            output stream stela to terminal.
            disp stream stela
                 estab.etbcod
                 produ.procod format ">>>>>>>>9" 
                 with frame fffpla centered color white/red.
            pause 0.
            output stream stela close.

            create tt-est.
            assign
                tt-est.etbcod = estab.etbcod
                tt-est.procod = produ.procod
                tt-est.estatual = vqtd
                tt-est.estcusto = vestcusto
                .

            /*
            vestcusto = (vestcusto - (vestcusto * (valicms / 100))) 
                    /*- (vpis + vcofins)*/.

            if vestcusto = ? then vestcusto = 0.
            */
            if vestcusto = 0
            then next.
            if vctomed-ant = 0
            then vctomed-ant = vestcusto.
            tt-est.ctomed = vctomed-ant.
            vtot31 = 0.
            vtot41 = 0.
            vtot35 = 0.
            if produ.catcod = 31
            then vtot31 = (vqtd * vctomed-ant).
            if produ.catcod = 41
            then vtot41 = (vqtd * vctomed-ant).

            if produ.catcod <> 31 and
               produ.catcod <> 41
            then vtot35 = (vqtd * vctomed-ant). 

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
             tt-estoq.est31(total) column-label "Vl.Custo Moveis" 
                                format "->>,>>>,>>9.99" space(10)
             tt-estoq.est41(total) column-label "Vl.Custo Confeccoes" 
                                format "->>,>>>,>>9.99" space(10)
             tt-estoq.est35(total) column-label "Vl.Custo Outros"
                                format "->>,>>>,>>9.99"    
             (tt-estoq.est31 + tt-estoq.est41 + tt-estoq.est35)(total) 
                            column-label "Vl.Custo Total"  
             format "->>,>>>,>>9.99"   with frame f-imp width 200 down.
    end.
    
    output close.     
    
    if opsys = "UNIX"
    then do:
    output to value("/admcom/custom/Claudir/est" + string(vmes,"99")
                + string(vano,"9999")).
    for each tt-est.
        export tt-est.
    end.
    output close.
    end.
    else do:
    output to value("l:\custom\Claudir/est" + string(vmes,"99")
                + string(vano,"9999")).
    for each tt-est.
        export tt-est.
    end.
    output close.
    end.
        
    if opsys = "UNIX"
    then do:
        message "Arquivo gerado: " varquivo.
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}.
    end.    
end.
