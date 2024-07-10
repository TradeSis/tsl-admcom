{admcab.i}

def var vcnpj-aux like forne.forcgc.
def var vtipo as int format "99".
def var vchave-nfe as char.
def var vdesval as dec format ">,>>9.99".
def var vobs as char format "x(14)" extent 4.
def var vcusto like estoq.estcusto.
def var vacr as dec format ">,>>9.99".
def buffer btitulo for titulo.
def buffer xestoq for estoq.
def temp-table wetique
    field wrec as recid
    field wqtd like estoq.estatual.
/***def var vdesc    like plani.descprod format ">9.99 %".***/
def var i as i.
def var Vezes as int format ">9".
def var Prazo as int format ">>9".
def var v-ok as log.
def var vforcod like forne.forcod.
def var vsaldo    as dec.
def var vmovqtm   like  movim.movqtm.
def var vvencod   like plani.vencod.
def var vsubtotal like  movim.movqtm.
def var vpladat   like  plani.pladat.
def var vrecdat   like  plani.pladat label "Recebimento".
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms.
def var vprotot   like  plani.protot.
def var vfrete    like  plani.frete.
def var vfrecod   like  frete.frecod.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char.
def var vopccod   like  plani.hiccod.
def var vprocod   like  produ.procod.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotpag     like plani.platot.
def var voutras     like plani.outras.
def var vdvnfe      as int.
def var vlechave    as log.
def var vlexml      as log.
def var vnfeprotot  like plani.protot.

def buffer bplani for plani.

def temp-table w-movim
               field wrec    as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc format ">>9.9999"
               field movpc     as decimal format ">,>>9.99"
               field movalicms like movim.movalicms initial 12
               field movalipi  like movim.movalipi.

def NEW shared temp-table tt-xmlretorno
    field root       as char format "x(15)"
    field tag        as char format "x(20)"
    field valor      as char format "x(20)".

form titulo.titpar
     titulo.titnum
     prazo
     titulo.titdtven
     titulo.titvlcob with frame ftitulo down centered color white/cyan.

form produ.procod
     produ.pronom format "x(30)"
     w-movim.movqtm format ">,>>>,>>9.99" column-label "Qtd"
     w-movim.movpc  format ">>>,>>>,>>9.9999" column-label "V.Unit."
     w-movim.movalicms column-label "ICMS"
     w-movim.movalipi  column-label "IPI"
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
    vchave-nfe    label "Cod Barras NFE" colon 15 format "x(44)"
    vcnpj-aux     colon 15
    forne.forcod  no-label
    forne.fornom  no-label
    vnumero       colon 15
    vserie        label "Serie" format "x(3)"
    vopccod       label "Op. Fiscal" format "9999" colon 15
    opcom.opcnom no-label
    vpladat colon 15
    vrecdat colon 40
    /***vdesc label "% Desc."***/
    vdesval label "Valor Desconto" 
    vfrecod label "Transp." colon 15
    frete.frenom no-label
    vfrete label "Frete"
    with frame f1 side-label width 80 row 4 color white/cyan.

form
    vbicms   label "Base Icms"  colon 17
    vicms    label "Valor Icms" colon 50
    vipi     label "IPI"        colon 17
    voutras                     colon 50
    vfrete  label "Frete"       colon 17
    vacr    label "Acrescimo"   colon 50
    vplatot                     colon 17
    with frame f2 side-label row 12 width 80 overlay color white/cyan.

{gnre.i} /* #1 */

