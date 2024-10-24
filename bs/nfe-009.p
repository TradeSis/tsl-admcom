{cabec.i}

def input parameter par-movtdc like tipmov.movtdc.

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.

def var vok as log.
def var v-ok as log format "Sim/Nao".
def var vmovqtm   like  movim.movqtm.
def var vemite    like  estab.etbcod.
def var vtrans    like  clien.clicod.
def var vsubtotal like  movim.movqtm.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms .
def var vprotot   like  plani.protot.
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
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vtotal      like plani.platot.
def buffer bestab for estab.
def buffer xestab for estab.

def temp-table w-movim
    field wrec      as   recid
    field movqtm    like movim.movqtm
    field subtotal  like movim.movpc
    field movpc     like movim.movpc format ">>,>>9.99"
    /***field ocnum     like movim.ocnum***/.

form produ.procod
     produ.pronom format "x(30)"
     w-movim.movqtm format ">>>>9" column-label "Qtd"
     w-movim.movpc  format ">>,>>9.99" column-label "V.Unit."
     w-movim.subtotal format ">>>,>>9.99" column-label "Total"
     /***w-movim.ocnum[1]***/
     with frame f-produ1 row 9 10 down overlay
                centered color white/cyan width 80.

form vprocod      label "Codigo"
     produ.pronom no-label format "x(25)"
     vprotot
     with frame f-produ centered color message side-label
                        row 8 no-box width 80.

def var v-title as char.
find tipmov where tipmov.movtdc = par-movtdc no-lock.
find first opcom where opcom.movtdc = tipmov.movtdc and
                       substr(opcom.opccod,1,1) = "5" no-lock.
v-title = opcom.opccod + " - " + opcom.opcnom.

form
    estab.etbcod  label "Emitente" colon 15
    estab.etbnom  no-label
    estab.ufecod  label "UF Emi"
    vetbcod       label "Destinatario" colon 15
    bestab.etbnom no-label
    bestab.ufecod label "UF Des"
    with frame f1 side-label color white/cyan width 80 row 4
      title string(v-title,"x(70)").

repeat:
    for each w-movim:
        delete w-movim.
    end.
    clear frame f1 all no-pause.
    clear frame f-produ all no-pause.
    clear frame f-produ1 all no-pause.
    clear frame f-produ2 all no-pause.
    clear frame f-exclusao all no-pause.
    hide frame f1 no-pause.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    hide frame f-produ2 no-pause.
    hide frame f-exclusao no-pause.

    disp vemite @ estab.etbcod with frame f1.
    prompt-for estab.etbcod with frame f1.

    vemite = input frame f1 estab.etbcod.
    find estab where estab.etbcod = vemite no-lock no-error.
    if not avail estab
    then do:
        message "Emitente nao cadastrado." view-as alert-box.
        undo, retry.
    end.    
    run not_notgvlclf.p ("estab", recid(estab), output sresp).
    if not sresp
    then undo.
    
/***    {valetbnf.i estab vemite ""Emitente""} ***/
/***
    if (vemite >= 993 and
        vemite <= 998) or
        vemite = 22 or
        vemite = 996 or 
        vemite = 995 or
        vemite = 999 or
        vemite = 980
    then.
    else do:
        if vemite <> 997
        then do:
            message "Emitente invalido".
            pause.
            undo, retry.
        end.
    end.
***/
    display estab.etbnom estab.ufecod with frame f1.

    update vetbcod  with frame f1.
/***
    if vetbcod = 998 
    then do:
        message "Deposito nao liberado para transferencia.".
        pause.
        undo, retry.
    end.
***/

    find bestab where bestab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Destinatario nao cadastrado." view-as alert-box.
        undo, retry.
    end.    
    run not_notgvlclf.p ("estab", recid(bestab), output sresp).
    if not sresp
    then undo.

