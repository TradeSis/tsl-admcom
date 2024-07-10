{admcab.i}

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-movimaux like movimaux.
def new shared temp-table tt-etiqpla
    field oscod     like etiqpla.oscod
    field etopeseq  like etiqpla.etopeseq
    field etmovcod  like etiqpla.etmovcod.

def var vok as log.

def var v-ok as log.
def var vmovqtm   like  movim.movqtm.
def var vvencod   like  plani.vencod.
def var vsubtotal like  movim.movqtm.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms .
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vacfprod  like  plani.acfprod.
def var vfrete    like  plani.frete.
def var vplatot   like  plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    like  plani.serie.
def var vopccod   like  plani.opccod.
def var vhiccod   like  plani.hiccod.
def var vprocod   like  produ.procod.
def var vdown as i.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vtotal      like plani.platot.
def var vobs        as char format "x(70)" extent 9.

def  temp-table w-movim
               field wrec    as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc
               field movpc     as decimal format ">,>>9.99"
               field movalicms like movim.movalicms
               field movalipi  like movim.movalipi.

form produ.procod
     produ.pronom format "x(30)"
     w-movim.movqtm format ">,>>9.99" column-label "Qtd"
     w-movim.movpc  format ">>>,>>9.99" column-label "V.Unit."
     w-movim.movalicms column-label "ICMS"
     w-movim.subtotal format ">>,>>9.99" column-label "Total"
     with frame f-produ1 row 7 12 down overlay
                centered color white/cyan width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
     with frame f-produ centered color message side-label
                        row 6 no-box width 81.

def var v-title as char.
def var vforcod like forne.forcod.
form
    vetbcod      label "Filial" colon 15
    estab.etbnom no-label
    vforcod      label "Fornecedor" colon 15
    forne.fornom no-label
    forne.ufecod
    vhiccod      label "Op.Com" colon 15
    with frame f1 side-label width 80 row 3 color white/cyan no-box.

find tipmov where tipmov.movtdc = 72 no-lock.

