{admcab.i}

def var vnom as char.
def var vetbcod like estab.etbcod.
def temp-table tt-estab
    field etbcod like estab.etbcod.
def buffer bclase for clase.
def var varquivo as char format "x(20)".
def var ii as int.

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

def var vclacod like clase.clacod.
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

def temp-table tt-clase
    field procod     like produ.procod
    field clasup     like clase.clasup
    field clacod     like clase.clacod
    field qtd-fisico like est-ven
    field val-venda  like venda
    field qtd-compra like est-com
    field val-compra like compra
    field qtd-atual  like est-atu
    field val-atual  like valest
    field val-custo  like valcus
    field val-giro   like v-giro.

def buffer xclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.

def temp-table tt-cla
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

repeat:
    for each tt-estab:
        delete tt-estab.
    end.
    for each tt-catcod:
        delete tt-catcod.
    end.
    for each tt-cla:
        delete tt-cla.
    end.
    for each tt-clase:
        delete tt-clase.
    end.
    
    vnom = "".
    
    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.
    
    if categoria.catcod = 31 or
       categoria.catcod = 35
    then message "Deseja agrupar departamentos [31 - 35]" update sresp.
    else message "Deseja agrupar departamentos [41 - 45]" update sresp.
    
    if sresp
    then do:
        if vcatcod = 31 or
           vcatcod = 35
        then do:
            create tt-catcod.
            assign tt-catcod.catcod = 31.
            create tt-catcod.
            assign tt-catcod.catcod = 35.
            create tt-catcod.
            assign tt-catcod.catcod = 50.
        end.
        if vcatcod = 41 or
           vcatcod = 45
        then do:
            create tt-catcod.
            assign tt-catcod.catcod = 41.
            create tt-catcod.
            assign tt-catcod.catcod = 45.
        end.
    end.
    else do:
        create tt-catcod.
        assign tt-catcod.catcod = categoria.catcod.
    end.

    assign  tt-1 = 0
            tt-2 = 0
            tt-3 = 0
            tt-4 = 0
            tt-5 = 0
            tt-6 = 0
            tt-7 = 0
            tt-8 = 0.
    
    update vdti label "Periodo"
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".

    /*
    update vclasup at 01 with frame f-dat side-label.
    if vclasup = 0
    then display "GERAL" @ clase.clanom with frame f-dat.
    else do:
        find clase where clase.clacod = vclasup no-lock.
        display clase.clanom no-label with frame f-dat.
    end.
    */
    
    update vclacod at 01 label "Classe" with frame f-dat side-label.
    /*if vclacod = 0
    then display "GERAL" @ bclase.clanom with frame f-dat.
    else do:
        find bclase where bclase.clacod = vclacod no-lock.
        display bclase.clanom no-label with frame f-dat.
    end.
    */
    
    if vclacod <> 0
    then do:
        find xclase where xclase.clacod = vclacod no-lock no-error.
        display xclase.clanom no-label with frame f-dat.
    end.
    else disp "Todas" @ xclase.clanom with frame f-dat.
    
    /*if vclacod <> 0
    then do:*/
    
        find first clase where clase.clasup = vclacod no-lock no-error. 
        if avail clase 
        then do:
            run cria-tt-cla. 
            hide message no-pause.
        end. 
        else do:
            find clase where clase.clacod = vclacod no-lock no-error.
            if not avail clase
            then do:
                message "Classe nao Cadastrada".
                undo.
            end.

            create tt-cla.
            assign tt-cla.clacod = clase.clacod
                   tt-cla.clanom = clase.clanom.

        end.
    /*end.*/

    
    repeat:
    
        for each tt-estab:
            disp tt-estab.etbcod column-label "Filiais"
                    with frame f-down row 05 down color blue/cyan.
        end.
        
        update vetbcod
            with frame f-etb centered side-label color blue/cyan row 15.
        
        if vetbcod <> 0
        then do:
            find estab where estab.etbcod = vetbcod no-lock.
            create tt-estab.
            assign tt-estab.etbcod = estab.etbcod.
        end.
        else do:
            display "GERAL" with frame f-etb.
            vnom = "GERAL".
            for each estab where estab.etbcod <> 0 no-lock:
                create tt-estab.
                assign tt-estab.etbcod = estab.etbcod.
            end.
            leave.
        end.
    end.
    if vnom = ""
    then do:
        for each tt-estab:
            vnom = vnom + string(tt-estab.etbcod,">>9") + " ".
        end.
    end.

    message "Confirma Resumo ? " update sresp.
    if not sresp
    then next.

    assign est-ven = 0
           venda   = 0
           est-com = 0
           compra  = 0
           est-atu = 0
           valest  = 0
           valcus  = 0.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/resu2003_" + string(time).
    else varquivo = "l:\relat\resu2003_" + string(time).
    

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "147"
        &Page-Line = "66"
        &Nom-Rel   = ""RESU2003""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """RESUMO COM/VEN/EST - FILIAL "" + string(vetbcod,"">>9"")
                        + "" PERIODO DE "" +
                         string(vdti,""99/99/9999"") + "" A "" +
                         string(vdtf,""99/99/9999"") "
       &Width     = "147"
       &Form      = "frame f-cabcab"}
    
    tot-v = 0.
    
    for each tt-cla /*clase where (if vclasup = 0
                          then true 
                          else clase.clasup = vclasup) and
                         (if vclacod = 0
                          then true
                          else clase.clacod = vclacod)
                                no-lock break by clase.clasup
                                              by clase.clacod*/ no-lock:
   
        find clase where clase.clacod = tt-cla.clacod no-lock no-error.
        
        for each tt-catcod,         
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
            
            for each tt-estab,
                each movim where movim.procod = produ.procod    and
                                 movim.etbcod = tt-estab.etbcod and
                                 movim.movtdc = 5               and
                                 movim.movdat >= vdti           and
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
                if not available plani
                then next.

 
                
                if plani.crecod = 2
                then do:
                    if plani.biss > ( plani.platot - plani.vlserv) and
                       (plani.platot - plani.vlserv) >= 1
                    then acre = plani.biss / (plani.platot - plani.vlserv).
                    
                    if plani.biss < ( plani.platot - plani.vlserv) 
                    then des = (plani.platot - plani.vlserv) / plani.biss.
                end. 
                else do: 
                    if plani.acfprod > 0
                    then acre = (plani.platot + plani.acfprod) / plani.platot.
                    if plani.descprod > 0
                    then des = plani.platot / (plani.platot - plani.descprod).
                end.
                if plani.platot < 1
                then assign des = 0
                            acre = 0.

                
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
                    then venda = venda + 
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
            for each tt-estab,
                each movim where movim.procod = produ.procod    and
                                 movim.etbcod = tt-estab.etbcod and
                                 movim.movtdc = 4               and
                                 movim.datexp >= vdti           and
                                 movim.datexp <= vdtf        no-lock.
                                 
               compra  = compra + (movim.movpc * movim.movqtm).
               est-com = est-com + movim.movqtm.
               
            end.
            for each tt-estab,
                each movim where movim.procod = produ.procod    and
                                 movim.etbcod = tt-estab.etbcod and
                                 movim.movtdc = 1            and
                                 movim.datexp >= vdti        and
                                 movim.datexp <= vdtf    no-lock.
                
                compra  = compra + (movim.movpc * movim.movqtm).
                est-com = est-com + movim.movqtm.
                
            end.
            
            
            for each tt-estab:
                find estoq where estoq.etbcod = tt-estab.etbcod and
                                 estoq.procod = produ.procod no-lock no-error.
                if avail estoq
                then do:
                    valest  = valest  + 
                              (estoq.estatual * estoq.estvenda).
                    valcus  = valcus  + 
                              (estoq.estatual * estoq.estcusto).
                    est-atu = est-atu + estoq.estatual.
                
                end.
            end.

            output stream stela to terminal.
            disp stream stela produ.procod produ.clacod
                    with frame ffff centered color white/red 1 down.
            pause 0.
            output stream stela close.
         

        
        v-giro = (valest / venda).
        if v-giro = ?
        then v-giro = 0.
        
        
        tt-1 = tt-1 + est-ven.
        tt-2 = tt-2 + venda.
        /* tt-3 = tt-3 + ((venda / tot-v) * 100). */
        tt-4 = tt-4 + est-com.
        tt-5 = tt-5 + compra.
        tt-6 = tt-6 + est-atu.
        tt-7 = tt-7 + valest.
        tt-8 = tt-8 + valcus.


        if venda > 0 or
           est-atu <> 0
        then do:
            create tt-clase.
            assign tt-clase.procod     = produ.procod
                   tt-clase.clasup     = clase.clasup
                   tt-clase.clacod     = clase.clacod
                   tt-clase.qtd-fisico = est-ven
                   tt-clase.val-venda  = venda
                   tt-clase.qtd-compra = est-com
                   tt-clase.val-compra = compra
                   tt-clase.qtd-atual  = est-atu
                   tt-clase.val-atual  = valest
                   tt-clase.val-custo  = valcus
                   tt-clase.val-giro   = v-giro.
          
            assign est-ven = 0
                   venda   = 0
                   est-com = 0
                   compra = 0
                   est-atu = 0
                   valest  = 0
                   valcus  = 0.
        end.
        end.
    end.    

    for each tt-clase no-lock break by tt-clase.clasup
                                    by tt-clase.clacod
                                    by tt-clase.procod:
                  
            
        if line-counter = 6
        then put "        V E N D A S                 C O M P R A S  " at 40
                 "               E S T O Q U E S        "
                                  skip fill("-",140) format "x(140)".
        if line-counter = 6
        then put "        V E N D A S                 C O M P R A S   " at 40
                 "               E S T O Q U E S "
                          skip fill("-",140) format "x(140)".

            
        find clase where clase.clacod = tt-clase.clacod no-lock.

        tot1 = tot1 + tt-clase.qtd-fisico.
        tot2 = tot2 + tt-clase.val-venda.
        tot3 = tot3 + ((tt-clase.val-venda / tt-2) * 100).
        tot4 = tot4 + tt-clase.qtd-compra.
        tot5 = tot5 + tt-clase.val-compra.
        tot6 = tot6 + tt-clase.qtd-atual.
        tot7 = tot7 + tt-clase.val-atual.
        tot8 = tot8 + tt-clase.val-custo.
          
        tt-3 = tt-3 + ((tt-clase.val-venda / tt-2) * 100). 
        find produ where produ.procod = tt-clase.procod no-lock no-error.
     
        display tt-clase.procod
                produ.pronom when avail produ format "x(30)"
                tt-clase.qtd-fisico column-label "FISICO"
                tt-clase.val-venda  column-label "FINANCEIRO"
                                format "->>>>>,>>9.99"
                ((tt-clase.val-venda / tt-2) * 100)
                                   column-label "%/Par." format "->,>>9.99"
                tt-clase.qtd-compra column-label "FISICO"
                tt-clase.val-compra column-label "FINANCEIRO"
                                format "->>>>>,>>9.99"
                tt-clase.qtd-atual  column-label "FISICO"
                tt-clase.val-atual  column-label "FIN.VENDA"
                                format "->>>>>,>>9.99"
                tt-clase.val-custo  column-label "FIN.CUSTO"
                                format "->>>>>,>>9.99"
                tt-clase.val-giro  column-label "GIRO"
                        with frame f-1 width 200 down no-box.
    
        assign t-venda  = t-venda  + tt-clase.val-venda
               t-valest = t-valest + tt-clase.val-atual
               t-ven    = t-venda  + tt-clase.val-venda
               t-val    = t-valest + tt-clase.val-atual.
      
      
        if last-of(tt-clase.clasup) and
           (tot2 > 0 or tot6 > 0)
        then do:
            put skip.
            put fill("-",145) format "x(145)" skip.
            put "T O T A I S ..............."
                 tot1  to 47  format "->>>,>>9" 
                 tot2  to 61  format ">>>>>,>>9.99"
                 tot3  to 71  format "->,>>9.99"
                 tot4  to 80  format "->>>,>>9"
                 tot5  to 94  format ">>>>>,>>9.99"
                 tot6  to 103 format "->>>,>>9"
                 tot7  to 117 format "->>>>>,>>9.99"
                 tot8  to 131 format "->>>>>,>>9.99" 
                 (t-valest / t-venda) to 141 skip
                     fill("-",145) format "x(145)" skip(1).

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
    end.
    
    if tt-2 > 0 or
       tt-6 > 0
    then do:
        put skip
            fill("-",145) format "x(145)" skip
            "T O T A L  G E R A L ......"
             tt-1 to 47 format "->>>,>>9"
             tt-2 to 61 format ">>>>>,>>9.99"
             tt-3 to 71 format "->,>>9.99"
             tt-4 to 80 format "->>>,>>9"
             tt-5 to 94 format  ">>>>>,>>9.99"
             tt-6 to 103 format "->>>,>>9"
             tt-7 to 117 format "->>>>>,>>9.99" 
             tt-8 to 131 format "->>>>>,>>9.99"
             (tt-7 / tt-2) to 141 skip
             fill("-",145) format "x(145)" skip.
        
    end.
    
    output close.  
    
    /* 210917 Helio TP 20609698 */
    if opsys = "UNIX" 
    then do: 
        hide message no-pause.
        message "Arquivo gerado: " varquivo. 
        run visurel.p (input varquivo, input "").   
    end. 
    else do: 
        {mrod.i} 
    end.
         
                                                    
end.

procedure cria-tt-cla.
 for each clase where clase.clasup = vclacod no-lock:
   find first bclase where bclase.clasup = clase.clacod no-lock no-error.
   if not avail bclase
   then do: 
     find tt-cla where tt-cla.clacod = clase.clacod no-error. 
     if not avail tt-cla 
     then do: 
       create tt-cla. 
       assign tt-cla.clacod = clase.clacod 
              tt-cla.clanom = clase.clanom.
     end.
   end.
   else do: 
     for each bclase where bclase.clasup = clase.clacod no-lock: 
         find first cclase where cclase.clasup = bclase.clacod no-lock no-error.
         if not avail cclase
         then do: 
           find tt-cla where tt-cla.clacod = bclase.clacod no-error. 
           if not avail tt-cla 
           then do: 
             create tt-cla. 
             assign tt-cla.clacod = bclase.clacod 
                    tt-cla.clanom = bclase.clanom.
           end.
         end.
         else do: 
           for each cclase where cclase.clasup = bclase.clacod no-lock: 
             find first dclase where dclase.clasup = cclase.clacod 
                                                     no-lock no-error. 
             if not avail dclase 
             then do: 
               find tt-cla where tt-cla.clacod = cclase.clacod no-error. 
               if not avail tt-cla 
               then do: 
                 create tt-cla. 
                 assign tt-cla.clacod = cclase.clacod 
                        tt-cla.clanom = cclase.clanom.
               end.                          
             end.
             else do: 
               for each dclase where dclase.clasup = cclase.clacod no-lock: 
                 find first eclase where eclase.clasup = dclase.clacod 
                                                         no-lock no-error. 
                 if not avail eclase 
                 then do: 
                   find tt-cla where tt-cla.clacod = dclase.clacod no-error.
                   if not avail tt-cla 
                   then do: 
                     create tt-cla. 
                     assign tt-cla.clacod = dclase.clacod 
                            tt-cla.clanom = dclase.clanom. 
                   end.       
                 end. 
                 else do:  
                   for each eclase where eclase.clasup = dclase.clacod no-lock:
                     find first fclase where fclase.clasup = eclase.clacod 
                                                             no-lock no-error.
                     if not avail fclase 
                     then do: 
                       find tt-cla where tt-cla.clacod = eclase.clacod
                                                             no-error.
                       if not avail tt-cla 
                       then do: 
                         create tt-cla. 
                         assign tt-cla.clacod = eclase.clacod 
                                tt-cla.clanom = eclase.clanom.
                       end.
                     end.
                     else do:
                     
                       for each fclase where fclase.clasup = eclase.clacod
                                    no-lock:
                         find first gclase where gclase.clasup = fclase.clacod 
                                                             no-lock no-error.
                         if not avail gclase 
                         then do: 
                           find tt-cla where tt-cla.clacod = fclase.clacod
                                                                 no-error.
                           if not avail tt-cla 
                           then do: 
                             create tt-cla. 
                             assign tt-cla.clacod = fclase.clacod 
                                    tt-cla.clanom = fclase.clanom.
                           end.
                         end.
                         else do:
                             find tt-cla where tt-cla.clacod = gclase.clacod 
                                                        no-error.
                             if not avail tt-cla
                             then do:
                             
                                 create tt-cla. 
                                 assign tt-cla.clacod = gclase.clacod 
                                        tt-cla.clanom = gclase.clanom.
                                        
                             end.  
                         end.
                       end.
                     end.
                   end.
                 end.
               end.
             end.
           end.                                  
         end.
     end.
   end.
 end.
end procedure.