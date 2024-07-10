{admcab.i}
{defp.i}
def temp-table tt-plani like plani.
def temp-table tt-movim like movim.
def temp-table tt-titulo like titulo.
def temp-table tt-btitulo like titulo.
def temp-table tt-titctb like titctb.
def buffer bliped for liped.
def var vtipo as int format "99".
def var vdesval like plani.platot.
def var vobs as char format "x(14)" extent 5.
def var v-ped as int.
def temp-table waux
    field auxrec as recid.
def var vnum like pedid.pednum.
form tt-titulo.titpar
     tt-titulo.titnum
     prazo
     tt-titulo.titdtven
     tt-titulo.titvlcob with frame ftitulo down centered color white/cyan.
form produ.procod
     produ.pronom format "x(23)"
     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
     w-movim.subtotal  format ">>>,>>9.99" column-label "Subtot"
     w-movim.movpc  format ">,>>9.99" column-label "V.Unit."
     w-movim.movalicms column-label "ICMS"
     w-movim.movalipi  column-label "IPI"
     with frame f-produ1 row 7 12 down overlay
                centered color white/cyan width 80.
form vprocod      label "Codigo"
     produ.pronom  no-label format "x(23)"
     vprotot1 with frame f-produ centered color message side-label
                        row 6 no-box width 81.
