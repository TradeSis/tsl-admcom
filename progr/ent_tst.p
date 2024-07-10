{admcab.i}
def var perc_dif as dec.
def var total_custo as dec format "->>,>>9.9999".
def var valor_rateio like plani.platot.
def var soma_icm_comdesc like plani.platot.
def var soma_icm_semdesc like plani.platot.
def var total_icm_calc   like movim.movpc.
def var total_pro_calc   like movim.movpc.
def var total_ipi_calc   like movim.movpc.
def var maior_valor like movim.movpc.
def var v-kit as log format "Sim/Nao".
def var libera_nota as log.
def var tranca as log.
def var valor_desconto as dec format ">>,>>9.9999".
def var v-red like clafis.perred.
def var vsub like movim.movpc.
def buffer bestab for estab.
def var vfre as dec format ">>,>>9.99".
def var vacr as dec format ">,>>9.99".
def var voutras like plani.outras.
def buffer btitulo for titulo.
def var vfrecod like frete.frecod.
def var totped like pedid.pedtot.
def var totpen like pedid.pedtot.
def var vok as l.
def var vcusto as dec format ">>,>>9.9999".
def var vpreco like estoq.estcusto.
def var vcria as log initial no.
def new shared workfile wfped field rec  as rec.
def var vped as recid.
def buffer xestoq for estoq.
def workfile wprodu
    field wpro like produ.procod
    field wqtd as int.
def temp-table w-movim 
    field wrec    as   recid 
    field codfis    like clafis.codfis 
    field sittri    like clafis.sittri
    field movqtm    like movim.movqtm 
    field subtotal  like movim.movpc format ">>>,>>9.99" column-label "Subtot" 
    field movpc     like movim.movpc format ">,>>9.99" 
    field movalicms like movim.movalicms initial 17 
    field valicms   like movim.movicms
    field movicms   like movim.movicms
    field movicms2  like movim.movicms
    field movalipi  like movim.movalipi 
    field movipi    like movim.movipi
    field movfre    like movim.movpc 
    field movdes    as dec format ">,>>9.9999"
    field valdes    as dec format ">,>>9.9999".
    
def workfile wetique
    field wrec as recid
    field wqtd like estoq.estatual.
def var vopcao as char format "x(10)" extent 2 initial [" Moveis ","Confeccao"].
def var vestcusto  like estoq.estcusto.
def var vestmgoper like estoq.estmgoper.
def var vestmgluc  like estoq.estmgluc.
def var vtabcod    like estoq.tabcod.
def var vestvenda  like estoq.estvenda.
def buffer cprodu for produ.
def var wetccod like produ.etccod.
def var wfabcod like produ.fabcod.
def var wprorefter like produ.prorefter.
def buffer witem for item.
def var witecod like produ.itecod.
def var vitecod like produ.itecod.
def var vresp    as log format "Sim/Nao".
def var wrsp    as log format "Sim/Nao".
def var vdesc    like plani.descprod format ">9.99 %".
def var i as i.
def var Vezes as int format ">9".
def var Prazo as int format ">>9".
def var v-ok as log.
def buffer bclien for clien.
def var vforcod like forne.forcod.
def var vsaldo    as dec.
def var vmovqtm   like  movim.movqtm.
def var vvencod   like plani.vencod.
def var vsubtotal like  movim.movqtm.
def var valicota  like  plani.alicms format ">9,99" initial 17.
def var vpladat   like  plani.pladat.
def var vrecdat   like  plani.pladat label "Recebimento".
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms .
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vacfprod  like  plani.acfprod.
def var vfrete    like  plani.frete format ">>,>>9.99".
def var vseguro   like  plani.seguro.
def var vdesacess like  plani.desacess.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vtotal    like plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(02)".
def var vopccod   like  opcom.opccod.
def var vhiccod   like  plani.hiccod initial 112.
def var vprocod   like  produ.procod.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotpag      like plani.platot.
def buffer bplani for plani.
def var recpro as recid.
def var ipi_item  like plani.ipi.
def var frete_item like plani.frete.
def var vdifipi as int.
def var frete_unitario like plani.platot.
def var qtd_total as int.
def var vrec as recid.
def buffer bforne for forne.
def var cgc-admcom like forne.forcgc.
def buffer bliped for liped.
def var vtipo as int format "99".
def var vdesval like plani.platot.
def var vobs as char format "x(14)" extent 5.
def var v-ped as int.
def temp-table waux
    field auxrec as recid.
def var vnum like pedid.pednum.
def var tipo_desconto as int.
form titulo.titpar
     titulo.titnum
     prazo
     titulo.titdtven
     titulo.titvlcob with frame ftitulo down centered color white/cyan.
     
form produ.procod column-label "Codigo" format ">>>>>9"
     w-movim.movqtm format ">>>>>9" column-label "Qtd"
     w-movim.movpc  format ">>,>>9.99" column-label "Val.Unit."
     w-movim.subtotal  format ">>>,>>9.99" column-label "Subtot"
     w-movim.valdes format ">>,>>9.9999" column-label "Val.Desc"
     w-movim.movdes format ">9.9999" column-label "%Desc"
     w-movim.movalicms column-label "ICMS" format ">9.99"
     w-movim.movalipi  column-label "IPI"  format ">9.99"
     w-movim.movfre    column-label "Frete" format ">>>,>>9.99"
     with frame f-produ1 row 7 12 down overlay
                centered color white/cyan width 80.


form w-movim.codfis label "Class.Fiscal" format "99999999"  
     w-movim.sittri label "Situacao Trib." format "999"
     v-kit          label "Kit" 
     w-movim.movipi label "Total IPI" 
        with frame f-sittri side-label centered row 10 overlay.
        



form vprocod      label "Codigo"
     produ.pronom  no-label format "x(23)"
     vprotot1 with frame f-produ centered color message side-label
                        row 6 no-box width 81.
form estab.etbcod label "Filial" colon 15
    estab.etbnom  no-label
    cgc-admcom    label "Fornecedor" colon 15
    forne.fornom no-label
    vopccod  label "Op. Fiscal" format "9999" colon 15 
    opcom.opcnom  no-label
    vnumero       colon 15
    vserie        label "Serie"
    vpladat colon 15
    vrecdat colon 39
    vfrecod label "Transp." colon 15
    frete.frenom no-label
    vfrete label "Frete"
      with frame f1 side-label width 80 row 4 color white/cyan.

 
def var vbase_subst like plani.bsubst.
def var v_subst     like plani.icmssubst.
def var voutras_acess like plani.platot.


form vbicms        column-label "Base Icms" at 01
     vicms         column-label "Valor Icms"
     vbase_subst   column-label "Base Icms Subst" 
     v_subst       column-label "Valor Substituicao" 
     vprotot       column-label "Tot.Prod." 
        with frame f-base1 row 12 overlay width 80.

form vfre          column-label "Frete"  at 01
     vseguro       column-label "Seguro"
     voutras_acess column-label "Outras Despesas Acessorias"
     vipi          column-label "IPI"
     vplatot       column-label "Total" format ">>,>>>,>>9.99"
        with frame f2 overlay row 17 width 80.
        
        
