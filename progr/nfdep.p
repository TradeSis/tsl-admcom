{admcab.i}
def temp-table wcol
        field wcol as int format ">9".
def var vpath as char format "x(30)".
def var vcol as i.
def var vlei            as char format "x(26)".
def var vetb            as i    format ">>9".
def var vcod            as i    format "9999999".
def var vcod2           as i    format "999999".
def var vqtd            as i    format "999999".
def var v-ok as log.
def var vmovqtm   like  movim.movqtm.
def var vemite    like  estab.etbcod.
def var vtrans    like  clien.clicod.
def var vsubtotal like  movim.movqtm.
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

def var vhiccod   like  plani.hiccod label "Op.Fiscal" initial 522.

def var vprocod   like  produ.procod.
def var vdown as i.
def var vant as l.
def var vi as int.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotal      like plani.platot.
def buffer bestab for estab.
def buffer bplani for plani.

def  temp-table w-movim
               field wrec    as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc
               field movpc     as decimal format ">,>>9.99".
/*                field movalicms like movim.movalicms
               field movalipi  like movim.movalipi.         */

form produ.procod
     produ.pronom format "x(30)"
/*
     w-movim.movpdesc column-label "Desc"
     */
     w-movim.movqtm format ">>>>9" column-label "Qtd"
     /* w-movim.movalicms column-label "ICMS"
     w-movim.movalipi  column-label "IPI"      */
     w-movim.movpc  format ">,>>9.99" column-label "V.Unit."
     w-movim.subtotal format ">>>,>>9.99" column-label "Total"
     with frame f-produ1 row 6 12 down overlay
                centered color white/cyan width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 5 no-box width 81.

form
    estab.etbcod  label "Emitente" colon 15
    estab.etbnom  no-label
    vetbcod        label "Destinatario" colon 15
    bestab.etbnom no-label format "x(20)"
/*     vtrans label "Transportador" colon 15
    clien.clinom                             */
    vserie  colon 15
    vnumero
/*    vopccod       colon 15*/
    vhiccod       format "999" colon 15
    /*opcom.opcnom*/
/*     opfis.opfnom no-label */
    vpladat       colon 15
      with frame f1 side-label color white/cyan width 80 row 4.
/*

form
    vbicms   colon 10
    vicms    colon 30
    vprotot1 colon 18
    vfrete   colon 18
    vipi     colon 30
    vdescpro colon 18
    vacfprod  colon 45
    vplatot  label "Total Geral"
                with frame f2 side-label row 10 width 80 overlay.  */
