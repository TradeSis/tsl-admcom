{admcab.i}
def var vlfrete like plani.frete.
def var vlipi   as dec.
def var vacrec  as dec.
def var vcusto  as dec.
def var vsubtotal like  movim.movpc.
def var vmovqtm   like  movim.movqtm.
def var vvencod   like  plani.vencod.
def var vciccgc   like  clien.ciccgc.
def var valicota  like  plani.alicms format ">9,99".
def var vpladat   like  plani.pladat.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms .
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vacfprod  like  plani.acfprod.
def var vfrete    like  plani.frete.
def var vseguro   like  plani.seguro.
def var vdesacess like  plani.desacess.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    like  plani.serie.
def var vopccod   like  plani.opccod.
def var vprocod   like  produ.procod.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotal      like plani.platot.

def buffer bplani for plani.

def  temp-table w-movim
               field wrec    as   recid
               /*
               field movpdesc  as decimal format ">9.999"
               */
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc
               field movpc     as decimal format ">,>>9.99"
               field movalicms like movim.movalicms
               field movalipi  like movim.movalipi.

form produ.procod
     produ.pronom format "x(30)"
/*
     w-movim.movpdesc column-label "Desc"
     */
     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
     w-movim.subtotal format ">>,>>9.99" column-label "Total"
     w-movim.movalicms column-label "ICMS"
     w-movim.movalipi  column-label "IPI"
     w-movim.movpc  format ">,>>9.99" column-label "Custo"
     with frame f-produ1 row 16 2 down overlay
                centered color white/cyan width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 15 no-box width 81 overlay.

form
    vvencod  label "Planilha" colon 15
    estab.etbnom
    vciccgc        colon 15
    clien.clinom no-label format "x(20)"
    clien.ciccgc no-label
    vnumero       colon 15
    vserie
    vopccod       colon 15
/*     opcom.opcnom  */
    vpladat       colon 15
      with frame f1 side-label width 80 row 3.

form
    vbicms   colon 10
    vicms    colon 30
    vprotot1 colon 65
    vfrete   colon 10
    vipi     colon 30
    vdescpro colon 10
    vacfprod  colon 45
    vplatot  with frame f2 side-label row 11 width 80 overlay.

