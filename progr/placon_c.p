{admcab.i}
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
def var vprocod   like  produ.procod.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movcon.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movcon.movseq.
def var vplacod     like placon.placod.
def var vtotal      like placon.platot.


form produ.procod
     produ.pronom format "x(30)"
     movcon.movqtm format ">,>>9.99" column-label "Qtd"
/*     movcon.movalicms column-label "ICMS"
     movcon.movalipi  column-label "IPI"*/
     movcon.movpc  format ">,>>9.99" column-label "Custo"
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
    /*vciccgc        colon 15*/
    /*clien.clinom  no-label format "x(20)"*/
    /*clien.ciccgc  no-label*/
    vnumero   colon 15
    vserie
    /*placon.opccod   colon 15
    opcom.opcnom
    placon.opfcod label "Op.Fiscal"  colon 15
    opfis.opfnom no-label */
    placon.pladat       colon 15
    placon.datexp format "99/99/9999"
      with frame f1 side-label color white/cyan width 80 row 4.

form
    placon.bicms    colon 10
    placon.icms     colon 30
    placon.protot  colon 65
    placon.frete    colon 10
    placon.ipi      colon 30
    placon.descpro  colon 10
    placon.acfprod  colon 45
    placon.platot  with frame f2 side-label row 11 width 80 overlay.

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
    find placon where placon.numero = vnumero and
                     placon.emite  = estab.etbcod and
                     placon.movtdc = 6   and
                     placon.serie  = vserie and
                     placon.etbcod = estab.etbcod no-error.
    if not avail placon
    then do:
        message "Nota Fiscal nao cadastrada".
        undo, retry.
    end.

    do on error undo, retry:
        find tipmov where tipmov.movtdc = 6 no-lock.
        display placon.pladat
                placon.datexp format "99/99/9999" 
                string(placon.horincl,"HH:MM") 
                placon.desti with frame f1.
    end.
    for each movcon where movcon.etbcod = placon.etbcod and
                         movcon.placod = placon.placod and
                         movcon.movtdc = placon.movtdc and
                         movcon.movdat = placon.pladat no-lock:
        
        find produ where produ.procod = movcon.procod no-lock.
         disp produ.procod
              produ.pronom format "x(25)"
              movcon.movqtm format ">,>>9.99" column-label "Qtd"
              movcon.movpc  format ">,>>9.99" column-label "Custo"
              (movcon.movpc * movcon.movqtm)(total)
                    format ">>>,>>9.99"
                                    column-label "TOTAL"
                            with frame f-produ2  9 down  overlay
                              centered color message width 80.
                down with frame f-produ2.
     end.
     message "confirma emissao da nota " update sresp.
     if sresp
     then run placon_l.p (input recid(placon)).
end.