do:

    
    clear frame f1 no-pause.
    clear frame f2 no-pause.
    clear frame f-base1 no-pause.
    clear frame f-produ no-pause.
    clear frame f-produ1 no-pause.
    clear frame f-produ2 no-pause.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause .
    hide frame f-produ2  no-pause.
    hide frame f1 no-pause.
    hide frame f2 no-pause.
    hide frame f-base1 no-pause.
    prompt-for estab.etbcod with frame f1.
    find estab using estab.etbcod no-lock.
    for each w-movim:
        delete w-movim.
    end.
    for each wprodu:
        delete wprodu.
    end.
    for each waux:
        delete waux.
    end.
    display estab.etbcod
            estab.etbnom with frame f1.
            
    vetbcod = estab.etbcod.
    if /* vetbcod <= 90 or */
       vetbcod >= 990 or
       {conv_difer.i estab.etbcod}
    then do:
        message "Deposito Invalido". pause.
        undo, leave.
    end.

    v-kit = no.
    libera_nota = no.
    
    update cgc-admcom with frame f1.
    find first forne where forne.forcgc = cgc-admcom no-lock no-error.
    if not avail forne
    then do:
        bell.
        message "Fornecedor nao Cadastrado !!".
        undo, retry.
    end.
    if forne.forcgc = ""
    then do:
        message "CGC NAO CADASTRADO".
        undo, retry.
    end.
    if forne.ativo = no
    then do:
        message "Fornecedor Desativado".
        pause.
        undo, retry.
    end.     
       

    display forne.fornom when avail forne with frame f1.
    if forne.forcod = 5027
    then do:
        message "Fornecedor Invalido".
        undo, retry.
    end.    
    
    if forne.forpai = 0
    then vrec = recid(forne).
    else do:
        find bforne where bforne.forcod = forne.forpai no-lock no-error.
        if not avail bforne
        then do:
            message "Fornecedor pai nao cadastrado".
            undo, retry.
        end.
        else vrec = recid(bforne).
    end.    

    vdesval = 0.
    vdesc   = 0.
    valor_rateio = 0.
        
    /*         
    run nffped.p (input vrec,
                  output vped).
    if vped = ?
    then do:
        message "Para continuar selecione pelo menos um pedido.".
        undo.
    end.       
    */
    
    vforcod = forne.forcod.
    
    vserie = "".
    if forne.ufecod = "RS"
    then find first opcom where opcom.movtdc = 4 no-lock.
    else find last opcom where opcom.movtdc = 4 no-lock.
    vopccod = opcom.opccod.


    do on error undo, retry:
        update vopccod with frame f1.
        find opcom where opcom.opccod = vopccod no-lock no-error.
        if not avail opcom
        then do:
            message "Operacao Fiscal Invalida".
            pause.
            undo, retry.
        end.
    end.                    
         
    
    vhiccod = int(opcom.opccod).
    display vopccod
            opcom.opcnom with frame f1.
    display vserie with frame f1.
    update vnumero validate( vnumero > 0, "Numero Invalido")
           vserie
             with frame f1.
    
    find first plani where plani.numero = vnumero and
                     plani.emite  = vforcod and
                     plani.desti  = estab.etbcod and
                     plani.serie  = vserie and
                     plani.etbcod = estab.etbcod and
                     plani.movtdc = 4 no-lock no-error.
    if avail plani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.
    
    
    vpladat = ?.
    
    find tipmov where tipmov.movtdc = 4 no-lock.
    vdesc = 0.
    do on error undo:
        update vpladat
               vrecdat with frame f1.
        if vpladat > today or vpladat = ? or
           vrecdat < vpladat or
           vpladat < today - 360 or
           vrecdat < today - 360
        then do:
            message "Data Invalida".
            undo, retry.
        end.
        
        
    end.
    

    tranca = yes.

    find autctb where autctb.movtdc = 4 and
                      autctb.emite  = vforcod and
                      autctb.datemi = vpladat and
                      autctb.serie  = vserie  and
                      autctb.numero = vnumero no-lock no-error.
    if avail autctb
    then tranca = no.
    
        
 
    
    update vfrecod with frame f1.
    find frete where frete.frecod = vfrecod no-lock.
    display frete.frenom no-label with frame f1.
    update vfrete with frame f1.
    vvencod = vfrecod.
    
    tipo_desconto = 1.
    display "( 1 ) Sem Desconto                           " 
            "( 2 ) Desconto Total na Nota                 " 
            "( 3 ) Percentual de Desconto por Item        " 
            "( 4 ) Valor de Desconto por Val.Unitario     " 
            "( 5 ) Valor de Desconto por Val.Total do Item"
                with frame f-des 1 column centered title "Tipo de Desconto".
                
    do on error undo, retry:
        update tipo_desconto format "9" label "Tipo Desconto"
                with frame f-des1 side-label centered no-box
                       color message.
        if tipo_desconto < 1 or
           tipo_desconto > 5
        then do:
            message "Opcao Invalida".
            undo, retry.
        end.
    end.                    
    if tipo_desconto = 2
    then do on error undo, retry:
        update vdesval label "Desconto Total da Nota"
                    with frame f-des2 side-label centered.
        if vdesval = 0
        then do:
            message "Valor Invalido".
            pause.
            undo, retry.
        end.
    end.
    hide frame f-des2 no-pause.                
    hide frame f-des1 no-pause.
    hide frame f-des  no-pause.
                
                
            
    
    
    do on error undo, retry:
    assign vbicms  = 0
           vicms   = 0
           vprotot1 = 0
           vipi    = 0
           vdescpro = 0
           vacfprod = 0
           vplatot  = 0
           vtotal = 0.
           voutras = 0.
           vacr    = 0.
           vfre    = 0.
           vseguro = 0.
           vprotot = 0.
    do on error undo:
        hide frame f-obs no-pause.
    
        update vbicms 
               vicms  
               vbase_subst  
               v_subst      
               vprotot with frame f-base1.
         valor_rateio = vprotot.
       
               
        if vbicms = 0 or
           vicms  = 0
        then do:
            
            vobs[1] = "ICMS DESTACADO".
            vobs[2] = "M.E.".
            vobs[3] = "GAS".
            vobs[4] = "NEW FREE".
            vobs[5] = "SUBST. TRIBUT.".


            
            display "1§ " TO 05 vobs[1] no-label 
                    "2§ " TO 05 vobs[2] no-label 
                    "3§ " TO 05 vobs[3] no-label 
                    "4§ " to 05 vobs[4] no-label
                    "5§ " to 05 vobs[5] no-label
                        with frame f-icms side-label row 5
                                 overlay columns 50.
           
            update vtipo label "Escolha" format "99" 
                           with frame f-icms2 side-label columns 58
                                           row 04 no-box. 
            
            if vtipo <> 1 and
               vtipo <> 2 and
               vtipo <> 3 and
               vtipo <> 4 and
               vtipo <> 5
            then do:
                message "Opcao Invalida".
                undo, retry.
            end.
            if vtipo = 1
            then do:
                vobs[1] = "N§______  DE __/__/__".
                update vobs[1] label "Obs" format "x(21)"
                        with frame f-obs side-label
                                                centered color message.
                if substring(vobs[1],04,1) = "_" or
                   substring(vobs[1],04,1) = ""  or
                   substring(vobs[1],14,1) = "_" or
                   substring(vobs[1],14,1) = ""
                then do:
                    message "Informar nota fiscal".
                    undo, retry.
                end.
            end.
        end.
        
        hide frame f-obs no-pause.

    end.
    update vfre        
           vseguro
           voutras_acess
           vipi 
           vplatot with frame f2.
   
        
    if tranca
    then do:
        if vforcod = 100725 
        then do: 
            if vplatot <> (vprotot + voutras_acess + vfre + vseguro
                           + vipi + v_subst) 
            then do:     
                message "Valor Total da Nota nao fecha".  
                undo, retry.
            end.
        end. 
        else do:  
            if tipo_desconto = 1 or
               tipo_desconto = 2
            then do:    
                if vplatot <> (vprotot +
                               voutras_acess +  
                               vfre +  
                               vseguro + 
                               vipi +  
                               v_subst -   
                               vdesval)
                then do:     
                    if vplatot <> (vprotot +
                                   voutras_acess +   
                                   vfre +   
                                   vseguro +  
                                   vipi +   
                                   v_subst)
                    then do:
                        message "Valor Total da Nota nao fecha".  
                        message vplatot (vprotot + 
                                         voutras_acess +    
                                         vfre +    
                                         vseguro + 
                                         vipi +    
                                         v_subst -     
                                         vdesval).
                        pause. 
                        undo, retry.
                    end.
                    else valor_rateio = vprotot + vdesval. 
                end.
                else valor_rateio = vprotot.
            end.
        end.
    end.
    
    hide frame f-obs no-pause.
    clear frame f-produ1 no-pause.
    
    if vhiccod <> 599 and
       vhiccod <> 699
    then do:
    bl-princ:
    repeat with 1 down:
        hide frame f-produ2 no-pause.
        vprotot1 = 0. 
        clear frame f-produ1 all no-pause.
        for each w-movim where w-movim.movqtm = 0 or
                               w-movim.movpc  = 0 or
                               w-movim.subtotal = 0:
            delete w-movim.
        end.    
        for each w-movim with frame f-produ1:
            find produ where recid(produ) = w-movim.wrec no-lock no-error.
            
            if not avail produ
            then next.
            
            display produ.procod
                    w-movim.movqtm
                    w-movim.valdes
                    w-movim.movdes
                    w-movim.subtotal
                    w-movim.movpc
                    w-movim.movalicms
                    w-movim.movalipi
                    w-movim.movfre  with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot1 = vprotot1 + (w-movim.movqtm * w-movim.movpc).
            display vprotot1 with frame f-produ.
        end.
        hide frame f-sittri no-pause.
        libera_nota = no.
        prompt-for vprocod go-on (F5 F6 F8 F9 F4 PF4 
                                  F10 E e C c) with frame f-produ.
                                  
        if keyfunction(lastkey) = "end-error" 
        then do:
            sresp = no.
            message "Confirma Geracao de Nota Fiscal" update sresp.
            if not sresp
            then do:
                for each w-movim:
                    delete w-movim.
                end.
                vprocod = 0.
                hide frame f-produ1 no-pause.
                hide frame f-produ no-pause.
                undo, return.
            end.
            else do:
                find first w-movim no-error.
                if not avail w-movim and
                (opcom.opccod = "1949"  or
                 opcom.opccod = "2949"  or
                 opcom.opccod = "1922"  or
                 opcom.opccod = "2922") 
                then do:
                    
                    if ((vicms >= soma_icm_comdesc - 1) and
                        (vicms <= soma_icm_comdesc + 1)) 
                    then do:
                    
                        total_icm_calc = soma_icm_comdesc.
                        
                        for each w-movim:
                            w-movim.valicms = w-movim.movicms.
                        end.
                        
                    end.
                    else do:
                        
                        total_icm_calc = soma_icm_semdesc.
                        
                        for each w-movim:
                            w-movim.valicms = w-movim.movicms2.
                        end.
                    
                    end. 
                    if ((vprotot >= vprotot1 - 1) and
                        (vprotot <= vprotot1 + 1)) 
                    then do:
                        total_pro_calc = vprotot1.
                    end.    
                    else do:
                        total_pro_calc = vprotot1 - vdesval.
                    end.   
 
 
                    libera_nota = yes.
                    leave bl-princ.
                end.
                else do:
                    if v-kit
                    then do:
                        if ((vprotot >= vprotot1 - 1) and
                            (vprotot <= vprotot1 + 1)) or
                           ((vprotot >= (vprotot1 - vdesval) - 1) and
                            (vprotot <= (vprotot1 - vdesval) + 1))
                        then.    
                        else do:
                            message "Total dos Produtos nao confere "
                            vprotot vprotot1 vdesval.
                            pause.
                            undo, retry.
                        end.
                    end. 
                      
                    if tranca 
                    then do:
                        if ((vprotot >= vprotot1 - 1) and
                            (vprotot <= vprotot1 + 1)) or
                           ((vprotot >= (vprotot1 - vdesval) - 1) and
                            (vprotot <= (vprotot1 - vdesval) + 1))
                        then.    
                        else do:
                            message "Total dos Produtos nao confere "
                            vprotot vprotot1 vdesval.
                            pause.
                            undo, retry.
                        end.
                    
                        if (((vicms >= soma_icm_comdesc - 1) and
                            (vicms <= soma_icm_comdesc + 1)) or
                           ((vicms >= soma_icm_semdesc - 1) and
                            (vicms <= soma_icm_semdesc + 1))) or 
                           vbase_subst > 0 
                        then.
                        else do:
                            message  "Valor Icms Nao Confere: CAPA= " 
                                     vicms  
                                     " ITEM C/Desconto= " 
                                     soma_icm_comdesc 
                                     " ITEM S/DESCONTO= "
                                     soma_icm_semdesc.
                            pause. 
                            undo, retry. 
                        end.
                                               
                        
                        if ((vipi >= ipi_item - 1) and
                            (vipi <= ipi_item + 1)) 
                        then.
                        else do:
                            message 
                            "IPI Nao Confere CAPA= " vipi " ITEM= " ipi_item. 
                            pause. 
                            undo, retry. 
                        end.
                        
                        if ((vfre >= frete_item - 1) and
                            (vfre <= frete_item + 1)) 
                        then.
                        else do:
                            message  "FRETE Nao Confere CAPA= " 
                                     vfre " ITEM= " frete_item. 
                            pause. 
                            undo, retry. 
                        end.

                        
                    end.

                    
                    if ((vicms >= soma_icm_comdesc - 1) and
                        (vicms <= soma_icm_comdesc + 1)) 
                    then do:
                    
                        total_icm_calc = soma_icm_comdesc.
                        
                        for each w-movim:
                            w-movim.valicms = w-movim.movicms.
                        end.
                        
                    end.
                    else do:
                        
                        total_icm_calc = soma_icm_semdesc.
                        
                        for each w-movim:
                            w-movim.valicms = w-movim.movicms2.
                        end.
                    
                    end. 
                    if ((vprotot >= vprotot1 - 1) and
                        (vprotot <= vprotot1 + 1)) 
                    then do:
                        total_pro_calc = vprotot1.
                    end.    
                    else do:
                        total_pro_calc = vprotot1 - vdesval.
                    end.   
 
                    libera_nota = yes.
                    leave bl-princ.
                end.
            end.
        end.
        if lastkey = keycode("c") or lastkey = keycode("C")
        then do with frame f-produ2:
            clear frame f-produ2 all no-pause.
            for each w-movim:
                find produ where recid(produ) = w-movim.wrec no-lock no-error.
                if not avail produ
                then next.
                disp produ.procod
                     produ.pronom format "x(30)"
                     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
                     w-movim.movpc  format ">,>>9.99" column-label "Custo"
                     w-movim.movalicms column-label "ICMS"
                     w-movim.movalipi  column-label "IPI"
                            with frame f-produ2 row 5 9 down  overlay
                              centered color message width 80.
                down with frame f-produ2.
            end.
            pause. undo.
        end.
        if lastkey = keycode("e") or lastkey = keycode("E")
        then do:
            vcria = no.
            update v-procod
                   with frame f-exclusao row 6 overlay side-label centered
                   width 80 color message no-box.
            find produ where produ.procod = v-procod no-lock no-error.
            if not avail produ
            then do:
                message "Produto nao Cadastrado".
                undo.
            end.
            find first w-movim where w-movim.wrec = recid(produ) no-error.
            if not avail w-movim
            then do:
                message "Produto nao pertence a esta nota".
                undo.
            end.
            display produ.pronom format "x(35)" no-label with frame f-exclusao.
            if w-movim.movqtm <> 1
            then update vqtd validate( vqtd <= w-movim.movqtm,
                                       "Quantidade invalida" )
                        label "Qtd" with frame f-exclusao.
            else do:
                vqtd = 1.
                display vqtd with frame f-exclusao.
            end.
            find first w-movim where w-movim.wrec = recid(produ) no-error.
            if avail w-movim
            then do:
                if w-movim.movqtm = vqtd
                then delete w-movim.
                else w-movim.movqtm = w-movim.movqtm - vqtd.
                hide frame f-exclusao no-pause.
            end.
            vprotot1 = 0.
            clear frame f-produ1 all no-pause.
            for each w-movim with frame f-produ1:
                find produ where recid(produ) = w-movim.wrec no-lock.
                display produ.procod
                        w-movim.movqtm
                        w-movim.valdes
                        w-movim.movdes
                        w-movim.subtotal
                        w-movim.movpc
                        w-movim.movalicms
                        w-movim.movalipi
                        w-movim.movfre with frame f-produ1.
                down with frame f-produ1.
                pause 0.
                vprotot1 = vprotot1 + (w-movim.movqtm * w-movim.movpc).
                display vprotot1 with frame f-produ.
            end.
            next.
        end.
        vant = no.
        find produ where produ.procod = input vprocod no-lock no-error.
        if not avail produ and (vhiccod <> 699 and vhiccod <> 599)
        then do:
            message "Produto nao Cadastrado".
            vresp = yes.
            message "Deseja Cadastrar ? " update vresp.
            if not vresp
            then undo.
            else do with frame f-altera
                        row 10  centered OVERLAY SIDE-LABELS color black/cyan:
                disp vopcao no-label with frame f-escolha
                                centered side-label overlay row 8.
                                    choose field vopcao with frame f-escolha.
                if frame-index = 1
                then do transaction:
                    find last cprodu where cprodu.procod >= 400000 and
                                           cprodu.procod <= 449999
                    exclusive-lock no-error.
                    if available cprodu
                    then assign vprocod = cprodu.procod + 1.
                    else assign vprocod = 400000.
                end.
                if frame-index = 2
                then do transaction:
                    find last cprodu where cprodu.procod >= 450000 and
                                           cprodu.procod <= 900000
                    exclusive-lock no-error.
                    if available cprodu
                    then assign vprocod = cprodu.procod + 1.
                    else assign vprocod = 450000.
                end.
            end.
            do transaction:
                create produ.
                assign produ.procod = vprocod
                produ.itecod = vprocod
                produ.datexp = today
                produ.fabcod = forne.forcod.
                disp produ.procod colon 15.
                update produ.pronom colon 15 label "Descricao".
                update produ.protam colon 15 label "Tamanho".
                update produ.corcod colon 50 label "Cor".
                find cor where cor.corcod = produ.corcod.
                display cor.cornom no-label format "x(20)".
                update produ.catcod colon 15 label "Departamento".
                find categoria where categoria.catcod = produ.catcod.
                disp categoria.catnom no-label.
                produ.pronom = produ.pronom + " " + produ.protam
                                        + " " + produ.corcod.
                produ.pronomc = produ.pronom.
                update produ.fabcod colon 15.
                find fabri where fabri.fabcod = produ.fabcod.
                display fabri.fabfant no-label format "x(20)".
                update produ.prorefter colon 50 label "Ref.".
                update produ.clacod colon 15 with no-validate .
                find clase where clase.clacod = produ.clacod no-error.
                if avail clase
                then display clase.clanom no-label format "x(20)".
                update produ.etccod colon 50.
                find estac where estac.etccod = produ.etccod.
                display estac.etcnom no-label.
                update produ.fabcod colon 15.
                find fabri where fabri.fabcod = produ.fabcod no-lock.
                disp fabri.fabnom no-label.
                produ.proipiper = 18.
                update produ.prouncom colon 15
                       produ.prounven colon 50
                       produ.procvcom colon 15
                       produ.procvven colon 50
                       produ.proipiper colon 15  label "Ali.Icms"
                       produ.proclafis colon 50  label "Para Montagem"
                                    format "x(3)"
                                  WITH OVERLAY SIDE-LABELS .
                       produ.prozort = fabri.fabfant + "-" + produ.pronom.
                if produ.proclafis = ""
                then produ.proclafis = "NAO".
                do with frame fpre centered overlay color white/red
                                           side-labels row 15 .
                    assign vestmgoper = wempre.empmgoper
                           vestmgluc  = wempre.empmgluc.
                           update vestcusto  colon 20
                                  vestmgoper colon 20
                                  vestmgluc  colon 20.
                                  vestvenda = (vestcusto *
                                              (vestmgoper / 100 + 1)) *
                                              (vestmgluc / 100 + 1).
                           update vestvenda colon 20.
                end.
            end.
            for each bestab:
                do transaction:
                    create estoq.
                    assign estoq.etbcod    = bestab.etbcod
                           estoq.procod    = produ.procod
                           estoq.estcusto  = vestcusto
                           estoq.estmgoper = vestmgoper
                           estoq.estmgluc  = vestmgluc
                           estoq.estvenda  = vestvenda
                           estoq.tabcod    = vtabcod
                           estoq.datexp    = today.
                end.
            end.
        end.
        else vant = yes.
        
        display produ.pronom when avail produ with frame f-produ.
        find estoq where estoq.etbcod = 999 and
                         estoq.procod = produ.procod no-lock no-error.
        if not available estoq
        then do:
            message "Produto Sem Registro de Armazenagem". pause. undo.
        end.

        display produ.pronom when avail produ with frame f-produ.
        vmovqtm = 0. vsubtotal = 0. vsub = 0. vcria = no.
        find first w-movim where w-movim.wrec = recid(produ) no-error.
        if not avail w-movim
        then do:
            create w-movim.
            assign w-movim.wrec = recid(produ).
            vcria = yes.
        end.
        vmovqtm = w-movim.movqtm.
        vsub    = w-movim.subtotal. 
       
        do on error undo, retry:
            display produ.procod with frame f-produ1.
           
            w-movim.codfis = produ.codfis.
            pause 0.
            
            update w-movim.codfis with frame f-sittri.
            find clafis where clafis.codfis = w-movim.codfis no-error.
            if not avail clafis
            then do:
                message "Classificacao Fiscal Nao Cadastrada".
                pause.
                undo, retry.
            end.
            w-movim.sittri = clafis.sittri.
            

            update w-movim.sittri 
                   v-kit with frame f-sittri.
            if v-kit
            then do:       
                find autctb where autctb.movtdc = 4 and
                                  autctb.emite  = vforcod and
                                  autctb.datemi = vpladat and
                                  autctb.serie  = vserie  and
                                  autctb.numero = vnumero no-lock no-error.
                if not avail autctb
                then do:
                    assign tranca = no.

                    create autctb.
                    assign autctb.emite  = vforcod 
                           autctb.desti  = estab.etbcod 
                           autctb.movtdc = 4 
                           autctb.serie  = vserie 
                           autctb.Numero = vnumero 
                           autctb.datemi = vpladat 
                           autctb.datexp = today
                           autctb.FunCod = 12
                           autctb.Motivo = "AUTORIZACAO AUTOMATICA KIT" 
                           autctb.hora   = time.
                end.
            end.       
            

            hide frame f-sittri no-pause.
            clafis.sittri = w-movim.sittri.            
            
            
            if forne.ufecod = "RS"
            then if w-movim.sittri = 20
                 then clafis.perred = 29.4117.
                 else clafis.perred = 0.

            
            run atu_fis.p( input w-movim.wrec,
                           input clafis.codfis).
                                   
        end.         
                    
        if (w-movim.codfis >= 18060000 and 
            w-movim.codfis <= 18069999) or
            w-movim.codfis = 84715010
        then update w-movim.movipi
                    with frame f-sittri.
       
        update w-movim.movqtm with frame f-produ1.
                       
        w-movim.movpc = estoq.estcusto. 
        w-movim.movqtm = vmovqtm + w-movim.movqtm. 
        display w-movim.movqtm with frame f-produ1. 
        update w-movim.subtotal with frame f-produ1.  
        
        w-movim.movpc = w-movim.subtotal / w-movim.movqtm.
        display w-movim.movpc with frame f-produ1. 

        if tipo_desconto = 2 
        then assign w-movim.movdes = ((vdesval / valor_rateio) * 100) 
                    w-movim.valdes = w-movim.movpc * 
                                     (vdesval / valor_rateio).
            
        display w-movim.valdes
                w-movim.movdes with frame f-produ1.
                    
        if tipo_desconto = 3 
        then do: 
            update w-movim.movdes with frame f-produ1. 
            w-movim.valdes = w-movim.movpc * (w-movim.movdes / 100).
            
            vdesval = vdesval + 
                      ((w-movim.movpc * (w-movim.movdes / 100)) * 
                      w-movim.movqtm).
            
        end.    
                
        if tipo_desconto = 4 
        then do on error undo, retry: 
            update w-movim.valdes with frame f-produ1.
            if w-movim.valdes > w-movim.movpc
            then do:
                message "Informar o Valor do Desconto Unitario". 
                pause. 
                undo, retry.
            end.    
            w-movim.movdes = ((w-movim.valdes / w-movim.movpc) * 100).
            vdesval = vdesval + (w-movim.valdes * w-movim.movqtm).
        end.
        
        if tipo_desconto = 5 
        then do on error undo, retry: 
            update w-movim.valdes with frame f-produ1.
            if w-movim.valdes > (w-movim.movpc * w-movim.movqtm)
            then do:
                message "Valor de Desconto Invalido". 
                pause. 
                undo, retry.
            end.    
            w-movim.movdes = ((w-movim.valdes / (w-movim.movpc * 
                                                 w-movim.movqtm)) * 100).
            vdesval = vdesval + w-movim.valdes.
        end.    
             
        
            
            
        display w-movim.valdes 
                w-movim.movdes with frame f-produ1.
             
            
        if forne.ufecod = "RS" 
        then w-movim.movalicms = 17. 
        else w-movim.movalicms = 12. 
       
        w-movim.movfre = (w-movim.movpc - w-movim.valdes) * (vfre / vprotot).
        
        
        update w-movim.movalicms with frame f-produ1.
                    
        if (w-movim.codfis >= 18060000 and 
            w-movim.codfis <= 18069999) or 
            w-movim.codfis = 84715010
        then.
        else do: 
            w-movim.movalipi = clafis.peripi.
            update w-movim.movalipi with frame f-produ1.
        end.
        
        update w-movim.movfre with frame f-produ1.
        
           
        vprotot1 = 0.
        soma_icm_comdesc = 0.
        soma_icm_semdesc = 0. 
        ipi_item  = 0.
        frete_item = 0.
        clear frame f-produ1 all no-pause.
        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = w-movim.wrec no-lock.
            display produ.procod 
                    w-movim.movqtm 
                    w-movim.valdes 
                    w-movim.movdes 
                    w-movim.subtotal 
                    w-movim.movpc 
                    w-movim.movalicms 
                    w-movim.movalipi 
                    w-movim.movfre with frame f-produ1.

            down with frame f-produ1.
            pause 0.
            find clafis where clafis.codfis = w-movim.codfis no-lock.
            
            v-red = clafis.perred.
            if forne.ufecod <> "RS"
            then v-red = 0.

            w-movim.movicms2 = ( (w-movim.movqtm * (w-movim.movpc + 
                                                   w-movim.movfre)) *
                              (1 - (v-red / 100)) ) *
                              (w-movim.movalicms / 100).

            soma_icm_semdesc = soma_icm_semdesc + w-movim.movicms2. 
            
                          
            
            if tipo_desconto < 5
            then do:
 
                w-movim.movicms = ( (w-movim.movqtm * (w-movim.movpc +  
                                                       w-movim.movfre -
                                                       w-movim.valdes)) *
                                    (1 - (v-red / 100)) ) *
                                    (w-movim.movalicms / 100).

 
                soma_icm_comdesc = soma_icm_comdesc + w-movim.movicms. 


                if w-movim.movalipi <> 0
                then
                w-movim.movipi = ((w-movim.movpc + 
                                   w-movim.movfre -
                                   w-movim.valdes) * w-movim.movqtm) * 
                                 (w-movim.movalipi / 100).

                
                ipi_item = ipi_item + w-movim.movipi.
                frete_item = frete_item + (w-movim.movfre * w-movim.movqtm).
                 
            end.
            else do:
                 
                 w-movim.movicms = ( (w-movim.movqtm * (w-movim.movpc + 
                                                        w-movim.movfre -
                                                      (w-movim.valdes / 
                                                       w-movim.movqtm))) *
                                     (1 - (v-red / 100)) ) *
                                     (w-movim.movalicms / 100).


                 soma_icm_comdesc = soma_icm_comdesc + w-movim.movicms. 


                 if w-movim.movalipi <> 0
                 then
                 w-movim.movipi = ((w-movim.movpc + 
                                    w-movim.movfre -
                                    (w-movim.valdes / w-movim.movqtm)) 
                                        * w-movim.movqtm) * 
                                   (w-movim.movalipi / 100).

                 ipi_item = ipi_item + w-movim.movipi.
                 frete_item = frete_item + (w-movim.movfre * w-movim.movqtm).
                 
           
            end.
                       
            vprotot1 = vprotot1 + w-movim.subtotal.
            display vprotot1 with frame f-produ.
        end.
    end.
    end.
    else sresp = yes.
    if not sresp
    then undo, retry.
    end.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    hide frame f2 no-pause.
    hide frame f-base1 no-pause.
    if v-ok = yes
    then undo, leave.
    if libera_nota = no
    then do: 
        for each w-movim: 
            delete w-movim.
        end. 
        vprocod = 0. 
        hide frame f-produ1 no-pause. 
        hide frame f-produ no-pause. 
        undo, return.             
    end.


    total_icm_calc = vicms - total_icm_calc.
    total_pro_calc = vprotot - total_pro_calc.
    total_ipi_calc = vipi - ipi_item.
    
    if ((total_icm_calc > 0 and total_icm_calc < 1) or
        (total_icm_calc < 0 and total_icm_calc > -1)) or
       ((total_pro_calc > 0 and total_pro_calc < 1) or
        (total_pro_calc < 0 and total_pro_calc > -1)) or
       ((total_ipi_calc > 0 and total_ipi_calc < 1) or
        (total_ipi_calc < 0 and total_ipi_calc > -1)) 
    then do:    
        recpro = ?.
        maior_valor = 0.
        for each w-movim:
            if w-movim.subtotal > maior_valor
            then assign maior_valor = w-movim.subtotal
                        recpro      = w-movim.wrec.
        end.

        find first w-movim where w-movim.wrec = recpro no-error.
        if avail w-movim
        then do:
            
            
            w-movim.movicms = w-movim.movicms + 
                              (total_icm_calc / w-movim.movqtm).
            w-movim.movpc   = w-movim.movpc   + 
                              (total_pro_calc / w-movim.movqtm).
            w-movim.movipi  = w-movim.movipi  + 
                              (total_ipi_calc / w-movim.movqtm).
            
        end.
    end.    

    
    
    
   
    qtd_total = 0.
    total_custo = 0.
    for each w-movim:
        qtd_total = qtd_total + w-movim.movqtm.
    end.    
    
    frete_unitario = vfre / qtd_total.  
    

    for each w-movim:
        find produ where recid(produ) = w-movim.wrec no-lock.
    
        if w-movim.movfre > 0
        then do:
            valor_desconto = w-movim.valdes.
            
            if tipo_desconto = 5
            then valor_desconto = w-movim.valdes / w-movim.movqtm.
             
            vcusto = (w-movim.movpc + w-movim.movfre
                       - valor_desconto) +
                      ( (w-movim.movpc + w-movim.movfre
                       - valor_desconto) *
                        (w-movim.movalipi / 100)).
                      
        end.
        else do:
        
            valor_desconto = w-movim.valdes.
            if tipo_desconto = 5
            then valor_desconto = w-movim.valdes / w-movim.movqtm.

            vcusto = (w-movim.movpc + frete_unitario
                       - valor_desconto) +
                      ( (w-movim.movpc + frete_unitario
                       - valor_desconto) *
                        (w-movim.movalipi / 100)).
        end.
        total_custo = total_custo + (vcusto * movqtm).
        
        display produ.procod  
                w-movim.movqtm  
                w-movim.valdes  
                w-movim.movdes  
                vcusto column-label "Custo"
                w-movim.movpc  
                w-movim.movalicms  
                w-movim.movicms
                w-movim.movalipi  
                w-movim.movfre label "Frete"
                w-movim.movipi label "IPI"
                    with frame f-pro 1 column.

    end.

    /*
    if total_custo >= vplatot - 1 and
       total_custo <= vplatot + 1
    then.
    else do:
        message "Total Custo: " total_custo          
                " Total Nota: " vplatot
                " Diferenca:  " (vplatot - total_custo)
                " = " ( 100 - ((total_custo / vplatot) * 100))
                " % ".
        pause.        
        undo, retry.
    end.   
    */       
    
    
    perc_dif = ( 100 - ((total_custo / vplatot) * 100)).


    if perc_dif >= 1 or
       perc_dif <= -1
    then do:
        message "Total Custo: " total_custo          
                " Total Nota: " vplatot
                " Diferenca:  " (vplatot - total_custo)
                " = " ( 100 - ((total_custo / vplatot) * 100))
                " % ".
        pause.        
        undo, retry.
    end.   

    
    
    message "Nota OK".
    pause.
    return. 
    
    
    
    

    find estab where estab.etbcod = vetbcod no-lock.
    find last bplani where bplani.etbcod = estab.etbcod and
                           bplani.placod <= 500000 and
                           bplani.placod <> ? no-lock no-error.
    if not avail bplani
    then vplacod = 1.
    else vplacod = bplani.placod + 1.
    if not sresp
    then do:
        hide frame f-produ no-pause.
        hide frame f-produ1 no-pause.
        clear frame f-produ all.
        clear frame f-produ1 all.
        for each w-movim:
            delete w-movim.
        end.
        undo, retry.
    end.
    do transaction:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.cxacod   = frete.forcod
               plani.placod   = vplacod
               plani.protot   = vprotot
               plani.emite    = vforcod
               plani.bicms    = vbicms
               plani.icms     = vicms
               plani.descpro  = vprotot * (vdesc / 100)
               plani.acfprod  = vacr
               plani.frete    = vfre
               plani.seguro   = vseguro
               plani.desacess = voutras_acess
               plani.bsubst   = vbase_subst
               plani.icmssubst = v_subst
               plani.ipi      = vipi
               plani.platot   = vplatot
               plani.serie    = vserie
               plani.numero   = vnumero
               plani.movtdc   = tipmov.movtdc
               plani.desti    = estab.etbcod
               plani.modcod   = tipmov.modcod
               plani.opccod   = int(opcom.opccod)
               plani.vencod   = vvencod
               plani.notfat   = vforcod
               plani.dtinclu  = vrecdat
               plani.pladat   = vpladat
               PLANI.DATEXP   = today
               plani.horincl  = time
               plani.hiccod   = int(opcom.opccod)
               plani.notsit   = no
               plani.outras = voutras
               plani.isenta = plani.platot - plani.outras - plani.bicms.
               if plani.descprod = 0
               then plani.descprod = vdesval.
               if vtipo = 0
               then plani.notobs[3] = "".
               else plani.notobs[3] = vobs[vtipo].
    
    end.
    for each wfped:
        find pedid where recid(pedid) = wfped.rec no-lock.
        find plaped where plaped.pedetb = pedid.etbcod and
                          plaped.plaetb = estab.etbcod and
                          plaped.pedtdc = pedid.pedtdc and
                          plaped.pednum = pedid.pednum and
                          plaped.placod = vplacod      and
                          plaped.serie  = vserie       no-error.
        if not avail plaped
        then do transaction: 
            create plaped.
            assign plaped.pedetb = pedid.etbcod 
                   plaped.plaetb = estab.etbcod 
                   plaped.pedtdc = pedid.pedtdc 
                   plaped.pednum = pedid.pednum 
                   plaped.placod = vplacod 
                   plaped.serie  = vserie 
                   plaped.numero = vnumero 
                   plaped.forcod = forne.forcod.

        end.
    end.
    
    for each wfped:
        create waux.
        assign waux.auxrec = wfped.rec.
    end.

    /****************** atualiza custos ********************/
    qtd_total = 0.
    for each w-movim:
        qtd_total = qtd_total + w-movim.movqtm.
    end.    
    
    frete_unitario = vfre / qtd_total.  
    
    for each w-movim:
    
        if w-movim.movfre > 0
        then do:
            valor_desconto = w-movim.valdes.
            
            if tipo_desconto = 5
            then valor_desconto = w-movim.valdes / w-movim.movqtm.
             
            vcusto = (w-movim.movpc + w-movim.movfre
                       - valor_desconto) +
                      ( (w-movim.movpc + w-movim.movfre
                       - valor_desconto) *
                        (w-movim.movalipi / 100)).
                      
        end.
        else do:
        
            valor_desconto = w-movim.valdes.
            if tipo_desconto = 5
            then valor_desconto = w-movim.valdes / w-movim.movqtm.

            vcusto = (w-movim.movpc + frete_unitario
                       - valor_desconto) +
                      ( (w-movim.movpc + frete_unitario
                       - valor_desconto) *
                        (w-movim.movalipi / 100)).
        end.
        find produ where recid(produ) = w-movim.wrec no-error.
        do transaction:
            produ.codfis = w-movim.codfis.
            find clafis where clafis.codfis = w-movim.codfis no-error.
            if avail clafis
            then assign clafis.perred = 0.
                        clafis.sittri = 0.
        end.
            
        for each estoq where estoq.procod = produ.procod.
            do transaction:
                estoq.estcusto = vcusto.
            end.    
        end.

    end.
 
    
    
    
    for each w-movim:
    
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movim.wrec no-lock no-error.
        if not avail produ
        then next.
        find first plani where plani.etbcod = estab.etbcod and
                               plani.placod = vplacod no-lock.
        create wetique.
        assign wetique.wrec = recid(produ)
               wetique.wqtd = w-movim.movqtm.
        for each wfped:
            find pedid where recid(pedid) = wfped.rec no-error.
            if avail pedid
            then do:
                find first liped where liped.pedtdc = pedid.pedtdc and
                                       liped.etbcod = pedid.etbcod and
                                       liped.procod = produ.procod and
                                       liped.pednum = pedid.pednum no-error.
                if avail liped
                then do:
                    find first wprodu where wprodu.wpro = liped.procod no-error.
                      if not avail wprodu
                      then do:
                        create wprodu.
                        assign wprodu.wpro = liped.procod.
                      end.
                      wprodu.wqtd = wprodu.wqtd + 1.
                end.
            end.
        end.
        for each wprodu:
            if wprodu.wqtd = 1
            then delete wprodu.
        end.
        vnum = 0.
        for each wfped:
            find pedid where recid(pedid) = wfped.rec no-lock no-error.
            if avail pedid
            then do:
                find first liped where liped.pedtdc = pedid.pedtdc and
                                       liped.etbcod = pedid.etbcod and
                                       liped.procod = produ.procod and
                                       liped.pednum = pedid.pednum no-error.
                if avail liped
                then do transaction:
                   vnum = 0.
                   sresp = yes.
                   find first wprodu where wprodu.wpro = liped.procod no-error.
                   if avail wprodu
                   then do:
                        vnum = 0.
                        message "PRODUTO EXISTE EM MAIS DE UM PEDIDO".
                        find produ where produ.procod = liped.procod no-lock.
                        display produ.procod
                                produ.pronom format "x(30)"
                                w-movim.movqtm label "Qtd"
                                    with frame f-l1 side-label width 80.
                        for each waux:
                           find pedid where recid(pedid) = waux.auxrec
                                                                    no-error.
                           find first bliped where
                                      bliped.pedtdc = pedid.pedtdc and
                                      bliped.etbcod = pedid.etbcod and
                                      bliped.procod = produ.procod and
                                      bliped.pednum = pedid.pednum
                                            no-lock no-error.
                           if not avail bliped
                           then next.
                           find first wprodu where wprodu.wpro =
                                            bliped.procod no-error.
                           if not avail wprodu
                           then next.
                           disp pedid.pednum
                                bliped.procod
                                produ.pronom format "x(30)"
                                bliped.lipqtd
                                        with frame f-l2 centered color
                                                message 6 down.
                        end.
                        v-ped = 0.
                        vnum  = pedid.pednum.
                        update vnum label "Pedido"
                               v-ped label "Quantidade"
                                    with frame f-l3 centered
                                            no-box side-label
                                                color message overlay.
                        find first liped where liped.pedtdc = pedid.pedtdc and
                                               liped.etbcod = pedid.etbcod and
                                               liped.procod = produ.procod and
                                               liped.pednum = vnum no-error.
                        if avail liped
                        then do:
                            liped.lipent = liped.lipent + v-ped.
                        end.
                   end.
                   else do:
                        liped.lipent = liped.lipent + w-movim.movqtm.
                   end.
                end.
            end.
        end.
        hide frame f-l1 no-pause.
        hide frame f-l2 no-pause.
        hide frame f-l3 no-pause.
        do transaction:

            create movim.
            ASSIGN movim.movtdc = plani.movtdc
                   movim.PlaCod = plani.placod
                   movim.etbcod = plani.etbcod
                   movim.movseq = vmovseq
                   movim.procod = produ.procod
                   movim.movqtm = w-movim.movqtm
                   movim.movpc  = w-movim.movpc
                   movim.movicms = w-movim.valicms
                   movim.movpdes = w-movim.movdes
                   movim.movdes  = w-movim.valdes
                   movim.MovAlICMS = w-movim.movalicms
                   movim.MovAlIPI  = w-movim.movalipi
                   movim.movipi    = w-movim.movipi
                   movim.movdev    = w-movim.movfre 
                   movim.movdat    = plani.pladat
                   movim.MovHr     = int(time)
                   MOVIM.DATEXP    = plani.datexp
                   movim.desti     = plani.desti
                   movim.emite     = plani.emite.

            if tipo_desconto = 5
            then movim.movdes = w-movim.valdes / w-movim.movqtm.       
                   
            find clafis where clafis.codfis = produ.codfis no-lock no-error.
            if avail clafis
            then movim.movsubst = clafis.persub.
                                
            
            if w-movim.movfre = 0
            then movim.movdev = frete_unitario.      
            
            /*
            movim.movipi    = (movim.movpc - movim.movdes + movim.movdev) * 
                              (w-movim.movalipi / 100).
            */
                   
            delete w-movim.
        end.
    end.
    
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock.
        do transaction:
            run atuest.p(input recid(movim),
                         input "I",
                         input 0).
        end.
    end.


    /*
    for each wfped:
        find pedid where recid(pedid) = wfped.rec no-error.
        if avail pedid
        then do:
            vok = no.
            totped = 0. totpen = 0.
            for each liped of pedid no-lock:
                do transaction:
                    if liped.lipent = 0
                    then pedid.sitped = "A".
                    if liped.lipent <> 0 and
                       liped.lipqtd <> liped.lipent
                    then do:
                        pedid.sitped = "P".
                        leave.
                        vok = yes.
                    end.
                end.
                if vok
                then leave.
            end.
            for each liped of pedid no-lock:
                totped = totped + liped.lipqtd.
                totpen = totpen + liped.lipent.
            end.
            if totped = totpen
            then do transaction:
                pedid.sitped = "F".
            end.
        end.
    end.
    */
    
    
    
    
    for each wfped:
        find pedid where recid(pedid) = wfped.rec no-error.
        if avail pedid
        then do:
            for each liped of pedid:
                do transaction:
                    liped.lipsit = "".
                    pedid.sitped = "".
                    if liped.lipent >= (liped.lipqtd - (liped.lipqtd * 0.10)) and 
                       liped.lipent <= (liped.lipqtd + (liped.lipqtd * 0.10))
                    then liped.lipsit = "F".
                    else liped.lipsit = "P". 
                    
                    if liped.lipent = 0
                    then liped.lipsit = "A".
                end.
            end.
            
            for each liped of pedid:
    
                do transaction:
                    if liped.lipsit = "A"
                    then pedid.sitped = "A".
                    else if liped.lipsit = "P" and
                            pedid.sitped <> "A"
                         then pedid.sitped = "P".
                         else if liped.lipsit = "F" and
                                 pedid.sitped = "" 
                              then pedid.sitped = "F". 
                end.
            end.    
        end.
    end.
    
    
    
    vezes = 0. prazo = 0.
    find first plani where plani.etbcod = estab.etbcod and
                           plani.placod = vplacod no-lock.
                           
    if vhiccod <> 599 and
       vhiccod <> 699
    then do:
    update vezes label "Vezes"
                with frame f-tit width 80 side-label centered color white/red.
    
    if plani.platot = 0
    then vtotpag = plani.protot.
    else vtotpag = plani.platot.


    find first movim where movim.placod = plani.placod and
                           movim.etbcod = plani.etbcod no-lock no-error.
                           
    if avail movim and (vhiccod <> 599 and vhiccod <> 699)
    then do:
        update vtotpag with frame f-tit.
    
        if vtotpag < (plani.protot + plani.ipi - vdesval - plani.descprod)
        then do:
            message "Verifique os valores da nota".
            undo, retry.
        end.

        do i = 1 to vezes:
            do transaction:
                create titulo.
                assign titulo.etbcod = plani.etbcod
                       titulo.titnat = yes
                       titulo.modcod = "DUP"
                       titulo.clifor = forne.forcod
                       titulo.titsit = "lib"
                       titulo.empcod = wempre.empcod
                       titulo.titdtemi = plani.pladat
                       titulo.titnum = string(plani.numero)
                       titulo.titpar = i.
                if prazo <> 0
                then assign titulo.titvlcob = vtotpag
                            titulo.titdtven = titdtemi + prazo.
                else assign titulo.titvlcob = vtotpag / vezes
                            titulo.titdtven = titulo.titdtemi + (30 * i).
            end.
        end.
        vsaldo = vtotpag.
        for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = estab.etbcod and
                              titulo.clifor = forne.forcod and
                              titulo.titnum = string(plani.numero).
            display titulo.titpar
                    titulo.titnum
                        with frame ftitulo down centered
                                color white/cyan.
            prazo = 0.
            update prazo with frame ftitulo.
            do transaction:
                titulo.titdtven = vpladat + prazo.
                titulo.titvlcob = vsaldo.
                update titulo.titdtven
                       titulo.titvlcob with frame ftitulo no-validate.
            end.
            vsaldo = vsaldo - titulo.titvlcob.
        
            find titctb where titctb.forcod = titulo.clifor and
                              titctb.titnum = titulo.titnum and
                              titctb.titpar = titulo.titpar no-error.
            if not avail titctb
            then do transaction:
                create titctb.
                ASSIGN titctb.etbcod   = titulo.etbcod
                       titctb.forcod   = titulo.clifor
                       titctb.titnum   = titulo.titnum
                       titctb.titpar   = titulo.titpar
                       titctb.titsit   = titulo.titsit
                       titctb.titvlpag = titulo.titvlpag
                       titctb.titvlcob = titulo.titvlcob
                       titctb.titdtven = titulo.titdtven
                       titctb.titdtemi = titulo.titdtemi
                       titctb.titdtpag = titulo.titdtpag.
            end.
            down with frame ftitulo.
        end.
        if vfrete > 0
        then do transaction:
            create btitulo.
            assign btitulo.etbcod   = plani.etbcod
                   btitulo.titnat   = yes
                   btitulo.modcod   = "NEC"
                   btitulo.clifor   = frete.forcod
                   btitulo.cxacod   = forne.forcod
                   btitulo.titsit   = "lib"
                   btitulo.empcod   = wempre.empcod
                   btitulo.titdtemi = vpladat
                   btitulo.titnum   = string(plani.numero)
                   btitulo.titpar   = 1
                   btitulo.titnumger = string(plani.numero)
                   btitulo.titvlcob = vfrete.
            update btitulo.titdtven label "Venc.Frete"
                   btitulo.titnum   label "Controle"
                        with frame f-frete centered color white/cyan
                                        side-label row 15 no-validate.
        end.    
    end.
    end.
    message "Nota Fiscal Incluida". pause.
    
    for each w-movim:
        delete w-movim.
    end.
    if plani.desti = 996 or
       plani.desti = 999
    then do:
        run peddis.p (input recid(plani)).
        
        find first wetique no-error.
        if not avail wetique
        then leave.
        message "Confirma emissao de Etiquetas" update sresp.
        if sresp
        then do:
                   
           
            
           if opsys = "unix"
           then do:
           
              if search("/admcom/relat/etique.bat") <> ?
               then do:
                   os-command silent rm -f /admcom/relat/etique.bat.
                   os-command silent rm -f /admcom/relat/cris*.* .
              end.
              
           end.
           else do:

                if search("c:\temp\etique.bat") <> ?
                then do:
                    dos silent del c:\temp\etique.bat.  
                    dos silent del c:\temp\cris*.* .
                end.
           end.
             
            for each wetique:
                
                if plani.desti = 996
                then run eti_barl.p (input wetique.wrec,
                                     input wetique.wqtd).
                
                else run etique-m2.p (input wetique.wrec,
                                      input wetique.wqtd).

            end.

            if opsys = "unix"
            then os-command silent /admcom/relat/etique.bat.
            else os-command silent c:\temp\etique.bat.

            
        end.
        for each wetique:
            delete wetique.
        end.
        message "Confirma relatorio de distribuicao" update sresp.
        if sresp
        then do:
            run disdep.p (input recid(plani)).
        end.

        


    end.
end.
