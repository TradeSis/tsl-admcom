
{admcab.i}

def input parameter p-etbcod like estab.etbcod.
def input parameter p-placod like plani.placod.
def input parameter p-serie  like plani.serie.

def var vforcod   like forne.forcod.
def var vmovqtm   like  movim.movqtm.
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
def var vprocod   like  produ.procod.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotal      like plani.platot.

hide frame f-com1 no-pause.
hide frame f-com2 no-pause.

form produ.procod
     produ.pronom format "x(30)"
     movim.movqtm format ">,>>9.99" column-label "Qtd"
     movim.movalicms column-label "ICMS"
     movim.movalipi  column-label "IPI"
     movim.movpc  format ">,>>9.99" column-label "Custo"
                    with frame f-produ1 row 8 7 down overlay
                                    centered color message width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 18 no-box width 81 overlay.

form
    estab.etbcod label "Filial" colon 15
    estab.etbnom no-label skip
    vforcod colon 15
    forne.fornom no-label
    vnumero   colon 15
    vserie    at 32
    /*
    plani.opfcod  label "Op.Fiscal" colon 15
    opfis.opfnom  no-label */
    plani.pladat       colon 15
    plani.dtinclu label "Dt.Receb." format "99/99/9999" 
    plani.datexp label "Dt.Digitacao" format "99/99/9999"
    plani.descprod colon 15
    plani.platot   at 32
    plani.protot   label  "Total Prod."
      with frame f1 side-label color blue/cyan width 80 row 10.

form
    plani.bicms    colon 10
    plani.icms     colon 30
    plani.protot  colon 65
    plani.frete    colon 10
    plani.ipi      colon 30
    plani.descpro  colon 10
    plani.acfprod  colon 45
    plani.platot  with frame f2 side-label row 15 width 80 overlay.

/*repeat:*/
    clear frame f1 no-pause.
    clear frame f-1 no-pause.
    clear frame f-produ1 no-pause.
    hide  frame f2 no-pause.
    
    /*prompt-for estab.etbcod with frame f1.
    find estab using estab.etbcod no-lock.
    display
        estab.etbnom with frame f1.

    update vforcod with frame f1.
    find forne where forne.forcod = vforcod no-lock.
    disp forne.fornom no-label with frame f1.
    
    vserie = "U".
    update vnumero
           vserie with frame f1.
    find plani where plani.numero = vnumero and
                     plani.emite  = vforcod and
                     plani.movtdc = 4    and
                     plani.serie  = vserie and
                     plani.etbcod = input estab.etbcod no-error.
    if not avail plani
    then do:
        message "Nota Fiscal nao cadastrada".
        undo, retry.
    end.
    */
    find plani where plani.etbcod = p-etbcod
                 and plani.placod = p-placod 
                 and plani.serie  = p-serie no-lock no-error.
    if not avail plani
    then do:
        message "Nota Fiscal nao Encontrada".
        undo.
    end.        
    pause 0.
    find estab where estab.etbcod = plani.etbcod no-lock.
    display
        estab.etbnom with frame f1 row 10.

    find forne where forne.forcod = plani.emite no-lock.
    disp forne.fornom no-label with frame f1.
    
    vserie = "U".
    /*update vnumero
           vserie with frame f1.*/
    disp plani.numero @ vnumero
         plani.serie  @ vserie
         with frame f1.
        
        display plani.pladat
                plani.dtinclu
                plani.datexp
                plani.descprod
                plani.platot
                plani.protot
                with frame f1.

        display plani.bicms
               plani.icms with frame f2.
    display
        plani.protot
        plani.frete
        plani.ipi
        plani.descpro
        plani.acfprod with frame f2.
    display plani.platot with frame f2.
    vtotal = vipi + vdesacess + vseguro + vfrete +
             vprotot - vdescpro.
    clear frame f-produ2 all no-pause.

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc no-lock:
        find produ where produ.procod = movim.procod no-lock.
         disp produ.procod
              produ.pronom format "x(24)"
              movim.movqtm format ">,>>9.99" column-label "Qtd"
              movim.movalicms column-label "ICMS"
              movim.movalipi  column-label "IPI"
              movim.movpc  format ">,>>9.99" column-label "Custo"
              (movim.movpc * movim.movqtm) format ">>>,>>9.99"
                                    column-label "TOTAL"
                            with frame f-produ2 6 down row 13
                              centered color message width 80.
             down with frame f-produ2.
     end.
     pause.
     clear frame f-1 all no-pause.
     hide frame f-produ no-pause.
     hide frame f-produ2 no-pause.
     hide frame f2 no-pause.
     hide frame f1 no-pause.
/*end. */
