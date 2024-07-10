{admcab.i}
def var recpla as recid.
def var recmov as recid.
def var v-ok as log.
def var vmovqtm   like  movimamx.movqtm.
def var vemite    like  centro.etbcod.
def var vtrans    like  clien.clicod.
def var vsubtotal like  movimamx.movqtm.
def var vciccgc   like  clien.ciccgc.
def var valicota  like  planiamx.alicms format ">9,99".
def var vpladat   like  planiamx.pladat.
def var vnumero   like  planiamx.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  planiamx.bicms.
def var vicms     like  planiamx.icms .
def var vprotot   like  planiamx.protot.
def var vprotot1  like  planiamx.protot.
def var vdescpro  like  planiamx.descpro.
def var vacfprod  like  planiamx.acfprod.
def var vfrete    like  planiamx.frete.
def var vseguro   like  planiamx.seguro.
def var vdesacess like  planiamx.desacess.
def var vipi      like  planiamx.ipi.
def var vplatot   like  planiamx.platot.
def var vetbcod   like  planiamx.etbcod.
def var vserie    like  planiamx.serie.
def var vopccod   like  planiamx.opccod.

def var vhiccod   like  planiamx.hiccod label "Op.Fiscal" initial 522.

def var vproamx   like  produamx.procod.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movimamx.movqtm.
def var v-procod    like produamx.procod no-undo.
def var vmovseq     like movimamx.movseq.
def var vplacod     like planiamx.placod.
def var vtotal      like planiamx.platot.
def buffer bcentro for centro.
def buffer bplaniamx for planiamx.
def buffer xcentro for centro.

def  temp-table w-movimamx
               field wrec      as   recid
               field movqtm    like movimamx.movqtm
               field subtotal  like movimamx.movpc
               field movpc     as decimal format ">,>>9.99".

form produamx.procod
     produamx.pronom format "x(30)"
     w-movimamx.movqtm format ">>>>9" column-label "Qtd"
     w-movimamx.movpc  format ">,>>9.99" column-label "V.Unit."
     w-movimamx.subtotal format ">>>,>>9.99" column-label "Total"
     with frame f-produamx1 row 6 12 down overlay
                centered color white/cyan width 80.

form vproamx      label "Codigo"
     produamx.pronom  no-label format "x(25)"
     vprotot
         with frame f-produamx centered color message side-label
                        row 5 no-box width 81.

form
    centro.etbcod  label "Emitente" colon 15
    centro.etbnom  no-label
    vetbcod        label "Destinatario" colon 15
    bcentro.etbnom no-label format "x(20)"
    vserie  colon 15  label "Serie"
    vnumero
    vpladat       colon 15
      with frame f1 side-label color white/cyan width 80 row 4.

