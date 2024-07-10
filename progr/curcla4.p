{admcab.i}

def buffer xclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.
def buffer bclase for clase.

def temp-table tt-cla
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def var vclacod like clase.clacod.
def var vano as i.
def var vmes as i.
def var varquivo as char format "x(20)".
def var vcusto   like estoq.estcusto.
def var vestven  like estoq.estvenda.
def var totcusto like estoq.estcusto.
def var totvenda like estoq.estvenda.
def buffer bestoq for estoq.
def var v-ac like plani.platot decimals 10.
def var v-de like plani.platot decimals 10.
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
def var vcatcod2    like produ.catcod.
def var vlcontrato  like contrato.vltotal.
def var vtotal_platot as dec.

def var vcomcod     like compr.comcod.

def stream stela.
def buffer bcontnf for contnf.
def buffer bplani for plani.

def temp-table tt-curva
    field pos    like curfab.pos
    field cod    like curfab.cod
    field valven like curfab.valven 
    field qtdven like curfab.qtdven
    field valcus like curfab.valcus
    field qtdest like curfab.qtdest
    field estcus like curfab.estcus
    field estven like curfab.estven
    field giro   like curfab.giro.

def temp-table tt-catcod
    field catcod like produ.catcod.

def buffer btt-curva for tt-curva.
    
repeat:
    for each tt-catcod:
        delete tt-catcod.
    end.
    for each tt-cla:
        delete tt-cla.
    end.

    update vcatcod label "Departamento" colon 16
                with frame f-dep centered side-label color blue/cyan row 4.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.

    update vclacod label "Clase Superior" colon 16 with frame f-dep.
    /*find bclase where bclase.clacod = vclacod no-lock no-error.
    display bclase.clanom no-label with frame f-dep.*/

/******/
    find xclase where xclase.clacod = vclacod no-lock no-error.
    if vclacod <> 0
    then do:
        display xclase.clanom no-label with frame f-dep.
    end.
    else disp "Todas" @ xclase.clanom with frame f-dep.
    
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
    
/******/    

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

    update vdti no-label
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan row 8
                                    title " Periodo ".

    update vetbi no-label
           "a"
           vetbf no-label with frame f-etb centered color blue/cyan row 12
                                    title " Filial ".
    
    update vcomcod label "Comprador" format ">>>9"
              with frame f-compr centered color blue/cyan row 15 side-labels.
                
    find first compr where compr.comcod = vcomcod
                       and vcomcod > 0  no-lock no-error.
                                   
    if avail compr then display compr.comnom format "x(27)" no-label
                             with frame f-compr.                 
    else if vcomcod = 0 then display "TODOS" @ compr.comnom no-label
                               with frame f-compr.
    else do:
                    
         message "Comprador não encontrado!" view-as alert-box.
         undo, retry.
                             
    end.
                              
    
    for each tt-curva:
        delete tt-curva.
    end.
    totcusto = 0.
    totvenda = 0.

    for each tt-catcod no-lock,
        each tt-cla /*clase where clase.clasup = vclacod*/ no-lock,
        each produ use-index catcla
            where produ.catcod = tt-catcod.catcod and
                  produ.clacod = tt-cla.clacod /*clase.clacod*/ no-lock:
                  
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
         
        output stream stela to terminal.
            disp stream stela 
                        produ.catcod
                        produ.pronom
                        produ.procod 
                        produ.fabcod
                           with frame ffff centered
                                            color white/red 1 down.
            pause 0.
        output stream stela close.
        
        find first bmovim where bmovim.procod = produ.procod and
                                bmovim.movtdc = 5            and
                                bmovim.movdat >= vdti        and
                                bmovim.movdat <= vdtf no-lock no-error.
        if not avail bmovim
        then next.

        find first tt-curva where tt-curva.cod = produ.fabcod no-error.
        if not avail tt-curva
        then do:
            create tt-curva.
            find last btt-curva no-error.
            if not avail btt-curva
            then tt-curva.pos = 1000000.
            else tt-curva.pos = btt-curva.pos + 1.
            tt-curva.cod = produ.fabcod.
        end.

        vestven = 0.
        vcusto  = 0.
        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf no-lock:
            find bestoq where bestoq.etbcod = estab.etbcod and
                              bestoq.procod = produ.procod no-lock no-error.
            if not avail bestoq
            then next.
            vestven = vestven + (bestoq.estatual * bestoq.estvenda).
            vcusto  = vcusto  + (bestoq.estatual * bestoq.estcusto).
            tt-curva.qtdest = tt-curva.qtdest + bestoq.estatual.
 
        end.
        
        assign tt-curva.estven = tt-curva.estven + vestven
               tt-curva.estcus = tt-curva.estcus + vcusto.
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

                find estoq where estoq.etbcod = movim.etbcod and
                                 estoq.procod = produ.procod no-lock no-error.
                if not avail estoq
                then next.


                if ( ( movim.movqtm * movim.movpc ) * 
                     ( vlcontrato / plani.platot  ) ) > 0
                then do:
                    tt-curva.qtdven = tt-curva.qtdven + movim.movqtm.
                    tt-curva.valven = tt-curva.valven + 
                                      ( ( movim.movqtm * movim.movpc ) * 
                                        ( vlcontrato / plani.platot ) ).
                    tt-curva.valcus = tt-curva.valcus + (movim.movqtm *
                                                         estoq.estcusto). 
                end.
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


    hide frame ffff no-pause.
    hide frame f-dep no-pause.
    hide frame f-dat no-pause.
    hide frame f-etb  no-pause.

    disp categoria.catcod label "Departamento" colon 15
         categoria.catnom no-label 
         xclase.clacod colon 15
         xclase.clanom no-label with frame f-dep2 side-label width 80 row 3.

     
    
    vacum = 0.
    
    
    

    for each tt-curva by tt-curva.pos:

        if tt-curva.estcus = 0 and
           tt-curva.estven = 0 and
           tt-curva.qtdven = 0 and
           tt-curva.qtdest = 0
        then next.

        vacum = vacum + ((tt-curva.valven / tot-v) * 100).
        find fabri where fabri.fabcod = tt-curva.cod no-lock no-error.

        tt-curva.giro = (tt-curva.estven / tt-curva.valven).

        disp fabri.fabfant when avail fabri format "x(28)" column-label "Nome"
             tt-curva.qtdven(total) format "->>>,>>9" column-label "Qtd.Ven"
             tt-curva.valcus(total) format "->>>,>>9" column-label "Val.Cus"
             tt-curva.valven(total) format "->>>,>>9" column-label "Val.Ven"
             tt-curva.qtdest(total) format "->>>,>>9" column-label "Qtd.Est"
             tt-curva.giro when tt-curva.giro > 0
                                 format ">>>>9.9" column-label "Giro"
                                   with frame f-imp width 80 down.


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

