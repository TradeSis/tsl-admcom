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
def buffer bclien for clien.
def var vclicod like clien.clicod.
def var vmovqtm   like  movim.movqtm.
def var vvencod   like plani.vencod.
def var vsubtotal like  movim.movqtm.
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
def var vhiccod   like  plani.hiccod initial 532.
def var vprocod   like  produ.procod.
def var vdown as i.
def var vant as l.
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
     with frame f-produ1 row 10 8 down overlay
                centered color white/cyan width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(30)"
     vprotot
         with frame f-produ centered color message side-label
                        row 9 width 81 no-box.

def var vform-pag as char extent 3 format "x(15)"
    init["  01=Dinheiro","  02=Cheque","  15=Boleto"].
def var vindexpag as int.

def var v-title as char.
def var vforcod like forne.forcod.
form
    vetbcod label "Filial"  colon 15
    estab.etbnom no-label
    vforcod      label "Cliente" colon 15
    forne.fornom no-label 
    forne.ufecod
    vhiccod      label "Op.Fiscal" format "9999" colon 15
    with frame f1 side-label width 80 row 4 color white/cyan .

find tipmov where tipmov.movtdc = 46 no-lock.
find first opcom where opcom.movtdc = 5 no-lock no-error.
if avail opcom
then v-title = opcom.opcnom.