form
    vbicms   colon 10
    vicms    colon 30
    vprotot1 colon 65
    vfrete   colon 10
    vdescpro colon 10
    vacfprod  colon 45
    vplatot  with frame f2 side-label row 10 width 80 overlay.

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

    update vetbcod with frame f1.
    find estab where estab.etbcod = vetbcod no-lock.
    display
        estab.etbnom with frame f1.

    update vforcod with frame f1.
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do:
         message "Nao cadastrado".
         pause.
         undo.
    end.
    display forne.fornom forne.ufecod with frame f1.
    run not_notgvlclf.p ("Forne", recid(forne), output sresp).
    if not sresp
    then undo, retry.
    
    if forne.ufecod = "RS"
    then vhiccod = 5910.
    else vhiccod = 6910.
    disp vhiccod with frame f1.
    vserie = "1".

    do on error undo, retry:
    assign vbicms  = 0
           vicms   = 0
           vfrete  = 0
           vprotot1 = 0
           vdescpro = 0
           vacfprod = 0
           vplatot = 0
           vtotal  = 0.

    clear frame f-produ1 no-pause.
    bl-princ:
    repeat with 1 down:
        hide frame f-produ2 no-pause.
        
        for each w-movim where w-movim.movqtm = 0 or
                               w-movim.movpc  = 0:
            delete w-movim.
        end.
 
        prompt-for vprocod go-on (F5 F6 F8 F9 F4 PF4
                            F10 E e C c) with frame f-produ.

        if keyfunction(lastkey) = "end-error"
        then do:
            sresp = yes.
            message "Confirma Geracao de Nota Fiscal?" update sresp.
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
                disp produ.pronom format "x(30)"
                     w-movim.movqtm format ">,>>9.99" column-label "Qtd"
                     w-movim.movpc  format ">,>>9.99" column-label "Custo"
                     w-movim.movalicms column-label "ICMS"
                     w-movim.subtotal format ">>,>>9.99" column-label "Total"
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
                else assign
                        w-movim.movqtm = w-movim.movqtm - vqtd
                        w-movim.subtotal = w-movim.movqtm * w-movim.movpc.
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
                        w-movim.subtotal
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
        then do:
            message "Produto nao Cadastrado".
            undo.
        end.
        display produ.pronom with frame f-produ.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.

        if not available estoq
        then do:
            message "Produto Sem Registro de Armazenagem".
            pause.
            undo.
        end.

        display produ.pronom with frame f-produ.
        display produ.pronom with frame f-produ1.

        vmovqtm   = 0.
        vsubtotal = 0.
        find first w-movim where w-movim.wrec = recid(produ) no-lock no-error.
        if not avail w-movim
        then do:
            create w-movim.
            assign w-movim.wrec = recid(produ).
        end.

        update w-movim.movqtm validate(w-movim.movqtm > 0,
                         "Quantidade Invalida") with frame f-produ1.
        display w-movim.movqtm with frame f-produ1.
        w-movim.movpc = estoq.estvenda.
        update w-movim.movpc with frame f-produ1.
        w-movim.movalicms = 17.
        vprotot = 0.
        w-movim.subtotal = w-movim.movqtm * w-movim.movpc.
        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = wrec no-lock.
            display produ.procod
                    produ.pronom
                    w-movim.movqtm
                    w-movim.movpc
                    w-movim.movalicms
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
    if v-ok = yes
    then undo, leave.

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

    vserie = "1".
    do on error undo:
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = ?
               tt-plani.protot   = vprotot
               tt-plani.emite    = estab.etbcod
               tt-plani.bicms    = vprotot
               tt-plani.icms     = vprotot * (17 / 100)
               tt-plani.descpro  = vdescpro
               tt-plani.acfprod  = vacfprod
               tt-plani.frete    = vfrete
               tt-plani.platot   = vprotot
               tt-plani.serie    = vserie
               tt-plani.numero   = vnumero
               tt-plani.movtdc   = tipmov.movtdc
               tt-plani.desti    = vforcod
               tt-plani.pladat   = today
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = vhiccod
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
              tt-plani.outras - tt-plani.bicms.
              
        update vobs[1] no-label
               vobs[2] no-label
               vobs[3] no-label
               vobs[4] no-label
               vobs[5] no-label
               vobs[6] no-label
               vobs[7] no-label
               vobs[8] no-label
               vobs[9] no-label
                    with frame f-obs overlay centered row 16
                          no-label title " Informações Adicionais ".

        assign
            tt-plani.notobs[1] = vobs[1] + " " + vobs[2] + " " + vobs[3] + " "
            tt-plani.notobs[2] = vobs[4] + " " + vobs[5] + " " + vobs[6] + " "
            tt-plani.notobs[3] = vobs[7] + " " + vobs[8] + " " + vobs[9].
    end.

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
               tt-movim.MovAlICMS = w-movim.movalicms
               tt-movim.MovAlIPI  = w-movim.movalipi
               tt-movim.movdat = tt-plani.pladat
               tt-movim.MovHr  = int(time)
               tt-movim.desti  = tt-plani.desti
               tt-movim.emite  = tt-plani.emite.        
    end.

    message "Deseja visualizar o total da nota antes da emissao?"
    update sresp.
    if sresp
    then run p-mostra-nota.
    
    sresp = no.
    message "Confirma Emissao da Nota?" update sresp.
    if sresp
    then run manager_nfe.p (input "5910",
                            input ?,
                            output vok).
end.

procedure p-mostra-nota:

    display tt-plani.bicms  
            tt-plani.icms 
            tt-plani.bsubst
            tt-plani.icmssubst
            tt-plani.protot   
            with frame f-mostra-1 overlay row 8 width 80.
                
    pause 0.

    display tt-plani.frete 
            tt-plani.seguro 
            tt-plani.desacess
            tt-plani.ipi     
            tt-plani.platot  
            with frame f-mostra-2 overlay row 12 width 80.

    pause.

    sresp = no.

    for each tt-movim.
        display tt-movim.procod
                tt-movim.movpc
                tt-movim.movdes
                tt-movim.movqtm
                tt-movim.movicms
                tt-movim.movalicms 
                tt-movim.movdev label "Frete" with 1 col.
    end.

end procedure.

