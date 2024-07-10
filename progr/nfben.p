{admcab.i}

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.

def var nfe-emite like plani.emite.

def buffer xestab for estab.
def var vforcod like forne.forcod.
def var vmovqtm   like  movim.movqtm.
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
def var vtofcod   like  tofis.tofcod label "Op.Fiscal" format ">>>9". 
def var vprocod   like  produ.procod.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotal      like plani.platot.
def buffer bestab for estab.
def buffer bplani for plani.

def temp-table w-movim
               field wrec    as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc
               field movpc     as decimal format ">,>>9.99".

form produ.pronom format "x(30)"
     w-movim.movqtm format ">>>>9" column-label "Qtd"
     w-movim.movpc  format ">,>>9.99" column-label "V.Unit."
     w-movim.subtotal format ">>,>>9.99" column-label "Total"
     with frame f-produ1 row 15 2 down overlay
                centered color white/cyan width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 14 no-box width 81 overlay.

form
    estab.etbcod  label "Emitente" colon 15
    estab.etbnom  no-label
    vforcod       label "Fornecedor" colon 15
    forne.fornom no-label format "x(20)"
    forne.ufecod
    vtofcod       colon 15
    tofis.tofnom no-label
    vserie        colon 15
    vnumero
    vpladat       colon 15
    with frame f1 side-label color white/cyan width 80 row 4.

repeat:
    for each w-movim:
        delete w-movim.
    end.
    clear frame f1 no-pause.
    clear frame f-produ1 no-pause.

    prompt-for estab.etbcod with frame f1.
    vetbcod = input frame f1 estab.etbcod.
    {valetbnf.i estab vetbcod ""Emitente""}
    display estab.etbnom no-label with frame f1.
    if (estab.etbcod >= 994 and
        estab.etbcod <= 998) or
        estab.etbcod = 988 or
        estab.etbcod = 995 or
        estab.etbcod = 996 or
        estab.etbcod = 22  or
        estab.etbcod = 993 or
        estab.etbcod = 900
    then.
    else do:
        message "Emitente invalido".
        pause.
        undo, retry.
    end.

    update vforcod with frame f1.
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do:
        message "Fornecedor nao cadastrado".
        undo, retry.
    end.
    display forne.fornom forne.ufecod with frame f1. 

    run not_notgvlclf.p ("Forne", recid(forne), output sresp).
    if not sresp
    then undo, retry.
    display forne.fornom forne.ufecod with frame f1.

    vtofcod = 5949.
    update vtofcod with frame f1.
    find tofis where tofis.tofcod = vtofcod no-lock.
    display tofis.tofnom no-label with frame f1.

    if vetbcod <> 995 and
       vetbcod <> 993 and
       vetbcod <> 998 and
       vetbcod <> 988 and
       vetbcod <> 900
    then do:
    vserie = "U". 
    display vserie with frame f1. 
    if vserie = "" 
    then do: 
        message "Serie deve ser U ou M1". 
        undo, retry.
    end.

    find last plani use-index numero 
                where plani.etbcod = estab.etbcod and
                      plani.emite  = estab.etbcod and
                      plani.serie  = vserie       and
                      plani.movtdc <> 4           and
                      plani.movtdc <> 5 no-lock no-error. 
    if not avail plani 
    then vnumero = 1. 
    else vnumero = plani.numero + 1.
    
    if  estab.etbcod = 995
    then do: 
        vnumero = 0. 
        for each xestab where xestab.etbcod = 998 or
                              xestab.etbcod = 995 no-lock.
                                 
            find last plani use-index numero 
                    where plani.etbcod = xestab.etbcod and
                          plani.emite  = xestab.etbcod and
                          plani.serie  = vserie       and
                          plani.movtdc <> 4           and
                          plani.movtdc <> 5 no-lock no-error. 
                      
            if not avail plani 
            then vnumero = 1. 
            else do: 
                if vnumero < plani.numero 
                then vnumero = plani.numero.
            end.    
        end.
        if vnumero = 1 
        then. 
        else vnumero = vnumero + 1.
    end.   

    if estab.etbcod = 998 or 
       estab.etbcod = 993 or
       estab.etbcod = 900
    then do: 
        vnumero = 0. 
        for each xestab where xestab.etbcod = 993 or
                              xestab.etbcod = 998 or
                              xestab.etbcod = 900
                                no-lock,
                                 
            last plani use-index numero 
                    where plani.etbcod = xestab.etbcod and
                          plani.emite  = xestab.etbcod and
                          plani.serie  = "U"       and
                          plani.movtdc <> 4           and
                          plani.movtdc <> 5           and
     /*                     plani.numero < 100000     and  */
                          plani.pladat >= 08/19/2009.
