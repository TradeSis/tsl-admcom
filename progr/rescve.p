{admcab.i} 
        

def var tt-1 like plani.platot.
def var tt-2 like plani.platot.
def var tt-3 like plani.platot.
def var tt-4 like plani.platot.
def var tt-5 like plani.platot.
def var tt-6 like plani.platot.
def var tt-7 like plani.platot.
def var tt-8 like plani.platot.




def var tot1 like plani.platot.
def var tot2 like plani.platot.
def var tot3 like plani.platot.
def var tot4 like plani.platot.
def var tot5 like plani.platot.
def var tot6 like plani.platot.
def var tot7 like plani.platot.
def var tot8 like plani.platot.

def var vmes as i.
def var vano as i.
def buffer estoq for estoq.
def var t-ven  like estoq.estvenda format "->>>,>>9.99".
DEF VAR t-val  like estoq.estvenda format "->>>,>>9.99".

def var t-venda  like estoq.estvenda format "->>>,>>9.99".
DEF VAR t-valest like estoq.estvenda format ">>,>>>,>>9.99".
def var v-giro   like estoq.estvenda format "->,>>9.99".
def var tot-v    like estoq.estvenda format "->>>,>>9.99".
DEF VAR est-ven  like estoq.estvenda format "->>>,>>9" .
DEF VAR venda    like estoq.estvenda format "->>>,>>9.99".
DEF VAR est-com  like estoq.estvenda format "->>>,>>9"   .
DEF VAR compra   like estoq.estvenda format "->>>,>>9.99".
DEF VAR est-atu  like estoq.estvenda format "->>>,>>9"   .
DEF VAR valest   like estoq.estvenda format "->>,>>>,>>9.9".
DEF VAR valcus   like estoq.estvenda format "->>>,>>9.99".

def var totcusto like estoq.estcusto.
def var totvenda like estoq.estcusto.
def buffer bestoq for estoq.
def var acre like plani.platot.
def var des like plani.platot.
def buffer bcurva for curva.
def buffer bmovim for movim.
def var totc like plani.platot.
def var tot-m like plani.platot.
def var vacum like plani.platot format "->>9.99".
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
def var vclasup like clase.clasup.
def temp-table tt-catcod
    field catcod like produ.catcod.

