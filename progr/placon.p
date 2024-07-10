{admcab.i}
def buffer bplani for plani.
def var vest  like estoq.estatual.
def var per-mov as dec format ">9.99%".
def var per-con as dec format ">9.99%".
def var vtot   like plani.platot.
def var vval   like plani.platot.
def var recpla as recid.
def var recmov as recid.
def var v-ok as log.
def var vmovqtm   like  movcon.movqtm.
def var vemite    like  estab.etbcod.
def var vtrans    like  clien.clicod.
def var vsubtotal like  movcon.movqtm.
def var vciccgc   like  clien.ciccgc.
def var valicota  like  placon.alicms format ">9,99".
def var vpladat   like  placon.pladat.
def var vnumero   like  placon.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  placon.bicms.
def var vicms     like  placon.icms .
def var vprotot   like  placon.protot.
def var vprotot1  like  placon.protot.
def var vdescpro  like  placon.descpro.
def var vacfprod  like  placon.acfprod.
def var vfrete    like  placon.frete.
def var vseguro   like  placon.seguro.
def var vdesacess like  placon.desacess.
def var vipi      like  placon.ipi.
def var vplatot   like  placon.platot.
def var vetbcod   like  placon.etbcod.
def var vserie    like  placon.serie.
def var vopccod   like  placon.opccod.

def var vhiccod   like  placon.hiccod label "Op.Fiscal" initial 522.

def var vprocod   like  produ.procod.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movcon.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movcon.movseq.
def var vplacod     like placon.placod.
def var vtotal      like placon.platot.
def buffer bestab for estab.
def buffer bplacon for placon.

def temp-table w-movcon
               field wrec    as   recid
               field movqtm    like movcon.movqtm
               field subtotal  like movcon.movpc
               field movpc     as decimal format ">,>>9.99".

form produ.procod
     produ.pronom format "x(30)"
     w-movcon.movqtm format ">>>>9" column-label "Qtd"
     w-movcon.movpc  format ">,>>9.99" column-label "V.Unit."
     w-movcon.subtotal format ">>>,>>9.99" column-label "Total"
     with frame f-produ1 row 6 12 down overlay
                centered color white/cyan width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 5 no-box width 81.

form
    estab.etbcod  label "Emitente" colon 15
    estab.etbnom  no-label
    vetbcod        label "Destinatario" colon 15
    bestab.etbnom no-label format "x(20)"
    vnumero colon 15
    vserie  label "Serie"
    vval    colon 15 label "Valor" 
    per-mov label "Perc. Moveis" colon 15
    per-con label "Perc. Conf  " colon 15
    vpladat       colon 15
      with frame f1 side-label color white/cyan width 80 row 4.

