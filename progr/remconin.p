{admcab.i}

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.

def buffer xestab for estab.
def var vforcod like forne.forcod.
def var vmovqtm   like  movim.movqtm.
def var vtrans    like  clien.clicod.
def var vsubtotal like  movim.movqtm.
def var vciccgc   like  clien.ciccgc.
def var valicota  like  plani.alicms format ">9,99".
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

def var vopfcod   like  opcom.opccod label "Op.Fiscal". 

def var vobs       as char extent 9 format "x(70)".

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
               field movpc     as decimal format ">,>>9.99".

form produ.pronom format "x(30)"
     w-movim.movqtm format ">>>9" column-label "Qtd"
     w-movim.movpc  format ">,>>9.99" column-label "V.Unit."
     w-movim.subtotal format ">>,>>9.99" column-label "Total"
     with frame f-produ1 row 15 8 down overlay
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
    vnumero       colon 15
    vserie
    opcom.opccod       colon 15 
    opcom.opcnom no-label 
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

    if vetbcod = 988 or vetbcod = 998 or
       setbcod = 988 or setbcod = 998
    then do:
        message "Realize a operacao no novo modulo de SSC" view-as alert-box.
        undo, retry.
    end.

    if (estab.etbcod >= 993 and
        estab.etbcod <= 999 and
        estab.etbcod <> 998) or
        estab.etbcod = 22 or
        estab.etbcod = 900
    then.
    else do:
        message "Emitente invalido".
        pause.
        undo, retry.
    end.
    display estab.etbnom no-label with frame f1.

    update vforcod with frame f1.
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do:
        message "Fornecedor nao cadastrado".
        undo, retry.
    end.
    display forne.fornom with frame f1. 
    run not_notgvlclf.p ("Forne", recid(forne), output sresp).
    if not sresp
    then undo, retry.

    if vetbcod <> 995 and
       vetbcod <> 993 and
       vetbcod <> 998 and
       vetbcod <> 999 and
       vetbcod <> 900
    then do: 
    vserie = "U".
    display vnumero
            vserie with frame f1.
    end.
    else do:
        vserie = "1".
        disp vserie with frame f1.
    end.
    if forne.ufecod = "RS"
    then find first opcom where opcom.movtdc = 16 no-lock.
    else find last  opcom where opcom.movtdc = 16 no-lock.

    display opcom.opccod label "Op.Fiscal" 
            opcom.opcnom no-label with frame f1.
 
        find tipmov where tipmov.movtdc = 16 no-lock.
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
        hide frame f-aviso no-pause.
        hide frame f-produ1 no-pause.
        vprotot1 = 0. 
        clear frame f-produ1 all no-pause.
        for each w-movim where w-movim.movqtm = 0 or
                               w-movim.movpc  = 0 or
                               w-movim.subtotal = 0:
            delete w-movim.
            
        end.    
        vprotot = 0.
        for each w-movim:
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
                     w-movim.movqtm format ">,>>9.99" column-label "Qtd"
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

      
        find estoq where estoq.etbcod = vetbcod and
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
        
        
        /*
        if estab.etbcod <> 22 
        then do:
            if (estoq.estatual >= 0 and 
               (estoq.estatual - w-movim.movqtm) < 0) or
                estoq.estatual < 0 
            then do:
                display  
                        "Qtd Estoque :" at 5 estoq.estatual 
                                            no-label format "->>,>>9.99"
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
        */
        vprotot = 0.
        w-movim.movqtm = vmovqtm + w-movim.movqtm.
        w-movim.movpc = estoq.estcusto.
        update w-movim.movpc format ">>,>>9.99"
                validate(w-movim.movpc > 0,
                         "Preco Invalido") with frame f-produ1.

        w-movim.subtotal = w-movim.movpc * w-movim.movqtm.

        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = wrec no-lock.
            display produ.pronom
                    w-movim.movqtm
                    w-movim.subtotal format ">>>,>>9.99"
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
    
    find first w-movim where w-movim.movqtm > 0 and
                             w-movim.movpc > 0 no-error.
                             
    if not avail w-movim 
    then undo, leave.

    if vetbcod <> 995 and
       vetbcod <> 998 and
       vetbcod <> 993 and
       vetbcod <> 999 and
       vetbcod <> 900        
    then do:
    /******** Pega a ultima nota e gera a numero *****/
    find last plani use-index numero where plani.etbcod = estab.etbcod and
                                           plani.emite  = estab.etbcod and
                                           plani.serie  = "U" and
                                           plani.movtdc <> 4 and
                                           plani.movtdc <> 5
                                           /*no-lock*/ no-error.
    if not avail plani
    then vnumero = 1.
    else vnumero = plani.numero + 1.

    
    if estab.etbcod = 998 or 
       estab.etbcod = 993 or
       estab.etbcod = 900
    then do:  
        vnumero = 0. 
        for each xestab where xestab.etbcod = 998 or 
                              xestab.etbcod = 993 or
                              xestab.etbcod = 900 no-lock,
                                 
            last plani use-index numero 
                    where plani.etbcod = xestab.etbcod and
                          plani.emite  = xestab.etbcod and
                          plani.serie  = "U"          and
                          plani.movtdc <> 4           and
                          plani.movtdc <> 5           and
                          plani.pladat >= 01/01/2008 /*no-lock*/ .
                      
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

    {valnumnf.i vnumero}
    
    /************************************************/

 

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
               plani.hiccod   = int(opcom.opccod)
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
               plani.pladat   = today
               plani.modcod   = tipmov.modcod
               
               plani.opccod   = int(opcom.opccod)
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
    vmovseq = 0.
    for each w-movim:
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movim.wrec no-lock.
        find plani where plani.etbcod = estab.etbcod and
                         plani.placod = vplacod and
                         plani.serie = vserie no-lock.

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
    message "Confirma impressao da nota fiscal " vnumero update sresp.
    if sresp
    then do:
        bell.
        message "Prepare a Impressora".
        pause.
        run impcons.p (input recid(plani)).
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
        vserie = "1".
        create tt-plani.
        assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = vplacod
               tt-plani.hiccod   = int(opcom.opccod)
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
               tt-plani.pladat   = today
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = int(opcom.opccod)
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
              tt-plani.isenta = tt-plani.platot - tt-plani.outras 
                        - tt-plani.bicms.
    end.
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
               tt-movim.movdat    = tt-plani.pladat
               tt-movim.MovHr     = int(time)
               tt-movim.desti     = tt-plani.desti
               tt-movim.emite     = tt-plani.emite.

    end.

    def var p-ok as log init no.
    def var p-valor as char.
    p-valor = "".
    def var nfe-emite like plani.emite.
    if vetbcod = 998
    then nfe-emite = 993.
    else nfe-emite = vetbcod.
    
    run le_tabini.p (nfe-emite, 0,
            "NFE - TIPO DOCUMENTO", OUTPUT p-valor) .
    if p-valor = "NFE"
    then do:
    
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
 
        assign tt-plani.notobs[1] = vobs[1]
                                     + " "
                                     + vobs[2]   
                                     + " "
                                     + vobs[3]     
                                     + " "
               tt-plani.notobs[2] = vobs[4]       
                                     + " "
                                     + vobs[5]          
                                     + " "
                                     + vobs[6]            
                                     + " "
               tt-plani.notobs[3] = vobs[7]              
                                     + " "
                                     + vobs[8]
                                     + " "
                                     + vobs[9].

        run manager_nfe.p (input "5915",
                           input ?,
                           output p-ok).
 
    end.
 
end procedure.

