{admcab.i}
def var vvencod like plani.vencod.
def var vsub like movim.movpc.
def buffer bestab for estab.
def var vfre as dec format ">>,>>9.99".
def var vacr as dec format ">,>>9.99".
def var voutras like plani.outras.
def var vfrecod like frete.frecod.
def var vok as l.
def var vcusto like estoq.estcusto.
def var vpreco like estoq.estcusto.
def var vcria as log initial no.
def new shared workfile wfped field rec  as rec.
def var vped as recid.
def buffer xestoq for estoq.
def workfile wprodu
    field wpro like produ.procod
    field wqtd as int.
def  workfile w-movim
               field wrec    as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc format ">>>,>>9.99"
                                column-label "Subtot"
               field movpc     as decimal format ">,>>9.99"
               field movalicms like movim.movalicms initial 17
               field movalipi  like movim.movalipi
               field movfre    like movim.movpc.
def var vresp    as log format "Sim/Nao".
def var vdesc    like plani.descprod format ">9.99 %".
def var v-ok as log.
def var vforcod like forne.forcod.
def var vmovqtm   like  movim.movqtm.
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
def var vhiccod   like  opcom.opccod format "9999".
def var vproamx   like  produ.procod.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def buffer bplani for plani.


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
     
form produ.procod column-label "Codigo" format ">>>>>9"
     produ.pronom format "x(21)"
     w-movim.movqtm format ">>>>9" column-label "Qtd"
     w-movim.subtotal  format ">>>,>>9.99" column-label "Subtot"
     w-movim.movpc  format ">,>>9.99" column-label "V.Unit."
     w-movim.movalicms column-label "ICMS" format ">9.99%"
     w-movim.movalipi  column-label "IPI"  format ">9.99%"
     w-movim.movfre    column-label "Frete" format ">>,>>9.99"
     with frame f-produ1 row 7 12 down overlay
                centered color white/cyan width 80.
      
     
form vproamx      label "Codigo"
     produ.pronom  no-label format "x(23)"
     vprotot1 with frame f-produ centered color message side-label
                        row 6 no-box width 81.
form vetbcod label "Filial" colon 15
    estab.etbnom  no-label
    cgc-admcom    label "Fornecedor" colon 15
    forne.fornom no-label
    vnumero       colon 15
    vserie        label "Serie"
    vhiccod       label "Op. Fiscal" format "9999" colon 15 
    opcom.opcnom  no-label
    vpladat colon 15
    vrecdat colon 40
    vdesc label "% Desc."
    vdesval label "Valor Desc." colon 15
    vfrecod label "Transp." colon 15
    frete.frenom no-label
    vfrete label "Frete"
      with frame f1 side-label width 80 row 4 color white/cyan.

 
def var vbase_subst like plani.bsubst.
def var v_subst     like plani.icmssubst.
def var voutras_acess like plani.platot.


form vbicms  
     vicms  
     vbase_subst   label "Base Icms Subst" 
     v_subst       label "Valor Substituicao" 
     vprotot       label "Tot.Prod." 
     vfre          label "Frete"  
     voutras_acess label "Outras Despesas Acessorias"
     vipi          label "IPI"
     vplatot       label "Total" format ">>>,>>>,>>>.99"
        with frame f2 side-label row 12 width 80 overlay color white/cyan.