repeat:
    for each w-movim:
        delete w-movim.
    end.
    clear frame f1 no-pause.
    clear frame f-produ1 no-pause.
    hide frame f2 no-pause.
    /* find first opcom where opcom.movtdc = 4 no-lock.  */
    find estab where estab.etbcod = setbcod no-lock.
    display
        estab.etbnom with frame f1.
    vvencod = 0.
    update vvencod with frame f1.
    update vciccgc with frame f1.
    find last clien where clien.ciccgc = vciccgc no-lock no-error.
    if not avail clien
    then do:
        message "Fornecedor nao cadastrado".
        undo, retry.
    end.
    display clien.clinom with frame f1.

    vserie = "m1".
    display vserie with frame f1.
    update vnumero with frame f1.
    find plani where plani.numero = vnumero and
                     plani.emite  = clien.clicod and
                     plani.movtdc = 4 and
                     plani.serie = "m1" and
                     plani.etbcod = estab.etbcod no-lock no-error.
    if avail plani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.
    /* vopccod = opcom.opccod. */
    do on error undo, retry:
        update vopccod with frame f1.
        /*
        find opcom where opcom.opccod = vopccod no-lock no-error.
        if not avail opcom
        then do:
            message "Operacao Comercial Nao Cadastrada".
            undo, retry.
        end.
        if opcom.movtdc <> 4
        then do:
            message "Operacao nao de Entrada".
            undo, retry.
        end.
        disp opcom.opcnom with frame f1.
        */
        find tipmov where tipmov.movtdc = 4 no-lock.
        update vpladat
                with frame f1.
    end.
    do on error undo, retry:
    assign vbicms  = 0
           vicms   = 0
           vfrete  = 0
           vprotot1 = 0
           vipi    = 0
           vdescpro = 0
           vacfprod = 0
           vplatot  = 0
           vtotal = 0.
        update
            vbicms with frame f2.
        do on error undo:
            update vicms with frame f2.
            if vicms = 0 and
               vbicms = 0
            then do:
            end.
            else do:
                valicota = vicms * 100 / (vbicms * (1 - (0 / 100))).
                valicota = round(valicota,1).
                if valicota <> 12.00
                then if valicota <> 17.00
                    then do:
                        message "Valor Do ICMS nao Confere com a Base".
                        undo, retry.
                    end.
            end.
        end.

    vprotot1 = vbicms.
    update
        vprotot1
        vfrete
        vipi
        vdescpro
        vacfprod with frame f2.
    vplatot = (vbicms + vfrete + vipi)  - vdescpro.
    update vplatot with frame f2.
    vtotal = vipi + vdesacess + vseguro + vfrete +
             vprotot - vdescpro.
    clear frame f-produ1 no-pause.
    do on error undo:
    repeat with 1 down:
        hide frame f-produ2 no-pause.
        prompt-for vprocod go-on (F5 F6 F8 F9 F4 PF4
                            F10 E e C c) with frame f-produ.

        if lastkey = keycode("c") or lastkey = keycode("C")
        then do with frame f-produ2:
            clear frame f-produ2 all no-pause.
            for each w-movim:
                find produ where recid(produ) = w-movim.wrec no-lock.
                disp produ.procod
                     produ.pronom format "x(30)"
                     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
                     w-movim.subtotal
                            format ">>,>>9.99" column-label "Total"
                     w-movim.movalicms column-label "ICMS"
                     w-movim.movalipi  column-label "IPI"
                     w-movim.movpc  format ">,>>9.99" column-label "Custo"
                            with frame f-produ2 row 5 9 down  overlay
                              centered color message width 80.
                down with frame f-produ2.
                pause 0.
            end.
            pause.
            undo.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            message "Confirma Geracao de Nota Fiscal" update sresp.
            if not sresp
            then do:
                for each w-movim:
                    delete w-movim.
                end.
                vprocod = 0.
                hide frame f-produ1 no-pause.
                hide frame f-produ no-pause.
                undo, leave.
            end.
            else leave.
        end.
        if lastkey = keycode("e") or lastkey = keycode("E")
        then do:
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
                then do:
                    delete w-movim.
                end.
                else w-movim.movqtm = w-movim.movqtm - vqtd.
                hide frame f-exclusao no-pause.
            end.
            vprotot = 0.
            clear frame f-produ1 all no-pause.
            for each w-movim with frame f-produ1:
                find produ where recid(produ) = wrec no-lock.
                display produ.procod
                        produ.pronom
                /*
                        w-movim.movpdesc
                        */
                        w-movim.movqtm
                        w-movim.movpc
                        w-movim.movalicms
                        w-movim.movalipi
                        w-movim.subtotal
                        with frame f-produ1.
                down with frame f-produ1.
                pause 0.
                vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
                display vprotot with frame f-produ.
            end.
            next.
        end.
        vant = no.
            find produ where produ.procod = input vprocod no-lock no-error.
            if not avail produ
            then do:
                message "Produto nao Cadastrado".
                undo.
            end.
        else vant = yes.
        display  produ.pronom with frame f-produ.
        find estoq where estoq.etbcod = setbcod and
                         estoq.procod = produ.procod no-lock no-error.

        if not available estoq
        then do:
            bell.
            message "Produto Sem Registro de Armazenagem".
            pause.
            undo.
        end.

        display  produ.pronom with frame f-produ.
        display produ.pronom with frame f-produ1.

        vmovqtm = 0.
        vsubtotal = 0.
        find first w-movim where w-movim.wrec = recid(produ) no-lock no-error.
        if not avail w-movim
        then do:
            create w-movim.
            assign w-movim.wrec = recid(produ).
        end.
        else assign vmovqtm = w-movim.movqtm
                    vsubtotal = w-movim.subtotal.

        /*
        w-movim.movpdesc = 0.
        update  w-movim.movpdesc with frame f-produ1.
        */
        update  w-movim.movqtm validate(w-movim.movqtm > 0,
                         "Quantidade Invalida") with frame f-produ1.
        update  w-movim.subtotal validate(w-movim.subtotal > 0,
                         "Total dos Produtos Invalido") with frame f-produ1.
        update  w-movim.movalicms
                w-movim.movalipi with frame f-produ1.
        vprotot = 0.
        w-movim.movqtm = vmovqtm + w-movim.movqtm.
        w-movim.subtotal = vsubtotal + w-movim.subtotal.
        w-movim.movpc = w-movim.subtotal / w-movim.movqtm.
        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = wrec no-lock.
            display produ.procod
                    produ.pronom
            /*
                    w-movim.movpdesc
                    */
                    w-movim.movqtm
                    w-movim.movpc
                    w-movim.movalicms
                    w-movim.movalipi
                    w-movim.subtotal
                            with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot = vprotot + w-movim.subtotal.
            display vprotot with frame f-produ.
        end.
    end.
    if not sresp
    then do:
        undo, retry.
        leave.
    end.
    end.
    if vprotot <> vprotot1
    then do:
        bell.
        message "Valor Total Dos Produtos Nao Confere".
        undo, retry.
    end.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    hide frame f2 no-pause.
