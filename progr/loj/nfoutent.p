{admcab.i}

def input parameter vmovtdc as int.

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-etiqpla
    field oscod     like etiqpla.oscod
    field etopeseq  like etiqpla.etopeseq
    field etmovcod  like etiqpla.etmovcod.

def var v-title as char.
def var v-ok      as log.
def var vforcod   like forne.forcod.
def var vmovqtm   like movim.movqtm.
def var vvencod   like plani.vencod.
def var vprotot   like plani.protot.
def var vetbcod   like plani.etbcod.
def var vopccod   like plani.opccod.
def var vprocod   like produ.procod.
def var vqtd      like movim.movqtm.
def var v-procod  like produ.procod no-undo.
def var vmovseq   like movim.movseq.
def var vclicod   like clien.clicod.
def var vnome     like clien.clinom.
def var vserie    like plani.serie.
def buffer bestab for estab.

def temp-table w-movim
    field wrec      as recid
    field movqtm    like movim.movqtm
    field subtotal  like movim.movpc
    field movpc     as decimal format ">,>>9.99".

form produ.procod
     produ.pronom
     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
     w-movim.movpc  format ">,>>9.99" column-label "V.Unit."
     with frame f-produ1 row 11 7 down overlay
                centered color white/cyan width 80.

form vprocod      label "Codigo"
     produ.pronom no-label format "x(25)"
     vprotot
     with frame f-produ centered color message side-label 
          row 10 no-box width 81.

form
    vetbcod  label "Filial" colon 15
    estab.etbnom  no-label
    vforcod       label "Fornecedor" colon 15
    vclicod       label "Cliente"
    vnome no-label format "x(30)"
    opcom.opccod label "Op. Fiscal" colon 15
    opcom.opcnom no-label
    with frame f1 side-label width 80 row 4 color white/cyan title v-title.

