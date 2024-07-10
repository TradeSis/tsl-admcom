{admcab.i}
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.

def var vlcontrato like plani.platot.

def var v-de like plani.platot.
def var v-ac like plani.platot.

def var vcla-cod like clase.clacod.
def var vclasup like clase.clasup.
def buffer bclase for clase.   
def buffer sclase for clase.

def var vetccod like produ.etccod.
def var vcarcod like subcaract.carcod.
def var vsubcod like subcaract.subcod.

def var ii as int.
def var vdown as i.

def new shared var v-q as dec format ">>,>>9".
def new shared var v-v as dec  format ">>>>,>>9".
def new shared var v-c as dec  format ">>>>,>>9".
def new shared var v-e as dec  format "->>>,>>9".

def temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def var v-qtdcomp as int.
def var v-valcomp as dec.

def new shared temp-table tt-curva
  field pos    like curva.pos
  field cod    like curva.cod
  field pronom like produ.pronom format "x(32)"
  field qtdcom like curva.qtdven
  field valven like curva.valven
  field qtdven like curva.qtdven
  field valcus like curva.valcus
  field qtdest like curva.qtdest
  field estcus like curva.estcus
  field estven like curva.estven
  field giro   like curva.giro
  index icurva valven desc.

def var varquivo as char format "x(20)".
def buffer bmovim for movim.
def var i as i.
def var tot-c like plani.platot.
def var tot-v like plani.platot format "->>9.99".
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
def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
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
def var vcatcod2    like produ.catcod.
def var vfabcod     like fabri.fabcod.

def var vforcod     like forne.forcod.
def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.

