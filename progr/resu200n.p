{admcab.i}

def buffer xclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.
def buffer estoq  for estoq.
def buffer bestoq for estoq.
def buffer bcurva for curva.
def buffer bmovim for movim.
def buffer bcontnf for contnf.
def buffer bplani for plani.
def buffer bclase for clase.

def var val_des like plani.platot.
def var vdesfil as char init "".
def var vanalitico as log format "Analitico/Sintetico".
def var vcarcod like subcaract.carcod.
def var vsubcod like subcaract.subcod. 
def var vestac like estac.etccod.

def temp-table tt-cla
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def var vfabcod like fabri.fabcod.
def var vforcod like forne.forcod.
def var vfabnom like fabri.fabnom.
def var vnom as char.
def var vetbcod like estab.etbcod.
def var vcomcod     like compr.comcod.

def temp-table tt-estab
field etbcod like estab.etbcod.

def var varquivo as char format "x(20)".
def var ii as int.

def var tt-1  like plani.platot.
def var tt-2  like plani.platot.
def var tt-21 like plani.platot.
def var tt-3  like plani.platot.
def var tt-4  like plani.platot.
def var tt-5  like plani.platot.
def var tt-51 like plani.platot.
def var tt-6  like plani.platot.
def var tt-7  like plani.platot.
def var tt-8  like plani.platot.

def var tot1  like plani.platot.
def var tot2  like plani.platot.
def var tot21 like plani.platot.
def var tot3  like plani.platot.
def var tot4  like plani.platot.
def var tot5  like plani.platot.
def var tot51  like plani.platot.
def var tot6  like plani.platot.
def var tot7  like plani.platot.
def var tot8  like plani.platot.

def var v-valor like plani.platot.
def var val_dev like plani.platot.
def var val_biss like plani.platot.
def var val_platot like plani.platot.

def var vmes as i.
def var vano as i.
def var t-com_v  like estoq.estvenda format "->>>,>>9.99".
def var t-ven_c  like estoq.estvenda format "->>>,>>9.99".
def var t-ven    like estoq.estvenda format "->>>,>>9.99".
def var t-val    like estoq.estvenda format "->>>,>>9.99".
def var t-venda  like estoq.estvenda format "->>>,>>9.99".
def var t-compra_v  like estoq.estvenda format "->>>,>>9.99".
def var t-venda_c   like estoq.estvenda format "->>>,>>9.99".
def var t-valest like estoq.estvenda format ">>,>>>,>>9.99".
def var v-giro   like estoq.estvenda format "->>,>>9.99".
def var v-giro_c like estoq.estvenda format "->>,>>9.99".
def var v-giro_q like estoq.estvenda format "->>,>>9.99".
def var tot-v    like estoq.estvenda format "->>>,>>9.99".
def var est-ven  like estoq.estvenda format "->>>,>>9" .
def var venda    like estoq.estvenda format "->>>,>>9.99".
def var venda_c  like estoq.estvenda format "->>>,>>9.99".
def var est-com  like estoq.estvenda format "->>>,>>9"   .
def var compra   like estoq.estvenda format "->>>,>>9.99".
def var compra_v like estoq.estvenda format "->>>,>>9.99".
def var est-atu  like estoq.estvenda format "->>>,>>9"   .
def var valest   like estoq.estvenda format "->>,>>>,>>9.9".
def var valcus   like estoq.estvenda format "->>>,>>9.99".
def var vend-qtd like estoq.estatual.
def var vclacod  like clase.clacod.
def var totcusto like estoq.estcusto.
def var totvenda like estoq.estcusto.
def var acre     like plani.platot.
def var des      like plani.platot.
def var totc     like plani.platot.
def var tot-m    like plani.platot.
def var vacum    like plani.platot format "->>9.99".

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
def var vclasup like clase.clasup.
def var val-fre as dec.
def var val-isu as dec.

def temp-table tt-catcod
    field catcod like produ.catcod.

def temp-table tt-clase
    field clasup       like clase.clasup
    field clacod       like clase.clacod
    field qtd-fisico   like est-ven
    field val-venda    like venda
    field vend-qtd     like est-com 
    field qtd-compra   like est-com
    field val-compra   like compra
    field qtd-atual    like est-atu
    field val-atual    like valest
    field val-custo    like valcus
    field val-giro     like v-giro
    field val-compra_v like compra
    field val-venda_c  like venda
    field val-giro_q   like v-giro
    field val-giro_c   like v-giro.