REPEAT:
    for each w-movim:
        delete w-movim.
    end.
    clear frame f1 no-pause.
    clear frame f-produ no-pause.
    clear frame f-produ1 no-pause.
    clear frame f-produ2 no-pause.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    hide frame f-produ2  no-pause.
    hide frame f1 no-pause.
    
    find tipmov where tipmov.movtdc = vmovtdc no-lock.
    v-title = string(tipmov.movtdc) + " " + tipmov.movtnom.
   
    vetbcod = setbcod.
    disp vetbcod with frame f1.
    {valetbnf.i estab vetbcod ""Filial""}
    disp estab.etbnom with frame f1.
   
    do on error undo:
        update vforcod with frame f1.
        if vforcod > 0 or
           vmovtdc = 11 /* Entrada de Montagem */
        then do:
            find forne where forne.forcod = vforcod NO-LOCK no-error.
            if not avail forne
            then do:
                if vmovtdc = 11
                then do:
                    message "Fornecedor Obrigatório para Entrada de Montagem !"
                    view-as alert-box.
                    undo, retry.
                end.
                else do:
                    message "Fornecedor nao Cadastrado !!".
                    undo, retry.
                end.    
            end.
            display
                forne.fornom @ vnome
                forne.ufecod
                with frame f1.
            run not_notgvlclf.p ("Forne", recid(forne), output sresp).
            if not sresp
            then /*return*/.

            if forne.ufecod = "RS"
            then find first opcom where opcom.movtdc = 11 no-lock.
            else find last  opcom where opcom.movtdc = 11 no-lock.
        end.
        else do:
            update vclicod with frame f1.
            if vclicod > 0
            then do:
                find clien where clien.clicod = vclicod NO-LOCK no-error.
                if not avail clien
                then do:
                    message "Cliente nao Cadastrado !!".
                    undo, retry.
                end.
                display clien.clinom @ vnome with frame f1.
                vforcod = vclicod.
                run not_notgvlclf.p ("Clien", recid(clien), output sresp).
                if not sresp
                then return.
                
                if clien.ufecod[1] = "RS"
                then find first opcom where opcom.movtdc = 11 no-lock.
                else find last  opcom where opcom.movtdc = 11 no-lock.
            end.
            else do:
                vforcod = vetbcod.
                find bestab where bestab.etbcod = vetbcod no-lock.
                if bestab.ufecod = "RS"
                then find first opcom where opcom.movtdc = 11 no-lock.
                else find last  opcom where opcom.movtdc = 11 no-lock.
            end.
        end.
    end.

    find first opcom where opcom.movtdc = 11 no-lock. /* Emite = Desti */
    display opcom.opccod with frame f1.

    bl-princ:
    repeat with 1 down:
        vprotot = 0.
        for each w-movim no-lock:
            vprotot = vprotot + w-movim.subtotal.
        end.
        display vprotot with frame f-produ.
        
        hide frame f-produ2 no-pause.
        prompt-for vprocod go-on (F5 F6 F8 F9 F4 PF4
                            F10 E e C c) with frame f-produ.

        if keyfunction(lastkey) = "end-error"
        then do:
            sresp = no.
            if vprotot = 0
            then return.
            message "Confirma Geracao de Nota Fiscal?" update sresp.
            if not sresp
            then do:
                hide frame f-produ1 no-pause.
                hide frame f-produ no-pause.
            end.
            leave.
        end.
        if lastkey = keycode("c") or lastkey = keycode("C")
        then do with frame f-produ2:
            clear frame f-produ2 all no-pause.
            for each w-movim:
                find produ where recid(produ) = w-movim.wrec no-lock.
                disp produ.procod
                     produ.pronom
                     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
                     w-movim.movpc  format ">,>>9.99"  column-label "Custo"
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
                then delete w-movim.
                else w-movim.movqtm = w-movim.movqtm - vqtd.
                hide frame f-exclusao no-pause.
            end.
            clear frame f-produ1 all no-pause.
            for each w-movim with frame f-produ1:
                find produ where recid(produ) = wrec no-lock.
                display produ.procod
                        produ.pronom
                        w-movim.movqtm
                        w-movim.movpc
                        with frame f-produ1.
                down with frame f-produ1.
                pause 0.
            end.
            next.
        end.

        find produ where produ.procod = input vprocod no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao Cadastrado" view-as alert-box.
            undo.
        end.

        display produ.pronom with frame f-produ.
        find estoq where estoq.etbcod = setbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not available estoq
        then do:
            message "Produto Sem Registro de Armazenagem".
            pause.
            undo.
        end.

        display produ.pronom with frame f-produ1.
        vmovqtm = 0.
        find first w-movim where w-movim.wrec = recid(produ) no-lock no-error.
        if not avail w-movim
        then do:
            create w-movim.
            assign w-movim.wrec = recid(produ).
        end.
        vmovqtm = w-movim.movqtm.
        update w-movim.movqtm validate(w-movim.movqtm > 0,
                         "Quantidade Invalida") with frame f-produ1.
        w-movim.movpc = estoq.estCUSTO.
        w-movim.movqtm = VMOVQTM + w-movim.movqtm.
        display w-movim.movqtm with frame f-produ1.
        update w-movim.movpc with frame f-produ1.
        w-movim.subtotal = w-movim.movqtm * w-movim.movpc.

        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = wrec no-lock.
            display produ.procod
                    produ.pronom
                    w-movim.movqtm
                    w-movim.movpc
                     with frame f-produ1.
            down with frame f-produ1.
            pause 0.
        end.
    end.

    if not sresp
    then next.

    /*
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    */
    
    if vprotot = 0
    then do.
        message "Total da nota zerado" view-as alert-box.
        next.
    end.

    find estab where estab.etbcod = vetbcod no-lock.
    run le_tabini.p (estab.etbcod, 0, "NFE - SERIE", OUTPUT vserie).
    do on error undo:
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = ?
               tt-plani.protot   = vprotot
               tt-plani.emite    = estab.etbcod
               tt-plani.descpro  = 0
               tt-plani.acfprod  = 0
               tt-plani.platot   = vprotot
               tt-plani.serie    = vserie
               tt-plani.numero   = ?
               tt-plani.movtdc   = vmovtdc
               tt-plani.desti    = estab.etbcod
               tt-plani.pladat   = today
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = int(opcom.opccod)
               tt-plani.vencod   = vvencod
               tt-plani.notfat   = vforcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.hiccod   = int(opcom.opccod)
               tt-plani.notsit   = no
               tt-plani.outras   = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi   +
                              tt-plani.icmssubst
              tt-plani.isenta    = tt-plani.platot - tt-plani.outras
                                   - tt-plani.bicms.
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
               tt-movim.movdat = tt-plani.pladat
               tt-movim.emite  = tt-plani.emite
               tt-movim.desti  = tt-plani.desti
               tt-movim.MovHr  = tt-plani.horincl
               tt-movim.movcstpiscof = 98.
    end.

    update tt-plani.notobs[1]  label "Inf. Adic." format "x(65)"
           tt-plani.notobs[2] at 13 no-label        format "x(65)"
           tt-plani.notobs[3] at 13 no-label        format "x(65)"
           with frame fif side-label overlay row 16.

    sresp = no.
    message "Confirma autorizar NFe?" update sresp.
    if sresp
    then do:
        if vmovtdc = 51
        then run manager_nfe.p (input "1949_c",input ? ,output v-ok).
        else if vmovtdc = 53
            then run manager_nfe.p (input "1949_l",input ? ,output v-ok).
            else do:
                if vclicod > 0
                then run manager_nfe.p (input "1949_c",input ? ,output v-ok).
                else run manager_nfe.p (input "1949",input ? ,output v-ok).
            end.
    end.
    for each w-movim:
        delete w-movim.
    end.
    hide frame fif no-pause.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    leave.
end.

