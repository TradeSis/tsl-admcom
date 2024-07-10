{admcab.i}
{fpc.i}

def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.

def var vlcontrato like plani.platot.

def var v-de like plani.platot.
def var v-ac like plani.platot.

def var vclacod like clase.clacod.
def var vclasup like clase.clasup.
def buffer bclase for clase.     
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
def var vcomcod     like compr.comcod.

def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.

repeat:

    for each tt-clase.
        delete tt-clase.
    end.

    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan row 4.
    
    find categoria where categoria.catcod = vcatcod no-lock.
    
    disp categoria.catnom no-label with frame f-dep.

    if vcatcod = 31
    then vcatcod2 = 35.
    
    if vcatcod = 41
    then vcatcod2 = 45.

    update /*vfabcod*/ vforcod label "Fabricante"
                with frame f-depf centered side-label color blue/cyan row 7.

    find forne where forne.forcod = vforcod no-lock.
    find fabri where fabri.fabcod = forne.forcod no-lock.    
    
    disp fabri.fabfan format "x(24)" /*forne.forfant*/ no-label with frame f-depf.

    vdti = today - 31.
    
    update vcomcod label "Comprador" format ">>>9"
                with frame f-compr centered color blue/cyan row 10 side-labels.
    
    find first compr where compr.comcod = vcomcod
                       and vcomcod > 0  no-lock no-error.
    
    if avail compr then display compr.comnom format "x(27)" no-label with frame f-compr.
    else if vcomcod = 0 then display "TODOS" @ compr.comnom no-label
                        with frame f-compr.
    else do:
    
         message "Comprador não encontrado!" view-as alert-box.
         undo, retry.
                    
    end.

    update vdti label "Periodo        " at 1
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 13
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

    update vclacod at 01 label "Classe " with frame f-dat side-label.
    /*****
    if vclacod = 0
    then display "GERAL" @ bclase.clanom with frame f-dat.
    else do:
        find bclase where bclase.clacod = vclacod no-lock.
        display bclase.clanom no-label with frame f-dat.
    end.*****/

    if vclacod <> 0
    then do:
        find clase where clase.clacod = vclacod no-lock no-error.
        display clase.clanom no-label with frame f-dat.
    end.
    else disp "Todas" @ clase.clanom with frame f-dat.
    
    /*if vclacod <> 0
    then do:*/
    
        find first clase where clase.clasup = vclacod no-lock no-error. 
        if avail clase 
        then do:
            run cria-tt-clase. 
            hide message no-pause.
        end. 
        else do:
            find clase where clase.clacod = vclacod no-lock no-error.
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
    
    update vetbi no-label
           "a"
           vetbf no-label with frame f-etb centered color blue/cyan row 18
                                    title " Filial ".
    
    for each tt-curva:
        delete tt-curva.
    end.

    run Pi-Ger-Paifilho(input fabri.fabcod).

    for each tt-clase:
        
        for each tt-forpaifi,
            each produ where (produ.catcod = vcatcod or
                              produ.catcod = vcatcod2) and
                              /*produ.fabcod = fabri.fabcod and 29415*/
                               produ.fabcod = tt-forpaifi.forcod and
                               produ.clacod = tt-clase.clacod
                               no-lock /*break by tt-clase.clacod*/ :

        if vcomcod > 0
        then do:
            release liped.
            release pedid.
            find last liped where liped.procod = produ.procod
                              and liped.pedtdc = 1
                                no-lock use-index liped2 no-error.
                                
            find first pedid of liped no-lock no-error.                    
            
            if (avail pedid and pedid.comcod <> vcomcod)
                or not avail pedid 
            then next.
            
        end.

        find first bmovim where bmovim.procod = produ.procod and
                                bmovim.movtdc = 5 and
                                bmovim.movdat >= vdti and
                                bmovim.movdat <= vdtf no-lock no-error.
        if not avail bmovim
        then next.

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

        for each movim where movim.procod = produ.procod and
                             movim.movtdc = 5 and
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
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat and
                                       plani.platot >= 1
                                            no-lock no-error.
                if not available plani
                then next.
                vlcontrato = plani.platot - plani.vlserv.
                if avail plani and plani.crecod = 2
                then vlcontrato = plani.biss.

                if ( ( movim.movqtm * movim.movpc ) * 
                     ( vlcontrato / plani.platot  ) ) > 0
                then do:
                    assign
                    tt-curva.qtdven = tt-curva.qtdven + movim.movqtm
                    tt-curva.valven = tt-curva.valven + 
                                      ( ( movim.movqtm * movim.movpc ) * 
                                        ( vlcontrato / plani.platot ) ).
                                        
                    find estoq where estoq.etbcod = setbcod and
                                     estoq.procod = produ.procod no-lock
                                                    no-error.
                    if avail estoq
                    then assign
                        tt-curva.valcus = tt-curva.valcus + 
                                        (movim.movqtm * estoq.estcusto).
                end.
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
    
    run con99a.p.


end.


procedure cria-tt-clase.
 for each clase where clase.clasup = vclacod no-lock:
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
                     and movim.desti  = 996 no-lock:
                                  
        p-valcomp = p-valcomp + ((movim.movpc * movim.movqtm)
                  + ((movim.movpc * movim.movqtm) * (movim.movalipi / 100))).
                
        p-qtdcomp = p-qtdcomp + movim.movqtm.

        if p-valcomp = ? then p-valcomp = 0.
        if p-qtdcomp = ? then p-qtdcomp = 0.
    end.
 
end procedure.