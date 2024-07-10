{admcab.i}
def var vobs like plani.notobs.
def buffer xestab for estab.
def var vdata   like plani.pladat.
def var vforcod like forne.forcod.
def var vetbcod like estab.etbcod.
def var vmovqtm   like  movim.movqtm.
def var vtrans    like  clien.clicod.
def var vsubtotal like  movim.movqtm.
def var vciccgc   like  clien.ciccgc.
def var valicota  like  plani.alicms format ">9,99".
def var vpladat   like  plani.pladat.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms.
def var base_icms_subst like plani.bsubst.
def var icms_subst      like plani.icmssubst.
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vacfprod  like  plani.acfprod.
def var vfrete    like  plani.frete.
def var vseguro   like  plani.seguro.
def var vdesacess like  plani.desacess.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vserie    like  plani.serie.
def var vopccod   like  plani.opccod.
def var vnumant   like  plani.numero.
def var vtofcod   like  plani.hiccod label "Op.Fiscal" initial 532.
def var vserant   as char format "x(03)".
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
def  temp-table w-movim
               field wrec    as   recid
               field movqtm    like movim.movqtm
               field subtotal  like movim.movpc
               field wicms     like movim.movalicms initial 17
               field wipi      like movim.movalicms initial 0
               field movpc     as decimal format ">,>>9.99".
form produ.procod
     produ.pronom format "x(30)"
     w-movim.movqtm format ">>>9" column-label "Qtd"
     w-movim.movpc  format ">,>>9.99" column-label "V.Unit."
     w-movim.wicms  format ">9.99" column-label "% ICMS"
     w-movim.wipi   format ">9.99" column-label "% IPI"
     w-movim.subtotal format ">>,>>9.99" column-label "Total"
     with frame f-produ1 row 15 2 down overlay
                centered color white/cyan width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 14 no-box width 81 overlay.

