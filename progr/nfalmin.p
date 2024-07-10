{admcab.i}

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-movimimp like movimimp.

def var v-ok as log.
def var vmovqtm   like  movim.movqtm.
def var vemite    like  estab.etbcod.
def var vsubtotal like  movim.movqtm.
def var vprotot   like  plani.protot.
def var vdesacess like  plani.desacess.
def var vplatot   like  plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(3)" /*like  plani.serie*/.
def var vhiccod   like  opcom.opccod.
def var vproamx   like  produ.procod.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vcentro01   like estab.etbcod.
def var vcentro02   like estab.etbcod. 
def buffer bestab  for estab.
def buffer bcentro for centro.

def  temp-table w-movim
               field wrec    as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc
               field movpc     as decimal format ">,>>9.99".

form produ.procod
     produ.pronom format "x(30)"
     w-movim.movqtm format ">>>>9" column-label "Qtd"
     w-movim.movpc  format ">,>>9.99" column-label "V.Unit."
     w-movim.subtotal format ">>>,>>9.99" column-label "Total"
     with frame f-produ1 row 6 12 down overlay
                centered color white/cyan width 80.

form vproamx      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 5 no-box width 81.

form
    estab.etbcod  label "Emitente" colon 15
    estab.etbnom  no-label
    vcentro01     label "C.C.Emitente" colon 15
    centro.etbnom no-label
    vetbcod       label "Destinatario" colon 15
    bestab.etbnom no-label format "x(20)"
    vcentro02     label "C.C.Destino" colon 15 
    bcentro.etbnom no-label
    vhiccod       label "CFOP" format "9999" colon 15
    opcom.opcnom  no-label
      with frame f1 side-label color white/cyan width 80 row 4.

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
    disp vemite @ estab.etbcod with frame f1.
    prompt-for estab.etbcod with frame f1.
    find estab where estab.etbcod = input estab.etbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento nao cadastrado".
        undo, retry.
    end.
    display estab.etbnom no-label with frame f1.
    run not_notgvlclf.p ("Estab", recid(estab), output sresp).
    if not sresp
    then undo.

    vemite = input estab.etbcod.
    if (vemite >= 994  and
        vemite <= 998) or
       (vemite >= 994 and
        vemite <= 998) OR
        vemite = 22 or
        vemite = 900 or
        vemite = 988
    then.
    else do:
        message "Emitente invalido".
        pause.
        undo, retry.
    end.
    do on error undo, retry:
        update vcentro01 with frame f1.
        find centro where centro.etbcod = vcentro01 no-lock no-error.
        if not avail centro
        then do:
            message "Centro de Custo nao Cadastrado".
            pause.
            undo, retry.
        end.
        display centro.etbnom with frame f1.
    end.        

    update vetbcod  with frame f1.
    find bestab where bestab.etbcod = vetbcod no-lock no-error.
    if not avail bestab
    then do:
        message "Estabelecimento nao cadastrado".
        undo, retry.
    end.
    display bestab.etbnom no-label with frame f1.
    run not_notgvlclf.p ("Estab", recid(bestab), output sresp).
    if not sresp
    then undo.

    if (bestab.etbcod = 995 and estab.etbcod  = 998) or
       (bestab.etbcod = 998 and estab.etbcod  = 995)
    then do:
        message "Operacao Bloqueada".
        pause.
        undo, retry.
    end.       
    
    if bestab.etbcod = 889
    then do:
        message "Filial desativada". pause.
        undo, retry.
    end.
    
    do on error undo, retry:
        update vcentro02 with frame f1.
        find bcentro where bcentro.etbcod = vcentro02 no-lock no-error.
        if not avail bcentro
        then do:
            message "Centro de Custo nao Cadastrado".
            pause.
            undo, retry.
        end.
        display bcentro.etbnom with frame f1.
    end.        
    vserie = "1".

    find tipmov 36 no-lock.
    run zopcomt.p (tipmov.movtdc, output vhiccod).
    
    disp vhiccod with frame f1.

    find first opcom where opcom.movtdc = tipmov.movtdc
                       and opcom.opccod = vhiccod
                     no-lock no-error.
    if not avail opcom
    then do.
        message "CFOP invalido" view-as alert-box.
        undo.
    end.
    display opcom.opcnom no-label with frame f1.

    do on error undo, retry:
        assign 
           vplatot  = 0.
    clear frame f-produ1 no-pause.

    repeat with 1 down:
        hide frame f-produ2 no-pause.
        hide frame f-aviso no-pause.
        
        for each w-movim where w-movim.movqtm = 0 or
                               w-movim.movpc  = 0 or
                               w-movim.subtotal = 0:
            delete w-movim.
        end.
        clear frame f-produ1 all no-pause.
            
        vprotot = 0.
        for each w-movim with frame f-produ1:
            find produ where recid(produ) = wrec no-lock.
            display produ.procod
                    produ.pronom
                    w-movim.movqtm
                    w-movim.movpc
                    w-movim.subtotal
                       with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
            display vprotot with frame f-produ.
        end.
        
        prompt-for vproamx go-on (F5 F6 F8 F9 F4 PF4
                            F10 E e C c) with frame f-produ.
        v-ok = no.
        if keyfunction(lastkey) = "end-error"
        then do:
            sresp = no.
            message "Confirma Geracao de Nota Fiscal?" update sresp.
            if not sresp
            then do:
                for each w-movim:
                    delete w-movim.
                end.
                vproamx = 0.
                hide frame f-produ1 no-pause.
                hide frame f-produ no-pause.
                v-ok = yes.
                undo, leave.
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
                        w-movim.movqtm
                        w-movim.movpc
                        w-movim.subtotal
                        with frame f-produ1.
                down with frame f-produ1.
                pause 0.
                vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
                display vprotot with frame f-produ.
            end.
            next.
        end.
        find produ where produ.procod = input vproamx no-lock no-error. 
        if not avail produ 
        then do: 
            message "Produto nao Cadastrado". 
            undo.
        end.
        if produ.catcod <> 91
        then do:
            message "Produto Invalido".
            pause.
            undo, retry.
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
        vmovqtm = 0.
        vsubtotal = 0.
        find first w-movim where w-movim.wrec = recid(produ) no-lock no-error.
        if not avail w-movim
        then do:
            create w-movim.
            assign w-movim.wrec = recid(produ)
                   w-movim.movpc = estoq.estcusto.
        end.
        vmovqtm = w-movim.movqtm.
        update w-movim.movqtm validate(w-movim.movqtm > 0,
                         "Quantidade Invalida") with frame f-produ1.
        
        w-movim.movqtm = w-movim.movqtm + vmovqtm.
        
        update w-movim.movpc validate(w-movim.movpc > 0,
                         "Preco Invalida") with frame f-produ1.
        
        vprotot = 0.
        w-movim.subtotal = vsubtotal + (w-movim.movpc * w-movim.movqtm).

        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = wrec no-lock.
            display produ.procod
                    produ.pronom
                    w-movim.movqtm
                    w-movim.subtotal
                    w-movim.movpc
                            with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot = vprotot + (w-movim.movpc * w-movim.movqtm).
            display vprotot with frame f-produ.
        end.
    end.
    if not sresp
    then undo, retry.
    end.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    if v-ok = yes
    then undo, retry.
    
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
 
    find first w-movim where w-movim.movqtm > 0 and
                             w-movim.movpc > 0 no-error.
    if not avail w-movim 
    then undo, leave.
                                 
    run emissao-NFe.     
