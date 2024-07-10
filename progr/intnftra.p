{admcab.i}
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.

def var vciccgc   like  clien.ciccgc.
def var valicota  like  plani.alicms format ">9,99".
def var vpladat   like  plani.pladat.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms .
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vtrans like clien.clicod.
def var vhiccod   like  plani.hiccod label "Op.Fiscal" initial 5152.
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
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotal      like plani.platot.


form produ.procod
     produ.pronom format "x(30)"
     movim.movqtm format ">,>>9.99" column-label "Qtd"
     movim.movpc  format ">,>>9.99" column-label "Custo"
                    with frame f-produ1 row 5 7 down overlay
                                    centered color message width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 15 no-box width 81 overlay.

form
    estab.etbcod label "Emitente" colon 15
    estab.etbnom  no-label
    vnumero   colon 15
    vserie   label "Serie"
    plani.pladat       colon 15 format "99/99/9999"
    plani.datexp format "99/99/9999"     label "Envio"
      with frame f1 side-label color white/cyan width 80 row 4
      title " Dados da Transferencia Interna ".

form
    plani.bicms    colon 10
    plani.icms     colon 30
    plani.protot  colon 65
    plani.frete    colon 10
    plani.ipi      colon 30
    plani.descpro  colon 10
    plani.acfprod  colon 45
    plani.platot  with frame f2 side-label row 11 width 80 overlay.

def var recpla as recid.
def var recmov as recid.
def var vdestino like plani.desti.
def buffer cestab for estab.
def buffer bestab for estab.
def buffer bplani for plani.
def buffer bmovim for movim.

def temp-table tt-plani1 like plani.
def temp-table w-movim like movim.
repeat:
    for each tt-plani1: delete tt-plani1. end.    
    for each w-movim: delete w-movim. end.
        
    clear frame f1 no-pause.
    clear frame f-1 no-pause.
    clear frame f-produ1 no-pause.
    hide  frame f2 no-pause.
    prompt-for estab.etbcod label "Emitente" with frame f1.
    find estab where estab.etbcod = input estab.etbcod no-lock no-error.
    if not avail estab
    then do:
        message "estabelecimento nao cadastrado".
        undo, retry.
    end.
    vserie = "T".
    display estab.etbnom with frame f1.
    update vnumero 
           vserie with frame f1.
    find plani where plani.numero = vnumero and
                     plani.emite  = estab.etbcod and
                     plani.movtdc = 3      and
                     plani.serie  = vserie and
                     plani.etbcod = estab.etbcod no-error.
    if not avail plani
    then do:
        message "Nota Fiscal nao cadastrada".
        undo, retry.
    end.

    do on error undo, retry:
        find tipmov where tipmov.movtdc = 3 no-lock.
        display plani.pladat
                plani.datexp format "99/99/9999" 
                string(plani.horincl,"HH:MM") 
                plani.desti label "Destino" with frame f1.
    end.
    create tt-plani1.
    buffer-copy plani to tt-plani1.
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock:
        
        if movim.movqtm = 0 then next.
        
        find produ where produ.procod = movim.procod no-lock.
         disp produ.procod
              produ.pronom format "x(25)"
              movim.movqtm format ">,>>9.99" column-label "Qtd"
              movim.movpc  format ">,>>9.99" column-label "Custo"
              (movim.movpc * movim.movqtm)(total)
                    format ">>>,>>9.99"
                                    column-label "TOTAL"
                            with frame f-produ2  9 down  overlay
                              centered color message width 80.
                down with frame f-produ2.
        create w-movim.
        buffer-copy movim to w-movim.
     end.
     sresp = no.
     message  "Confirma Gerar Transferencia ? " update sresp.
     if sresp
     then do on error undo:
        update vdestino  
         label "Informe Destino da Transferencia"
            help "Informe o destinatario da transferencia interna"
            with frame f-destino
            centered row 19 overlay side-label
            color with/black.

        find cestab where cestab.etbcod = vdestino no-lock no-error.
        if not avail cestab 
        then do:
            bell.
            message color red/with
            "Destino Invalido"
            view-as alert-box.
            undo.
        end.    
 
        find bestab where bestab.etbcod = plani.desti no-lock.

        /*** Emissão anterior a NFe
        find last bplani where bplani.etbcod = bestab.etbcod and
                           bplani.placod <= 500000 no-lock no-error.
        if not avail bplani
        then vplacod = 1.
        else vplacod = bplani.placod + 1.
 
        find last bplani use-index numero 
                where bplani.etbcod = bestab.etbcod and
                      bplani.emite  = bestab.etbcod and
                      bplani.serie  = "U"       and
                      bplani.movtdc <> 4           and
                      bplani.movtdc <> 5 no-lock no-error. 
        if not avail bplani 
        then vnumero = 1. 
        else vnumero = bplani.numero + 1.
 
        create bplani.
        assign bplani.etbcod   = bestab.etbcod
               bplani.placod   = vplacod
               bplani.emite    = bestab.etbcod
               bplani.bicms    = plani.bicms
               bplani.icms     = plani.icms
               bplani.frete    = plani.frete
               bplani.alicms   = bplani.icms * 100 / (bplani.bicms *
                                (1 - (0 / 100)))
               bplani.descpro  = plani.descpro
               bplani.acfprod  = plani.acfprod
               bplani.frete    = plani.frete
               bplani.seguro   = plani.seguro
               bplani.desacess = plani.desacess
               bplani.ipi      = plani.ipi
               bplani.serie    = "U"
               bplani.numero   = vnumero
               bplani.movtdc   = 6
               bplani.desti    = cestab.etbcod
               bplani.pladat   = today
               bplani.modcod   = tipmov.modcod
               bplani.opccod   = vhiccod
               bplani.notfat   = cestab.etbcod
               bplani.dtinclu  = today
               bplani.horincl  = time
               bplani.notsit   = no
               bplani.hiccod   = vhiccod
               bplani.nottran  = vtrans
               bplani.notobs[3] = "D"
               bplani.outras = bplani.frete  +
                              bplani.seguro +
                              bplani.vlserv +
                              bplani.desacess +
                              bplani.ipi   +
                              bplani.icmssubst
              bplani.isenta = bplani.platot - bplani.outras - bplani.bicms.
        recpla = recid(bplani).
        release bplani.

        find bplani where recid(bplani) = recpla .

        for each w-movim:
            vmovseq = vmovseq + 1.
            find produ where produ.procod = w-movim.procod no-lock no-error.
            if not avail produ
            then next.
            bplani.protot = bplani.protot + (w-movim.movqtm * w-movim.movpc).
            bplani.platot = bplani.platot + (w-movim.movqtm * w-movim.movpc).

            create bmovim.
            ASSIGN bmovim.movtdc = 6
               bmovim.PlaCod = bplani.placod
               bmovim.etbcod = bplani.etbcod
               bmovim.movseq = vmovseq
               bmovim.procod = produ.procod
               bmovim.movqtm = w-movim.movqtm
               bmovim.movpc  = w-movim.movpc
               bmovim.movdat    = bplani.pladat
               bmovim.MovHr     = int(time).
               bmovim.emite     = bplani.emite.
               bmovim.desti     = bplani.desti.    
            recmov = recid(bmovim).
            release bmovim.
            find bmovim where recid(bmovim) = recmov no-lock.
            
            run atuest.p (input recid(bmovim),
                      input "I",
                      input 0).
            delete w-movim.
        end.    
        find bplani where recid(bplani) = recpla no-lock.
        Emissão anterior a NFe *****/
        
        run emissao-NFe.
        
    end.
    else do:
        for each w-movim:
            delete w-movim.
        end.
    end.    
    /**
    sresp = no.
    message "Confirma Emissao da Nota " update sresp.
    if sresp
    then run imptra_l.p (input recid(bplani)).
    **/
