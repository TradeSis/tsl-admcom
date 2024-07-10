{admcab.i}
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
def var vserie    as char.
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

form
    estab.etbcod label "Emitente" colon 15
    estab.etbnom  no-label
    /*vciccgc        colon 15*/
    /*clien.clinom  no-label format "x(20)"*/
    /*clien.ciccgc  no-label*/
    vnumero   colon 15
    vserie
    /*plani.opccod   colon 15
    opcom.opcnom
    plani.opfcod label "Op.Fiscal"  colon 15
    opfis.opfnom no-label */
    plani.pladat       colon 15
    plani.datexp format "99/99/9999"
      with frame f1 side-label color white/cyan width 80 row 4.

form
    plani.bicms    colon 10
    plani.icms     colon 30
    plani.protot  colon 65
    plani.frete    colon 10
    plani.ipi      colon 30
    plani.descpro  colon 10
    plani.acfprod  colon 45
    plani.platot  with frame f2 side-label row 11 width 80 overlay.

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
           vserie with frame f1 no-validate.
           
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
     end.
     message "confirma emissao da nota " update sresp.
     if sresp
     then run imptra_l.p  /* imptra_r.p */ (input recid(plani)).
end.