def temp-table tt-clase-sint
    field clasup       like clase.clasup
    field clacod       like clase.clacod
    field qtd-fisico   like est-ven
    field val-venda    like venda
    field vend-qtd     like est-com 
    field qtd-compra   like est-com
    field val-compra   like compra
    field qtd-atual    like est-atu
    field val-atual    like valest
    field val-custo    like valcus
    field val-giro     like v-giro
    field val-compra_v like compra
    field val-venda_c  like venda
    field val-giro_q   like v-giro
    field val-giro_c   like v-giro.        

def temp-table tt-plani
    field etbcod like plani.etbcod        
    field placod like plani.placod
    index idx01 etbcod placod.
            
def var vcla-cod like clase.clacod.

repeat:
    assign vdesfil = "".
    
    for each tt-clase-sint:
        delete tt-clase-sint.
    end.
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

    assign t-ven  =   0
           t-val   =  0
           t-venda  = 0
           t-valest = 0 
           v-giro   = 0
           tot-v    = 0
           est-ven  = 0
           venda    = 0
           vend-qtd = 0
           est-com  = 0
           compra   = 0
           est-atu  = 0
           valest   = 0
           valcus   = 0
           v-giro_q = 0
           v-giro_c = 0
           venda_c  = 0
           compra_v = 0.
           vnom = "".
    
    update vcatcod label "Departamento"
                with frame f-dat centered side-label color blue/cyan row 3.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label skip with frame f-dat.
    
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

    assign tot1 = 0 tot2 = 0 tot3 = 0 tot4 = 0 tot5 = 0 
           tot6 = 0 tot7 = 0 tot8 = 0 t-valest = 0 t-venda  = 0.

    assign  tt-1 = 0 tt-2 = 0  tt-21 = 0 
            tt-3 = 0 tt-4 = 0 
            tt-5 = 0 tt-51 = 0 tt-6  = 0
            tt-7 = 0 tt-8 = 0.
    
    update vdti label "Periodo"
           "a"
           vdtf no-label with frame f-dat centered color blue/cyan
                                    title " Periodo ".

    update skip vanalitico label "Tipo"
        help "[A] Analitico [S] Sintetico"
        with frame f-dat.

    update vcla-cod at 01 label "Classe" with frame f-dat side-label.
    vclacod = vcla-cod.
    if vclacod <> 0
    then do:
        find xclase where xclase.clacod = vclacod no-lock no-error.
        display xclase.clanom no-label with frame f-dat.
    end.
    else disp "Todas" @ xclase.clanom with frame f-dat.
    
    update vcomcod at 1 label "Comprador" format ">>>9"
            with frame f-dat .
            
    find first compr where compr.comcod = vcomcod
                       and vcomcod > 0  no-lock no-error.
                               
    if avail compr then display compr.comnom format "x(27)" no-label
                         with frame f-dat.
    else if vcomcod = 0 then display "TODOS" @ compr.comnom no-label
                               with frame f-dat.
    else do:
                           
        message "Comprador não encontrado!" view-as alert-box.
        undo, retry.     
    end.
         
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
    /* Antonio - Sol 26324 */
    update vcarcod label "Caracteristica " at 5 
           with frame f-caract centered side-labels color blue/cyan
           title " Caracteristica / Sub-Caracteristica / Estacao" width 79.
    if vcarcod > 0
    then do:
        find caract where caract.carcod = vcarcod no-lock no-error.
        if not avail caract
        then do:
            message "Caracteristica nao cadastrada" view-as alert-box.
            undo.
        end.
        disp caract.cardes no-label format "x(15)" with frame f-caract.
        /*
        disp "Geral" @ caract.cardes no-label format "x(15)" 
            with frame f-caract .
        */
        
        update vsubcod at 5 label "Sub-Caract" with frame f-caract.
            find subcaract where subcaract.carcod = caract.carcod and
                                 subcaract.subcar = vsubcod
                   no-lock no-error.
            if not avail subcaract
            then do:
               message "sub-caracteristica nao cadastrada" 
                       view-as alert-box.
               undo.
            end.
            disp subcaract.subdes no-label format "x(15)" with frame f-caract.
    end.
    else vsubcod = 0.

    update vestac at 5 label "Estacao" with frame f-caract.
    if vestac <> 0
    then do:    
        find estac where estac.etccod = vestac no-lock no-error.
        if not avail estac
        then do:
           message "Estacao nao cadastrada" 
                        view-as  alert-box.
           undo.
        end.
        disp estac.etcnom no-label format "x(15)" with frame f-caract.
    end.
    else  disp "Geral" @ estac.etcnom no-label format "x(15)" 
                    with frame f-caract.
         
    /**/         
    
    form vetbcod vdesfil with frame f-etb.
    repeat:
        disp vdesfil at 35 with frame f-etb.
        update vetbcod at 1
          with frame f-etb centered side-label color blue/cyan width 75.
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
        assign vdesfil = "".
        for each tt-estab:
            vdesfil = vdesfil + string(tt-estab.etbcod) + " ".
        end.
        disp vdesfil no-label with frame f-etb.
    end.

    if vnom = ""
    then do:
        for each tt-estab:
            vnom = vnom + string(tt-estab.etbcod,">>9") + " ".
        end.
    end.

    update /*vfabcod*/ vforcod label "Fornecedor"
                with frame f-depf centered side-label color blue/cyan.
    vfabcod = vforcod.
    if vfabcod = 0
    then do:
        display "GERAL" @ fabri.fabnom with frame f-depf.
        vfabnom = "GERAL".
    end.
    else do:             
        find fabri where fabri.fabcod = vfabcod no-lock.
        disp fabri.fabnom no-label with frame f-depf.
        vfabnom = fabri.fabfant.
    end.
 
    message "Confirma Resumo ? " update sresp.
    if not sresp
    then next.

    assign est-ven  = 0
           venda    = 0
           venda_c  = 0 
           vend-qtd = 0
           est-com  = 0
           compra   = 0
           compra_v = 0 
           est-atu  = 0
           valest   = 0
           valcus   = 0.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/resu" + string(time).
    else varquivo = "l:\\relat\\resu" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "147"
        &Page-Line = "0"
        &Nom-Rel   = ""RESU2002""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """FILIAL "" + string(vetbcod,"">>9"")
                        + "" "" + vfabnom + "" ""
                        + string(vfabcod,"">>>>>9"") + 
                        "" PERIODO DE "" +
                         string(vdti,""99/99/9999"") + "" A "" +
                         string(vdtf,""99/99/9999"") "
       &Width     = "147"
       &Form      = "frame f-cabcab"}
    
    tot-v = 0.
    
    for each tt-cla no-lock:
        find clase where clase.clacod = tt-cla.clacod no-lock no-error.

        find cclase where cclase.clacod = clase.clasup no-lock no-error.
        find dclase where dclase.clacod = cclase.clasup no-lock no-error.
                              
        for each tt-catcod,         
            
            each produ where produ.catcod = tt-catcod.catcod and
                             produ.clacod = tt-cla.clacod no-lock:
            
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
                                
            if vfabcod = 0
            then.
            else do:
                if vfabcod = produ.fabcod
                then.
                else next.
            end.
            if vcarcod > 0
            then do.
            
                           sresp = no. 
                           run valprocaract.p (produ.procod, 
                                               vcarcod,
                                               vsubcod,
                                               output sresp).
                           if not sresp then next. 
            end.
    
            /*
            /* Antonio - Sol 26324 */
            if vsubcod > 0 /* Carcteristica */
            then do:
                find procaract where procaract.procod = produ.procod and
                                     procaract.subcod = vsubcod
                               no-lock no-error.
                if not avail procaract
                then next.
            end.
            */
            if vestac <> 0 then do:
               find estac where 
                    estac.etccod = produ.etccod no-lock no-error.
               if not avail estac then next.
               if estac.etccod <> vestac then next.
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
            
            for each tt-estab,
                each movim where movim.procod = produ.procod    and
                                 movim.etbcod = tt-estab.etbcod and
                                 movim.movtdc = 5               and
                                 movim.movdat >= vdti           and
                                 movim.movdat <= vdtf        no-lock:
                
                if movim.movqtm = 0 or
                   movim.movpc  = 0
                then next.

                assign totc       = 0
                       des        = 0
                       acre       = 0
                       val_dev    = 0
                       val_biss   = 0
                       val_platot = 0
                       val_des    = 0
                       v-valor    = 0.
                
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.pladat = movim.movdat and
                                       plani.movtdc = movim.movtdc
                                                        no-lock no-error.
                if not available plani
                then next.
 
                find estoq where estoq.etbcod = movim.etbcod and
                                 estoq.procod = produ.procod
                                 no-lock no-error.
                if not avail estoq
                then next.
                
                /*
                if plani.crecod = 2
                then do:
                    if plani.biss > ( plani.platot - plani.vlserv) and
                       (plani.platot - plani.vlserv) >= 1
                    then acre = plani.biss / (plani.platot - plani.vlserv).
                    
                    if acre = ? then acre = 0.
                    
                    if plani.biss < ( plani.platot - plani.vlserv) 
                    then des = (plani.platot - plani.vlserv) / plani.biss.
                    
                    if des = ? then des = 0.
                end. 
                else do: 
                    if plani.acfprod > 0
                    then acre = (plani.platot + plani.acfprod) / plani.platot.                    
                    if acre = ? then acre = 0.
                    
                    if plani.descprod > 0
                    then des = plani.platot / (plani.platot - plani.descprod).                  
                    if des = ? then des = 0.
                end.
                if plani.platot < 1
                then assign des = 0
                            acre = 0.


                if acre > 0
                then do:
                    if ( movim.movqtm * movim.movpc * acre ) - 
                       ( ( ( movim.movqtm * movim.movpc ) / 
                             plani.platot ) * plani.vlserv ) <> ?
                    then venda = venda + 
                        ( movim.movqtm * movim.movpc * acre ) - 
                        ( ( ( movim.movqtm * movim.movpc ) / 
                              plani.platot ) * plani.vlserv ).
                
                    if venda = ? then venda = 0.
                    
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
                                   
                    if venda = ? then venda = 0.               
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
                    
                    if venda = ? then venda = 0.
                    
                end.
                */
                                
                /** [[]] **/
                                
                val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) *
                                                   plani.vlserv.
                                                   
                val_biss = ((movim.movpc * movim.movqtm) / plani.platot) *
                                                   plani.biss.
                             
                val_platot = ((movim.movpc * movim.movqtm) / plani.platot) *
                               plani.platot.
                               
                if plani.biss > (plani.platot - plani.vlserv)
                then assign acre = val_biss -
                                        (val_platot - val_dev).
                else acre = ((movim.movpc * movim.movqtm) / plani.platot) *
                                                 plani.acfprod.
                                                 
                val_des =  ((movim.movpc * movim.movqtm) / plani.platot) *
                                                             plani.descprod.
                                                             
                v-valor = val_platot - val_des + acre.

                if v-valor = ?
                then do:
                                                
                    v-valor = 0.

                end.
                
                venda = venda + v-valor.
                
                /** [[]] **/

                est-ven = est-ven + movim.movqtm.
                
                if est-ven = ? then est-ven = 0.
                /* antonio Sol - 26324 */
                vend-qtd = vend-qtd + movim.movqtm. 
                venda_c  = venda_c + (movim.movqtm * estoq.estcus).
                /* */
                
            end.
            
            for each tt-estab,                  
                each movim where movim.procod = produ.procod    and
                                 movim.etbcod = tt-estab.etbcod and
                                 movim.movtdc = 4               and
                                 movim.datexp >= vdti           and
                                 movim.datexp <= vdtf        no-lock:
                                 
                find first plani where plani.etbcod = movim.etbcod and
                                      plani.placod = movim.placod and
                                      plani.pladat = movim.movdat and
                                      plani.movtdc = movim.movtdc 
                                      no-lock no-error.
               if not available plani
               then next.

               find estoq where estoq.etbcod = movim.etbcod and
                                estoq.procod = movim.procod no-lock no-error.
                                
               if not avail estoq
               then next.                 
               
               val_des = 0. 
               val_des = ((movim.movpc * movim.movqtm) / 
                            (plani.platot + plani.descprod)) 
                       * plani.descprod.
                       
               /*val-fre = plani.frete *
                         ((movim.movpc * movim.movqtm) /  plani.protot).
               */
               val-isu = plani.icmssubst *
                        ((movim.movpc * movim.movqtm) /  plani.protot). 

                if val_des = ? then val_des = 0.      
               if val-fre = ? then val-fre = 0.
               if val-isu = ? then val-isu = 0.  
               compra = compra + 
                 (((movim.movpc * movim.movqtm) + 
                  ((movim.movpc * movim.movqtm) * (movim.movalipi / 100)))                           - val_des ) + val-fre + val-isu.
               

               /*(movim.movqtm * estoq.estcusto).
               */
               /*( (movim.movpc * movim.movqtm) +
                  ((movim.movpc * movim.movqtm) * (movim.movalipi / 100)) ).
               */
               
               est-com = est-com + movim.movqtm.
               
               if compra = ? then compra = 0.
               if est-com = ? then est-com = 0.

               /* antonio Sol - 26324 */
                compra_v = compra_v + (movim.movqtm * estoq.estvenda).
               /* */            
            end.
            
            for each tt-estab,
                each movim where movim.procod = produ.procod    and
                                 movim.etbcod = tt-estab.etbcod and
                                 movim.movtdc = 1            and
                                 movim.datexp >= vdti        and
                                 movim.datexp <= vdtf    no-lock.
                
                                  
                compra  = compra + ( (movim.movpc * movim.movqtm) +
                                    
                  ((movim.movpc * movim.movqtm) * (movim.movalipi / 100)) ).
                
                est-com = est-com + movim.movqtm.
            
                if compra = ? then compra = 0.
                if est-com = ? then est-com = 0.

                /* Antonio Sol 26324 */
                find estoq where estoq.etbcod = movim.etbcod and
                                estoq.procod = movim.procod no-lock no-error.

                if avail estoq 
                then  compra_v = compra_v + (movim.movqtm * estoq.estvenda).
                /* */
            end.

            /***** compras newfree *******/
            for each movim where movim.etbcod = 22 and
                                 movim.movtdc = 06 and
                                 movim.procod = produ.procod and
                                 movim.movdat >= vdti and
                                 movim.movdat <= vdtf and 
                                 (movim.desti  = 995 or
                                  movim.desti  = 900 or
                                  movim.desti  = 996) no-lock:
                                  
                compra  = compra + ( (movim.movpc * movim.movqtm) +
                  ((movim.movpc * movim.movqtm) * (movim.movalipi / 100)) ).
                
                est-com = est-com + movim.movqtm.

                if compra = ? then compra = 0.
                if est-com = ? then est-com = 0.  

                 /* Antonio Sol 26324 */
                find estoq where estoq.etbcod = movim.etbcod and
                                estoq.procod = movim.procod no-lock no-error.

                if avail estoq 
                then compra_v = compra_v + (movim.movqtm * estoq.estvenda).
                /* */

            end.

            for each tt-estab:
                find estoq where estoq.etbcod = tt-estab.etbcod and
                                 estoq.procod = produ.procod no-lock no-error.                if avail estoq
                then do:
                    
                    valest  = valest  + 
                              (estoq.estatual * estoq.estvenda).
                    valcus  = valcus  + 
                              (estoq.estatual * estoq.estcusto).
                    est-atu = est-atu + estoq.estatual.
                
                    if valest = ? then valest = 0.
                    if valcus = ? then valcus = 0.
                    if est-atu = ? then est-atu = 0.
                end.
            end.

            output stream stela to terminal.
                disp stream stela produ.procod format ">>>>>>>9" produ.clacod
                        with frame ffff centered color white/red 1 down.
                pause 0.
            output stream stela close.
        end.

        
        v-giro = (valest / venda).
        if v-giro = ? then v-giro = 0.

        /* Antonio Sol 26324 */
        v-giro_c = (valest / compra).
        if v-giro_c = ? then v-giro_c = 0.
        v-giro_q = (vend-qtd / est-atu).
        if v-giro_q = ? then v-giro_q = 0.
                           
       /* */
        tt-1 = tt-1 + est-ven.
        tt-2 = tt-2 + venda.

        /* Antonio Sol 26324 */
        tt-21 = tt-21 + venda_c.
        /* */
        
        /* tt-3 = tt-3 + ((venda / tot-v) * 100). */

        tt-4 = tt-4 + est-com.
        
        tt-5 = tt-5 + compra.
        
        /* Antonio Sol 26324 */
        tt-51 = tt-51 + compra_v.
        /* */

        tt-6 = tt-6 + est-atu.
        
        tt-7 = tt-7 + valest.
        
        tt-8 = tt-8 + valcus.

        if venda > 0 or
           est-atu <> 0
        then do:
            create tt-clase.
            assign tt-clase.clasup       = clase.clasup
                   tt-clase.clacod       = clase.clacod
                   tt-clase.qtd-fisico   = est-ven
                   tt-clase.val-venda    = venda
                   tt-clase.qtd-compra   = est-com
                   tt-clase.val-compra   = compra
                   tt-clase.qtd-atual    = est-atu
                   tt-clase.val-atual    = valest
                   tt-clase.val-custo    = valcus
                   tt-clase.val-compra_v = compra_v   
                   tt-clase.val-venda_c  = venda_c
                   tt-clase.vend-qtd     = vend-qtd
                   tt-clase.val-giro_q   = v-giro_q.
                   tt-clase.val-giro_c   = v-giro_c.
                   tt-clase.val-giro     = v-giro.

          /*** teste ***/
          
            find cclase where cclase.clacod = tt-clase.clasup no-lock no-error.
            find dclase where dclase.clacod = cclase.clasup no-lock no-error.

            find first tt-clase-sint where
                 tt-clase-sint.clacod = dclase.clacod no-lock no-error.
            if not avail tt-clase-sint
            then do:
                create tt-clase-sint.
                assign tt-clase-sint.clasup     = dclase.clasup
                       tt-clase-sint.clacod     = dclase.clacod.
            end.
                   
            assign tt-clase-sint.qtd-fisico = 
                       tt-clase-sint.qtd-fisico + est-ven
                   
                   tt-clase-sint.val-venda  =
                       tt-clase-sint.val-venda + venda

                   tt-clase-sint.qtd-compra =
                       tt-clase-sint.qtd-compra + est-com
                       
                   tt-clase-sint.val-compra =
                       tt-clase-sint.val-compra + compra
                       
                   tt-clase-sint.qtd-atual  =
                       tt-clase-sint.qtd-atual + est-atu
                       
                   tt-clase-sint.val-atual  = 
                       tt-clase-sint.val-atual + valest
                       
                   tt-clase-sint.val-custo  = 
                       tt-clase-sint.val-custo + valcus
                
                   tt-clase-sint.val-compra_v  = 
                    tt-clase-sint.val-compra_v + compra_v

                   tt-clase-sint.val-venda_c  =
                    tt-clase-sint.val-venda_c + venda_c.

                   tt-clase-sint.vend-qtd  =
                    tt-clase-sint.vend-qtd + vend-qtd.

          /***       ***/
            assign est-ven  = 0
                   venda    = 0
                   venda_c  = 0 
                   est-com  = 0
                   compra   = 0
                   compra_v = 0
                   vend-qtd = 0
                   est-atu  = 0
                   valest   = 0
                   valcus   = 0.
        end.
    end.    

    for each tt-clase-sint:
    
        tt-clase-sint.val-giro = 
            (tt-clase-sint.val-atual / tt-clase-sint.val-venda).
        if tt-clase-sint.val-giro = ?
        then tt-clase-sint.val-giro = 0.
       
        /* Antonio Sol 26324 */
        tt-clase-sint.val-giro_c = 
            (tt-clase-sint.val-atual / tt-clase-sint.val-compra).
        if tt-clase-sint.val-giro_c = ?
        then tt-clase-sint.val-giro_c = 0.
        tt-clase-sint.val-giro_q = 
            (tt-clase-sint.vend-qtd / tt-clase-sint.qtd-atual).
        if tt-clase-sint.val-giro_q = ?
        then tt-clase-sint.val-giro_q = 0.
        /* */
                                    
    end.

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

if vanalitico
then do:
    for each tt-clase no-lock break by tt-clase.clasup
                                    by tt-clase.clacod:
                  
        if line-counter = 6
        then put "        V E N D A S                 C O M P R A S   " at 35
                 "               E S T O Q U E S "
                          skip fill("-",135) format "x(135)".

            
        find clase where clase.clacod = tt-clase.clacod no-lock.

        tot1 = tot1 + tt-clase.qtd-fisico.
        tot2 = tot2 + tt-clase.val-venda.
        tot3 = tot3 + (if (tt-clase.val-venda / tt-2) /* * 100*/ <> ?
                       then (tt-clase.val-venda / tt-2)
                       else 0).
        tot21 = tot21 + tt-clase.val-venda_c.
        
        tot4 = tot4 + tt-clase.qtd-compra.
        tot5 = tot5 + tt-clase.val-compra.
        tot51 = tot51 + tt-clase.val-compra_v.
        
        tot6 = tot6 + tt-clase.qtd-atual.
        tot7 = tot7 + tt-clase.val-atual.
        tot8 = tot8 + tt-clase.val-custo.
          
        tt-3 = tt-3 + ( if ((tt-clase.val-venda / tt-2) * 100) <> ?
                        then ((tt-clase.val-venda / tt-2) * 100)
                        else 0). 
       
        /*****************************************
        display tt-clase.clacod
                clase.clanom when avail clase
                tt-clase.qtd-fisico column-label "Qtd.Ven"
                tt-clase.val-venda  
                column-label "FINANCEIRO(1)"
                                format "->>>>>,>>9.99"
                 ((tt-clase.val-venda / tt-2) /** 100*/)
                                   column-label "%/Par." format "->,>>9.99"
                tt-clase.qtd-compra column-label "Qtd.Com"
                tt-clase.val-compra column-label "FINANCEIRO(2)"
                                format "->>>>>,>>9.99"
                tt-clase.qtd-atual  column-label "Qtd.Est"
                tt-clase.val-atual  column-label "Est.Ven"
                                format "->>>>>,>>9.99"
                tt-clase.val-custo  column-label "Est.Cus"
                                format "->>>>>,>>9.99"
                tt-clase.val-giro  column-label "Giro(3)"
                        with frame f-1 width 200 down no-box.
        *********************************************/
        
        /****** Antonio ****/
        display tt-clase.clacod
                clase.clanom when avail clase
                tt-clase.qtd-fisico column-label "Qtd.Ven"
                tt-clase.val-venda  
                column-label "R$ Venda(2)"
                                format "->>>>>,>>9.99"
                tt-clase.val-venda_c  column-label "R$ Vendido PC"
                                format "->>>>>,>>9.99"
                tt-clase.qtd-compra column-label "Qtd.Com"
                tt-clase.val-compra column-label "R$ Comprada PC"
                                format "->>>>>,>>9.99"
                tt-clase.val-compra_v column-label "R$ Comprada PV"
                                format "->>>>>,>>9.99"
               tt-clase.qtd-atual  column-label "Qtd.Est"
               tt-clase.val-custo  column-label "Est.Cus"
                                format "->>>>>,>>9.99"
               tt-clase.val-giro   column-label "Giro PV"
               tt-clase.val-giro_c column-label "Giro PC"
               tt-clase.val-giro_q column-label "Giro Qt"
        with frame f-1 width 200 down no-box.
 
        assign  
        t-venda    = t-venda     + tt-clase.val-venda
        t-valest   = t-valest    + tt-clase.val-atual
        t-ven      = t-venda     + tt-clase.val-venda
        t-val      = t-valest    + tt-clase.val-atual
        t-compra_v = t-compra_v  + tt-clase.val-compra_v
        t-venda_c  = t-venda_c   + tt-clase.val-venda_c
        t-ven_c    = t-venda_c   + tt-clase.val-venda
        t-com_v    = t-com_v     + tt-clase.val-compra_v.

      
        if last-of(tt-clase.clasup) and
           (tot2 > 0 or tot6 > 0)
        then do:
            put skip.
            put fill("-",135) format "x(135)" skip.
            disp "" @ tt-clase.clacod
                 "T O T A I S ..............." @ clase.clanom
                 tot1                          @ tt-clase.qtd-fisico
                 tot2                          @ tt-clase.val-venda
                 tot21                         @ tt-clase.val-venda_c    
                 tot4                          @ tt-clase.qtd-compra
                 tot5                          @ tt-clase.val-compra                                 
                 tot51                         @ tt-clase.val-compra_v
                 tot6                          @ tt-clase.qtd-atual
                 tot8                          @ tt-clase.val-custo 
                 ""                            @ tt-clase.val-giro  
                 ""                            @ tt-clase.val-giro_c
                 ""                            @ tt-clase.val-giro_q
              with frame f-1 width 200 down no-box.
              
              put skip(2).
              assign tot1  = 0
                     tot2  = 0
                     tot21 = 0
                     tot3  = 0
                     tot4  = 0
                     tot5  = 0
                     tot51 = 0
                     tot6  = 0
                     tot7  = 0
                     tot8  = 0
                     t-valest   = 0
                     t-venda    = 0
                     t-venda_c  = 0
                     t-compra_v = 0 .

        end.
    end.
end.
else do: /* sintetico */
    for each tt-clase-sint no-lock break by tt-clase-sint.clasup
                                         by tt-clase-sint.clacod:
                  
            
        if line-counter = 6
        then put "        V E N D A S                 C O M P R A S  " at 35
                 "               E S T O Q U E S        "
                                  skip fill("-",135) format "x(135)".
        
        find clase where clase.clacod = tt-clase-sint.clacod no-lock.

        tot1 = tot1 + tt-clase-sint.qtd-fisico.
        tot2 = tot2 + tt-clase-sint.val-venda.
        tot21 = tot21 + tt-clase-sint.val-venda_c.
        
        tot3 = tot3 + (if ((tt-clase-sint.val-venda / tt-2) * 100) <> ?
                      then ((tt-clase-sint.val-venda / tt-2) * 100)
                      else 0).
        
        tot4 = tot4 + tt-clase-sint.qtd-compra.
        tot5 = tot5 + tt-clase-sint.val-compra.
        tot51 = tot51 + tt-clase-sint.val-compra_v.

        tot6 = tot6 + tt-clase-sint.qtd-atual.
        tot7 = tot7 + tt-clase-sint.val-atual.
        tot8 = tot8 + tt-clase-sint.val-custo.
          
        tt-3 = tt-3 + (if ((tt-clase-sint.val-venda / tt-2) * 100) <> ?
                       then ((tt-clase-sint.val-venda / tt-2) * 100)
                       else 0). 
                 
        /***                    
        display tt-clase-sint.clacod
                clase.clanom when avail clase
                tt-clase-sint.qtd-fisico column-label "Qtd.Ven"
                tt-clase-sint.val-venda  column-label "FINANCEIRO(1)"
                                format "->>>>>,>>9.99"
                
                (if ((tt-clase-sint.val-venda / tt-2) * 100) <> ?
                 then ((tt-clase-sint.val-venda / tt-2) * 100)
                 else 0)
               
                column-label "%/Par." format "->,>>9.99"
                tt-clase-sint.qtd-compra column-label "Qtd.Com"
                tt-clase-sint.val-compra column-label "FINANCEIRO(2)"
                                format "->>>>>,>>9.99"
                tt-clase-sint.qtd-atual  column-label "Qtd.Est"
                tt-clase-sint.val-atual  column-label "Est.Ven"
                                format "->>>>>,>>9.99"
                tt-clase-sint.val-custo  column-label "Est.Cus"
                                format "->>>>>,>>9.99"
                tt-clase-sint.val-giro  column-label "Giro(3)"
        with frame f-1sint width 200 down no-box.
        ***/

        display tt-clase-sint.clacod
                clase.clanom when avail clase
                tt-clase-sint.qtd-fisico column-label "Qtd.Ven"
                tt-clase-sint.val-venda  
                column-label "R$ Venda(2)"
                                format "->>>>>,>>9.99"
                tt-clase-sint.val-venda_c  column-label "R$ Vendido PC"
                                format "->>>>>,>>9.99"
                tt-clase-sint.qtd-compra column-label "Qtd.Com"
                tt-clase-sint.val-compra column-label "R$ Comprada PC"
                                format "->>>>>,>>9.99"
                tt-clase-sint.val-compra_v column-label "R$ Comprada PV"
                                format "->>>>>,>>9.99"
               tt-clase-sint.qtd-atual  column-label "Qtd.Est"
               tt-clase-sint.val-custo  column-label "Est.Cus"
                                format "->>>>>,>>9.99"
               tt-clase-sint.val-giro   column-label "Giro PV"
               tt-clase-sint.val-giro_c column-label "Giro PC"
               tt-clase-sint.val-giro_q column-label "Giro Qt"
        with frame f-1sint width 200 down no-box.

        t-venda  = t-venda  + tt-clase-sint.val-venda.
        t-valest = t-valest + tt-clase-sint.val-atual.
        t-ven    = t-venda  + tt-clase-sint.val-venda.
        t-val    = t-valest + tt-clase-sint.val-atual.
        t-compra_v = t-compra_v  + tt-clase-sint.val-compra_v.
        t-venda_c  = t-venda_c   + tt-clase-sint.val-venda_c.
        t-ven_c    = t-venda_c   + tt-clase-sint.val-venda.
        t-com_v    = t-com_v     + tt-clase-sint.val-compra_v.
      
        if last-of(tt-clase-sint.clasup) and
           (tot2 > 0 or tot6 > 0)
        then do:
                
             put skip.
             put fill("-",135) format "x(135)" skip.
             disp "" @ tt-clase-sint.clacod
                  "T O T A I S ..............." @ clase.clanom
                  tot1                          @ tt-clase-sint.qtd-fisico
                  tot2                          @ tt-clase-sint.val-venda
                  tot21                         @ tt-clase-sint.val-venda_c    
                  tot4                          @ tt-clase-sint.qtd-compra
                  tot5                          @ tt-clase-sint.val-compra                                 
                  tot51                         @ tt-clase-sint.val-compra_v
                  tot6                          @ tt-clase-sint.qtd-atual
                  tot8                          @ tt-clase-sint.val-custo 
                  ""                            @ tt-clase-sint.val-giro  
                  ""                            @ tt-clase-sint.val-giro_c
                  ""                            @ tt-clase-sint.val-giro_q
               with frame f-1sint width 200 down no-box.

               put skip(2).
               assign tot1  = 0
                      tot2  = 0
                      tot21 = 0
                      tot3  = 0
                      tot4  = 0
                      tot5  = 0
                      tot51 = 0
                      tot6  = 0
                      tot7  = 0
                      tot8  = 0
                      t-valest   = 0
                      t-venda    = 0
                      t-venda_c  = 0
                      t-compra_v = 0 .

        end.
    end.
end.    
    
 if tt-2 > 0 or tt-6 > 0
 then do:
     put skip(2).
     put fill("-",135) format "x(135)" skip.
     disp "" @ tt-clase.clacod
          "T O T A L     G E R A L...." @ clase.clanom
          tt-1                          @ tt-clase.qtd-fisico
          tt-2                          @ tt-clase.val-venda
          tt-21                         @ tt-clase.val-venda_c    
          tt-4                          @ tt-clase.qtd-compra
          tt-5                          @ tt-clase.val-compra                                 
          tt-51                         @ tt-clase.val-compra_v
          tt-6                          @ tt-clase.qtd-atual
          tt-8                          @ tt-clase.val-custo 
          ""                            @ tt-clase.val-giro  
          ""                            @ tt-clase.val-giro_c
          ""                            @ tt-clase.val-giro_q
       with frame f-1geral width 200 down no-box.
        
end.
output close.
    
 if opsys = "UNIX"
 then do:
     message "Arquivo gerado: " varquivo. pause.
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
                   for each eclase where 
                            eclase.clasup = dclase.clacod no-lock:
                     find first fclase where fclase.clasup = eclase.clacod 
                                                             no-lock no-error.                     if not avail fclase 
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
                                                             no-lock no-error.                         if not avail gclase 
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