do:
    for each w-movim:
        delete w-movim.
    end.
    clear frame f1 no-pause.
    clear frame f2 no-pause.
    clear frame f-produ no-pause.
    clear frame f-produ1 no-pause.
    clear frame f-produ2 no-pause.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    hide frame f-produ2 no-pause.
    hide frame f1 no-pause.
    hide frame f2 no-pause.
    prompt-for estab.etbcod with frame f1.
    find estab using estab.etbcod no-lock.
    display estab.etbcod
            estab.etbnom with frame f1.

    assign
        vetbcod = estab.etbcod
        vlechave = no
        vserie  = "U"
        vrecdat = today
        vbicms  = 0
        vicms   = 0
        vipi    = 0
        vplatot = 0
        voutras = 0
        vfrete  = 0
        vacr    = 0
        /***vdesc   = 0***/.

    if vetbcod = 990
    then do:
        message "Operacao Invalida para Matriz".
        pause.
        undo, leave.
    end.       

    update vchave-nfe with frame f1.
    
    if length(vchave-nfe) = 44
    then do:
        /* Digito Verificador */
        run nfe_caldvnfe11.p (input dec(substr(vchave-nfe,1,43)),
                              output vdvnfe).
        if substr(vchave-nfe,44,1) <> string(vdvnfe)
        then do.
            message "Chave da NFE invalida" view-as alert-box.
            undo.
        end.
        assign vcnpj-aux = substring(vchave-nfe,7,14)
               vserie    = string(int(substring(vchave-nfe,23,3)))
               vnumero   = int(substring(vchave-nfe,26,9))
               vlechave  = yes.    
        run not_nfedistr.p(vetbcod, vchave-nfe, output sresp).
        if not sresp
        then undo.
    end.
    else assign
            vlechave   = no
            vchave-nfe = "".

    disp
        vcnpj-aux
        vserie
        vnumero with frame f1.    

    update vcnpj-aux when vlechave = no with frame f1.
    find first forne where forne.forcgc = vcnpj-aux
                       and forne.ativo
                     no-lock no-error.
    if not avail forne
    then do:
        message "Fornecedor nao Cadastrado !!".
        undo, retry.
    end.
    display forne.forcod forne.fornom with frame f1.

    find last cpforne where cpforne.forcod = forne.forcod no-lock no-error.
    if avail cpforne
        and date(cpforne.date-1) <> ?
        and date(cpforne.date-1) <= today
        and length(vchave-nfe) <> 44
    then do:
        message "Fornecedor NFE desde " string(cpforne.date-1) skip
                " Informe a chave de acesso do DANFE! " view-as alert-box. 
        undo,retry.
    end.

    run not_notgvlclf.p ("Forne", recid(forne), output sresp).
    if not sresp
    then undo, retry.
    vforcod = forne.forcod.

    if vlechave = no
    then update vnumero
              vserie  with frame f1.

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

    if vlechave
    then run xml-retorno.

    do on error undo, retry:       
        update vopccod with frame f1.
        
        find first opcom where opcom.opccod = string(vopccod)
                            no-lock no-error.
        if not avail opcom                    
            or length(string(vopccod)) <> 4
        then do:
            message "CFOP Inválido, Pressione F7 e escolha novamente."
                            view-as alert-box.
            undo,retry.
        end.
        display opcom.opcnom with frame f1.
    end.

    find tipmov where tipmov.movtdc = 4 no-lock.
    do on error undo, retry:
        update vpladat when vlexml = no
               with frame f1.
        
        if (vpladat > today
            or vpladat < today - 30
            or vpladat = ?)
        then do:
            message "Data Invalida - Func: " sfuncod.
            undo, retry.
        end.
        
        update /***vdesc***/
               vdesval
               vfrecod
               with frame f1.
        
        find frete where frete.frecod = vfrecod no-lock no-error.
        if not avail frete
        then do:
            message color red/with
            "Transportador nao cadastrado."
            view-as alert-box.
            undo, retry.
        end. 
        else display frete.frenom no-label with frame f1.

        update vfrete with frame f1.

        vvencod = vfrecod.
    end.

    disp
        vbicms
        vicms
        vipi
        voutras
        vfrete
        vacr
        vplatot
        with frame f2.

    do on error undo, retry:
    
    do on error undo:
        hide frame f-obs no-pause.
        update vbicms when vlexml = no
               vicms  when vlexml = no
            with frame f2.

        if vbicms = 0 or
           vicms  = 0
        then do:
            vobs[1] = "ICMS DESTACADO".
            vobs[2] = "M.E.".
            vobs[3] = "GAS".
            vobs[4] = "NEW FREE".
            display "1§ " TO 05 vobs[1] no-label 
                    "2§ " TO 05 vobs[2] no-label 
                    "3§ " TO 05 vobs[3] no-label 
                    "4§ " to 05 vobs[4] no-label
                    with frame f-icms side-label row 5 overlay columns 50.

            update vtipo label "Escolha" format "99" 
                           with frame f-icms2 side-label columns 58
                                           row 04 no-box. 
            
            if vtipo <> 1 and
               vtipo <> 2 and
               vtipo <> 3 and
               vtipo <> 4
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
            if (vbicms * 0.25) < vicms
            then do:
                message "Valor do icms nao confere com Base de Calculo".
                undo, retry.
            end.
        end.
 
        hide frame f-obs no-pause.
    end.

    if vlexml = no
    then update
           vipi    label "IPI"
           voutras
           vfrete  label "Frete"
           vacr    label "Acrescimo" with frame f2.

    do on error undo:
       update vplatot when vlexml = no with frame f2.
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
    end.
    hide frame f-obs no-pause.

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
                     produ.pronom format "x(30)"
                     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
                     w-movim.movpc  format ">,>>9.99" column-label "Custo"
                     w-movim.movalicms column-label "ICMS"
                     w-movim.movalipi  column-label "IPI"
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
                        w-movim.movqtm
                        w-movim.movpc
                        w-movim.movalicms
                        w-movim.movalipi
                        with frame f-produ1.
                down with frame f-produ1.
                pause 0.
                vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
                display vprotot with frame f-produ.
            end.
            next.
        end.
        find produ where produ.procod = input vprocod no-lock no-error.
        if not avail produ
        then do.
            message "Produto nao Cadastrado" view-as alert-box.
            undo.
        end.
        if produ.proseq = 98 or produ.proseq = 99
        then do:
            message "Produto INATIVO/BLOQUEADO" view-as alert-box.
            undo.
        end.
        display produ.pronom with frame f-produ.
        find estoq where estoq.etbcod = 999 and
                         estoq.procod = produ.procod no-lock no-error.
        if not available estoq
        then do:
            message "Produto Sem Registro de Armazenagem".
            pause.
            undo.
        end.

        display produ.pronom with frame f-produ1.

        vmovqtm = 0.
        vsubtotal = 0.
        find first w-movim where w-movim.wrec = recid(produ) no-lock no-error.
        if not avail w-movim
        then do:
            create w-movim.
            assign w-movim.wrec = recid(produ).
        end.

        vmovqtm = w-movim.movqtm.
        update  w-movim.movqtm validate(w-movim.movqtm > 0,
                         "Quantidade Invalida") with frame f-produ1.
        w-movim.movpc = estoq.estCUSTO.
        w-movim.movqtm = VMOVQTM + w-movim.movqtm.
        display w-movim.movqtm with frame f-produ1.
        update w-movim.movpc with frame f-produ1.
        w-movim.movalicms = 12.
        update  w-movim.movalicms
                w-movim.movalipi
                    with frame f-produ1.
        vcusto = w-movim.movpc.
        if vbicms <> 0
        then vcusto = vcusto + 
                (w-movim.movpc * ((vbicms / (vbicms - vacr)) - 1)).
        for each xestoq where xestoq.procod = produ.procod.
            xestoq.estcusto = ((vcusto * (w-movim.movalipi / 100)) + vcusto).
        end.

        vprotot = 0.
        w-movim.subtotal = w-movim.movqtm * (((w-movim.movpc * w-movim.movalipi)
                                              / 100) + w-movim.movpc).
        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = wrec no-lock.
            display produ.procod
                    produ.pronom
                    w-movim.movqtm
                    w-movim.movpc
                    w-movim.movalicms
                    w-movim.movalipi
                    with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
            display vprotot with frame f-produ.
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

    run trata_gnre. /* #1 */

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
                     /*
    if vbicms > vprotot
    then do:
        message "Base do icms maior que total da nota".
        undo, retry.
    end.               */

    do on error undo:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.notobs[3] = if vtipo = 0
                                 then ""
                                 else vobs[vtipo]
               plani.cxacod   = if avail frete 
                                then frete.forcod else vfrecod
               plani.placod   = vplacod
               plani.protot   = vprotot
               plani.emite    = vforcod
               plani.bicms    = vbicms
               plani.icms     = vicms
               plani.frete    = vfrete
               plani.descpro  = vdesval /***vprotot * (vdesc / 100)***/
               plani.ipi      = vipi
               plani.platot   = vplatot
               plani.serie    = vserie
               plani.numero   = vnumero
               plani.movtdc   = tipmov.movtdc
               plani.desti    = estab.etbcod
               plani.modcod   = tipmov.modcod
               plani.opccod   = vopccod
               plani.vencod   = if avail frete 
                                then frete.frecod else vfrecod
               plani.notfat   = vforcod
               plani.horincl  = time
               plani.hiccod   = vopccod
               plani.dtinclu  = vrecdat
               plani.pladat   = vpladat
               PLANI.DATEXP   = today
               plani.notsit   = no
               plani.outras   = voutras
               plani.isenta   = plani.platot - plani.outras - plani.bicms
               plani.ufdes    = vchave-nfe.
        if plani.descprod = 0
        then plani.descprod = vdesval.
        for each w-movim:
            vmovseq = vmovseq + 1.
            find produ where recid(produ) = w-movim.wrec no-lock.
            find plani where plani.etbcod = estab.etbcod and
                             plani.placod = vplacod no-lock.
            create wetique.
            assign wetique.wrec = recid(produ)
                   wetique.wqtd = w-movim.movqtm.

            create movim.
            ASSIGN movim.movtdc = plani.movtdc
                   movim.PlaCod = plani.placod
                   movim.etbcod = plani.etbcod
                   movim.movseq = vmovseq
                   movim.procod = produ.procod
                   movim.movqtm = w-movim.movqtm
                   movim.movpc  = w-movim.movpc
                   movim.MovAlICMS = (plani.icms * 100) / plani.bicms
                   movim.MovAlIPI  = w-movim.movalipi
                   movim.movdat = plani.pladat
                   movim.MovHr  = int(time)
                   MOVIM.DATEXP = plani.datexp
                   movim.desti  = plani.desti
                   movim.emite  = plani.emite.
            delete w-movim.
        end.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock.
            run atuest.p(input recid(movim),
                         input "I",
                         input 0).
        end.

        find       planiaux where
                   planiaux.movtdc = plani.movtdc and
                   planiaux.etbcod = plani.etbcod and
                   planiaux.emite  = plani.emite  and
                   planiaux.serie  = plani.serie  and
                   planiaux.numero = plani.numero and
                   planiaux.nome_campo = "ProgramaInclusao" and
                   planiaux.valor_campo = "nfent1"
                   no-lock no-error.
        if not avail planiaux
        then do:
            create planiaux.
            assign
                planiaux.movtdc = plani.movtdc 
                planiaux.etbcod = plani.etbcod 
                planiaux.emite  = plani.emite  
                planiaux.serie  = plani.serie  
                planiaux.numero = plani.numero 
                planiaux.nome_campo = "ProgramaInclusao"
                planiaux.valor_campo = "nfent1".
        end.
        run grava_gnre. /* #1 */
    end.
    vezes = 0.
    prazo = 0.
    find plani where plani.etbcod = estab.etbcod and
                     plani.placod = vplacod no-lock.

    repeat on endkey undo:
    
        update vezes label "Vezes"
                with frame f-tit width 80 side-label centered color white/red.

        vtotpag = plani.platot.

        do on error undo:
            update vtotpag with frame f-tit.    

            if vtotpag < (plani.protot + plani.ipi - vdesval - plani.descprod)
            then do:
                message "Verifique os valores da nota".
                undo, retry.
            end.
        end.

        do i = 1 to vezes:

            create titulo.
            assign titulo.etbcod = plani.etbcod
               titulo.titnat = yes
               titulo.modcod = "DUP"
               titulo.clifor = forne.forcod
               titulo.titsit = "lib"
               titulo.empcod = wempre.empcod
               titulo.titdtemi = vpladat
               titulo.titnum = string(plani.numero)
               titulo.titpar = i.

            if prazo <> 0
            then assign titulo.titvlcob = vtotpag
                    titulo.titdtven = titdtemi + prazo.
            else assign titulo.titvlcob = vtotpag / vezes
                    titulo.titdtven = titulo.titdtemi + ( 30 * i).
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

            titulo.titdtven = vpladat + prazo.
            titulo.titvlcob = vsaldo.

            update titulo.titdtven
               titulo.titvlcob with frame ftitulo no-validate.

            vsaldo = vsaldo - titulo.titvlcob.

            find titctb where titctb.forcod = titulo.clifor and
                          titctb.titnum = titulo.titnum and
                          titctb.titpar = titulo.titpar no-error.
            if not avail titctb
            then do:
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
        leave. 
    end.

    if vlechave
    then run not_nfecnfrec.p (recid(plani)).

    message "Nota Fiscal Incluida".
    pause.

    for each w-movim:
        delete w-movim.
    end.

    if plani.desti = 996
    then do:
        run peddis.p (input recid(plani)).

        find first wetique no-error.
        if not avail wetique
        then leave.
        message "Confirma emissao de Etiquetas?" update sresp.
        if sresp
        then
            for each wetique:
                run eti_barl.p (input wetique.wrec,
                                input wetique.wqtd).
            end.
        for each wetique:
            delete wetique.
        end.
    end.
