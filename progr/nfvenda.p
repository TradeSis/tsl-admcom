{admcab.i}               

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def var vok as log.

def var v-ok as log.
def buffer bclien for clien.
def var vclicod like clien.clicod.
def var vmovqtm   like  movim.movqtm.
def var vvencod   like plani.vencod.
def var vsubtotal like  movim.movqtm.
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
def var vhiccod   like  plani.hiccod initial 532.
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
     w-movim.movqtm format ">,>>9.99" column-label "Qtd"
     w-movim.movpc  format ">,>>9.99" column-label "V.Unit."
     w-movim.movalicms column-label "ICMS"
     /*w-movim.movalipi  column-label "IPI"*/
     w-movim.subtotal format ">>,>>9.99" column-label "Total"
     with frame f-produ1 row 9 9 down overlay
                centered color white/cyan width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 8 no-box width 81.

def var vform-pag as char extent 3 format "x(15)"
    init["  01=Dinheiro","  02=Cheque","  15=Boleto"].
def var vindexpag as int.

def var v-title as char.
form
    estab.etbcod  label "Filial" colon 15
    estab.etbnom  no-label
    /* clien.ciccgc no-label */
    vclicod       label "Cliente" colon 15
    clien.clinom no-label    
   /* vnumero       colon 15
    vserie
    vhiccod   label "Op.Fiscal" format "9999"  
    vpladat colon 15
     vvencod  */
      with frame f1 side-label width 80 row 4 color white/cyan
      title v-title.

find tipmov where tipmov.movtdc = 46 no-lock.
find first opcom where opcom.movtdc = 5 no-lock no-error.
if avail opcom
then v-title = opcom.opcnom.

form
    vbicms   colon 10
    vicms    colon 30
    vprotot1 colon 65
    vfrete   colon 10
    vipi     colon 30
    vdescpro colon 10
    vacfprod  colon 45
    vplatot  with frame f2 side-label row 10 width 80 overlay.