/*12/01/2006 */
                      
            if not avail plani 
            then vnumero = 1. 
            else do:
                if vnumero < plani.numero 
                then assign vnumero = plani.numero.
            end.    
        end.
        if vnumero = 1 
        then. 
        else vnumero = vnumero + 1.
    end. 
    
    disp vnumero with frame f1.
    {valnumnf.i vnumero}    

    find first plani where plani.numero = vnumero and
                     plani.emite  = estab.etbcod and
                     plani.serie  = vserie and
                     plani.etbcod = estab.etbcod and
                     plani.movtdc = 14 no-lock no-error.
    if avail plani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.
    end.
    else do:
        vserie = "1".
        display vserie with frame f1.
    end.        
    do on error undo, retry:
        find tipmov where tipmov.movtdc = 14 no-lock.
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

    vplatot = (vbicms + vfrete + vipi)  - vdescpro.
    vtotal = vipi + vdesacess + vseguro + vfrete +
             vprotot - vdescpro.
    clear frame f-produ1 no-pause.
    repeat with 1 down:
        hide frame f-produ2 no-pause.
        prompt-for vprocod go-on (F5 F6 F8 F9 F4 PF4
                            F10 E e C c) with frame f-produ.

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
        if lastkey = keycode("c") or lastkey = keycode("C")
        then do with frame f-produ2:
            clear frame f-produ2 all no-pause.
            for each w-movim:
                find produ where recid(produ) = w-movim.wrec no-lock.
                disp produ.pronom format "x(30)"
                     w-movim.movqtm format ">>>>9" column-label "Qtd"
                     w-movim.subtotal
                            format ">>,>>9.99" column-label "Total"
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
            find produ where produ.procod = v-procod no-error.
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
                display produ.pronom
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
        vant = no.
        find produ where produ.procod = input vprocod no-error.
        if not avail produ
        then do:
            message "Produto nao Cadastrado".
            undo.
        end.
        else vant = yes.
        display produ.pronom with frame f-produ.
        if produ.procod >= 40 and
           produ.procod <= 50
        then do transaction:
            update produ.pronom with frame f-produ.
        end.
        find produ where produ.procod = input vprocod no-lock.

        find estoq where estoq.etbcod = setbcod and
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
                   w-movim.subtotal = estoq.estcusto.
        end.
        else assign vmovqtm = w-movim.movqtm
                    vsubtotal = w-movim.subtotal.

        update  w-movim.movqtm validate(w-movim.movqtm > 0,
                         "Quantidade Invalida") with frame f-produ1.
        vprotot = 0.
        w-movim.movqtm = vmovqtm + w-movim.movqtm.
        w-movim.subtotal = vsubtotal + (w-movim.subtotal * w-movim.movqtm).
        w-movim.movpc = w-movim.subtotal / w-movim.movqtm.
        w-movim.movpc = estoq.estcusto.
        update w-movim.movpc with frame f-produ1.

        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = wrec no-lock.
            display produ.pronom
                    w-movim.movqtm
                    w-movim.subtotal
                    w-movim.movpc
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

    if vetbcod <> 995 and
       vetbcod <> 993 and
       vetbcod <> 998 and
       vetbcod <> 988 and
       vetbcod <> 900
    then do:

    find last bplani where bplani.etbcod = estab.etbcod and
                           bplani.placod <= 500000 no-lock no-error.
    if not avail bplani
    then vplacod =  1.
    else vplacod = bplani.placod + 1.
    if not sresp
    then undo, retry.
    
    do on error undo:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.placod   = vplacod
               plani.protot   = vprotot
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
               plani.platot   = vprotot
               plani.serie    = vserie
               plani.numero   = vnumero
               plani.movtdc   = tipmov.movtdc
               plani.desti    = forne.forcod
               plani.pladat   = vpladat
               plani.modcod   = tipmov.modcod
               plani.opccod   = 14
               plani.hiccod   = tofis.tofcod
               plani.notfat   = forne.forcod
               plani.dtinclu  = today
               plani.horincl  = time
               plani.notsit   = no
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
                         plani.placod = vplacod and
                         plani.serie = vserie no-lock.
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
               movim.movdat    = plani.pladat
               movim.MovHr     = int(time)
               movim.desti     = plani.desti
               movim.emite     = plani.emite.
        
        run atuest.p (input recid(movim),
                      input "I", 
                      input 0).
                      
    end.
    message "Confirma Emissao da Nota " update sresp.
    if sresp
    then run impben_l.p (input recid(plani)).
    
    for each produ where produ.procod >= 40 and
                         produ.procod <= 50:
    
        do transaction:
            produ.pronom = "PRODUTO TEMPORARIO".
        end.
    
        for each estoq where estoq.procod = produ.procod.

            do transaction:
                estoq.estatual = 0.
                estoq.estcusto = 0.
                estoq.estvenda = 0.
            end.
        
            for each hiest where hiest.etbcod = estoq.etbcod and
                                 hiest.procod = estoq.procod:
                do transaction:
                    hiest.hiestf = 0.
                    hiest.hiepcf = 0.
                    hiest.hiepvf = 0.
                end.
            end.
    
        end.
    end.
    end.
    else do:
        run emissao-NFe.
    end.
end.
        
procedure emissao-NFe:
        
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
     
    do on error undo:
        vplacod = ?.
        vnumero = ?.
        vserie  = "1".
        
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = vplacod
               tt-plani.protot   = vprotot
               tt-plani.emite    = estab.etbcod
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
               tt-plani.platot   = vprotot
               tt-plani.serie    = vserie
               tt-plani.numero   = vnumero
               tt-plani.movtdc   = tipmov.movtdc
               tt-plani.desti    = forne.forcod
               tt-plani.pladat   = vpladat
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = tofis.tofcod
               tt-plani.hiccod   = tofis.tofcod
               tt-plani.notfat   = forne.forcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.nottran  = vtrans
               tt-plani.outras = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi   +
                              tt-plani.icmssubst
              tt-plani.isenta = tt-plani.platot - tt-plani.outras - tt-plani.bicms.
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
               tt-movim.movdat    = tt-plani.pladat
               tt-movim.MovHr     = int(time)
               tt-movim.desti     = tt-plani.desti
               tt-movim.emite     = tt-plani.emite.
    end.

    def var p-ok as log init no.
    def var p-valor as char.
    p-valor = "".
    if vetbcod = 998
    then nfe-emite = 900.
    else nfe-emite = vetbcod.
    
    run le_tabini.p (nfe-emite, 0,
            "NFE - TIPO DOCUMENTO", OUTPUT p-valor) .
    if p-valor = "NFE"
    then do:
        run manager_nfe.p (input "5949",
                           input ?,
                           output p-ok).
    end.

end.