bl-princ:
repeat:
    for each w-movim:
        delete w-movim.
    end.
    clear frame f1 all no-pause.
    clear frame f2 all no-pause.
    clear frame f-produ all no-pause.
    clear frame f-produ1 all no-pause.
    clear frame f-produ2 all no-pause.
    clear frame f-exclusao all no-pause.
    hide frame f1 no-pause.
    hide frame f2 no-pause.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    hide frame f-produ2 no-pause.
    hide frame f-exclusao no-pause.
    /* hide frame f2 no-pause.
    find opcom where opcom.opccod = 25 no-lock.

    find opfis where opfis.opfcod = 522 no-lock. */
    disp vemite @ estab.etbcod with frame f1.
    prompt-for estab.etbcod with frame f1.
    vemite = input frame f1 estab.etbcod.
    {valetbnf.i estab vemite ""Emitente""}
    display estab.etbnom no-label with frame f1.
    update vetbcod  with frame f1.
    {valetbnf.i bestab vetbcod ""Destinatario""}

    display bestab.etbnom no-label with frame f1.

    /******** Pega a ultima nota e gera a numero *****/
    find last bplani where bplani.etbcod = estab.etbcod and
                           bplani.placod <= 500000 and
                           bplani.placod <> ? no-lock no-error.
    if not avail bplani
    then vplacod = 1.
    else vplacod = bplani.placod + 1.
    do on error undo:
        vserie = "U".
        update vserie with frame f1.
        if vserie = ""
        then do:
            bell.
            message "Serie deve ser U ou M1".
            undo, retry.
        end.
    end.

    find last plani use-index numero where plani.etbcod = estab.etbcod and
                                           plani.emite  = estab.etbcod and
                                           plani.serie  = vserie       and
                                           plani.movtdc <> 4 no-lock no-error.
    if not avail plani
    then vnumero = 1.
    else vnumero = plani.numero + 1.
    /************************************************/

    update vnumero
           vhiccod with frame f1.
    {valnumnf.i vnumero}
    
    find first plani where plani.numero = vnumero and
                     plani.emite  = estab.etbcod and
                     plani.serie  = vserie and
                     plani.etbcod = estab.etbcod and
                     plani.movtdc = 6  no-error.
    if avail plani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.
    /*
    vopccod = opcom.opccod.

    vopfcod = opfis.opfcod.
    */
    do on error undo, retry:
        /*update vopccod with frame f1.*/

        /*find opcom where opcom.opccod = vopccod no-lock no-error.
        if not avail opcom
        then do:
            message "Operacao Comercial Nao Cadastrada".
            undo, retry.
        end.
        /*
        disp opcom.opcnom with frame f1.*/

        update vopfcod with frame f1.
        find opfis where opfis.opfcod = vopfcod no-lock no-error.
        if not avail opfis
        then do:
            message "Operacao Comercial Nao Cadastrada".
            undo, retry.
        end.
        disp opfis.opfnom with frame f1.
        */
        find tipmov where tipmov.movtdc = 6  no-lock.
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
           /*
        update
            vbicms with frame f2.
        do on error undo:
            update vicms with frame f2.
            if vicms = 0 and
               vbicms = 0
            then do:
            end.
            else do:
                valicota = vicms * 100 / (vbicms * (1 - (tipmov.opcper / 100))).
                valicota = round(valicota,0).
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
        vacfprod  with frame f2. */
    vplatot = (vbicms + vfrete + vipi)  - vdescpro.
    /* update vplatot with frame f2. */
    vtotal = vipi + vdesacess + vseguro + vfrete +
             vprotot - vdescpro.


    repeat:
        update vcol label "Coletor" with frame f3 side-label centered.
        find first wcol where wcol.wcol = vcol no-error.
        if not avail wcol
        then do:
            create wcol.
            assign wcol.wcol = vcol.
        end.
    end.


    for each wcol:
       vpath = "h:\aplic\coletor\col" + string(wcol.wcol,"9") + "\coleta99.txt".
        input from value(vpath).
        repeat:
            import vlei.
            assign vetb = int(substring(string(vlei),4,2))
                   vcod = int(substring(string(vlei),14,7))
                   vcod2 = int(substring(string(vlei),14,6))
                   vqtd = int(substring(string(vlei),21,6)).
            find produ where produ.procod = vcod no-lock no-error.
            if not avail produ
            then find produ where produ.procod = vcod2 no-lock no-error.
            if not avail produ
            then next.
            find estoq where estoq.etbcod = 7 and
                             estoq.procod = produ.procod no-lock.
            find first w-movim where w-movim.wrec = recid(produ)
                                                    no-lock no-error.
            if not avail w-movim
            then do:
                create w-movim.
                assign w-movim.wrec = recid(produ)
                       w-movim.movpc = estoq.estcusto.
            end.
            w-movim.movqtm = vqtd.
            w-movim.subtotal = w-movim.subtotal +
                                            (w-movim.movpc * w-movim.movqtm).
        end.
    end.
    for each wcol:
        delete wcol.
    end.
    vprotot = 0.
    clear frame f-produ1 all no-pause.
    for each w-movim with frame f-produ1:
        find produ where recid(produ) = wrec no-lock.
        display produ.procod
                produ.pronom
                w-movim.movqtm
                w-movim.movpc
                w-movim.subtotal with frame f-produ1.
        down with frame f-produ1.
        pause 0.
        vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
        display vprotot with frame f-produ.
    end.



    clear frame f-produ1 no-pause.
    repeat with 1 down:
        hide frame f-produ2 no-pause.
        prompt-for vprocod go-on (F5 F6 F8 F9 F4 PF4
                            F10 E e C c) with frame f-produ.
        v-ok = no.
        if keyfunction(lastkey) = "end-error"
        then do:
            sresp = yes.
            message "Confirma Geracao de Nota Fiscal" update sresp.
            if not sresp
            then do:
                for each w-movim:
                    delete w-movim.
                end.
                vprocod = 0.
                hide frame f-produ1 no-pause.
                hide frame f-produ no-pause.
                v-ok = yes.
                undo, leave bl-princ.
            end.
            else leave.
        end.
        if lastkey = keycode("c") or lastkey = keycode("C")
        then do with frame f-produ2:
            clear frame f-produ2 all no-pause.
            for each w-movim:
                find produ where recid(produ) = w-movim.wrec no-lock.
                disp produ.procod
                     produ.pronom format "x(30)"
                     w-movim.movqtm format ">,>>9.99" column-label "Qtd"
                     w-movim.subtotal
                            format ">>>,>>9.99" column-label "Total"
                    /*  w-movim.movalicms column-label "ICMS"
                     w-movim.movalipi  column-label "IPI"     */
                     w-movim.movpc  format ">,>>9.99" column-label "Custo"
                            with frame f-produ2 row 5 9 down  overlay
                              centered color message width 80.
                down with frame f-produ2.
                pause 0.
            end.
            pause.
            undo.
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
                     w-movim.subtotal = w-movim.movqtm * w-movim.movpc.
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
                        /* w-movim.movalicms
                        w-movim.movalipi     */
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
        display produ.pronom with frame f-produ.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.

        if not available estoq
        then do:
            bell.
            message "Produto Sem Registro de Armazenagem".
            pause.
            undo.
        end.

        display produ.pronom with frame f-produ.
        display produ.pronom with frame f-produ1.
        vmovqtm = 0.
        vsubtotal = 0.
        find first w-movim where w-movim.wrec = recid(produ) no-lock no-error.
        if not avail w-movim
        then do:
            create w-movim.
            assign w-movim.wrec = recid(produ)
                   w-movim.movpc = estoq.estcusto.
        end.
        /*else assign vmovqtm = w-movim.movqtm
                    vsubtotal = w-movim.movqtm * w-movim.movpc.
        */
        vmovqtm = w-movim.movqtm.
        update  w-movim.movqtm validate(w-movim.movqtm > 0,
                         "Quantidade Invalida") with frame f-produ1.
        update w-movim.movpc with frame f-produ1.
        w-movim.movqtm = w-movim.movqtm + vmovqtm.
        vprotot = 0.
        /*
        w-movim.movqtm   = 1 + w-movim.movqtm.
        display w-movim.movqtm with frame f-produ1.
        */
        w-movim.subtotal = vsubtotal + (w-movim.movpc * w-movim.movqtm).

        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = wrec no-lock.
            display produ.procod
                    produ.pronom
            /*
                    w-movim.movpdesc
                    */
                    w-movim.movqtm
                    /*
                    w-movim.movalicms
                    w-movim.movalipi
                    */
                    w-movim.subtotal
                    w-movim.movpc
                            with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot = vprotot + w-movim.subtotal.
            display vprotot with frame f-produ.
        end.
    end.
    if not sresp
    then undo, retry.
    end.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    /* hide frame f2 no-pause. */
    /*do for planum on endkey undo, leave:

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
    end.*/
    if v-ok = yes
    then undo, retry.
    find last bplani where bplani.etbcod = estab.etbcod and
                           bplani.placod <= 500000 no-lock no-error.
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

    do on error undo:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.placod   = vplacod
               /* plani.protot   = vprotot */
               plani.emite    = estab.etbcod
               plani.bicms    = vbicms
               plani.icms     = vicms
               plani.frete    = vfrete
               plani.alicms   = plani.icms * 100 / (plani.bicms *
                                (1 - (0 / 100)))
               plani.descpro  = vdescpro
               plani.acfprod  = vacfprod
               plani.frete    = vfrete
               plani.seguro   = vseguro
               plani.desacess = vdesacess
               plani.ipi      = vipi
               /* plani.platot   = vprotot */
               plani.serie    = vserie
               plani.numero   = vnumero
               plani.movtdc   = 6
               plani.desti    = bestab.etbcod
               plani.pladat   = vpladat
               plani.modcod   = tipmov.modcod
               /* plani.opccod   = opcom.opccod
               plani.opfcod   = opfis.opfcod */

               plani.notfat   = bestab.etbcod
               plani.dtinclu  = today
               plani.horincl  = time
               plani.notsit   = no
               plani.hiccod   = vhiccod
               plani.nottran  = vtrans
               plani.outras = plani.frete  +
                              plani.seguro +
                              plani.vlserv +
                              plani.desacess +
                              plani.ipi   +
                              plani.icmssubst
              plani.isenta = plani.platot - plani.outras - plani.bicms.
    end.

    for each w-movim:
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movim.wrec no-lock.
        find plani where plani.etbcod = estab.etbcod and
                         plani.placod = vplacod .
        plani.protot = plani.protot + (w-movim.movqtm * w-movim.movpc).
        plani.platot = plani.platot + (w-movim.movqtm * w-movim.movpc).

        create movim.
        ASSIGN movim.movtdc = plani.movtdc
               movim.PlaCod = plani.placod
               movim.etbcod = plani.etbcod
               movim.movseq = vmovseq
               movim.procod = produ.procod
               movim.movqtm = w-movim.movqtm
               movim.movpc  = w-movim.movpc
               /*
               movim.movpdesc = w-movim.movpdesc
               movim.movipi   =
               movim.MovICMS  =
               movim.MovAlICMS = w-movim.movalicms
               movim.MovAlIPI  = w-movim.movalipi
               */
               movim.movdat    = plani.pladat
               movim.MovHr     = int(time).
               movim.desti     = plani.desti.
               movim.emite     = plani.emite.
        if plani.serie <> "M1"
        then run atuest.p (input recid(movim),
                           input "I",
                           input 0).
        delete w-movim.
    end.

    sresp = no.
    message "Confirma Emissao da Nota " update sresp.
    if sresp
    then run  imptra_l.p (input recid(plani)).

end.
