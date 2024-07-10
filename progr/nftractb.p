{admcab.i}
def var recpla as recid.
def var recmov as recid.
def var v-ok as log.
def var vmovqtm   like  movim.movqtm.
def var vemite    like  estab.etbcod.
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

def var vhiccod   like  plani.hiccod label "Op.Fiscal" initial 522.

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
def buffer xestab for estab.

def temp-table w-movim
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

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 5 no-box width 81.

form
    vetbcod  label "Emitente" colon 15
    estab.etbnom  no-label
    vserie  colon 15
    vnumero
    opcom.opccod  format "9999" colon 15
    opcom.opcnom no-label
    vpladat       colon 15
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
    if (vetbcod >= 993 and
        vetbcod <= 998) or
        vetbcod = 22
    then.
    else do:
        message "Emitente invalido".
        pause.
        undo, retry.
    end.
    display estab.etbnom no-label with frame f1.
    
    /******** Pega a ultima nota e gera a numero *****/
    find last bplani where bplani.etbcod = estab.etbcod and
                           bplani.placod <= 500000 and
                           bplani.placod <> ? no-lock no-error.
    if not avail bplani
    then vplacod = 1.
    else vplacod = bplani.placod + 1.
    vserie = "U".
    display vserie with frame f1. 



    find last plani use-index numero 
                where plani.etbcod = estab.etbcod and
                      plani.emite  = estab.etbcod and
                      plani.serie  = vserie       and
                      plani.movtdc <> 4           and
                      plani.movtdc <> 5 no-lock no-error. 
    if not avail plani 
    then vnumero = 1. 
    else vnumero = plani.numero + 1.
        
    if estab.etbcod = 998 or 
       estab.etbcod = 995
    then do: 
        vnumero = 0. 
        for each xestab where xestab.etbcod = 998 or
                              xestab.etbcod = 995
                               no-lock.
                                 
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
    
    if estab.etbcod = 993
    then do: 
        vnumero = 0. 
        for each xestab where xestab.etbcod = 993
                               no-lock.
                                 
            find last plani use-index numero 
                    where plani.etbcod = xestab.etbcod and
                          plani.emite  = xestab.etbcod and
                          plani.serie  = vserie       and
                          plani.movtdc <> 4           and
                          plani.movtdc <> 5 /* and
                          plani.numero < 100000 */ no-lock no-error. 
                      
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

    display vnumero with frame f1.
    
    find last opcom where opcom.movtdc = 6 no-lock.
    display opcom.opccod 
            opcom.opcnom no-label with frame f1.
    find first plani where plani.numero = vnumero and
                     plani.emite  = estab.etbcod and
                     plani.serie  = vserie and
                     plani.etbcod = estab.etbcod and
                     plani.movtdc = 6  no-error.
    if avail plani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end. 
    find tipmov where tipmov.movtdc = 22 no-lock.
    vpladat = today.
   
    display vpladat with frame f1.
    message "Confirma Nota Fiscal " vnumero update sresp.
    if sresp = no
    then undo, retry.
    
    find last bplani where bplani.etbcod = estab.etbcod and
                           bplani.placod <= 500000 no-lock no-error.
    if not avail bplani
    then vplacod = 1.
    else vplacod = bplani.placod + 1.
 
    
    do on error undo:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.placod   = vplacod
               plani.emite    = estab.etbcod
               plani.serie    = vserie
               plani.numero   = vnumero
               plani.movtdc   = tipmov.movtdc
               plani.desti    = estab.etbcod
               plani.pladat   = vpladat
               plani.modcod   = tipmov.modcod
               plani.opccod   = int(opcom.opccod)
               plani.dtinclu  = vpladat
               plani.horincl  = time
               plani.notsit   = no
               plani.hiccod   = int(opcom.opccod).
        recpla = recid(plani).
        release plani.
    end.

    find plani where recid(plani) = recpla no-lock.

end.