repeat:
    for each w-movcon:
        delete w-movcon.
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
    vemite = input estab.etbcod.
    display estab.etbnom no-label with frame f1.
    update vetbcod  with frame f1.
    find bestab where bestab.etbcod = vetbcod no-lock no-error.
    if not avail bestab
    then do:
        message "Estabelecimento nao cadastrado".
        undo, retry.
    end.
    display bestab.etbnom no-label with frame f1.

    /******** Pega a ultima nota e gera a numero *****/
    find last bplacon where bplacon.etbcod = estab.etbcod and
                            bplacon.placod <= 500000      and
                            bplacon.placod <> ? no-lock no-error.
    if not avail bplacon
    then vplacod = 1.
    else vplacod = bplacon.placod + 1.
    
    vserie = "U".
    display vserie with frame f1.


    find last plani use-index numero where 
                                    plani.etbcod = estab.etbcod and
                                    plani.emite  = estab.etbcod and
                                    plani.serie  = vserie       and
                                    plani.movtdc <> 4           and
                                    plani.movtdc <> 5  no-lock no-error.
    if not avail plani
    then vnumero = 1.
    else vnumero = plani.numero + 1.
    
    display vnumero with frame f1.
    
    find first placon where placon.numero = vnumero and
                            placon.emite  = estab.etbcod and
                            placon.serie  = vserie and
                            placon.etbcod = estab.etbcod and
                            placon.movtdc = 6  no-error.
    if avail placon
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.

    
    find last bplani where bplani.etbcod = estab.etbcod and
                           bplani.placod <= 500000 no-lock no-error.
    if not avail bplani
    then vplacod = 1.
    else vplacod = bplani.placod + 1.
    

    
    do transaction:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.placod   = vplacod
               plani.emite    = estab.etbcod
               plani.serie    = vserie
               plani.numero   = vnumero
               plani.movtdc   = 6
               plani.desti    = bestab.etbcod
               plani.pladat   = today
               plani.notfat   = bestab.etbcod
               plani.dtinclu  = today
               plani.horincl  = time
               plani.notsit   = no
               plani.hiccod   = vhiccod
        recpla = recid(plani).
        release plani.
    end.
    
    find plani where recid(plani) = recpla no-lock.

 
    
    
    
    
    
    vval = 0.
    vtot = 0.
    per-mov = 0.
    per-con = 0.
    update vval 
           per-mov
           per-con with frame f1.
    update vpladat with frame f1.
    
    for each estoq where estoq.etbcod = estab.etbcod no-lock:
        
        if estoq.estcusto = 0 or
           estoq.estcusto = ? or
           estoq.estatual <= 0 
        then next.

        find produ where produ.procod = estoq.procod no-lock no-error.
        if not avail produ
        then next.
        
        vest = estoq.estatual.
        

        if produ.catcod = 31 or
           produ.catcod = 35 
        then vest = int(estoq.estatual * (per-mov / 100)).    
        
        if produ.catcod = 41 or
           produ.catcod = 45 
        then vest = int(estoq.estatual * (per-con / 100)).    
        
        if vest <= 0
        then next.
            
        
        find first w-movcon where w-movcon.wrec = recid(produ)  
                                no-lock no-error.
        if not avail w-movcon
        then do:
            create w-movcon.
            assign w-movcon.wrec   = recid(produ)
                   w-movcon.movpc  = estoq.estcusto
                   w-movcon.movqtm = vest.
        end.
        


        vtot = vtot + (estoq.estcusto * vest).
        
        display produ.procod
                produ.pronom format "x(25)"
                estoq.estatual
                estoq.estcusto
                vest
                vtot with frame f-tot down centered.
        pause 0.        
        

        if vtot > vval
        then leave.
                    
        

        
    end.

    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.

    message "Confirma nota fiscal" update sresp.
    if sresp = no
    then undo, retry.
    
    find last bplacon where bplacon.etbcod = estab.etbcod and
                            bplacon.placod <= 500000 no-lock no-error.
    if not avail bplacon
    then vplacod = 1.
    else vplacod = bplacon.placod + 1.

    do transaction:
        create placon.
        assign placon.etbcod   = estab.etbcod
               placon.placod   = vplacod
               placon.emite    = estab.etbcod
               placon.bicms    = vbicms
               placon.icms     = vicms
               placon.frete    = vfrete
               placon.alicms   = placon.icms * 100 / (placon.bicms *
                                (1 - (0 / 100)))
               placon.descpro  = vdescpro
               placon.acfprod  = vacfprod
               placon.frete    = vfrete
               placon.seguro   = vval
               placon.desacess = vdesacess
               placon.ipi      = vipi
               placon.serie    = vserie
               placon.numero   = vnumero
               placon.movtdc   = 6
               placon.desti    = bestab.etbcod
               placon.pladat   = vpladat
               placon.notfat   = bestab.etbcod
               placon.dtinclu  = today
               placon.horincl  = time
               placon.notsit   = no
               placon.hiccod   = 522
               placon.nottran  = vtrans
               placon.outras   = placon.frete  +
                                 placon.vlserv +
                                 placon.desacess +
                                 placon.ipi   +
                                 placon.icmssubst
               placon.isenta = placon.platot - placon.outras - placon.bicms.
        recpla = recid(placon).
        release placon.
    end.
    find placon where recid(placon) = recpla no-lock.

    for each w-movcon:
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movcon.wrec no-lock no-error.
        if not avail produ
        then next.
        find placon where placon.etbcod = estab.etbcod and
                          placon.placod = vplacod and
                          placon.serie = vserie.
        do transaction:
            placon.protot = placon.protot + 
                            (w-movcon.movqtm * w-movcon.movpc).
            placon.platot = placon.platot + 
                        (w-movcon.movqtm * w-movcon.movpc).

            create movcon.
            assign movcon.movtdc = 6
                   movcon.PlaCod = placon.placod
                   movcon.etbcod = placon.etbcod
                   movcon.movseq = vmovseq
                   movcon.procod = produ.procod
                   movcon.movqtm = w-movcon.movqtm
                   movcon.movpc  = w-movcon.movpc
                   movcon.movdat = placon.pladat
                   movcon.MovHr  = int(time).
                   movcon.emite  = placon.emite.
                   movcon.desti  = placon.desti.    
            recmov = recid(movcon).
            release movcon.
            delete w-movcon.
        end.
    end.
    
    
    sresp = no.
    message "Confirma Emissao da Nota " update sresp.
    if sresp
    then run placon_l.p (input recid(placon)).
    
    
    
end.