end.

procedure emissao-NFe:

    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    for each tt-movimimp. delete tt-movimimp. end.

    do transaction:
        vserie  = "1".
        
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.cxacod   = centro.etbcod    /* c.c.emite */
               tt-plani.vencod   = bcentro.etbcod   /* c.c.desti */
               tt-plani.placod   = ?
               tt-plani.emite    = estab.etbcod
               tt-plani.plaufemi = estab.ufecod
               tt-plani.desacess = vdesacess
               tt-plani.serie    = vserie
               tt-plani.numero   = ?
               tt-plani.movtdc   = tipmov.movtdc /***9***/
               tt-plani.desti    = bestab.etbcod
               tt-plani.plaufdes = bestab.ufecod
               tt-plani.pladat   = today
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = int(opcom.opccod)
               tt-plani.notfat   = bestab.etbcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.hiccod   = int(vhiccod)
               tt-plani.outras = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi.
              tt-plani.isenta = tt-plani.platot - tt-plani.outras.
    end.
   
    for each w-movim:
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movim.wrec no-lock no-error.
        if not avail produ
        then next.
        do transaction:
            tt-plani.protot = tt-plani.protot + (w-movim.movqtm * w-movim.movpc).
            tt-plani.platot = tt-plani.platot + (w-movim.movqtm * w-movim.movpc).

            create tt-movim.
            ASSIGN tt-movim.movtdc = tipmov.movtdc /***9***/
                   tt-movim.PlaCod = tt-plani.placod
                   tt-movim.etbcod = tt-plani.etbcod
                   tt-movim.movseq = vmovseq
                   tt-movim.procod = produ.procod
                   tt-movim.movqtm = w-movim.movqtm
                   tt-movim.movpc  = w-movim.movpc
                   tt-movim.movdat = tt-plani.pladat
                   tt-movim.MovHr  = tt-plani.horincl
                   tt-movim.emite  = tt-plani.emite.
                   tt-movim.desti  = tt-plani.desti.    
        end.
        delete w-movim.
    end.

    run manager_nfe.p (input "5552", input ?, output sresp).
end procedure.