repeat:

    for each tt-clase.
        delete tt-clase.
    end.

    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4
                title " Departamento ".
    
    find categoria where categoria.catcod = vcatcod no-lock.
    
    disp categoria.catnom no-label with frame f-dep.

    if vcatcod = 31
    then vcatcod2 = 35.
    
    if vcatcod = 41
    then vcatcod2 = 45.

    update /*vfabcod*/ vforcod label "Fabricante"
                with frame f-depf centered side-label color blue/cyan row 7
                Title " Fabricante ".

    find forne where forne.forcod = vforcod no-lock.
    find fabri where fabri.fabcod = forne.forcod no-lock.    
    
    disp fabri.fabfan /*forne.forfant*/ no-label with frame f-depf.
    
    vdti = today - 31.

    update vdti label "Periodo        " at 1
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 10
                                    title " Periodo ".
    vetbi = 1.
    vetbf = 999.
                               
    /*update vclasup at 01 with frame f-dat side-label.
    if vclasup = 0
    then display "GERAL" @ clase.clanom with frame f-dat.
    else do:
        find clase where clase.clacod = vclasup no-lock.
        display clase.clanom no-label with frame f-dat.
    end.*/

    update vcla-cod at 01 label "Classe " with frame f-dat side-label.
    /*****
    if vcla-cod = 0
    then display "GERAL" @ bclase.clanom with frame f-dat.
    else do:
        find bclase where bclase.clacod = vcla-cod no-lock.
        display bclase.clanom no-label with frame f-dat.
    end.*****/

    if vcla-cod <> 0
    then do:
        find clase where clase.clacod = vcla-cod no-lock no-error.
        display clase.clanom no-label with frame f-dat.
    end.
    else disp "Todas" @ clase.clanom with frame f-dat.
    
    /*if vcla-cod <> 0
    then do:*/
    
        find first clase where clase.clasup = vcla-cod no-lock no-error. 
        if avail clase 
        then do:
                run cria-tt-clase. 
            hide message no-pause.
        end. 
        else do:
            find clase where clase.clacod = vcla-cod no-lock no-error.
            if not avail clase
            then do:
                message "Classe nao Cadastrada".
                undo.
            end.

            create tt-clase.
            assign tt-clase.clacod = clase.clacod
                   tt-clase.clanom = clase.clanom.

        end.
    /*end.*/
    
    do on error undo:
    
        update vetccod label "Cod.Estacao" 
           with frame f-param side-labels centered color blue/cyan row 11
                      title "Parametros".
        if vetccod <> 0
        then do:
            find first estac 
                where estac.etccod = vetccod no-lock no-error.
            if not avail estac 
            then do:
                message "Estacao Inexistente" VIEW-AS ALERT-BOX.
                undo, retry.
             end.        
            else disp estac.etcnom format "x(15)" skip with frame f-param.
        end.
        else disp "Geral" @ estac.etcnom no-label skip with frame f-param.
        do on error undo:
            update vcarcod label "Caracteristica"
                    with frame f-param .
            if vcarcod <> 0
            then do:
                find first caract 
                            where caract.carcod = vcarcod no-lock no-error.
                if not avail caract
                then do:
                     message "Caracteristica Inexistente" VIEW-AS ALERT-BOX.
                     undo, retry.
                end.
                 update vsubcod label "Sub-Caracteristica"
                        with frame f-param row 15.
                find first subcarac where subcarac.subcod = vsubcod
                    no-lock no-error.
                if not avail subcaract
                then do:
                     message "Sub-Caracteristica Inexistente" VIEW-AS ALERT-BOX.
                     undo, retry.
                end.
            end.
        end.
    end.
    
    update vetbi no-label
           "a"
           vetbf no-label with frame f-etb centered color blue/cyan row 19
                                    title " Filial ".
    
    for each tt-curva:
        delete tt-curva.
    end.

    for each tt-clase:
    
        for each produ where (produ.catcod = vcatcod or
                              produ.catcod = vcatcod2) and
                              produ.fabcod = fabri.fabcod and
                              produ.clacod = tt-clase.clacod
                               no-lock /*break by tt-clase.clacod*/ :

        /* antonio - Sol 26337 */
        
        /* Estacao */
        if vetccod  <> 0
        then do:  
             if produ.etccod <> vetccod then next.
        end.
        /* Caracterirstica */
        if vcarcod <> 0
        then do:
             find first procaract 
                  where procaract.procod = produ.procod no-lock no-error.
                    if avail procaract                       
                    then do:
                        find first subcaract where
                                subcaract.subcar = procaract.subcod
                                    no-lock no-error.
                        if not avail subcaract then next.            
                        if subcaract.carcod <> vcarcod then next.
                    end.
        end.
        /* Sub-caracteristica */
        if vsubcod <> 0
        then do:
             find first subcaract where
                        subcaract.subcar = vsubcod
                                no-lock no-error.
             if not avail subcaract then next.
             find procaract where procaract.procod  = produ.procod and
                                  procaract.subcod  = vsubcod
                            no-lock no-error.
             if not avail procaract then next.
        end.     
        /***/
        
        if forne.forcod = 5027
        then do:
         
            find first bmovim where bmovim.procod = produ.procod and
                                    bmovim.movtdc = 6 and
                                    bmovim.emite  = 22 and
                                    ( bmovim.desti  = 996 or 
                                      bmovim.desti  = 995 or
                                      bmovim.desti  = 900) and
                                    bmovim.movdat >= vdti and
                                    bmovim.movdat <= vdtf no-lock no-error.
            if not avail bmovim
            then next.
        
        end.
        else do:
            find first bmovim where bmovim.procod = produ.procod and
                                    bmovim.movtdc = 4 and
                                    bmovim.movdat >= vdti and
                                    bmovim.movdat <= vdtf no-lock no-error.
            if not avail bmovim
            then do: 
                find first bmovim where bmovim.procod = produ.procod and
                                        bmovim.movtdc = 1 and
                                        bmovim.movdat >= vdti and
                                        bmovim.movdat <= vdtf 
                                                no-lock no-error.
                if not avail bmovim
                then next.
            end.            
        end.
        output stream stela to terminal.
        disp stream stela produ.procod with frame ffff centered
                                       color white/red 1 down.
        pause 0.
        output stream stela close.
        find tt-curva where tt-curva.cod = produ.procod no-error.
        if not avail tt-curva
        then do:
            create tt-curva.
            find last tt-curva no-error.
            if not avail tt-curva
            then tt-curva.pos = 1000000.
            else tt-curva.pos = tt-curva.pos + 1.
            tt-curva.cod = produ.procod.
            tt-curva.pronom = produ.pronom.
        end.

        if forne.forcod = 5027
        then do:
            
            for each movim where movim.procod = produ.procod and
                                 movim.movtdc = 6            and
                                 movim.emite  = 22           and
                                 (movim.desti  = 996  or
                                  movim.desti  = 995  or
                                  movim.desti  = 900)        and
                                 movim.movdat >= vdti        and
                                 movim.movdat <= vdtf no-lock:
        
            
                if movim.movqtm = 0 or
                   movim.movpc  = 0
                then next.
                assign tt-curva.qtdven = tt-curva.qtdven + movim.movqtm.
                                                         
                find estoq where estoq.etbcod = setbcod and
                                 estoq.procod = produ.procod no-lock
                                                    no-error.
                if avail estoq 
                then assign tt-curva.valcus = tt-curva.valcus + 
                                        (movim.movqtm * estoq.estcusto)
                            tt-curva.valven = tt-curva.valven + 
                                        (movim.movqtm * estoq.estvenda).
            end.
        end.
        
        for each movim where movim.procod = produ.procod and
                             movim.movtdc = 4 and
                             movim.movdat >= vdti and
                             movim.movdat <= vdtf no-lock:
        
            
            if movim.movqtm = 0 or
               movim.movpc  = 0
            then next.
            v-de = 0.
            v-ac = 0.
            if movim.etbcod >= vetbi and
               movim.etbcod <= vetbf
            then do: 
                assign
                    tt-curva.qtdven = tt-curva.qtdven + movim.movqtm.
                                                         
                    find estoq where estoq.etbcod = setbcod and
                                     estoq.procod = produ.procod no-lock
                                                    no-error.
                    if avail estoq
                    then assign
                        tt-curva.valcus = tt-curva.valcus + 
                                        (movim.movqtm * estoq.estcusto)
                        tt-curva.valven = tt-curva.valven + 
                                   ( movim.movqtm * estoq.estvenda).
            end.
        end.
        
        for each movim where movim.procod = produ.procod and
                             movim.movtdc = 1 and
                             movim.movdat >= vdti and
                             movim.movdat <= vdtf no-lock:
        
            
            if movim.movqtm = 0 or
               movim.movpc  = 0
            then next.
            v-de = 0.
            v-ac = 0.
            if movim.etbcod >= vetbi and
               movim.etbcod <= vetbf
            then do: 
                assign
                    tt-curva.qtdven = tt-curva.qtdven + movim.movqtm.
                                        
                    find estoq where estoq.etbcod = setbcod and
                                     estoq.procod = produ.procod no-lock
                                                    no-error.
                    if avail estoq
                    then assign
                        tt-curva.valcus = tt-curva.valcus + 
                                        (movim.movqtm * estoq.estcusto)
                        tt-curva.valven = tt-curva.valven + 
                                      ( movim.movqtm * estoq.estvenda).
            end.

        end.
        
        ii = 0.
        do ii = vetbi to vetbf:
            find estoq where estoq.etbcod = ii and
                             estoq.procod = produ.procod no-lock no-error.
            if avail estoq
            then assign tt-curva.estven = tt-curva.estven + 
                                          (estoq.estatual * estoq.estvenda)
                        tt-curva.estcus = + tt-curva.estcus + 
                                          (estoq.estatual * estoq.estcusto)
                        tt-curva.qtdest = tt-curva.qtdest + estoq.estatual.
        end.
        
      end.
    end.
    hide frame ffff.
    i = 1.
    tot-v = 0.
    tot-c = 0.
    for each tt-curva by tt-curva.valven descending:
        tt-curva.pos = i.
        tot-v = tot-v + tt-curva.valven.
        tot-c = tot-c + (tt-curva.valven - tt-curva.valcus).
        i = i + 1.
    end.
    
    hide frame f-dep no-pause.
    hide frame f-depf no-pause.
    hide frame f-dat no-pause.
    hide frame f-etb no-pause.
    
    vacum = 0.
    display categoria.catnom label "Depart."
            fabri.fabfan /*forne.forfant*/    label "Fabric."
                    format "x(30)" with frame f-cab side-label
                    row 4 no-box color white/red.
    assign   v-q = 0
             v-v = 0
             v-c = 0
             v-e = 0.
    vdown = 0.
    
    for each tt-curva by tt-curva.pos:
        vacum = vacum + ((tt-curva.valven / tot-v) * 100).
        find produ where produ.procod = tt-curva.cod no-lock no-error.
        tt-curva.giro = (tt-curva.estven / tt-curva.valven).
        
        
             v-q = v-q + tt-curva.qtdven.
             v-v = v-v + tt-curva.valven.
             v-c = v-c + tt-curva.valcus.
             v-e = v-e + tt-curva.qtdest.
       
    end.

    pause 0.
    
    for each tt-curva:
        run p-qtdcompras(input vetbi, 
                         input vetbf,
                         input vdti,
                         input vdtf,
                         input tt-curva.cod,
                         output v-qtdcomp,
                         output v-valcomp).

        tt-curva.qtdcom = tt-curva.qtdcom + v-qtdcomp.
        
        if tt-curva.cod = 0
        then delete tt-curva.
        
    end.
    
    hide frame ffff no-pause.
    run con99c.p.