end.
    /*
    do for planum on endkey undo, leave:

        find last planum no-error.
        if available planum
        then planum.pncod  = planum.pncod  + 1.
        else do:
            create planum.
            assign planum.pncod  = 1
                   planum.numero = 1.
        end.
        assign vplacod = planum.pncod.
        find last planum no-lock.
    end.  */
    find last bplani where bplani.etbcod = estab.etbcod and
                           bplani.placod <> ? no-lock no-error.
    if avail bplani
    then vplacod = bplani.placod + 1.
    else vplacod = 1.
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



    do on error undo:
        create plani.
        assign plani.etbcod   = estab.etbcod .
               plani.placod   = vplacod      .
               plani.protot   = vprotot1     .
               plani.emite    = clien.clicod .
               plani.bicms    = vbicms       .
               plani.icms     = vicms        .
               plani.frete    = vfrete .
               plani.alicms   = plani.icms * 100 / (plani.bicms *
                                (1 - (0 / 100))) .
               plani.descpro  = vdescpro         .
               plani.acfprod  = vacfprod         .
               plani.frete    = vfrete           .
               plani.seguro   = vseguro          .
               plani.desacess = vdesacess        .
               plani.ipi      = vipi             .
               plani.platot   = vplatot          .
               plani.serie    = "M1"             .
               plani.numero   = vnumero          .
               plani.movtdc   = tipmov.movtdc    .
               plani.desti    = estab.etbcod     .
               plani.pladat   = vpladat          .
               plani.modcod   = tipmov.modcod    .
               plani.vencod   = vvencod          .
               plani.notfat   = clien.clicod      .
               plani.dtinclu  = today             .
               plani.horincl  = time             .
               plani.notsit   = no              .
               plani.outras = plani.frete  +
                              plani.seguro +
                              plani.vlserv +
                              plani.desacess +
                              plani.ipi   +
                              plani.icmssubst    .
              plani.isenta = plani.platot - plani.outras - plani.bicms.
    end.

    for each w-movim:
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movim.wrec no-lock.
        find plani where plani.etbcod = estab.etbcod and
                         plani.placod = vplacod no-lock.
        /*
        plani.protot = plani.protot + (w-movim.movqtm * w-movim.movpc).
        */

        create movim.
        ASSIGN movim.movtdc = plani.movtdc
               movim.PlaCod = plani.placod
               movim.etbcod = plani.etbcod
               movim.movseq = vmovseq
               movim.procod = produ.procod
               movim.movqtm = w-movim.movqtm
               movim.movpc  = w-movim.movpc
               movim.emite = plani.emite
               movim.desti = plani.desti
               /*
               movim.movpdesc = w-movim.movpdesc
               movim.movipi   =
               movim.MovICMS  =
               */
               movim.MovAlICMS = w-movim.movalicms
               movim.MovAlIPI  = w-movim.movalipi
               movim.MovHr     = int(time).
        /*
        vlfrete = 0.
        vlipi   = 0.
        vacrec  = 0.
        vcusto  = 0.
        vlfrete = (plani.frete / plani.protot) * movim.movpc.
        vlipi   = (movim.movalipi / 100) * movim.movpc.
        vacrec  = (plani.acfprod / plani.protot) * movim.movpc.
        vicms   = (movim.movalicms / 100) * movim.movpc.
        vcusto  =  movim.movpc + vlfrete + vlipi + vacrec - vicms.
        find estoq where estoq.etbcod = movim.etbcod and
                         estoq.procod = movim.procod.
        assign estoq.estcusto = vcusto.
        run atuest.p (input recid(movim),
                      input "I",
                      input 0).
        */
    end.
end.