form
    vbicms   colon 10
    vicms    colon 30
    vprotot1 colon 65
    vfrete   colon 10
    vipi     colon 30
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
    find forne where forne.forcod = vforcod no-lock.

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
      
    if forne.ufecod <> "RS"
    then vhiccod = 6602.
    else vhiccod = 5502.
    disp vhiccod with frame f1.
    vserie = "1".

    find tipmov where tipmov.movtdc = 46 no-lock.

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

    clear frame f-produ1 no-pause.
    bl-princ:
    repeat with 1 down:
        vindexpag = 1.
        hide frame f-pag no-pause.
        hide frame f-produ2 no-pause.
        
        for each w-movim where w-movim.movqtm = 0 or
                               w-movim.movpc  = 0 
                               :
        
            delete w-movim.
       
        end.
 
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
            else do:
                disp vform-pag with frame f-pag no-label width 80 
                        row 19 overlay title " FORMAS DE PAGAMENTO ".
                choose field vform-pag with frame f-pag.
                vindexpag = frame-index.
                hide frame f-pag no-pause.
                leave.
            end.
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
                     /*w-movim.movalipi  column-label "IPI"*/
                     w-movim.subtotal
                            format ">>,>>9.99" column-label "Total"
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
                /*
                        w-movim.movpdesc
                        */
                        w-movim.movqtm
                        w-movim.movpc
                        w-movim.movalicms
                        /*w-movim.movalipi*/
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

        display  produ.pronom with frame f-produ.
        display produ.pronom with frame f-produ1.

        vmovqtm = 0.
        vsubtotal = 0.
        find first w-movim where w-movim.wrec = recid(produ) no-lock no-error.
        if not avail w-movim
        then do:
            create w-movim.
            assign w-movim.wrec = recid(produ).
        end.
        /*else assign vmovqtm = w-movim.movqtm
                    vsubtotal = w-movim.subtotal.*/

        /*
        w-movim.movpdesc = 0.
        update  w-movim.movpdesc with frame f-produ1.

        */
        update  w-movim.movqtm validate(w-movim.movqtm > 0,
                         "Quantidade Invalida") with frame f-produ1.
        display w-movim.movqtm with frame f-produ1.
        w-movim.movpc = estoq.estvenda.
        update w-movim.movpc with frame f-produ1.
        /*update w-movim.movalicms
                 w-movim.movalipi with frame f-produ1.*/
           
        w-movim.movalicms = 18.
        if produ.proipiper <> 98 and
           produ.proipiper <> 99
        then w-movim.movalicm = produ.proipiper.
        else w-movim.movalicm = 0.
        
        if forne.ufecod <> "RS"
        then w-movim.movalicm = 12.                             
        
        vprotot = 0.
        /* w-movim.movqtm = vmovqtm + w-movim.movqtm. */
        w-movim.subtotal = w-movim.movqtm * w-movim.movpc.
        /*update  w-movim.subtotal validate(w-movim.subtotal > 0,
                         "Total dos Produtos Invalido")  with frame f-produ1.*/
        clear frame f-produ1 all no-pause.


        clear frame f-produ1 all no-pause.
        for each w-movim:
            find produ where recid(produ) = wrec no-lock.
            display produ.procod
                    produ.pronom
            /*
                    w-movim.movpdesc
                    */
                    w-movim.movqtm
                    w-movim.movpc
                    w-movim.movalicms
                    /*w-movim.movalipi*/
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
               tt-plani.icms     = vprotot * (18 / 100)
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
                              tt-plani.outras - tt-plani.bicms
              tt-plani.notped = trim(vform-pag[vindexpag])                
                              .
              
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
                                    
    end.
    
    assign tt-plani.bicms = 0
            tt-plani.icms = 0.

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
               /*
               tt-movim.movpdesc = w-movim.movpdesc
               tt-movim.movipi   =
               tt-movim.MovICMS  =
               */
               tt-movim.movcsticms = "41" 
               tt-movim.MovAlICMS = w-movim.movalicms
               tt-movim.MovAlIPI  = w-movim.movalipi
               tt-movim.movdat    = tt-plani.pladat
               tt-movim.MovHr     = int(time)
               tt-movim.desti = tt-plani.desti
               tt-movim.emite = tt-plani.emite.
               
               if tt-movim.MovAlICMS > 0
               then assign
                         tt-movim.movbicms = tt-movim.movpc * tt-movim.movqtm
                         tt-movim.movicms  = tt-movim.movbicms *
                                            (tt-movim.MovAlICMS / 100)
                         tt-plani.bicms = tt-plani.bicms + tt-movim.movbicms
                         tt-plani.icms  = tt-plani.icms + tt-movim.movicms
                         .
                                    
    end.

   /* message "Deseja visualizar o total da nota antes da emissao? 1.0"         update sresp.
    if sresp
    then do:
        run p-mostra-nota.
    end. */
    
    sresp = no.
    /* message "Deseja Alterar o CFOP?" update sresp.
    if sresp
    then update tt-plani.opccod format ">>>>>>>9" label "CFOP"
                with frame f-cfop overlay centered row 5
                        title "Alteração de Opercação Comercial" side-labels.
                        */
    vok = no.
    sresp = no.
    message "Confirma Emissao da Nota " update sresp.
    
    if sresp
    then do:
        if tt-plani.opccod = 5502 or
           tt-plani.opccod = 6602 
        then run manager_nfe.p (input "5502_je",
                                input ?,
                                output vok).
    end.
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

            pause 0.

    sresp = no.
    

    for each tt-movim.
    
        display tt-movim.procod
                tt-movim.movpc
                tt-movim.movdes
                tt-movim.movipi
                tt-movim.movalipi
                tt-movim.movicms
                tt-movim.movalicms 
                tt-movim.movdev label "Frete"
                tt-movim.movsubst
                tt-movim.movsubst / 18 * 100 with 1 col.
    
    end.

    /* message "Deseja alterar as informacoes? " update sresp. */
    if sresp
    then do:
                                   
        update tt-plani.bicms  
               tt-plani.icms 
               tt-plani.bsubst
               tt-plani.icmssubst
               tt-plani.protot   
                  with frame f-mostra-1 overlay row 8 width 80.

        update tt-plani.frete 
               tt-plani.seguro 
               tt-plani.desacess
               tt-plani.ipi     
               tt-plani.platot  
                 with frame f-mostra-2 overlay row 12 width 80.
    
        for each tt-movim.
    
            update tt-movim.procod
                   tt-movim.movpc
                   tt-movim.movdes
                   tt-movim.movipi
                   tt-movim.movalipi
                   tt-movim.movicms
                   tt-movim.movalicms
                   tt-movim.movdev label "Frete"
                   tt-movim.movsubst with 1 col.
               
        end.

    end.

end procedure.