end.

procedure emissao-NFe.
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    vplacod = ?.
    vnumero = ?.
    vserie  = "1".
    create tt-plani.
        assign tt-plani.etbcod   = bestab.etbcod
               tt-plani.placod   = vplacod
               tt-plani.emite    = bestab.etbcod
               tt-plani.bicms    = plani.bicms
               tt-plani.icms     = plani.icms
               tt-plani.frete    = plani.frete
               tt-plani.alicms   = tt-plani.icms * 100 / (tt-plani.bicms *
                                (1 - (0 / 100)))
               tt-plani.descpro  = plani.descpro
               tt-plani.acfprod  = plani.acfprod
               tt-plani.frete    = plani.frete
               tt-plani.seguro   = plani.seguro
               tt-plani.desacess = plani.desacess
               tt-plani.ipi      = plani.ipi
               tt-plani.serie    = vserie
               tt-plani.numero   = vnumero
               tt-plani.movtdc   = 6
               tt-plani.desti    = cestab.etbcod
               tt-plani.pladat   = today
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = vhiccod
               tt-plani.notfat   = cestab.etbcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.hiccod   = vhiccod
               tt-plani.nottran  = vtrans
               tt-plani.notobs[3] = "D"
               tt-plani.outras = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi   +
                              tt-plani.icmssubst
              tt-plani.isenta = tt-plani.platot - tt-plani.outras 
                    - tt-plani.bicms.

        recpla = recid(tt-plani).

        for each w-movim where w-movim.movqtm > 0:
            vmovseq = vmovseq + 1.
            find produ where produ.procod = w-movim.procod no-lock no-error.
            if not avail produ
            then next.
            tt-plani.protot = tt-plani.protot + 
                        (w-movim.movqtm * w-movim.movpc).
            tt-plani.platot = tt-plani.platot + 
                        (w-movim.movqtm * w-movim.movpc).

            
            create tt-movim.
            ASSIGN tt-movim.movtdc = 6
               tt-movim.PlaCod = tt-plani.placod
               tt-movim.etbcod = tt-plani.etbcod
               tt-movim.movseq = vmovseq
               tt-movim.procod = produ.procod
               tt-movim.movqtm = w-movim.movqtm
               tt-movim.movpc  = w-movim.movpc
               tt-movim.movdat    = tt-plani.pladat
               tt-movim.MovHr     = int(time).
               tt-movim.emite     = tt-plani.emite.
               tt-movim.desti     = tt-plani.desti.    
            recmov = recid(tt-movim).
            delete w-movim.
        end. 
        
    def var p-ok as log init no.
    def var p-valor as char.
    p-valor = "".
    run le_tabini.p (bestab.etbcod, 0,
            "NFE - TIPO DOCUMENTO", OUTPUT p-valor) .
    if p-valor = "NFE"
    then do:
        run manager_nfe.p (input "5152",
                           input ?,
                           output p-ok).
    end.
end procedure.