end.


procedure cria-tt-clase.
 for each clase where clase.clasup = vcla-cod no-lock:
   find first bclase where bclase.clasup = clase.clacod no-lock no-error.
   if not avail bclase
   then do: 
     find tt-clase where tt-clase.clacod = clase.clacod no-error. 
     if not avail tt-clase 
     then do: 
       create tt-clase. 
       assign tt-clase.clacod = clase.clacod 
              tt-clase.clanom = clase.clanom.
     end.
   end.
   else do: 
     for each bclase where bclase.clasup = clase.clacod no-lock: 
         find first cclase where cclase.clasup = bclase.clacod no-lock no-error.
         if not avail cclase
         then do: 
           find tt-clase where tt-clase.clacod = bclase.clacod no-error. 
           if not avail tt-clase 
           then do: 
             create tt-clase. 
             assign tt-clase.clacod = bclase.clacod 
                    tt-clase.clanom = bclase.clanom.
           end.
         end.
         else do: 
           for each cclase where cclase.clasup = bclase.clacod no-lock: 
             find first dclase where dclase.clasup = cclase.clacod 
                                                     no-lock no-error. 
             if not avail dclase 
             then do: 
               find tt-clase where tt-clase.clacod = cclase.clacod no-error. 
               if not avail tt-clase 
               then do: 
                 create tt-clase. 
                 assign tt-clase.clacod = cclase.clacod 
                        tt-clase.clanom = cclase.clanom.
               end.                          
             end.
             else do: 
               for each dclase where dclase.clasup = cclase.clacod no-lock: 
                 find first eclase where eclase.clasup = dclase.clacod 
                                                         no-lock no-error. 
                 if not avail eclase 
                 then do: 
                   find tt-clase where tt-clase.clacod = dclase.clacod no-error.
                   if not avail tt-clase 
                   then do: 
                     create tt-clase. 
                     assign tt-clase.clacod = dclase.clacod 
                            tt-clase.clanom = dclase.clanom. 
                   end.       
                 end. 
                 else do:  
                   for each eclase where eclase.clasup = dclase.clacod no-lock:
                     find first fclase where fclase.clasup = eclase.clacod 
                                                             no-lock no-error.
                     if not avail fclase 
                     then do: 
                       find tt-clase where tt-clase.clacod = eclase.clacod
                                                             no-error.
                       if not avail tt-clase 
                       then do: 
                         create tt-clase. 
                         assign tt-clase.clacod = eclase.clacod 
                                tt-clase.clanom = eclase.clanom.
                       end.
                     end.
                     else do:
                     
                       for each fclase where fclase.clasup = eclase.clacod
                                    no-lock:
                         find first gclase where gclase.clasup = fclase.clacod 
                                                             no-lock no-error.
                         if not avail gclase 
                         then do: 
                           find tt-clase where tt-clase.clacod = fclase.clacod
                                                                 no-error.
                           if not avail tt-clase 
                           then do: 
                             create tt-clase. 
                             assign tt-clase.clacod = fclase.clacod 
                                    tt-clase.clanom = fclase.clanom.
                           end.
                         end.
                         else do:
                           find tt-clase where tt-clase.clacod = gclase.clacod
                                                                 no-error.
                           if not avail tt-clase 
                           then do:
                     
                             create tt-clase. 
                             assign tt-clase.clacod = gclase.clacod 
                                    tt-clase.clanom = gclase.clanom.
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

