{admcab.i}

def buffer bliped for liped.
def new shared workfile  wfped
    field rec       as rec.
def var v-ped as int.
    
def var vnum like pedid.pednum.
def workfile wprodu
    field wpro like produ.procod
    field wqtd as int.
    
def temp-table waux
    field auxrec as recid.

def var vrec as recid.
def var vped like pedid.pednum.
def buffer cplani for plani.
def var i as i.
def var vezes as int format ">9".
def var prazo as int format ">>9".
def var v-ok as log.
def buffer bclien for clien.
def var vforcod like forne.forcod.
def var vmovqtm   like  movim.movqtm.
def var vvencod   like plani.vencod.
def var vsubtotal like  movim.movqtm.
def var valicota  like  plani.alicms format ">9,99" initial 17.
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
def var vhiccod   like  plani.hiccod initial 512.
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
               field movqtm    like movim.movqtm format ">>,>>9.99"
               field subtotal  like movim.movpc
               field movpc     as decimal format ">,>>9.99"
               field movalicms like movim.movalicms initial 17
               field movalipi  like movim.movalipi.
form titulo.titpar
     titulo.titnum
     titulo.titdtven
     titulo.titvlcob with frame ftitulo down centered color white/cyan.

form produ.procod
     produ.pronom format "x(30)"
/*
     w-movim.movpdesc column-label "Desc"
     */
     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
     w-movim.movpc  format ">,>>9.99" column-label "V.Unit."

     w-movim.movalicms column-label "ICMS"
     w-movim.movalipi  column-label "IPI"
     /*
     w-movim.subtotal format ">>,>>9.99" column-label "Total"
     */
     with frame f-produ1 row 7 12 down overlay
                centered color white/cyan width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 6 no-box width 81.

form
    estab.etbcod  label "Filial" colon 15
    estab.etbnom  no-label
    /* clien.ciccgc no-label */
    vforcod       label "Fornecedor" colon 15
    forne.fornom no-label
    vnumero       colon 15
    vserie
    /*
    vhiccod       label "Op. Fiscal" format "999" colon 15
    */
    /* opcom.opcnom*/
    /*
    vopfcod   label "Op.Fiscal"    colon 15
    opfis.opfnom no-label
    */
    vpladat colon 15
/*     vvencod  */
      with frame f1 side-label width 80 row 4 color white/cyan.

form
    vbicms   colon 10
    vicms    colon 30
    vprotot1 colon 65
    vfrete   colon 10
    vipi     colon 30
    vdescpro colon 10
    vacfprod  colon 45
    vplatot  with frame f2 side-label row 10 width 80 overlay.