end.

procedure xml-retorno.

    def var vdata  as char.
    def var vvalor as dec.
    for each tt-xmlretorno where tt-xmlretorno.root = "ide" no-lock.
        case tt-xmlretorno.tag.
            when "dEmi"
            then do.
                vdata   = tt-xmlretorno.valor. /* Ex:2013-03-21 */
                vpladat = date (int(substr(vdata, 6, 2)),
                                int(substr(vdata, 9, 2)),
                                int(substr(vdata, 1, 4))).
            end.
            when "dhEmi"
            then do.
                vdata   = tt-xmlretorno.valor. /* Ex:2013-03-21 */
                vpladat = date (int(substr(vdata, 6, 2)),
                                int(substr(vdata, 9, 2)),
                                int(substr(vdata, 1, 4))).
            end.

        end case.
    end.

    for each tt-xmlretorno where tt-xmlretorno.root = "ICMSTot" no-lock.
/***/        vlexml = yes. /***/
        vvalor = dec(tt-xmlretorno.valor).
        case tt-xmlretorno.tag.
            when "vBC"    then vbicms  = vvalor.
            when "vICMS"  then vicms   = vvalor.
            when "vProd"  then vnfeprotot = vvalor.
            when "vIPI"   then vipi    = vvalor.
            when "vFrete" then vfrete  = vvalor.
/*            when "vOutro" then voutras = vvalor.*/
            when "vDesc"  then vdesval = vvalor.
            when "vNF"    then vplatot = vvalor.
        end case.
    end.
end procedure.