do:
    clear frame f1 no-pause.
    clear frame f2 no-pause.
    clear frame f-produ no-pause.
    clear frame f-produ1 no-pause.
    clear frame f-produ2 no-pause.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause .
    hide frame f-produ2  no-pause.
    hide frame f1 no-pause.
    hide frame f2 no-pause.
    vetbcod = 996.
    
    find estab where estab.etbcod = vetbcod no-lock.
    for each w-movim: 
        delete w-movim.
    end.
    for each wprodu:
        delete wprodu.
    end.

    display vetbcod
            estab.etbnom with frame f1.
    
    cgc-admcom = "". 

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
    
    vforcod = forne.forcod.
    
    vserie = "1".
    display vserie with frame f1.
    update vnumero with frame f1.
    
    find first opcom where opcom.movtdc = 10 no-lock.
    vhiccod = opcom.opccod.
    display vnumero with frame f1.
    do on error undo, retry:
        update vhiccod with frame f1.
        find opcom where opcom.opccod = vhiccod no-lock no-error.
        if not avail opcom
        then do:
            message "Operacao Fiscal Invalida".
            pause.
            undo, retry.
        end.
        if opcom.opccod = "2551" or
           opcom.opccod = "1551" or 
           opcom.opccod = "1102" or
           opcom.opccod = "2102" or
           opcom.opccod = "1557" or
           opcom.opccod = "2557"
        then.
        else do:
            message "Operacao Fiscal Invalida".
            pause.
            undo, retry.
        end.
           
        
    end.
    display opcom.opcnom no-label with frame f1.
     

    find first plani where plani.numero = vnumero and
                     plani.emite  = vforcod and
                     plani.desti  = estab.etbcod and
                     plani.serie  = vserie and
                     plani.etbcod = estab.etbcod and
                     plani.movtdc = 10 no-lock no-error.
    if avail plani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.
    vpladat = ?.

    find tipmov where tipmov.movtdc = 10 no-lock.
    vdesc = 0.
    do on error undo:
        update vpladat
               vrecdat with frame f1.
        if vpladat > today or vpladat = ? or
           vrecdat < vpladat
        then do:
            message "Data Invalida".
            undo, retry.
        end.
    end.
    update vdesc
           vdesval
           vfrecod with frame f1.
    find frete where frete.frecod = vfrecod no-lock.
    display frete.frenom no-label with frame f1.
    update vfrete with frame f1.
    vvencod = vfrecod.
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
           vprotot = 0.
    do on error undo:
        hide frame f-obs no-pause.
        update vbicms label "Base Icms"
               vicms  label "Valor Icms" with frame f2.
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
        else do:
            if (vbicms * 0.35) < vicms
            then do:
                message "Valor do icms nao confere com Base de Calculo".
                undo, retry.
            end.
        end.
        
        hide frame f-obs no-pause.

    end.
    update vbase_subst 
           v_subst     
           vprotot
           vfre        
           voutras_acess
           vipi with frame f2.
    
    do on error undo:
        update vplatot with frame f2. 
        if vbicms > vplatot 
        then do: 
            vtipo = 1. 
            vobs[1] = "". 
            update vobs[1] label "Obs" format "x(21)"
                        with frame f-obs 
                                side-label centered color message.
            if substring(vobs[1],04,1) = "" 
            then do:
                message "Informar Observacao".
                undo, retry.
            end.
        end. 
       
        
        if vplatot <> (vprotot + voutras_acess + vfre + vipi + v_subst)
        then do:    
            message "aqui". pause.
            message "Valor Total da Nota nao fecha". 
            undo, retry.
        end.
        
         
    end.
    
    
    hide frame f-obs no-pause.
    clear frame f-produ1 no-pause.
    
    bl-princ:
    repeat with 1 down:
        hide frame f-produ2 no-pause.
        vprotot1 = 0. 
        clear frame f-produ1 all no-pause.
        for each w-movim with frame f-produ1:
            find produ where recid(produ) = w-movim.wrec no-lock no-error.
            
            if not avail produ
            then next.
            
            display produ.procod
                    produ.pronom
                    w-movim.movqtm
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
        prompt-for vproamx go-on (F5 F6 F8 F9 F4 PF4
                                  F10 E e C c) with frame f-produ.
        if keyfunction(lastkey) = "end-error"
        then do:
            sresp = no.
            message "Confirma Geracao de Nota Fiscal" update sresp.
            if not sresp
            then do:
                for each w-movim:
                    do transaction:
                        delete w-movim.
                    end.
                end.
                vproamx = 0.
                hide frame f-produ1 no-pause.
                hide frame f-produ no-pause.
                undo, return.
            end.
            else do:
                find first w-movim no-error.
                if not avail w-movim 
                then leave bl-princ.
                else do:
                    if vprotot <> vprotot1
                    then do:
                        message "Total dos produtos nao confere".
                        undo, retry.
                    end.
                    else leave bl-princ.
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
            then do transaction:
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
                        produ.pronom
                        w-movim.movqtm
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
        find produ where produ.procod = input vproamx no-lock no-error.
        if not avail produ 
        then do:
            message "Produto nao Cadastrado".
            pause.
            undo, retry.
        end. 
        display produ.pronom when avail produ with frame f-produ.
        find estoq where estoq.etbcod = 999 and
                         estoq.procod = produ.procod no-lock no-error.
        if not available estoq
        then do:
            message "Produto Sem Registro de Armazenagem". pause. undo.
        end.

        display produ.pronom when avail produ with frame f-produ.
        display produ.pronom when avail produ with frame f-produ1.
        vmovqtm = 0. vsubtotal = 0. vsub = 0. vcria = no.
        find first w-movim where w-movim.wrec = recid(produ) no-error.
        if not avail w-movim
        then do transaction:
            create w-movim.
            assign w-movim.wrec = recid(produ).
            vcria = yes.
        end.
        vmovqtm = w-movim.movqtm.
        vsub    = w-movim.subtotal.
        do transaction:
            update w-movim.movqtm with frame f-produ1.
            w-movim.movpc = estoq.estcusto.
            w-movim.movqtm = VMOVQTM + w-movim.movqtm.
            display w-movim.movqtm with frame f-produ1.
            update w-movim.subtotal with frame f-produ1.
            w-movim.subtotal = vsub + w-movim.subtotal.
            w-movim.movpc = (w-movim.subtotal / w-movim.movqtm) -
                        ((w-movim.subtotal / w-movim.movqtm) * (vdesc / 100)).
            display w-movim.movpc with frame f-produ1.
            if forne.ufecod = "RS"
            then w-movim.movalicms = 17.
            else w-movim.movalicms = 12.
            update  w-movim.movalicms
                    w-movim.movalipi
                    w-movim.movfre with frame f-produ1.
            if vipi > 0 and
            w-movim.movalipi = 0
            then do:
                message "Percentual de IPI Incorreto".
                pause.
                undo, retry. 
            end. 
            if vicms > 0 and
            w-movim.movalicms = 0
            then do:
                message "Percentual de ICMS Incorreto".
                pause.
                undo, retry. 
            end. 
           
            vdifipi = 0.
            if int(((vipi / (vprotot + vfre)) * 100)) <> 
               int(w-movim.movalipi)
            then do: 
           
                vdifipi = int(((vipi / (vprotot + vfre)) * 100)) - 
                          int(w-movim.movalipi).
                if vdifipi < 0
                then vdifipi = vdifipi * -1.

            end.

            if vdifipi >= 10
            then do:
                message "Percentual de IPI diferente do corpo da nota".
                pause.
                undo, retry.
            end.
               
               

                    
        end.
        vprotot1 = 0.
        for each w-movim:
            vprotot1 = vprotot1 + (w-movim.movqtm * w-movim.movpc).
        end.

        vprotot1 = 0.
        clear frame f-produ1 all no-pause.
        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = w-movim.wrec no-lock no-error.
            display produ.procod
                    produ.pronom
                    w-movim.movqtm
                    w-movim.subtotal
                    w-movim.movpc
                    w-movim.movalicms
                    w-movim.movalipi
                    w-movim.movfre with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot1 = vprotot1 + w-movim.subtotal.
            display vprotot1 with frame f-produ.
        end.
    end.
    end.
    if not sresp
    then undo, retry.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    hide frame f2 no-pause.
    if v-ok = yes
    then undo, leave.
    
    
    
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
            do transaction:
                delete w-movim.
            end.
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
               plani.datexp   = today
               plani.horincl  = time
               plani.hiccod   = int(vhiccod)
               plani.notsit   = no
               plani.outras = voutras
               plani.isenta = plani.platot - plani.outras - plani.bicms.
               if plani.descprod = 0
               then plani.descprod = vdesval.
               if vtipo = 0
               then plani.notobs[3] = "".
               else plani.notobs[3] = vobs[vtipo].
    
    end.

    /****************** atualiza custos ********************/
    qtd_total = 0.
    for each w-movim:
        qtd_total = qtd_total + w-movim.movqtm.
    end.    
    
    frete_unitario = vfre / qtd_total.  
    
    for each w-movim:
        if w-movim.movfre > 0
        then vcusto = (w-movim.movpc + w-movim.movfre) +
                      ( (w-movim.movpc + w-movim.movfre) *
                        (w-movim.movalipi / 100)).
        else vcusto = (w-movim.movpc + frete_unitario) +
                      ( (w-movim.movpc + frete_unitario) *
                        (w-movim.movalipi / 100)).

        find produ where recid(produ) = w-movim.wrec no-lock no-error.
            
        for each estoq where estoq.procod = produ.procod.
            estoq.estcusto = vcusto.
        end.
    end.
 
    

        
    
    for each w-movim:
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movim.wrec no-lock no-error.
        if not avail produ
        then next.
        find first plani where plani.etbcod = estab.etbcod and
                               plani.placod = vplacod no-lock.
       
        do transaction:
            create movim.
            ASSIGN movim.movtdc = plani.movtdc
                   movim.PlaCod = plani.placod
                   movim.etbcod = plani.etbcod
                   movim.movseq = vmovseq
                   movim.procod = produ.procod
                   movim.movqtm = w-movim.movqtm
                   movim.movpc  = w-movim.movpc
                   movim.MovAlICMS = w-movim.movalicms
                   movim.MovAlIPI  = w-movim.movalipi
                   movim.movdev    = w-movim.movfre 
                   movim.movdat    = plani.pladat
                   movim.MovHr     = int(time)
                   movim.datexp    = plani.datexp
                   movim.desti     = plani.desti
                   movim.emite     = plani.emite.
            delete w-movim.
        end.
    end.
    

     message "Nota Fiscal Incluida". pause.
    
    for each w-movim: 
        delete w-movim.
    end.
end.
