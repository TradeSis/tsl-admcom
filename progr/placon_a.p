{admcab.i}
def var vmovqtm   like  movcon.movqtm.
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
     movcon.movqtm format ">>>>99" column-label "Qtd"
     movcon.movpc  format ">>,>>9.99" column-label "Custo"
     vtotger as dec format ">>>,>>9.99" label "Total"
                    with frame f-produ2 row 9 9 down overlay
                                    centered color message width 70.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(30)"
     vprotot
         with frame f-produ centered color message side-label
                        row 20 no-box width 81 overlay.

form
    estab.etbcod label "Emitente" colon 15
    estab.etbnom no-label
    vnumero        colon 15
    vserie         label "Serie"
    placon.pladat  colon 15
    placon.platot
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
        message "Estabelecimento nao cadastrado".
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
    display placon.platot with frame f1.
    update placon.pladat with frame f1.

    clear frame f-produ2 all no-pause.

    for each movcon where movcon.etbcod = placon.etbcod and
                          movcon.placod = placon.placod and
                          movcon.movtdc = placon.movtdc:
        movcon.movdat = placon.pladat.
        find produ where produ.procod = movcon.procod no-lock.
        disp produ.procod
             produ.pronom format "x(30)"
             movcon.movqtm format ">>>>99" column-label "Qtd"
             movcon.movpc  format ">>,>>9.99" column-label "Custo"
             (movcon.movpc * movcon.movqtm) @ vtotger
                            with frame f-produ2.
             down with frame f-produ2.
     end.
     repeat with on endkey undo, leave on error undo, retry:
        /* view frame f-produ2. */
        vprocod = 0.
        display placon.platot with frame f1. 
        update vprocod with frame f-1  
                no-box color message centered row 22 
                                    side-label overlay width 71.
        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao Cadastrado".
            undo, retry.
        end.
        disp produ.pronom no-label with frame f-1.
        find movcon where movcon.etbcod = placon.etbcod and
                         movcon.placod = placon.placod and
                         movcon.procod = produ.procod  no-error.

        if not avail movcon
        then do:
            message "Produto nao pertence a nota".
            undo, retry.
        end.
        vmovqtm = movcon.movqtm.
        update movcon.movqtm
                   with frame f-produ2.

        movcon.desti = placon.desti.
        movcon.emite = placon.emite.        

        clear frame f-produ2 all no-pause.
        hide frame f-1.
        platot = 0.
        protot = 0.
        for each movcon where movcon.etbcod = placon.etbcod and
                              movcon.placod = placon.placod and
                              movcon.movtdc = placon.movtdc and
                              movcon.movdat = placon.pladat:
            find produ where produ.procod = movcon.procod no-lock.
            disp produ.procod
                 produ.pronom format "x(30)"
                 movcon.movqtm format ">>>>99" column-label "Qtd"
                 movcon.movpc  format ">>,>>9.99" column-label "Custo"
                 (movcon.movpc * movcon.movqtm) @ vtotger 
                    with frame f-produ2.
            down with frame f-produ2.
            pause 0.
            placon.protot = placon.protot + (movcon.movpc * movcon.movqtm).
            placon.platot = placon.platot + (movcon.movpc * movcon.movqtm).
        end.

     end.
     clear frame f-1 all no-pause.
     hide frame f-1.
end.
