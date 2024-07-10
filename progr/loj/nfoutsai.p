{admcab.i}

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.

def var v-title as char.
def var vmovtdc like tipmov.movtdc init ?.

run sel-operacao.
if vmovtdc = ?
then return.

def var vdesc    like plani.descprod format ">9.99 %".
def var i as i.
def var v-ok as log.
def buffer bclien for clien.
def var vforcod   like forne.forcod.
def var vufecod   as char.
def var vmovqtm   like  movim.movqtm.
def var vvencod   like plani.vencod.
def var vsubtotal like  movim.movqtm.
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vplatot   like  plani.platot.
def var vtotal    like plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(03)".
def var vopccod   like  plani.opccod.
def var vprocod   like  produ.procod.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.

def buffer bplani for plani.

def temp-table w-movim
               field wrec    as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc
               field movpc     as decimal format ">,>>9.99".

form produ.procod
     produ.pronom
     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
     w-movim.movpc  format ">,>>9.99" column-label "V.Unit."
     with frame f-produ1 row 10 8 down overlay
                centered color white/cyan width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 9 no-box width 81.

find tipmov where tipmov.movtdc = 26 no-lock.
find first opcom where opcom.opccod = "5949" no-lock.

def var vclicod like clien.clicod.
def var vnome like forne.fornom. 
form
    vetbcod  label "Filial" colon 15
    estab.etbnom  no-label
    vforcod       label "Fornecedor" colon 15
    vclicod       label "Cliente"
    vnome no-label  FORMAT "X(30)"
    opcom.opccod label "Op. Fiscal" colon 15
    opcom.opcnom no-label
      with frame f1 side-label width 80 row 4 color white/cyan title v-title.

def buffer bestab for estab.

REPEAT:
    for each w-movim:
        delete w-movim.
    end.
    clear frame f1 no-pause.
    clear frame f-produ no-pause.
    clear frame f-produ1 no-pause.
    clear frame f-produ2 no-pause.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause .
    hide frame f-produ2  no-pause.
    hide frame f1 no-pause.
    
    find tipmov where tipmov.movtdc = 26 no-lock.
   
    vetbcod = setbcod.
    disp vetbcod with frame f1.
    {valetbnf.i estab vetbcod ""Filial""}
    disp estab.etbnom with frame f1.
   
    do on error undo:
        update vforcod with frame f1.
        if vforcod > 0 or vmovtdc = 26 /* Saída para montagem */
        then do:
            find forne where forne.forcod = vforcod no-error.
            if not avail forne
            then do:
                if vmovtdc = 26
                then do:
                    message "Fornecedor Obrigatório para Saída para Montagem !!"
                    view-as alert-box.
                    undo, retry.
                end.
                else do:                                          
                    message "Fornecedor nao Cadastrado !!".
                    undo, retry.
                end.
            end.
            display forne.fornom @ vnome with frame f1.
            vufecod = forne.ufecod.
        end.
        else do:
            update vclicod with frame f1.
            find clien where clien.clicod = vclicod no-lock no-error.
            if not avail clien
            then do:
                message "Cliente não cadastrado.".
                undo, retry.
            end.
            disp clien.clinom @ vnome with frame f1.    
            vforcod = vclicod.
            vufecod = clien.ufecod[1].
        end.

        if vufecod = "RS"
        then find first opcom where opcom.opccod = "5949" no-lock.
        else find first opcom where opcom.opccod = "6949" no-lock.
        display opcom.opccod with frame f1.
    end.
    
    do on error undo, retry:
    assign vprotot1 = 0
           vplatot  = 0
           vtotal = 0.

    clear frame f-produ1 no-pause.
    bl-princ:
    repeat with 1 down:
        hide frame f-produ2 no-pause.
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
            else leave.
        end.
        if lastkey = keycode("c") or lastkey = keycode("C")
        then do with frame f-produ2:
            clear frame f-produ2 all no-pause.
            for each w-movim:
                find produ where recid(produ) = w-movim.wrec no-lock.
                disp produ.procod
                     produ.pronom
                     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
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
        find estoq where estoq.etbcod = setbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not available estoq
        then do:
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
            assign w-movim.wrec = recid(produ).
        end.
        vmovqtm = w-movim.movqtm.
        update w-movim.movqtm validate(w-movim.movqtm > 0,
                         "Quantidade Invalida") with frame f-produ1.
        w-movim.movpc = estoq.estCUSTO.
        w-movim.movqtm = VMOVQTM + w-movim.movqtm.
        display w-movim.movqtm with frame f-produ1.
        update w-movim.movpc with frame f-produ1.
        vprotot = 0.
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
            vprotot = vprotot + w-movim.subtotal.
            display vprotot with frame f-produ.
        end.
    end.
    if not sresp
    then undo, retry.
    end.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    if v-ok = yes
    then undo, leave.
    find estab where estab.etbcod = vetbcod no-lock.
    
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

    run le_tabini.p (estab.etbcod, 0, "NFE - SERIE", OUTPUT vserie).
    
    do on error undo:
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = ?
               tt-plani.emite    = estab.etbcod
/***
               tt-plani.protot   = vprotot
               tt-plani.bicms    = vprotot
               tt-plani.icms     = vprotot * (17 / 100)
               tt-plani.descpro  = vprotot * (vdesc / 100)
               tt-plani.platot   = vprotot - (vprotot * (vdesc / 100))
***/
               tt-plani.serie    = vserie
               tt-plani.numero   = ?
               tt-plani.movtdc   = vmovtdc
               tt-plani.desti    = vforcod
               tt-plani.pladat   = today
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = int(opcom.opccod)
               tt-plani.vencod   = vvencod
               tt-plani.notfat   = vforcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.hiccod   = int(opcom.opccod)
               tt-plani.notsit   = no
               tt-plani.outras = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi   +
                              tt-plani.icmssubst
              tt-plani.isenta = tt-plani.platot 
                              - tt-plani.outras - tt-plani.bicms.
         end.

    find first tt-plani where tt-plani.etbcod = estab.etbcod.
    tt-plani.platot = 0.
    tt-plani.protot = 0.
    
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
               tt-movim.MovHr  = tt-plani.horincl.
        if forne.forinest = "" or forne.forinest begins "ISEN"
        then tt-movim.movcsticms = "40".
        else tt-movim.movcsticms = "51".
        tt-plani.platot = tt-plani.platot + (tt-movim.movpc * tt-movim.movqtm).
        tt-plani.protot = tt-plani.protot + (tt-movim.movpc * tt-movim.movqtm).
    end.

    if vmovseq = 0
    then do:    
        message "Nota Fiscal sem itens, a emissão será cancelada!"
                view-as alert-box.
        undo, retry.
    end.
    v-ok = no.
    if vmovtdc = 52
    then run manager_nfe.p (input "5949_c", input ?, output v-ok).
    else do:
        if vclicod > 0
        then run manager_nfe.p (input "5949_c", input ?, output v-ok).
        else run manager_nfe.p (input "5949", input ?, output v-ok).
    end.
    for each w-movim:
        delete w-movim.
    end.
    leave.
end.


procedure sel-operacao:
    def var vselope as char extent 4 format "x(40)".
    vselope[1] = "REMESSA ESTUDIO FOTOGRAFICO".
    vselope[2] = "SAIDA PARA MONTAGEM".

    disp vselope with frame f-selop 1 down side-label
         no-label 1 column centered row 7 overlay.
    choose field vselope with frame f-selop.
    if frame-index = 1
    then vmovtdc = 56.
    else if frame-index = 2
    then vmovtdc = 26.
    v-title = vselope[frame-index].
end procedure.