form estab.etbcod label "Filial" colon 15
    estab.etbnom  no-label
    vforcod       label "Fornecedor" colon 15
    forne.fornom no-label
    vnumero       colon 15
    vserie
    /* vhiccod       label "Op. Fiscal" format "999" colon 15 */
    vpladat colon 15
    vrecdat colon 40
    vdesc label "% Desc."
    vdesval label "Valor Desc." colon 15
    vfrecod label "Transp." colon 15
    frete.frenom no-label
    vfrete label "Frete"
      with frame f1 side-label width 80 row 4 color white/cyan.
    form vbicms 
        vicms
        vipi
        voutras 
        vfre    label "Frete"
        vacr    label "Acresc."
        vprotot label "Tot.Prod."
        vplatot label "Total" format ">>>,>>>,>>>.99"
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
    prompt-for estab.etbcod with frame f1.
    find estab using estab.etbcod no-lock.
    for each w-movim:
        do transaction:
            delete w-movim.
        end.
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
    if vetbcod = 990
    then do:
        message "Operacao Invalida para Matriz". pause.
        undo, leave.
    end.
    update vforcod with frame f1.
    find forne where forne.forcod = vforcod no-lock no-error.
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
    display forne.fornom when avail forne with frame f1.
    run nffped.p (input recid(forne),
                  output vped).
    vserie = "U".
    display vserie with frame f1.
    update vnumero
           vserie
           /* vhiccod */ with frame f1.
    find first tt-plani where tt-plani.numero = vnumero and
                     tt-plani.emite  = vforcod and
                     tt-plani.desti  = estab.etbcod and
                     tt-plani.serie  = vserie and
                     tt-plani.etbcod = estab.etbcod and
                     tt-plani.movtdc = 4 no-lock no-error.
    if avail tt-plani
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
        if vpladat > today or /* vpladat < today - 30 or */ vpladat = ?
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
        
        hide frame f-obs no-pause.

    end.
    update
           vipi   label "IPI"
           voutras
           vfre   label "Frete"
           vacr   
           vprotot with frame f2.
    
    do on error undo:
       update  vplatot with frame f2.
       if vbicms > vplatot
       then do:
           vtipo = 1.
           vobs[1] = "".
           update vobs[1] label "Obs" format "x(21)"
                        with frame f-obs side-label
                                                centered color message.
           if substring(vobs[1],04,1) = "" 
           then do:
               message "Informar Observacao".
               undo, retry.
           end.
       end.
       else do:
           if (vbicms + vipi + vfrete + voutras + vacr) <> vplatot
           then do:
              message "Valor nao confere".
              undo, retry.
           end. 
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
            find produ where recid(produ) = w-movim.wrec no-lock.
            display produ.procod
                    produ.pronom
                    w-movim.movqtm
                    w-movim.subtotal
                    w-movim.movpc
                    w-movim.movalicms
                    w-movim.movalipi with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot1 = vprotot1 + (w-movim.movqtm * w-movim.movpc).
            display vprotot1 with frame f-produ.
        end.
        prompt-for vprocod go-on (F5 F6 F8 F9 F4 PF4
                                  F10 E e C c) with frame f-produ.
        if keyfunction(lastkey) = "end-error"
        then do:
            sresp = yes.
            message "Confirma Geracao de Nota Fiscal" update sresp.
            if not sresp
            then do:
                for each w-movim:
                    do transaction:
                        delete w-movim.
                    end.
                end.
                vprocod = 0.
                hide frame f-produ1 no-pause.
                hide frame f-produ no-pause.
                undo, return.
            end.
            else do:
                vprotot1 = vprotot1 - vdesval.
                if vprotot <> vprotot1
                then do:
                    message "Total dos produtos nao confere".
                    pause.
                    hide frame f-produ1 no-pause.
                    hide frame f-produ no-pause.
                    undo, retry.
                end.
                else leave.
            end.
        end.
        if lastkey = keycode("c") or lastkey = keycode("C")
        then do with frame f-produ2:
            clear frame f-produ2 all no-pause.
            for each w-movim:
                find produ where recid(produ) = w-movim.wrec no-lock.
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
                        w-movim.movalipi with frame f-produ1.
                down with frame f-produ1.
                pause 0.
                vprotot1 = vprotot1 + (w-movim.movqtm * w-movim.movpc).
                display vprotot1 with frame f-produ.
            end.
            next.
        end.
        vant = no.
        find produ where produ.procod = input vprocod no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao Cadastrado".
            undo, retry.
        end.
        else vant = yes.
        display  produ.pronom with frame f-produ.
        find estoq where estoq.etbcod = 999 and
                         estoq.procod = produ.procod no-lock no-error.
        if not available estoq
        then do:
            message "Produto Sem Registro de Armazenagem". pause. undo.
        end.
        display  produ.pronom with frame f-produ.
        display produ.pronom with frame f-produ1.
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
                    w-movim.movalipi with frame f-produ1.
        end.
        vprotot1 = 0.
        for each w-movim:
            vprotot1 = vprotot1 + (w-movim.movqtm * w-movim.movpc).
        end.


        for each w-movim:
            vcusto = w-movim.movpc.
            if vbicms <> 0
            then do:
                vcusto = vcusto +
                    (w-movim.movpc * ((vbicms / (vbicms - vacr)) - 1)).
            end.
        end.

        vprotot1 = 0.
        clear frame f-produ1 all no-pause.
        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = w-movim.wrec no-lock.
            display produ.procod
                    produ.pronom
                    w-movim.movqtm
                    w-movim.subtotal
                    w-movim.movpc
                    w-movim.movalicms
                    w-movim.movalipi with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot1 = vprotot1 + w-movim.subtotal.
            display vprotot1 with frame f-produ.
        end.
    end.
    if not sresp
    then undo, retry.
    end.
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
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.cxacod   = frete.forcod
               tt-plani.placod   = vplacod
               tt-plani.protot   = vprotot
               tt-plani.emite    = vforcod
               tt-plani.bicms    = vbicms
               tt-plani.icms     = vicms
               tt-plani.descpro  = vprotot * (vdesc / 100)
               tt-plani.acfprod  = vacfprod
               tt-plani.frete    = vfre
               tt-plani.seguro   = vseguro
               tt-plani.desacess = vdesacess
               tt-plani.ipi      = vipi
               tt-plani.platot   = /* vbicms + voutras + vipi */ vplatot
               tt-plani.serie    = vserie
               tt-plani.numero   = vnumero
               tt-plani.movtdc   = tipmov.movtdc
               tt-plani.desti    = estab.etbcod
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = 4
               tt-plani.vencod   = vvencod
               tt-plani.notfat   = vforcod
               tt-plani.dtinclu  = vrecdat
               tt-plani.pladat   = vpladat
               tt-plani.DATEXP   = today
               tt-plani.horincl  = time
               tt-plani.hiccod   = vhiccod
               tt-plani.notsit   = no
               tt-plani.outras = voutras
               tt-plani.isenta = tt-plani.platot - tt-plani.outras -                                  tt-plani.bicms.
               if tt-plani.descprod = 0
               then tt-plani.descprod = vdesval.
               if vtipo = 0
               then tt-plani.notobs[3] = "".
               else tt-plani.notobs[3] = vobs[vtipo].
    
    end.
    for each w-movim:
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movim.wrec no-lock.
        find first tt-plani where tt-plani.etbcod = estab.etbcod and
                                  tt-plani.placod = vplacod no-lock.
        hide frame f-l1 no-pause.
        hide frame f-l2 no-pause.
        hide frame f-l3 no-pause.
        do transaction:
            create tt-movim.
            ASSIGN tt-movim.movtdc = tt-plani.movtdc
                   tt-movim.PlaCod = tt-plani.placod
                   tt-movim.etbcod = tt-plani.etbcod
                   tt-movim.movseq = vmovseq
                   tt-movim.procod = produ.procod
                   tt-movim.movqtm = w-movim.movqtm
                   tt-movim.movpc  = w-movim.movpc
                   tt-movim.MovAlICMS = w-movim.movalicms
                   tt-movim.MovAlIPI  = w-movim.movalipi
                   tt-movim.movdat    = tt-plani.pladat
                   tt-movim.MovHr     = int(time)
                   tt-movim.DATEXP    = tt-plani.datexp.
            delete w-movim.
        end.
    end.
    vezes = 0. prazo = 0.
    find first tt-plani where tt-plani.etbcod = estab.etbcod and
                              tt-plani.placod = vplacod no-lock.
    update vezes label "Vezes"
                with frame f-tit width 80 side-label centered color white/red.
    if tt-plani.platot = 0
    then vtotpag = tt-plani.protot.
    else vtotpag = tt-plani.platot.

    update vtotpag with frame f-tit.
    
    if vtotpag < (tt-plani.protot + tt-plani.ipi - vdesval - tt-plani.descprod)
    then do:
        message "Verifique os valores da nota".
        undo, retry.
    end.




    do i = 1 to vezes:
        do transaction:
            create tt-titulo.
            assign tt-titulo.etbcod = tt-plani.etbcod
                   tt-titulo.titnat = yes
                   tt-titulo.modcod = "DUP"
                   tt-titulo.clifor = forne.forcod
                   tt-titulo.titsit = "lib"
                   tt-titulo.empcod = wempre.empcod
                   tt-titulo.titdtemi = tt-plani.pladat
                   tt-titulo.titnum = string(tt-plani.numero)
                   tt-titulo.titpar = i.
            if prazo <> 0
            then assign tt-titulo.titvlcob = vtotpag
                        tt-titulo.titdtven = titdtemi + prazo.
            else assign tt-titulo.titvlcob = vtotpag / vezes
                        tt-titulo.titdtven = tt-titulo.titdtemi + (30 * i).
        end.
    end.
    vsaldo = vtotpag.
    for each tt-titulo where tt-titulo.empcod = wempre.empcod and
                          tt-titulo.titnat = yes and
                          tt-titulo.modcod = "DUP" and
                          tt-titulo.etbcod = estab.etbcod and
                          tt-titulo.clifor = forne.forcod and
                          tt-titulo.titnum = string(tt-plani.numero).
        display tt-titulo.titpar
                tt-titulo.titnum
                    with frame ftitulo down centered
                            color white/cyan.
        prazo = 0.
        update prazo with frame ftitulo.
        do transaction:
            tt-titulo.titdtven = vpladat + prazo.
            tt-titulo.titvlcob = vsaldo.
            update tt-titulo.titdtven
                   tt-titulo.titvlcob with frame ftitulo no-validate.
        end.
        vsaldo = vsaldo - tt-titulo.titvlcob.

        find tt-titctb where tt-titctb.forcod = tt-titulo.clifor and
                          tt-titctb.titnum = tt-titulo.titnum and
                          tt-titctb.titpar = tt-titulo.titpar no-error.
        if not avail tt-titctb
        then do transaction:
            create tt-titctb.
            ASSIGN tt-titctb.etbcod   = tt-titulo.etbcod
                   tt-titctb.forcod   = tt-titulo.clifor
                   tt-titctb.titnum   = tt-titulo.titnum
                   tt-titctb.titpar   = tt-titulo.titpar
                   tt-titctb.titsit   = tt-titulo.titsit
                   tt-titctb.titvlpag = tt-titulo.titvlpag
                   tt-titctb.titvlcob = tt-titulo.titvlcob
                   tt-titctb.titdtven = tt-titulo.titdtven
                   tt-titctb.titdtemi = tt-titulo.titdtemi
                   tt-titctb.titdtpag = tt-titulo.titdtpag.
        end.
        down with frame ftitulo.
    end.
    if vfrete > 0
    then do transaction:
        create tt-btitulo.
        assign tt-btitulo.etbcod   = tt-plani.etbcod
               tt-btitulo.titnat   = yes
               tt-btitulo.modcod   = "FRE"
               tt-btitulo.clifor   = frete.forcod
               tt-btitulo.cxacod   = forne.forcod
               tt-btitulo.titsit   = "lib"
               tt-btitulo.empcod   = wempre.empcod
               tt-btitulo.titdtemi = vpladat
               tt-btitulo.titnum   = string(tt-plani.numero)
               tt-btitulo.titpar   = 1
               tt-btitulo.titnumger = string(tt-plani.numero)
               tt-btitulo.titvlcob = vfrete.
        update tt-btitulo.titdtven label "Venc.Frete"
               tt-btitulo.titnum   label "Controle"
                    with frame f-frete centered color white/cyan
                                    side-label row 15 no-validate.
    end.
    message "Nota Fiscal Incluida". pause.
    for each w-movim:
        do transaction:
            delete w-movim.
        end.
    end.
end.