procedure p-qtdcompras:
    def input parameter p-etbi as int.
    def input parameter p-etbf as int.
    def input parameter p-datai as date format "99/99/9999".
    def input parameter p-dataf as date format "99/99/9999".
    def input parameter p-procod as int.
    def output parameter p-qtdcomp as int.
    def output parameter p-valcomp as dec.

    for each estab where estab.etbcod >= p-etbi 
                     and estab.etbcod <= p-etbf,  
        each movim where movim.procod = p-procod     
                     and movim.etbcod = estab.etbcod
                     and movim.movtdc = 4
                     and movim.datexp >= p-datai
                     and movim.datexp <= p-dataf no-lock:
                                 
        p-valcomp  = p-valcomp + ( (movim.movpc * movim.movqtm) +
                  ((movim.movpc * movim.movqtm) * (movim.movalipi / 100)) ).
                                    
        p-qtdcomp = p-qtdcomp + movim.movqtm.
               
        if p-valcomp = ? then p-valcomp = 0.
        if p-qtdcomp = ? then p-qtdcomp = 0.
               
    end.
            
    for each estab where estab.etbcod >= p-etbi 
                     and estab.etbcod <= p-etbf,  
        each movim where movim.procod = p-procod     
                     and movim.etbcod = estab.etbcod
                     and movim.movtdc = 1
                     and movim.datexp >= p-datai
                     and movim.datexp <= p-dataf no-lock:

        p-valcomp = p-valcomp + ((movim.movpc * movim.movqtm) 
                  + ((movim.movpc * movim.movqtm) * (movim.movalipi / 100))).
                
        p-qtdcomp = p-qtdcomp + movim.movqtm.
            
        if p-valcomp = ? then p-valcomp = 0.
        if p-qtdcomp = ? then p-qtdcomp = 0.
        
    end.

    /***** compras newfree *******/
    for each movim where movim.etbcod = 22
                     and movim.movtdc = 06
                     and movim.procod = p-procod
                     and movim.movdat >= p-datai
                     and movim.movdat <= p-dataf
                     and ( movim.desti  = 996 or 
                           movim.desti  = 995 or
                           movim.desti  = 900) no-lock:
                                  
        p-valcomp = p-valcomp + ((movim.movpc * movim.movqtm)
                  + ((movim.movpc * movim.movqtm) * (movim.movalipi / 100))).
                
        p-qtdcomp = p-qtdcomp + movim.movqtm.

        if p-valcomp = ? then p-valcomp = 0.
        if p-qtdcomp = ? then p-qtdcomp = 0.
    end.
 
end procedure.