repeat:
    for each w-movimamx:
        delete w-movimamx.
    end.
    clear frame f1 all no-pause.
    clear frame f2 all no-pause.
    clear frame f-produamx all no-pause.
    clear frame f-produamx1 all no-pause.
    clear frame f-produamx2 all no-pause.
    clear frame f-exclusao all no-pause.
    hide frame f1 no-pause.
    hide frame f2 no-pause.
    hide frame f-produamx no-pause.
    hide frame f-produamx1 no-pause.
    hide frame f-produamx2 no-pause.
    hide frame f-exclusao no-pause.
    disp vemite @ centro.etbcod with frame f1.
    prompt-for centro.etbcod with frame f1.
    find centro where centro.etbcod = input centro.etbcod no-lock no-error.
    if not avail centro
    then do:
        message "centroelecimento nao cadastrado".
        undo, retry.
    end.
    vemite = input centro.etbcod.
    display centro.etbnom no-label with frame f1.
    update vetbcod  with frame f1.
    find bcentro where bcentro.etbcod = vetbcod no-lock no-error.
    if not avail bcentro
    then do:
        message "centroelecimento nao cadastrado".
        undo, retry.
    end.
    display bcentro.etbnom no-label with frame f1.

    /******** Pega a ultima nota e gera a numero *****/
    find last bplaniamx where bplaniamx.etbcod = centro.etbcod and
                           bplaniamx.placod <= 500000 and
                           bplaniamx.placod <> ? no-lock no-error.
    if not avail bplaniamx
    then vplacod = 1.
    else vplacod = bplaniamx.placod + 1.
    vserie = "U".
    display vserie with frame f1.

    find last planiamx use-index numero  
                where planiamx.etbcod = centro.etbcod and
                      planiamx.emite  = centro.etbcod and
                      planiamx.serie  = vserie no-lock no-error.
    if not avail planiamx
    then vnumero = 1.
    else vnumero = planiamx.numero + 1.
    
    /************************************************/
    display vnumero with frame f1.
    find first planiamx where planiamx.numero = vnumero and
                     planiamx.emite  = centro.etbcod and
                     planiamx.serie  = vserie and
                     planiamx.etbcod = centro.etbcod and
                     planiamx.movtdc = 6  no-error.
    if avail planiamx
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.
    do on error undo, retry:
        find tipmov where tipmov.movtdc = 6  no-lock.
        update vpladat
                with frame f1.
        if vpladat > today + 3 or vpladat < today - 30
        then do:
            message "Data Invalida".
            undo, retry.
        end.
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
    clear frame f-produamx1 no-pause.
    repeat with 1 down:
        hide frame f-produamx2 no-pause.
        hide frame f-aviso no-pause.
        prompt-for vproamx go-on (F5 F6 F8 F9 F4 PF4
                            F10 E e C c) with frame f-produamx.
        v-ok = no.
        if keyfunction(lastkey) = "end-error"
        then do:
            sresp = no.
            message "Confirma Geracao de Nota Fiscal" update sresp.
            if not sresp
            then do:
                for each w-movimamx:
                    delete w-movimamx.
                end.
                vproamx = 0.
                hide frame f-produamx1 no-pause.
                hide frame f-produamx no-pause.
                v-ok = yes.
                undo, leave.
            end.
            else leave.
        end.
        if lastkey = keycode("c") or lastkey = keycode("C")
        then do with frame f-produamx2:
            clear frame f-produamx2 all no-pause.
            for each w-movimamx:
                find produamx where recid(produamx) = w-movimamx.wrec no-lock.
                disp produamx.procod
                     produamx.pronom format "x(30)"
                     w-movimamx.movqtm format ">,>>9.99" column-label "Qtd"
                     w-movimamx.subtotal
                            format ">>>,>>9.99" column-label "Total"
                     w-movimamx.movpc  format ">,>>9.99" column-label "Custo"
                            with frame f-produamx2 row 5 9 down  overlay
                              centered color message width 80.
                down with frame f-produamx2.
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
            find produamx where produamx.procod = v-procod no-lock no-error.
            if not avail produamx
            then do:
                message "produamxto nao Cadastrado".
                undo.
            end.
            find first w-movimamx where w-movimamx.wrec = 
                                            recid(produamx) no-error.
            if not avail w-movimamx
            then do:
                message "produamxto nao pertence a esta nota".
                undo.
            end.
            display produamx.pronom format "x(35)" 
                        no-label with frame f-exclusao.
            
            if w-movimamx.movqtm <> 1
            then update vqtd validate( vqtd <= w-movimamx.movqtm,
                                       "Quantidade invalida" )
                        label "Qtd" with frame f-exclusao.
            else do:
                vqtd = 1.
                display vqtd with frame f-exclusao.
            end.
            find first w-movimamx where w-movimamx.wrec = 
                                            recid(produamx) no-error.
            if avail w-movimamx
            then do:
                if w-movimamx.movqtm = vqtd
                then do:
                    delete w-movimamx.
                end.
                else w-movimamx.movqtm = w-movimamx.movqtm - vqtd.
                     w-movimamx.subtotal = w-movimamx.movqtm * w-movimamx.movpc.
                hide frame f-exclusao no-pause.
            end.
            vprotot = 0.
            clear frame f-produamx1 all no-pause.
            for each w-movimamx with frame f-produamx1:
                find produamx where recid(produamx) = wrec no-lock.
                display produamx.procod
                        produamx.pronom
                        w-movimamx.movqtm
                        w-movimamx.movpc
                        w-movimamx.subtotal
                        with frame f-produamx1.
                down with frame f-produamx1.
                pause 0.
                vprotot = vprotot + (w-movimamx.movqtm * w-movimamx.movpc).
                display vprotot with frame f-produamx.
            end.
            next.
        end.
        vant = no.
        find produamx where produamx.procod = input vproamx no-lock no-error.
        if not avail produamx
        then do:
            message "produamxto nao Cadastrado".
            undo.
        end.
        else vant = yes.
        display produamx.pronom with frame f-produamx.

        display produamx.pronom with frame f-produamx.
        display produamx.pronom with frame f-produamx1.
        vmovqtm = 0.
        vsubtotal = 0.
        find first w-movimamx where w-movimamx.wrec = recid(produamx) 
                                    no-lock no-error.
        if not avail w-movimamx
        then do:
            create w-movimamx.
            assign w-movimamx.wrec = recid(produamx)
                   w-movimamx.movpc = produamx.procvcom.
        end.
        vmovqtm = w-movimamx.movqtm.
        update w-movimamx.movqtm validate(w-movimamx.movqtm > 0,
                         "Quantidade Invalida") with frame f-produamx1.
        
        w-movimamx.movqtm = w-movimamx.movqtm + vmovqtm.
        
        update w-movimamx.movpc with frame f-produamx1.
        
        vprotot = 0.
        w-movimamx.subtotal = vsubtotal + 
                              (w-movimamx.movpc * w-movimamx.movqtm).

        clear frame f-produamx1 all no-pause.
        for each w-movimamx:
            find produamx where recid(produamx) = wrec no-lock.
            display produamx.procod
                    produamx.pronom
                    w-movimamx.movqtm
                    w-movimamx.subtotal
                    w-movimamx.movpc
                            with frame f-produamx1.
            down with frame f-produamx1.
            pause 0.
            vprotot = vprotot + (w-movimamx.movpc * w-movimamx.movqtm).
            display vprotot with frame f-produamx.
        end.
    end.
    if not sresp
    then undo, retry.
    end.
    hide frame f-produamx no-pause.
    hide frame f-produamx1 no-pause.
    if v-ok = yes
    then undo, retry.
    find last bplaniamx where bplaniamx.etbcod = centro.etbcod and
                           bplaniamx.placod <= 500000 no-lock no-error.
    if not avail bplaniamx
    then vplacod = 1.
    else vplacod = bplaniamx.placod + 1.
    if not sresp
    then do:
        hide frame f-produamx no-pause.
        hide frame f-produamx1 no-pause.
        clear frame f-produamx all.
        clear frame f-produamx1 all.
        for each w-movimamx:
            delete w-movimamx.
        end.
        undo, retry.
    end.

    do on error undo:
        create planiamx.
        assign planiamx.etbcod   = centro.etbcod
               planiamx.placod   = vplacod
               planiamx.emite    = centro.etbcod
               planiamx.bicms    = vbicms
               planiamx.icms     = vicms
               planiamx.frete    = vfrete
               planiamx.alicms   = planiamx.icms * 100 / (planiamx.bicms *
                                (1 - (0 / 100)))
               planiamx.descpro  = vdescpro
               planiamx.acfprod  = vacfprod
               planiamx.frete    = vfrete
               planiamx.seguro   = vseguro
               planiamx.desacess = vdesacess
               planiamx.ipi      = vipi
               planiamx.serie    = vserie
               planiamx.numero   = vnumero
               planiamx.movtdc   = 6
               planiamx.desti    = bcentro.etbcod
               planiamx.pladat   = vpladat
               planiamx.modcod   = tipmov.modcod
               planiamx.notfat   = bcentro.etbcod
               planiamx.dtinclu  = today
               planiamx.horincl  = time
               planiamx.notsit   = no
               planiamx.hiccod   = vhiccod
               planiamx.nottran  = vtrans
               planiamx.outras = planiamx.frete  +
                                 planiamx.seguro +
                                 planiamx.vlserv +
                                 planiamx.desacess +
                                 planiamx.ipi   +
                                 planiamx.icmssubst
              planiamx.isenta = planiamx.platot - 
                                planiamx.outras - planiamx.bicms.
        recpla = recid(planiamx).
        release planiamx.
    end.

    find planiamx where recid(planiamx) = recpla no-lock.

    for each w-movimamx:
        vmovseq = vmovseq + 1.
        find produamx where recid(produamx) = w-movimamx.wrec no-lock no-error.
        if not avail produamx
        then next.
        find planiamx where planiamx.etbcod = centro.etbcod and
                            planiamx.placod = vplacod and
                            planiamx.serie = vserie.
        planiamx.protot = planiamx.protot + 
                          (w-movimamx.movqtm * w-movimamx.movpc).
        planiamx.platot = planiamx.platot + 
                          (w-movimamx.movqtm * w-movimamx.movpc).

        create movimamx.
        ASSIGN movimamx.movtdc = 6
               movimamx.PlaCod = planiamx.placod
               movimamx.etbcod = planiamx.etbcod
               movimamx.movseq = vmovseq
               movimamx.procod = produamx.procod
               movimamx.movqtm = w-movimamx.movqtm
               movimamx.movpc  = w-movimamx.movpc
               movimamx.movdat    = planiamx.pladat
               movimamx.MovHr     = int(time).
               movimamx.emite     = planiamx.emite.
               movimamx.desti     = planiamx.desti.    
    
        recmov = recid(movimamx).
        release movimamx.
        find movimamx where recid(movimamx) = recmov no-lock.
        delete w-movimamx.
    
    end.

    /*
    sresp = no.
    message "Confirma Emissao da Nota " update sresp.
    if sresp
    then run imptra_l.p (input recid(planiamx)).
    */
    
end.