repeat:
    for each w-movim: delete w-movim. end.
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end. 
    
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
    /*
    find opcom where opcom.opccod = 20 no-lock.
    find estab where estab.etbcod = setbcod no-lock.
    */
    prompt-for estab.etbcod with frame f1.
    vetbcod = input frame f1 estab.etbcod.
    /*{valetbnf.i ""Emitente"" vetbcod}
    */
    find estab where estab.etbcod = vetbcod no-lock.
    display
        estab.etbcod
        estab.etbnom with frame f1.

    /******** Pega a ultima nota e gera a numero *****/
    
    /**
    find last plani where
              plani.etbcod = estab.etbcod and
              plani.emite = estab.etbcod and
              plani.serie = "55" 
              no-lock no-error.
    if not avail plani
    then vnumero = 1.
    else vnumero = plani.numero + 1.
    **/
    
    update vclicod with frame f1.
    find clien where clien.clicod = vclicod no-lock.
    disp clien.clinom with frame f1.
    /*
    if vclicod = 0
    then do:
        create clien.
        find last bclien  exclusive-lock no-error.
        if available bclien
        then assign vclicod = bclien.clicod.
        else assign vclicod = 0.
        {di.v 1 "vclicod"}
        clien.clicod = vclicod.
        disp clien.clicod colon 12 with frame f-cli centered row 10
                                color blue/cyan side-label
                                        title " Cliente ".
        update clien.clinom label "Nome" colon 20
               clien.ciccgc label "CPF" colon 20
                                   WITH FRAME F-CLI NO-VALIDATE.

                    /*  run cpf.p (input scpf, output v-certo).
                        if v-certo = no      or
                           scpf = ""
                        then do:
                            bell.
                            message "CPF Inv lido".
                            pause.
                            undo.
                        end.
         UPDATE
               clien.endereco[1] colon 20
               clien.numero[1]   colon 20
               clien.compl[1]    colon 20
               clien.cidade[1] colon 20
               clien.cep colon 20
               clien.ufecod
               clien.fone label "Fone" colon 20 with frame f-cli no-validate
                        overlay.  */
    end.

    find clien where clien.clicod = vclicod no-error.
    if not avail clien
    then do:
        bell.
        message "Cliente nao Cadastrado !!".
        undo, retry.
    end.
    */
    /*
    display clien.clicod
            clien.clinom label "Nome" colon 20
            clien.ciccgc  colon 20
            clien.endereco[1] colon 20
            clien.numero[1]  colon 20
            clien.compl[1]   colon 20
            clien.cidade[1] colon 20
            clien.cep colon 20
            clien.ufecod
            clien.fone label "Fone" colon 20 with frame f-cli.
    sresp = no.
    message "Deseja alterar dados ?" update sresp.
    if sresp
    then do:
        update clien.clinom label "Nome" colon 20
               clien.ciccgc label "CPF"  colon 20
                                   WITH FRAME F-CLI NO-VALIDATE.

                     /* run cpf.p (input scpf, output v-certo).
                        if v-certo = no      or
                           scpf = ""
                        then do:
                            bell.
                            message "CPF Inv lido".
                            pause.
                            undo.
                        end.  */
         UPDATE
               clien.endereco colon 20
               clien.numero  colon 20
               clien.compl   colon 20
               clien.cidade colon 20
               clien.cep colon 20
               clien.ufecod
               clien.fone label "Fone" colon 20 with frame f-cli no-validate.
    end.
    display clien.clinom when avail clien with frame f1.
    */
    /*vserie = opcom.serie.*/
    if clien.ufecod[1] <> "RS"
    then vhiccod = 6102.
    else vhiccod = 5102.
    vserie = "55".
    /***
    display vserie with frame f1.
    disp vnumero
           vserie
           vhiccod with frame f1.
    find first plani where plani.numero = vnumero and
                     plani.emite  = estab.etbcod and
                     plani.desti  = estab.etbcod and
                     plani.serie  = vserie and
                     plani.etbcod = estab.etbcod and
                     plani.movtdc = 46 no-lock no-error.

    if avail plani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.
    ***/
    /* vopccod = opcom.opccod. */
    do on error undo, retry:
        /*update vopccod with frame f1.
        find opcom where opcom.opccod = vhiccod no-lock no-error.
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
        find tipmov where tipmov.movtdc = 46 no-lock.
        vpladat = today.
        /*
        update vpladat
                with frame f1.
        */
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
        vindexpag = 1.
        hide frame f-pag no-pause.
        hide frame f-produ2 no-pause.
        for each w-movim where w-movim.movqtm = 0 or
                               w-movim.movpc  = 0 :
        
            delete w-movim.
       
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
                    delete w-movim.
                end.
                vprocod = 0.
                hide frame f-produ1 no-pause.
                hide frame f-produ no-pause.
                undo, return.
            end.
            else do:
                disp vform-pag with frame f-pag no-label width 80 
                        row 19 overlay title " FORMAS DE PAGAMENTO ".
                choose field vform-pag with frame f-pag.
                vindexpag = frame-index.
                leave.
            end.
        end.
        if lastkey = keycode("c") or lastkey = keycode("C")
        then do with frame f-produ2:
            clear frame f-produ2 all no-pause.
            for each w-movim:
                find produ where recid(produ) = w-movim.wrec no-lock.
                disp produ.pronom format "x(30)"
                     w-movim.movqtm format ">,>>9.99" column-label "Qtd"
                     w-movim.movpc  format ">,>>9.99" column-label "Custo"
                     w-movim.movalicms column-label "ICMS"
                     /*w-movim.movalipi  column-label "IPI"*/
                     w-movim.subtotal
                            format ">>,>>9.99" column-label "Total"
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
                        /*w-movim.movalipi*/
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
        find estoq where estoq.etbcod = estab.etbcod and
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
                    vsubtotal = w-movim.subtotal.*/

        /*
        w-movim.movpdesc = 0.
        update  w-movim.movpdesc with frame f-produ1.

        */
        update  w-movim.movqtm validate(w-movim.movqtm > 0,
                         "Quantidade Invalida") with frame f-produ1.
        display w-movim.movqtm with frame f-produ1.
        w-movim.movpc = estoq.estvenda.
        update w-movim.movpc with frame f-produ1.
        /*update w-movim.movalicms
                 w-movim.movalipi with frame f-produ1.*/
        
        w-movim.movalicms = 17.
        
        if produ.proipiper <> 99 and
           produ.proipiper <> 98
        then w-movim.movalicms = produ.proipiper.
        else w-movim.movalicms = 0.
        
        if clien.ufecod[1] <> "RS"
        then w-movim.movalicms = 12.
        
        vprotot = 0.
        /* w-movim.movqtm = vmovqtm + w-movim.movqtm. */
        w-movim.subtotal = w-movim.movqtm * w-movim.movpc.
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
                    /*w-movim.movalipi*/
                    w-movim.subtotal
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

    vserie = "55".
    do on error undo:
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = ?
               tt-plani.protot   = vprotot
               tt-plani.emite    = estab.etbcod
               tt-plani.bicms    = vprotot
               tt-plani.icms     = vprotot * (17 / 100)
               /*tt-plani.frete    = vfrete
               tt-plani.alicms   = tt-plani.icms * 100 / (tt-plani.bicms *
                                (1 - (0 / 100)))*/
               tt-plani.descpro  = vdescpro
               tt-plani.acfprod  = vacfprod
               tt-plani.frete    = vfrete
               tt-plani.seguro   = vseguro
               tt-plani.desacess = vdesacess
               tt-plani.ipi      = vipi
               tt-plani.platot   = vprotot
               tt-plani.serie    = vserie
               tt-plani.numero   = vnumero
               tt-plani.movtdc   = tipmov.movtdc
               tt-plani.desti    = vclicod
               tt-plani.pladat   = vpladat
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = vhiccod
               /* tt-plani.opfcod   = opfis.opfcod */
               tt-plani.vencod   = vvencod
               tt-plani.notfat   = estab.etbcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.hiccod   = vhiccod
               tt-plani.outras = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi   +
                              tt-plani.icmssubst
              tt-plani.isenta = tt-plani.platot - 
                                tt-plani.outras - tt-plani.bicms
              tt-plani.notped = trim(vform-pag[vindexpag])
              .
    end.
    tt-plani.bicms = 0.
    tt-plani.icms = 0.
    vmovseq = 0.
    for each w-movim:
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movim.wrec no-lock.

        create tt-movim.
        ASSIGN tt-movim.movtdc = tt-plani.movtdc
               tt-movim.PlaCod = tt-plani.placod
               tt-movim.etbcod = tt-plani.etbcod
               tt-movim.movseq = vmovseq
               tt-movim.procod = produ.procod
               tt-movim.movqtm = w-movim.movqtm
               tt-movim.movpc  = w-movim.movpc
               /*
               tt-movim.movpdesc = w-movim.movpdesc
               tt-movim.movipi   =
               tt-movim.MovICMS  =
               */
               tt-movim.MovAlICMS = w-movim.movalicms
               tt-movim.MovAlIPI  = w-movim.movalipi
               tt-movim.movdat    = tt-plani.pladat
               tt-movim.MovHr     = int(time)
               tt-movim.desti = tt-plani.desti
               tt-movim.emite = tt-plani.emite.
               
        if tt-movim.MovAlICMS > 0
        then assign
                 tt-movim.movbicms = tt-movim.movpc * tt-movim.movqtm
                 tt-movim.movicms  = tt-movim.movbicms * 
                        (tt-movim.MovAlICMS / 100)
                 tt-plani.bicms = tt-plani.bicms + tt-movim.movbicms
                 tt-plani.icms  = tt-plani.icms + tt-movim.movicms
                   .
        
    end.
    vok = no.
    sresp = no.
    message "Confirma Emissao da Nota " update sresp.
    if sresp
    then run manager_nfe.p (input "5102",
                            input ?,
                            output vok).
 
end.