repeat:
    for each tt-catcod:
        delete tt-catcod.
    end.
    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.

    if vcatcod = 31
    then do:
        create tt-catcod.
        assign tt-catcod.catcod = 31.
        create tt-catcod.
        assign tt-catcod.catcod = 35.
        create tt-catcod.
        assign tt-catcod.catcod = 50.
    end.
    else do:
        create tt-catcod.
        assign tt-catcod.catcod = 41.
        create tt-catcod.
        assign tt-catcod.catcod = 45.
    end.

    assign  tt-1 = 0
            tt-2 = 0
            tt-3 = 0
            tt-4 = 0
            tt-5 = 0
            tt-6 = 0
            tt-7 = 0
            tt-8 = 0.

    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".
    update vclasup with frame f-dat side-label.
    if vclasup = 0
    then display "GERAL" @ clase.clanom with frame f-dat.
    else do:
        find clase where clase.clacod = vclasup no-lock.
        display clase.clanom no-label with frame f-dat.
    end.
    assign est-ven = 0
           venda   = 0
           est-com = 0
           compra = 0
           est-atu = 0
           valest  = 0
           valcus  = 0.


    {mdadmcab.i
        &Saida     = "i:\admcom\relat\resu"
        &Page-Size = "64"
        &Cond-Var  = "135"
        &Page-Line = "66"
        &Nom-Rel   = ""RESCVE""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """RESUMO VENDA/COMPRA/ESTOQUE - DA FILIAL "" +
                            string(vetbi,"">>9"") + "" A "" +
                            string(vetbf,"">>9"") +
                      "" PERIODO DE "" +
                         string(vdti,""99/99/9999"") + "" A "" +
                         string(vdtf,""99/99/9999"") "
       &Width     = "135"
       &Form      = "frame f-cabcab"}

    tot-v = 0.
    if vclasup = 0
    then do:
    for each clase no-lock by clase.clasup
                           by clase.clacod:

        for each tt-catcod no-lock,
            each produ where produ.catcod = tt-catcod.catcod and
                             produ.clacod = clase.clacod no-lock:
            
               find first movim where movim.procod = produ.procod and
                                      movim.movdat >= vdti        and
                                      movim.movdat <= vdtf no-lock no-error.
               if not avail movim
               then do:
                    find first estoq where estoq.procod = produ.procod and
                                           estoq.estatual <> 0 no-lock no-error.
                    if not avail estoq
                    then next.
               end.


               find first movim where movim.procod = produ.procod and
                                      movim.movdat >= vdti        and
                                      movim.movdat <= vdtf no-lock no-error.
               if not avail movim
               then do:
                    find first estoq where estoq.procod = produ.procod and
                                           estoq.estatual <> 0 no-lock no-error.
                    if not avail estoq
                    then next.
               end.

            
            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 5            and
                                 movim.movdat >= vdti        and
                                 movim.movdat <= vdtf        no-lock:

                if movim.movqtm = 0 or
                   movim.movpc  = 0
                then next.

                totc = 0.
                des = 0.
                acre = 0.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.pladat = movim.movdat and
                                       plani.movtdc = movim.movtdc
                                                        no-lock no-error.
                if avail plani and plani.crecod = 2
                then do:
                    for each contnf where contnf.placod = plani.placod and
                                          contnf.etbcod = plani.etbcod no-lock:
                        find contrato where contrato.contnum = contnf.contnum
                                                            no-lock no-error.
                        if avail contrato
                        then do:
                            if contrato.vltotal > ( plani.platot - 
                                                    plani.vlserv)
                            then do:
                                acre = contrato.vltotal /
                                       (plani.platot - 
                                        plani.vlserv).
                            end.
                            if contrato.vltotal < ( plani.platot - 
                                                    plani.vlserv) 
                            then do:
                                des = (plani.platot 
                                        - plani.vlserv)
                                        / contrato.vltotal.
                            end.
                        end.
                        else do:
                            if plani.acfprod > 0
                            then acre = (plani.platot + plani.acfprod) / 
                                         plani.platot.
                            if plani.descprod > 0
                            then des = plani.platot /
                                       (plani.platot - plani.descprod).
                        end.
                    end.
                    if plani.platot < 1
                    then assign des = 0
                                acre = 0.
                end.

                if not available plani
                then next.

                find estoq where estoq.etbcod = movim.etbcod and
                                 estoq.procod = produ.procod no-lock no-error.
                if not avail estoq
                then next.

                if acre > 0
                then do:
              
                    if ( movim.movqtm * movim.movpc * acre ) - 
                       ( ( ( movim.movqtm * movim.movpc ) / 
                             plani.platot ) * plani.vlserv ) <> ?
                    then
                    tot-v = tot-v + 
                             ( movim.movqtm * movim.movpc * acre ) - 
                             ( ( ( movim.movqtm * movim.movpc ) / 
                                 plani.platot ) * plani.vlserv ).
                end.
                if des > 0
                then do:
                    if ( movim.movqtm * movim.movpc / des ) - 
                       ( ( ( movim.movqtm * movim.movpc ) / 
                             plani.platot ) * plani.vlserv ) <> ?
                    then
                    tot-v = tot-v +
                             ( movim.movqtm * movim.movpc / des ) - 
                             ( ( ( movim.movqtm * movim.movpc ) / 
                                 plani.platot ) * plani.vlserv ).
                end.
                if acre = 0 and des = 0
                then do:
                    if  ( ( movim.movqtm * movim.movpc ) - 
                        ( ( ( movim.movqtm * movim.movpc ) / 
                              plani.platot ) * plani.vlserv ) ) <> ?
                    then
                    tot-v = tot-v +
                             ( ( movim.movqtm * movim.movpc ) - 
                             ( ( ( movim.movqtm * movim.movpc ) / 
                               plani.platot ) * plani.vlserv ) ).
                end.
            end.
        end.
    end. 
    for each clase no-lock break by clase.clasup
                                 by clase.clacod:
                  
        for each tt-catcod no-lock,
            each produ where produ.catcod = tt-catcod.catcod and
                             produ.clacod = clase.clacod no-lock:

            
           find first movim where movim.procod = produ.procod and
                                  movim.movdat >= vdti        and
                                  movim.movdat <= vdtf no-lock no-error.
           if not avail movim
           then do:
                find first estoq where estoq.procod = produ.procod and
                                       estoq.estatual <> 0 no-lock no-error.
                if not avail estoq
                then next.
           end.

            
            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 5            and
                                 movim.movdat >= vdti        and
                                 movim.movdat <= vdtf        no-lock:
                
                if movim.movqtm = 0 or
                   movim.movpc  = 0
                then next.

                totc = 0.
                des = 0.
                acre = 0.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.pladat = movim.movdat and
                                       plani.movtdc = movim.movtdc
                                                        no-lock no-error.
                if avail plani and plani.crecod = 2
                then do:
                    for each contnf where contnf.placod = plani.placod and
                                          contnf.etbcod = plani.etbcod no-lock:
                        find contrato where contrato.contnum = contnf.contnum
                                                            no-lock no-error.
                        if avail contrato
                        then do:
                            if contrato.vltotal > ( plani.platot - 
                                                    plani.vlserv)
                            then do:
                                acre = contrato.vltotal /
                                       (plani.platot - 
                                        plani.vlserv).
                            end.
                            if contrato.vltotal < ( plani.platot - 
                                                    plani.vlserv) 
                            then do:
                                des = (plani.platot 
                                        - plani.vlserv)
                                        / contrato.vltotal.
                            end.
                        end.
                        else do:
                            if plani.acfprod > 0
                            then acre = (plani.platot + plani.acfprod) / 
                                         plani.platot.
                            if plani.descprod > 0
                            then des = plani.platot /
                                       (plani.platot - plani.descprod).
                        end.
                    end.
                    if plani.platot < 1
                    then assign des = 0
                                acre = 0.
                end.

                if not available plani
                then next.

                find estoq where estoq.etbcod = movim.etbcod and
                                 estoq.procod = produ.procod no-lock no-error.
                if not avail estoq
                then next.

                if acre > 0
                then do:
                    if ( movim.movqtm * movim.movpc * acre ) - 
                       ( ( ( movim.movqtm * movim.movpc ) / 
                             plani.platot ) * plani.vlserv ) <> ?
                    then 
                    venda = venda + 
                             ( movim.movqtm * movim.movpc * acre ) - 
                             ( ( ( movim.movqtm * movim.movpc ) / 
                                 plani.platot ) * plani.vlserv ).
                end.
                if des > 0
                then do:
                    if ( movim.movqtm * movim.movpc / des ) - 
                           ( ( ( movim.movqtm * movim.movpc ) / 
                                 plani.platot ) * plani.vlserv ) <> ?
                    
                    then venda = venda +
                             ( movim.movqtm * movim.movpc / des ) - 
                             ( ( ( movim.movqtm * movim.movpc ) / 
                                 plani.platot ) * plani.vlserv ).
                end.
                if acre = 0 and des = 0
                then do:
                    
                   if ( ( movim.movqtm * movim.movpc ) - 
                      ( ( ( movim.movqtm * movim.movpc ) / 
                            plani.platot ) * plani.vlserv ) ) <> ?
                   
                   then venda = venda +
                             ( ( movim.movqtm * movim.movpc ) - 
                             ( ( ( movim.movqtm * movim.movpc ) / 
                               plani.platot ) * plani.vlserv ) ).
                end.
                est-ven = est-ven + movim.movqtm.
            end.
            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 4  no-lock.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat no-lock
                                            no-error.

                if avail plani
                then do:
                    if  plani.datexp >= vdti  and
                        plani.datexp <= vdtf
                    then assign
                            compra  = compra + (movim.movpc * movim.movqtm)
                            est-com = est-com + movim.movqtm.
                end.
            end.
            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 1  no-lock.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat no-lock
                                            no-error.

                if avail plani
                then do:
                    if  plani.datexp >= vdti  and
                        plani.datexp <= vdtf
                    then assign
                            compra  = compra + (movim.movpc * movim.movqtm)
                            est-com = est-com + movim.movqtm.
                end.
            end.
            
            /**************************/


            for each estab no-lock:
                find bestoq where bestoq.etbcod = estab.etbcod and
                                  bestoq.procod = produ.procod no-lock no-error.
                if not avail bestoq
                then next.
                find hiest where hiest.etbcod = estab.etbcod and
                                 hiest.procod = produ.procod and
                                 hiest.hiemes = month(vdtf)  and
                                 hiest.hieano = year(vdtf) no-lock no-error.
                if not avail hiest
                then do:
                    if month(vdtf) = 1
                    then assign vano = year(vdtf) - 1
                                vmes = 12.
                    else assign vano = year(vdtf)
                                vmes = month(vdtf).
                    find last hiest where hiest.etbcod = estab.etbcod and
                                          hiest.procod = produ.procod and
                                          hiest.hiemes <= vmes        and
                                          hiest.hieano = vano no-lock no-error.
                    if not avail hiest
                    then do:
                        find bestoq where bestoq.etbcod = estab.etbcod and
                                          bestoq.procod = produ.procod
                                                              no-lock no-error.
                        if avail bestoq
                        then do:
                            valest = valest +
                                     (bestoq.estatual * bestoq.estvenda).
                            valcus = valcus +
                                        (bestoq.estatual * bestoq.estcusto).
                            est-atu = est-atu + bestoq.estatual.
                        end.
                    end.
                    else do:
                        valest  = valest  + (hiest.hiestf * bestoq.estvenda).
                        valcus  = valcus  + (hiest.hiestf * bestoq.estcusto).
                        est-atu = est-atu + hiest.hiestf.
                    end.
                end.
                else do:
                    valest  = valest  + (hiest.hiestf * bestoq.estvenda).
                    valcus  = valcus  + (hiest.hiestf * bestoq.estcusto).
                    est-atu = est-atu + hiest.hiestf.
                end.
            end.
            
            output stream stela to terminal.
            disp stream stela produ.procod produ.clacod
                        with frame ffff centered color white/red 1 down.
            pause 0.
            output stream stela close.
        end.


        if line-counter = 6
        then put "        V E N D A S                 C O M P R A S  "  at 35
                 "               E S T O Q U E S        "
                                 skip fill("-",135) format "x(135)".

        if line-counter = 6
        then put "        V E N D A S                 C O M P R A S   " at 35
                 "               E S T O Q U E S "
                      skip fill("-",135) format "x(135)".


        tot1 = tot1 + est-ven.
        tot2 = tot2 + venda.
        tot3 = tot3 + ((venda / tot-v) * 100).
        tot4 = tot4 + est-com.
        tot5 = tot5 + compra.
        tot6 = tot6 + est-atu.
        tot7 = tot7 + valest.
        tot8 = tot8 + valcus.

        
        tt-1 = tt-1 + est-ven.
        tt-2 = tt-2 + venda.
        tt-3 = tt-3 + ((venda / tot-v) * 100).
        tt-4 = tt-4 + est-com.
        tt-5 = tt-5 + compra.
        tt-6 = tt-6 + est-atu.
        tt-7 = tt-7 + valest.
        tt-8 = tt-8 + valcus.


        v-giro = (valest / venda).
        if v-giro = ?
        then v-giro = 0.
        
        if venda > 0 or
           est-atu <> 0
        then 
        display clase.clacod
                clase.clanom when avail clase
                est-ven column-label "FISICO"
                venda    column-label "FINANCEIRO"
                ((venda / tot-v) * 100)
                                       column-label "%/Par." format "->,>>9.99"
                est-com column-label "FISICO"
                compra  column-label "FINANCEIRO"
                est-atu column-label "FISICO"
                valest  column-label "FIN.VENDA"
                valcus  column-label "FIN.CUSTO"
                v-giro  column-label "GIRO"
                            with frame f-1 width 200 down no-box.

        t-venda = t-venda + venda.
        t-valest = t-valest + valest.
        t-ven = t-venda + venda.
        t-val = t-valest + valest.
     
        
        if last-of(clase.clasup) and
           (tot2 > 0 or tot6 > 0)
        then do:
             put skip.
             put fill("-",135) format "x(135)" skip.
             put "T O T A I S ..............."
                 tot1  to 41  format "->>>,>>9" 
                 tot2  to 53  format "->>>,>>9.99"
                 tot3  to 63  format "->>>,>>9"
                 tot4  to 72  format "->>>,>>9"
                 tot5  to 84  format "->>>,>>9.99"
                 tot6  to 93  format "->>>,>>9"
                 tot7  to 107 format "->>>,>>9.99"
                 tot8  to 119 format "->>>,>>9.99" 
                 (t-valest / t-venda) to 129 skip
                 fill("-",135) format "x(135)" skip(1).

             assign tot1 = 0
                    tot2 = 0
                    tot3 = 0
                    tot4 = 0
                    tot5 = 0
                    tot6 = 0
                    tot7 = 0
                    tot8 = 0
                    t-valest = 0
                    t-venda  = 0.
        end.

        assign est-ven = 0
               venda   = 0
               est-com = 0
               compra = 0
               est-atu = 0
               valest  = 0
               valcus  = 0.

    end.
    end.
    else do:
        for each clase where clase.clasup = vclasup
                                no-lock by clase.clasup
                                        by clase.clacod:
        
            for each tt-catcod no-lock,
                each produ where produ.catcod = tt-catcod.catcod and
                                 produ.clacod = clase.clacod no-lock:
                
                
                   find first movim where movim.procod = produ.procod and
                                          movim.movdat >= vdti        and
                                          movim.movdat <= vdtf no-lock no-error.
                   if not avail movim
                   then do:
                        find first estoq where estoq.procod = produ.procod and
                                               estoq.estatual <> 0 
                                                            no-lock no-error.
                        if not avail estoq
                        then next.
                   end.

                
                
                
                for each movim where movim.procod = produ.procod and
                                     movim.movtdc = 5            and
                                     movim.movdat >= vdti        and
                                     movim.movdat <= vdtf        no-lock:
             
                    if movim.movqtm = 0 or
                       movim.movpc  = 0
                    then next.

                    totc = 0.
                    des = 0.
                    acre = 0.
                    find first plani where plani.etbcod = movim.etbcod and
                                           plani.placod = movim.placod and
                                           plani.pladat = movim.movdat and
                                           plani.movtdc = movim.movtdc
                                                            no-lock no-error.
                    if avail plani and plani.crecod = 2
                    then do:
                        for each contnf where contnf.placod = plani.placod and
                                              contnf.etbcod = plani.etbcod 
                                                                        no-lock:
                            find contrato where contrato.contnum = 
                                                           contnf.contnum
                                                            no-lock no-error.
                            if avail contrato
                            then do:
                                if contrato.vltotal > ( plani.platot - 
                                                        plani.vlserv)
                                then do:
                                    acre = contrato.vltotal /
                                           (plani.platot - 
                                            plani.vlserv).
                                end.
                                if contrato.vltotal < ( plani.platot - 
                                                        plani.vlserv) 
                                then do:
                                    des = (plani.platot 
                                            - plani.vlserv)
                                            / contrato.vltotal.
                                end.
                            end.
                            else do:
                                if plani.acfprod > 0
                                then acre = (plani.platot + plani.acfprod) / 
                                             plani.platot.
                                if plani.descprod > 0
                                then des = plani.platot /
                                           (plani.platot - plani.descprod).
                            end.
                        end.
                        if plani.platot < 1
                        then assign des = 0
                                    acre = 0.
                    end.

                    if not available plani
                    then next.

                    find estoq where estoq.etbcod = movim.etbcod and
                                     estoq.procod = produ.procod 
                                                            no-lock no-error.
                    if not avail estoq
                    then next.

                    if acre > 0
                    then do:
                        if ( movim.movqtm * movim.movpc * acre ) - 
                           ( ( ( movim.movqtm * movim.movpc ) / 
                                 plani.platot ) * plani.vlserv ) <> ?
                        then
                        tot-v = tot-v + 
                                 ( movim.movqtm * movim.movpc * acre ) - 
                                 ( ( ( movim.movqtm * movim.movpc ) / 
                                       plani.platot ) * plani.vlserv ).
                    end.
                    if des > 0
                    then do:
                        if ( movim.movqtm * movim.movpc / des ) - 
                             ( ( ( movim.movqtm * movim.movpc ) / 
                                 plani.platot ) * plani.vlserv ) <> ?
                        then
                        tot-v = tot-v +
                             ( movim.movqtm * movim.movpc / des ) - 
                             ( ( ( movim.movqtm * movim.movpc ) / 
                                 plani.platot ) * plani.vlserv ).
                    end.
                    if acre = 0 and des = 0
                    then do:
                 
                        if ( ( movim.movqtm * movim.movpc ) - 
                           ( ( ( movim.movqtm * movim.movpc ) / 
                                 plani.platot ) * plani.vlserv ) ) <> ?
                        then
                        tot-v = tot-v +
                                ( ( movim.movqtm * movim.movpc ) - 
                                 ( ( ( movim.movqtm * movim.movpc ) / 
                                   plani.platot ) * plani.vlserv ) ).
                    end.
                end.
            end.
        end.


        for each clase where clase.clasup = vclasup
                        no-lock break by clase.clasup
                                      by clase.clacod:

            for each tt-catcod no-lock,
                each produ where produ.catcod = tt-catcod.catcod and
                                 produ.clacod = clase.clacod no-lock:
                
                
                   find first movim where movim.procod = produ.procod and
                                          movim.movdat >= vdti        and
                                          movim.movdat <= vdtf no-lock no-error.
                   if not avail movim
                   then do:
                        find first estoq where estoq.procod = produ.procod and
                                           estoq.estatual <> 0 no-lock no-error.
                        if not avail estoq
                        then next.
                   end.

                
                for each movim where movim.procod = produ.procod and
                                     movim.movtdc = 5            and
                                     movim.movdat >= vdti        and
                                     movim.movdat <= vdtf        no-lock:
               
                    if movim.movqtm = 0 or
                       movim.movpc  = 0
                    then next.
     
                    totc = 0.
                    des = 0.
                    acre = 0.
                    find first plani where plani.etbcod = movim.etbcod and
                                           plani.placod = movim.placod and
                                           plani.movtdc = movim.movtdc and
                                           plani.pladat = movim.movdat
                                                            no-lock no-error.
                    if avail plani and plani.crecod = 2
                    then do:
                        for each contnf where contnf.placod = plani.placod and
                                              contnf.etbcod = plani.etbcod 
                                                                        no-lock:
                            find contrato where contrato.contnum = 
                                                                contnf.contnum
                                                            no-lock no-error.
                            if avail contrato
                            then do:
                                if contrato.vltotal > ( plani.platot - 
                                                        plani.vlserv)
                                then do:
                                    acre = contrato.vltotal /
                                           (plani.platot - 
                                            plani.vlserv).
                                end.        
                                if contrato.vltotal < ( plani.platot - 
                                                        plani.vlserv) 
                                then do:
                                    des = (plani.platot 
                                            - plani.vlserv)
                                            / contrato.vltotal.
                                end.
                            end.
                            else do:
                                if plani.acfprod > 0
                                then acre = (plani.platot + plani.acfprod) / 
                                             plani.platot.
                                if plani.descprod > 0
                                then des = plani.platot /
                                           (plani.platot - plani.descprod).
                            end.
                        end.
                        if plani.platot < 1
                        then assign des = 0
                                    acre = 0.
                    end.


                    if not available plani
                    then next.
            
                    find estoq where estoq.etbcod = movim.etbcod and
                                     estoq.procod = produ.procod 
                                                        no-lock no-error.
                    if not avail estoq
                    then next.

                    if acre > 0
                    then do:
                        if (movim.movqtm * movim.movpc * acre ) -
                           ( ( ( movim.movqtm * movim.movpc) /
                           plani.platot ) * plani.vlserv) <> ?
                        then
                        venda = venda + 
                                 ( movim.movqtm * movim.movpc * acre ) - 
                                 ( ( ( movim.movqtm * movim.movpc ) / 
                                       plani.platot ) * plani.vlserv ).
                    end.
                    if des > 0
                    then do:
                        if (movim.movqtm * movim.movpc / des ) -
                         ((( movim.movqtm * movim.movpc) /
                         plani.platot ) * plani.vlserv) <> ?
                        then
                        venda = venda +
                                 ( movim.movqtm * movim.movpc / des ) - 
                                 ( ( ( movim.movqtm * movim.movpc ) / 
                                     plani.platot ) * plani.vlserv ).
                    end.    
                    if acre = 0 and des = 0
                    then do:
                        if (( movim.movqtm * movim.movpc) -
                            ((( movim.movqtm * movim.movpc) /
                            plani.platot ) * plani.vlserv)) <> ?
                        then
                        venda = venda +
                                 ( ( movim.movqtm * movim.movpc ) - 
                                 ( ( ( movim.movqtm * movim.movpc ) / 
                                   plani.platot ) * plani.vlserv ) ).
                    end.
                    est-ven = est-ven + movim.movqtm.
                end.

                for each movim where movim.procod = produ.procod and
                                     movim.movtdc = 4            and
                                     movim.movdat >= vdti        and
                                     movim.movdat <= vdtf        no-lock:
                    compra  = compra + (movim.movpc * movim.movqtm).
                    est-com = est-com + movim.movqtm.
                end.

                for each movim where movim.procod = produ.procod and
                                     movim.movtdc = 1            and
                                     movim.movdat >= vdti        and
                                     movim.movdat <= vdtf        no-lock:
                    compra  = compra + (movim.movpc * movim.movqtm).
                    est-com = est-com + movim.movqtm.
                end.
                /**************************/


                for each estab no-lock:
                    find bestoq where bestoq.etbcod = estab.etbcod and
                                      bestoq.procod = produ.procod 
                                                        no-lock no-error.
                    if not avail bestoq
                    then next.
                    find hiest where hiest.etbcod = estab.etbcod and
                                     hiest.procod = produ.procod and
                                     hiest.hiemes = month(vdtf)  and
                                     hiest.hieano = year(vdtf) no-lock no-error.
                    if not avail hiest
                    then do:
                        if month(vdtf) = 1
                        then assign vano = year(vdtf) - 1
                                    vmes = 12.
                        else assign vano = year(vdtf)
                                    vmes = month(vdtf).
                        find last hiest where hiest.etbcod = estab.etbcod and
                                              hiest.procod = produ.procod and
                                              hiest.hiemes <= vmes        and
                                              hiest.hieano = vano 
                                                        no-lock no-error.
                        if not avail hiest
                        then do:
                            /*
                            find bestoq where bestoq.etbcod = estab.etbcod and
                                              bestoq.procod = produ.procod
                                                              no-lock no-error.
                            if avail bestoq
                            then do:
                                valest = valest +
                                         (bestoq.estatual * bestoq.estvenda).
                                valcus = valcus +
                                        (bestoq.estatual * bestoq.estcusto).
                                est-atu = est-atu + bestoq.estatual.
                            end. */
                            next.
                        end.
                        else do:
                            valest  = valest  + 
                                    (hiest.hiestf * bestoq.estvenda).
                            valcus  = valcus  + 
                                    (hiest.hiestf * bestoq.estcusto).
                            est-atu = est-atu + hiest.hiestf.
                        end.
                    end.
                    else do:
                        valest  = valest  + (hiest.hiestf * bestoq.estvenda).
                        valcus  = valcus  + (hiest.hiestf * bestoq.estcusto).
                        est-atu = est-atu + hiest.hiestf.
                    end.
                end.

                output stream stela to terminal.
                    disp stream stela produ.procod produ.clacod
                            with frame fff3 centered color white/red 1 down.
                pause 0.
                output stream stela close.
            end.

            if line-counter = 6
            then put "        V E N D A S               C O M P R A S  "  at 35
                     "               E S T O Q U E S        "
                                     skip fill("-",135) format "x(135)".

            if line-counter = 6
            then put "        V E N D A S               C O M P R A S  " at 35
                     "               E S T O Q U E S "
                          skip fill("-",135) format "x(135)".


            tot1 = tot1 + est-ven.
            tot2 = tot2 + venda.
            tot3 = tot3 + ((venda / tot-v) * 100).
            tot4 = tot4 + est-com.
            tot5 = tot5 + compra.
            tot6 = tot6 + est-atu.
            tot7 = tot7 + valest.
            tot8 = tot8 + valcus.

            
            tt-1 = tt-1 + est-ven.
            tt-2 = tt-2 + venda.
            tt-3 = tt-3 + ((venda / tot-v) * 100).
            tt-4 = tt-4 + est-com.
            tt-5 = tt-5 + compra.
            tt-6 = tt-6 + est-atu.
            tt-7 = tt-7 + valest.
            tt-8 = tt-8 + valcus.

            v-giro = (valest / venda).
            if v-giro = ?
            then v-giro = 0.
            
            
            if venda > 0 or
               est-atu <> 0
            then 
            
            display clase.clacod
                    clase.clanom when avail clase
                    est-ven column-label "FISICO"
                    venda    column-label "FINANCEIRO"
                    ((venda / tot-v) * 100)
                                       column-label "%/Par." format "->,>>9.99"
                    est-com column-label "FISICO"
                    compra  column-label "FINANCEIRO"
                    est-atu column-label "FISICO"
                    valest  column-label "FIN.VENDA"
                    valcus  column-label "FIN.CUSTO"
                    v-giro  column-label "GIRO"
                                with frame f-3 width 200 down no-box.

            t-venda = t-venda + venda.
            t-valest = t-valest + valest.
            t-ven = t-venda + venda.
            t-val = t-valest + valest.
     
        
            if last-of(clase.clasup) and
               (tot2 > 0 or tot6 > 0)
            then do:
                 put skip.
                 put fill("-",135) format "x(135)" skip.
                 put "T O T A I S ..............."
                     tot1  to 41  format "->>>,>>9" 
                     tot2  to 53  format "->>>,>>9.99"
                     tot3  to 63  format "->>>,>>9"
                     tot4  to 72  format "->>>,>>9"
                     tot5  to 84  format "->>>,>>9.99"
                     tot6  to 93  format "->>>,>>9"
                     tot7  to 107 format "->>>,>>9.99"
                     tot8  to 119 format "->>>,>>9.99" 
                     (t-valest / t-venda) to 129 skip
                     fill("-",135) format "x(135)" skip(1).
                
                 
                 assign tot1 = 0
                        tot2 = 0
                        tot3 = 0
                        tot4 = 0
                        tot5 = 0
                        tot6 = 0
                        tot7 = 0
                        tot8 = 0
                        t-valest = 0
                        t-venda  = 0.
            end.

            assign est-ven = 0
                   venda   = 0
                   est-com = 0
                   compra  = 0
                   est-atu = 0
                   valest  = 0
                   valcus  = 0.
        end.
    end.
    
    if tt-2 > 0 or
       tt-6 > 0
    then do:
        put skip
            fill("-",135) format "x(135)" skip
            "T O T A L  G E R A L ......"
             tt-1 to 41 format "->>>,>>9"
             tt-2 to 53 format "->>>,>>9.99"
             tt-3 to 63 format "->>>,>>9"
             tt-4 to 72 format "->>>,>>9"
             tt-5 to 84 format "->>>,>>9.99"
             tt-6 to 93 format "->>>,>>9"
             tt-7 to 107 format "->>,>>>,>>9" 
             tt-8 to 119 format "->>,>>>,>>9"
             (tt-7 / tt-2) to 129 skip
             fill("-",135) format "x(135)" skip.
        
    end.
    
    output close.
    message "Deseja Imprimir Relatorio" update sresp.
    if sresp
    then dos silent value( "type i:\admcom\relat\resu > prn" ).
end.