/***
    if (bestab.etbcod = 995 and
        estab.etbcod  = 998) or
       (bestab.etbcod = 998 and
        estab.etbcod  = 995)
    then do:
        message "Operacao Bloqueada".
        pause.
        undo, retry.
    end.       
***/
    display bestab.etbnom bestab.ufecod with frame f1.

    do on error undo, retry:

    assign vbicms  = 0
           vicms   = 0
           vfrete  = 0
           vipi    = 0
           vdescpro = 0
           vacfprod = 0
           vplatot  = 0
           vtotal = 0.
    vplatot = (vbicms + vfrete + vipi)  - vdescpro.
    vtotal = vipi + vdesacess + vseguro + vfrete + vprotot - vdescpro.
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
                    /***w-movim.ocnum[1]***/
                    with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot = vprotot + (w-movim.movqtm * w-movim.movpc).
            display vprotot with frame f-produ.
        end.
        
        prompt-for vprocod go-on (F5 F6 F8 F9 F4 PF4
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
                vprocod = 0.
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
                     w-movim.movpc  format ">>,>>9.99" column-label "Custo"
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
                     w-movim.subtotal = w-movim.movqtm * w-movim.movpc.
            end.
            hide frame f-exclusao no-pause.
            vprotot = 0.
            clear frame f-produ1 all no-pause.
            for each w-movim with frame f-produ1:
                find produ where recid(produ) = wrec no-lock.
                display produ.procod
                        produ.pronom
                        w-movim.movqtm
                        w-movim.movpc
                        w-movim.subtotal
                        /***w-movim.ocnum[1]***/
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
        else do:
            if produ.proseq = 98 or
               produ.proseq = 99
            then do:
                message "Transferencia bloqueada para produto INATIVO."
                    view-as alert-box.
                undo.
            end.
            if produ.codfis = 0
            then do.
                message "Produto sem NCM" view-as alert-box.
                undo.
            end.
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
        do on error undo, retry:
            update w-movim.movqtm validate(w-movim.movqtm > 0,
                         "Quantidade Invalida") with frame f-produ1.
        
            w-movim.movqtm = w-movim.movqtm + vmovqtm.
            if w-movim.movqtm > 1000
            then do:
                sresp = no.
                message "Confirma esta quantidade?" update sresp.
                if not sresp
                then undo, retry.
            end.
        end.        
        
        if estab.etbcod <> 22 and estab.etbcod <> 996 and estab.etbcod <> 999
        then do:
            if ((estoq.estatual - estoq.estpedcom) >= 0 and 
               ((estoq.estatual - estoq.estpedcom) - w-movim.movqtm) < 0) or
                (estoq.estatual - estoq.estpedcom) < 0 
            then do:
                display  
                    "Qtd Estoque :" at 5 (estoq.estatual - estoq.estpedcom)                                                        no-label format "->>,>>9.99"
                    "Qtd Desejada:" at 5 w-movim.movqtm 
                                            no-label format "->>,>>9.99"
                    with frame f-aviso overlay row 10
                                side-label centered 
                                    title "Estoque nao possui esta Quantidade".
                pause.
                delete w-movim. 
                undo, retry.
            end.
        end.
        
        display w-movim.movpc with frame f-produ1.
        
        vprotot = 0.
        w-movim.subtotal = vsubtotal + (w-movim.movpc * w-movim.movqtm).
        
/***
        if estab.etbcod = 22 and bestab.etbcod = 995
        then do on error undo:
            update w-movim.ocnum[1] column-label "Pedido"
                with frame f-produ1.
            if w-movim.ocnum[1] > 0
            then do:
            find pedid where
                 pedid.etbcod = 996 and
                 pedid.pednum = w-movim.ocnum[1] and
                 pedid.pedtdc = 1 no-lock no-error.
            if not avail pedid
            then do:
                message "Pedido nao encontrado." .
                pause.
                undo.
            end.    
            end.
        end.
***/
        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = wrec no-lock.
            display produ.procod
                    produ.pronom
                    w-movim.movqtm
                    w-movim.subtotal
                    w-movim.movpc
                    /***w-movim.ocnum[1]***/
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
    find first w-movim where w-movim.movqtm > 0 and
                             w-movim.movpc > 0 no-error.
                             
    if not avail w-movim 
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

    find first w-movim where w-movim.movqtm > 0 and
                             w-movim.movpc > 0 no-error.
    if not avail w-movim 
    then undo, leave.
    
    /*******************/
    vserie = "1". 
    create tt-plani.
    assign
        tt-plani.placod   = ?
        tt-plani.etbcod   = estab.etbcod
        tt-plani.emite    = estab.etbcod
        tt-plani.plaufemi = estab.ufecod
        tt-plani.desti    = bestab.etbcod
        tt-plani.plaufdes = bestab.ufecod
        tt-plani.notfat   = bestab.etbcod

               tt-plani.bicms    = vbicms
               tt-plani.icms     = vicms
               tt-plani.frete    = vfrete
               tt-plani.alicms   = tt-plani.icms * 100 / (tt-plani.bicms *
                                (1 - (0 / 100)))
               tt-plani.descpro  = vdescpro
               tt-plani.acfprod  = vacfprod
               tt-plani.frete    = vfrete
               tt-plani.seguro   = vseguro
               tt-plani.desacess = vdesacess
               tt-plani.ipi      = vipi
               tt-plani.serie    = vserie
               tt-plani.numero   = vnumero

        tt-plani.movtdc   = tipmov.movtdc
        tt-plani.pladat   = today
        tt-plani.modcod   = tipmov.modcod
        tt-plani.opccod   = int(opcom.opccod)
        tt-plani.dtinclu  = today
        tt-plani.horincl  = time
        tt-plani.notsit   = no
        tt-plani.hiccod   = int(opcom.opccod)
        tt-plani.nottran  = vtrans
        tt-plani.notobs[3] = "D"
               tt-plani.outras = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi   +
                              tt-plani.icmssubst
               tt-plani.isenta = tt-plani.platot 
                        - tt-plani.outras - tt-plani.bicms.

    for each w-movim:
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movim.wrec no-lock no-error.
        if not avail produ
        then next.
        tt-plani.protot = tt-plani.protot + (w-movim.movqtm * w-movim.movpc).
        tt-plani.platot = tt-plani.platot + (w-movim.movqtm * w-movim.movpc).

        create tt-movim.
        ASSIGN tt-movim.movtdc = tt-plani.movtdc
               tt-movim.PlaCod = tt-plani.placod
               tt-movim.etbcod = tt-plani.etbcod
               tt-movim.movseq = vmovseq
               tt-movim.procod = produ.procod
               tt-movim.movqtm = w-movim.movqtm
               tt-movim.movpc  = w-movim.movpc
               tt-movim.movdat = tt-plani.pladat
               tt-movim.MovHr  = tt-plani.horincl
               tt-movim.emite  = tt-plani.emite
               tt-movim.desti  = tt-plani.desti
               /***tt-movim.ocnum[1] = w-movim.ocnum[1]***/ .

        delete w-movim.
    end.
    sresp = no.
    message "Confirma Emissao da Nota ?" update sresp.
    if sresp
    then run manager_nfe.p (input "5552",
                            input ?,
                            output vok).
end.

