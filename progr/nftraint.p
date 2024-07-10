{admcab.i}

def var vciccgc   like  clien.ciccgc.
def var valicota  like  plani.alicms format ">9,99".
def var vpladat   like  plani.pladat.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms .
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vtrans    like  clien.clicod.
def var vdescpro  like  plani.descpro.
def var vacfprod  like  plani.acfprod.
def var vfrete    like  plani.frete.
def var vseguro   like  plani.seguro.
def var vdesacess like  plani.desacess.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(3)" /*like  plani.serie*/.
def var vopccod   like  plani.opccod.
def var vprocod   like  produ.procod.
def var recpla as recid.
def var recmov as recid.
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
/*     movim.movalicms column-label "ICMS"
     movim.movalipi  column-label "IPI"*/
     movim.movpc  format ">,>>9.99" column-label "Custo"
                    with frame f-produ1 row 5 7 down overlay
                                    centered color message width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 15 no-box width 81 overlay.

def var vhiccod   like  plani.hiccod label "Op.Fiscal" initial 522.


form
    estab.etbcod label "Emitente" colon 15
    estab.etbnom  no-label
    vnumero   colon 15
    vserie     label "Serie"
    plani.pladat       colon 15  format "99/99/9999"
    plani.datexp format "99/99/9999"    label "Envio"
    plani.desti label "Destinatario"
      with frame f1 side-label color white/cyan width 80 row 4
      title " Dados da Transferencia Normal ".

form
    plani.bicms    colon 10
    plani.icms     colon 30
    plani.protot  colon 65
    plani.frete    colon 10
    plani.ipi      colon 30
    plani.descpro  colon 10
    plani.acfprod  colon 45
    plani.platot  with frame f2 side-label row 11 width 80 overlay.

def temp-table tt-plani like plani.
def temp-table w-movim like movim.
def buffer bestab for estab.
def buffer bplani for plani.
def buffer cestab for estab.
def var vdestino like plani.desti.

repeat:
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
    vserie = "U".
    display estab.etbnom with frame f1.
    update vnumero
           vserie with frame f1.
    find plani where plani.numero = vnumero and
                     plani.emite  = estab.etbcod and
                     plani.movtdc = 6   and
                     plani.serie  = vserie and
                     plani.etbcod = estab.etbcod no-error.
    if not avail plani
    then do:
        message "Nota Fiscal nao cadastrada".
        undo, retry.
    end.

    do on error undo, retry:
        find tipmov where tipmov.movtdc = 6 no-lock.
        display plani.pladat
                plani.datexp format "99/99/9999" 
                string(plani.horincl,"HH:MM") 
                plani.desti with frame f1.
    end.
    create tt-plani.
    buffer-copy plani to tt-plani.
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock:
        
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
     message "Confirma Transferencia Interna ? " 
        update sresp.
     if sresp
     then do on error undo:
        
        find bestab where bestab.etbcod = plani.desti no-lock.
        
        update vdestino  
         label "Informe Destino da Transferencia Interna"
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
        
        find last bplani use-index nota 
                where bplani.etbcod = bestab.etbcod and
                      bplani.emite  = bestab.etbcod and
                      bplani.serie  = "T"           and
                      bplani.movtdc = 3  no-lock no-error.
        if not avail bplani
        then vnumero = 1.
        else vnumero = bplani.numero + 1.
    

        find last bplani where bplani.etbcod = bestab.etbcod and
                           bplani.placod <= 500000 no-lock no-error.
        if not avail bplani
        then vplacod = 1.
        else vplacod = bplani.placod + 1.
        
        create bplani.
        assign bplani.etbcod   = bestab.etbcod
               bplani.placod   = vplacod
               bplani.emite    = bestab.etbcod
               bplani.bicms    = plani.bicms
               bplani.icms     = plani.icms
               bplani.frete    = plani.frete
               bplani.alicms   = plani.alicms
               bplani.descpro  = plani.descpro
               bplani.acfprod  = plani.acfprod
               bplani.frete    = plani.frete
               bplani.seguro   = plani.seguro
               bplani.desacess = plani.desacess
               bplani.ipi      = plani.ipi
               bplani.serie    = "T"
               bplani.numero   = vnumero
               bplani.movtdc   = 3
               bplani.desti    = cestab.etbcod
               bplani.pladat   = today
               bplani.modcod   = "dup"
               bplani.notfat   = cestab.etbcod
               bplani.dtinclu  = today
               bplani.horincl  = time
               bplani.notsit   = no
               bplani.hiccod   = vhiccod
               bplani.nottran  = vtrans
               bplani.outras = bplani.frete  +
                              bplani.seguro +
                              bplani.vlserv +
                              bplani.desacess +
                              bplani.ipi   +
                              bplani.icmssubst
              bplani.isenta = bplani.platot - bplani.outras - bplani.bicms.
        recpla = recid(bplani).
        release bplani.
        find bplani where recid(bplani) = recpla.

        for each w-movim:
            vmovseq = vmovseq + 1.
            find produ where produ.procod = w-movim.procod no-lock no-error.
            if not avail produ
            then next.
            bplani.protot = bplani.protot + (w-movim.movqtm * w-movim.movpc).
            bplani.platot = bplani.platot + (w-movim.movqtm * w-movim.movpc).

            create movim.
            ASSIGN movim.movtdc = 3
               movim.PlaCod = bplani.placod
               movim.etbcod = bplani.etbcod
               movim.movseq = vmovseq
               movim.procod = produ.procod
               movim.movqtm = w-movim.movqtm
               movim.movpc  = w-movim.movpc
               movim.movdat    = bplani.pladat
               movim.MovHr     = int(time)
               movim.emite     = bplani.emite
               movim.desti     = bplani.desti.
            recmov = recid(movim).
            release movim.
            find movim where recid(movim) = recmov no-lock.
            run atuest.p (input recid(movim),
                       input "I",
                       input 0).
            delete w-movim.
        end.
        find bplani where recid(bplani) = recpla no-lock.

    end.
end.