do:
        for each wfped. delete wfped. end.
    for each w-movim:
        delete w-movim.
    end.
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
    /*
    find opcom where opcom.opccod = 20 no-lock.
    */
    prompt-for estab.etbcod with frame f1.
    find estab using estab.etbcod no-lock.
    display
        estab.etbcod
        estab.etbnom with frame f1.

    /******** Pega a ultima nota e gera a numero *****/
    find last plani use-index plani where plani.movtdc = 1 and
                          plani.etbcod = estab.etbcod
                     no-lock no-error.
    if not avail plani
    then vnumero = 1.
    else vnumero = plani.numero + 1.
    /************************************************/

    update vforcod with frame f1.
    find forne where forne.forcod = vforcod no-error.
    if not avail forne
    then do:
        bell.
        message "Fornecedor nao Cadastrado !!".
        undo, retry.
    end.
    display forne.fornom when avail forne with frame f1.
    vrec = recid(forne). 
    
    run nffped.p (input vrec,
                  output vped).
                  
    if vped = ?
    then do:
        message "Para continuar selecione pelo menos um pedido.".
        undo.
    end.
    


    /*vserie = opcom.serie.*/
    vserie = "U".
    disp  vnumero
          vserie
          with frame f1.
    find first cplani where cplani.numero = vnumero and
                            cplani.emite  = vforcod and
                            cplani.desti  = estab.etbcod and
                            cplani.serie  = vserie and
                            cplani.etbcod = estab.etbcod and
                            cplani.movtdc = 1 no-lock no-error.

    if avail cplani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.

    /* vopccod = opcom.opccod. */
    do on error undo, retry:
        /*update vopccod with frame f1.
        find opcom where opcom.opccod = vopccod no-lock no-error.
        if not avail opcom
        then do:
            message "Operacao Comercial Nao Cadastrada".
            undo, retry.
        end.
        vopfcod = 132.
        update vopfcod with frame f1.
        find opfis where opfis.opfcod = vopfcod no-lock no-error.
        if not avail opfis
        then do:
            message "Operacao Fiscal nao Cadastrada".
            undo, retry.
        end.
        disp opfis.opfnom with frame f1.
        */
        find tipmov where tipmov.movtdc = 1 no-lock.
        update vpladat
                with frame f1.
        /* update vvencod with frame f1.
        find first func where func.funcod = vvencod no-lock no-error.
        if not avail func
        then do:
            bell.
            message "Vendedor Nao Cadastrado".
            pause. undo.
        end. */
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
/*        update
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
        vacfprod with frame f2.
    vplatot = (vbicms + vfrete + vipi)  - vdescpro.
    update vplatot with frame f2.
    vtotal = vipi + vdesacess + vseguro + vfrete +
             vprotot - vdescpro.*/

    clear frame f-produ1 no-pause.
    bl-princ:
    repeat with 1 down:
        hide frame f-produ2 no-pause.
        prompt-for vprocod go-on (F5 F6 F8 F9 F4 PF4
                            F10 E e C c) with frame f-produ.

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
                undo, return.
            end.
            else leave.
        end.
        if lastkey = keycode("c") or lastkey = keycode("C")
        then do with frame f-produ2:
            clear frame f-produ2 all no-pause.
            for each w-movim:
                find produ where recid(produ) = w-movim.wrec no-lock.
                disp produ.procod
                     produ.pronom format "x(29)"
                     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
                     w-movim.movpc  format ">,>>9.99" column-label "Custo"
                     w-movim.movalicms column-label "ICMS"
                     w-movim.movalipi  column-label "IPI"
                     /*
                     w-movim.subtotal
                            format ">>,>>9.99" column-label "Total" */
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
                        /*
                        w-movim.subtotal */
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
        find estoq where estoq.etbcod = 999 and
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
        
        /*else assign vmovqtm = w-movim.movqtm
                    vsubtotal = w-movim.subtotal.

        w-movim.movpdesc = 0.
        update  w-movim.movpdesc with frame f-produ1.
        */

        vmovqtm = w-movim.movqtm.
        update  w-movim.movqtm validate(w-movim.movqtm > 0,
                         "Quantidade Invalida") with frame f-produ1.
        
        w-movim.movpc = estoq.estcusto.
        
        w-movim.movqtm = VMOVQTM + w-movim.movqtm.
        display w-movim.movqtm with frame f-produ1.
        update w-movim.movpc with frame f-produ1.
        w-movim.movalicms = 17.
        update  w-movim.movalicms
                w-movim.movalipi
                    with frame f-produ1.
        vprotot = 0.
        w-movim.subtotal = w-movim.movqtm * (((w-movim.movpc * w-movim.movalipi)
                                              / 100) + w-movim.movpc).
        /*update  w-movim.subtotal validate(w-movim.subtotal > 0,
                         "Total dos Produtos Invalido")  with frame f-produ1.*/
        clear frame f-produ1 all no-pause.


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
                    /*
                    w-movim.subtotal */
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
    hide frame f2 no-pause.
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
    then undo, leave.
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


    do on error undo:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.placod   = vplacod
               plani.protot   = vprotot
               plani.emite    = vforcod
               plani.bicms    = vprotot
               plani.icms     = vprotot * (17 / 100)
               /*plani.frete    = vfrete
               plani.alicms   = plani.icms * 100 / (plani.bicms *
                                (1 - (0 / 100)))*/
               plani.descpro  = vdescpro
               plani.acfprod  = vacfprod
               plani.frete    = vfrete
               plani.seguro   = vseguro
               plani.desacess = vdesacess
               plani.ipi      = vipi
               plani.platot   = vprotot
               plani.serie    = vserie
               plani.numero   = vnumero
               plani.movtdc   = tipmov.movtdc
               plani.desti    = estab.etbcod
               plani.pladat   = vpladat
               plani.modcod   = tipmov.modcod
               plani.opccod   = 4
               /* plani.opfcod   = opfis.opfcod */
               plani.vencod   = vvencod
               plani.notfat   = vforcod
               plani.dtinclu  = today
               plani.horincl  = time
               plani.hiccod   = vhiccod
               plani.notsit   = no
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
               /*
               movim.movpdesc = w-movim.movpdesc
               movim.movipi   =
               movim.MovICMS  =
               */
               movim.MovAlICMS = w-movim.movalicms
               movim.MovAlIPI  = w-movim.movalipi
               movim.movdat    = plani.pladat
               movim.MovHr     = int(time)
               movim.desti     = plani.desti
               movim.emite     = plani.emite.

        run atuest.p(input recid(movim),
                     input "I",
                     input 0).

        
            
        for each estoq where estoq.procod = produ.procod.
            estoq.estcusto = w-movim.movpc.
            estoq.datexp = today.
        end.

    
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

    
    for each w-movim:
    
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movim.wrec no-lock no-error.
        if not avail produ
        then next.
        find first plani where plani.etbcod = estab.etbcod and
                               plani.placod = vplacod no-lock.
        /*create wetique.
        assign wetique.wrec = recid(produ)
               wetique.wqtd = w-movim.movqtm.*/
        
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
    end.
     
    
    for each wfped:
        find pedid where recid(pedid) = wfped.rec no-error.
        if avail pedid
        then do:
            for each liped of pedid:
                do transaction:
                    liped.lipsit = "".
                    pedid.sitped = "".
                    if liped.lipent >= (liped.lipqtd - (liped.lipqtd * 0.10))
                     and 
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
    
     
    /*
    vezes = 0.
    prazo = 0.
    find plani where plani.etbcod = estab.etbcod and
                     plani.placod = vplacod no-lock.
    update vezes label "Vezes"
           prazo label "Prazo"
                with frame f-tit width 80 side-label.
    disp plani.platot with frame f-tit.

    do i = 1 to vezes:


        create titulo.
        assign titulo.etbcod = estab.etbcod
               titulo.titnat = yes
               titulo.modcod = "DUP"
               titulo.clifor = forne.forcod
               titulo.titsit = "lib"
               titulo.empcod = wempre.empcod
               titulo.titdtemi = today
               titulo.titnum = string(plani.numero)
               titulo.titpar = i.

        if prazo <> 0
        then assign titulo.titvlcob = plani.platot
                    titulo.titdtven = titdtemi + prazo.
        else assign titulo.titvlcob = plani.platot / vezes
                    titulo.titdtven = titulo.titdtemi + ( 30 * i).
    end.

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
        update titulo.titdtven
               titulo.titvlcob with frame ftitulo no-validate.
        down with frame ftitulo.
    end. */
    message "Nota Fiscal Incluida". pause.



    for each w-movim:
        delete w-movim.
    end.
        /* run impnfdev.p (input recid(plani)). */
end.