form
    vetbcod label "Emitente" colon 17
    estab.etbnom no-label format "x(20)"
    vFORCOD label "Destinatario" colon 17
    FORNE.FORNOM  no-label
    vnumant label "Numero NF Origem" colon 17
    vserant label "Serie"  
    vnumero       colon 17
    vserie  label "Serie"  
    vtofcod       format "999" colon 17
    tofis.tofnom  no-label
    vdata         label "Data"      colon 17
    vpladat       colon 17
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

    update vetbcod with frame f1.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento nao cadastrado".
        undo, retry.
    end.
    display estab.etbnom with frame f1.

    update vforcod with frame f1.
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do:
        message "fornecedor nao cadastrado".
        undo, retry.
    end.
    display forne.fornom no-label with frame f1.
    if forne.ativo = no
    then do:
        message "Fornecedor Desativado".
        pause.
        undo, retry.
    end.        

    do on error undo, retry:
        update vnumant 
               vserant label "Serie" with frame f1.
        find plani where plani.emite  = forne.forcod and
                         plani.etbcod = estab.etbcod and
                         plani.movtdc = 4            and
                         plani.serie  = vserant      and
                         plani.numero = vnumant no-lock no-error.
        if not avail plani
        then do:
            message "Nota Fiscal de Compra nao encontrada".
            pause .
            undo, retry.
        end.
        vobs[1] = "NF ORIGINAL: " + string(plani.numero).
        if plani.ipi > 0
        then vobs[1] = vobs[1] +  " VALOR IPI: " +  string(plani.ipi).
        if plani.icmssubst > 0
        then vobs[1] = vobs[1] +  " VALOR ICMS SUBS. TRBT. " 
                        +  string(plani.icmssubst).
    
    end.
 
 


    /******** Pega a ultima nota e gera a numero *****/
    find last plani use-index numero where
                          plani.etbcod = estab.etbcod and
                          plani.emite  = ESTAB.ETBCOD and
                          plani.serie  = "U" and
                          plani.movtdc <> 4  and
                          plani.movtdc <> 5 no-lock no-error.
    if not avail plani
    then vnumero = 1.
    else vnumero = plani.numero + 1.
    
    if estab.etbcod = 998 or
       estab.etbcod = 995 
    then do: 
        vnumero = 0.
        for each xestab where xestab.etbcod = 998 or
                              xestab.etbcod = 995 no-lock.
                                 
            find last plani use-index numero 
                    where plani.etbcod = xestab.etbcod and
                          plani.emite  = xestab.etbcod and
                          plani.serie  = "u"          and
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

    
    
    /************************************************/

    vserie = "U".
    update vnumero
           vserie
           vtofcod with frame f1.
    find tofis where tofis.tofcod = vtofcod no-lock.
    display tofis.tofnom no-label with frame f1.

    find first plani where plani.numero = vnumero and
                     plani.emite  = forne.forcod  and
                     plani.serie  = vserie        and
                     plani.etbcod = estab.etbcod  and
                     plani.movtdc = 13 no-lock no-error.
    if avail plani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.
    update vdata with frame f1. 
    
    do on error undo, retry:
        find tipmov where tipmov.movtdc = 13 no-lock.
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
           vtotal = 0
           base_icms_subst = 0
           icms_subst = 0.
           
    update vbicms 
           vicms           label "Valor Icms"
           base_icms_subst label "Base Icms Subst."
           icms_subst label "Icms Substituicao"
               with frame f2 side-label color white/cyan.
    
    vprotot1 = vbicms.
    update vdescpro with frame f2 centered.  
    
              
    update vobs[1] no-label
           vobs[2] no-label
           vobs[3] no-label 
                with frame f-obs centered title "Observacoes".
    

    
    
    vplatot = (vbicms + vfrete + vipi)  - vdescpro.
    vtotal = vipi + vdesacess + vseguro + vfrete +
             vprotot - vdescpro.
    clear frame f-produ1 no-pause.
    repeat with 1 down:
        hide frame f-produ2 no-pause.
        
        for each w-movim where w-movim.movqtm = 0 or
                               w-movim.movpc  = 0 or
                               w-movim.subtotal = 0:
            delete w-movim.
        end.    

        
        vprotot = 0. 
        clear frame f-produ1 all no-pause. 
        for each w-movim with frame f-produ1: 
            find produ where recid(produ) = wrec no-lock. 
            display produ.procod 
                    produ.pronom 
                    w-movim.movqtm 
                    w-movim.movpc 
                    w-movim.wicms 
                    w-movim.wipi 
                    w-movim.subtotal 
                        with frame f-produ1.
            down with frame f-produ1.
            pause 0. 
            vprotot = vprotot + (w-movim.movqtm * w-movim.movpc). 
            display vprotot with frame f-produ.
        end.
 
        
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
                clear frame f-produ all.
                clear frame f-produ1 all.
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
                            format ">>,>>9.99" column-label "Total"
                     w-movim.movpc  format ">,>>9.99" column-label "Custo"
                     w-movim.wicms
                     w-movim.wipi
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
                        w-movim.wicms
                        w-movim.wipi
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

        /*
        w-movim.movpdesc = 0.
        update  w-movim.movpdesc with frame f-produ1.
        update  w-movim.subtotal validate(w-movim.subtotal > 0,
                         "Total dos Produtos Invalido") with frame f-produ1.
        update  w-movim.movalicms
                w-movim.movalipi with frame f-produ1.
        */
        update  w-movim.movqtm validate(w-movim.movqtm > 0,
                         "Quantidade Invalida") with frame f-produ1.
        vprotot = 0.
        display w-movim.movqtm with frame f-produ1.
        w-movim.movpc = estoq.estcusto.
        update w-movim.movpc validate(w-movim.movpc > 0,
                         "Preco Invalido") with frame f-produ1.

        update w-movim.wicms
               w-movim.wipi with frame f-produ1.

        vipi = vipi + (((w-movim.movqtm * w-movim.movpc) * w-movim.wipi) / 100).

        w-movim.subtotal = (w-movim.movpc * w-movim.movqtm).
        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = wrec no-lock.
            display produ.procod
                    produ.pronom
                    w-movim.movqtm
                    w-movim.movpc
                    w-movim.wicms
                    w-movim.wipi
                    w-movim.subtotal
                            with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot = vprotot + (w-movim.movpc * w-movim.movqtm).
            display vprotot with frame f-produ.
        end.
    end.
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
    end.

    find first w-movim where w-movim.movqtm > 0 and
                              w-movim.movpc > 0 no-error.
                             
    if not avail w-movim 
    then undo, leave.
     

    find last bplani where bplani.etbcod = estab.etbcod and
                           bplani.placod <= 500000 and
                           bplani.placod <> ? no-lock no-error.
    if not avail bplani
    then vplacod =  1.
    else vplacod = bplani.placod + 1.
    if not sresp
    then undo, retry.
    
    find first w-movim no-error.
    if not avail w-movim
    then undo, retry.
    

    do on error undo:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.placod   = vplacod
               plani.protot   = vprotot 
               plani.desti    = forne.forcod
               plani.bicms    = vbicms
               plani.icms     = vbicms * (w-movim.wicms / 100)
               plani.bsubst   = base_icms_subst
               plani.icmssubst = icms_subst
               plani.frete    = vfrete
               plani.alicms   = plani.icms * 100 / (plani.bicms *
                                (1 - (0 / 100)))
               plani.descpro  = vdescpro
               plani.acfprod  = vacfprod
               plani.frete    = vfrete
               plani.seguro   = vseguro
               plani.desacess = vdesacess
               plani.ipi      = vipi
               plani.platot   = vprotot + vipi - vdescpro 
               plani.serie    = vserie
               plani.numero   = vnumero
               plani.movtdc   = tipmov.movtdc
               plani.emite    = estab.etbcod
               plani.pladat   = vpladat
               plani.modcod   = tipmov.modcod
               plani.opccod   = 13
               plani.notfat   = estab.etbcod
               plani.dtinclu  = today
               plani.horincl  = time
               plani.notsit   = no
               plani.nottran  = vtrans
               plani.dtinclu  = vdata
               plani.notobs[1] = vobs[1]
               plani.notobs[2] = vobs[2]
               plani.notobs[3] = vobs[3]
               plani.hiccod   = vtofcod
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
               movim.MovAlICMS = w-movim.wicms
               movim.MovAlIPI  = w-movim.wipi
               movim.movdat    = plani.pladat
               movim.MovHr     = int(time)
               movim.desti     = plani.desti
               movim.emite     = plani.emite.
        run atuest.p (input recid(movim),
                      input "I",
                      input 0).
    end.
    message "Confirma impressao da nota fiscal" update sresp.
    if sresp
    then do:
        bell.
        message "Prepare a Impressora".
        pause.
        run impnffor.p (input recid(plani)).
    end.
end.
