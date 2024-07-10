{admcab.i}
def var varquivo as char.
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
def buffer bplani for plani.

form produ.procod
     produ.pronom format "x(30)"
     movim.movqtm format ">,>>9.99" column-label "Qtd"
     movim.movpc  format ">,>>9.99" column-label "Custo"
     movim.movalicms column-label "ICMS"
     /*movim.movalipi  column-label "IPI"*/
                    with frame f-produ1 row 5 7 down overlay
                                    centered color message width 80.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(25)"
     vprotot
         with frame f-produ centered color message side-label
                        row 15 no-box width 81 overlay.

form
    estab.etbcod label "Filial" colon 15
    estab.etbnom no-label
    clien.clinom  no-label format "x(20)"
    vnumero   colon 15
    vserie
    plani.pladat       colon 15
    plani.datexp format "99/99/9999" 
      with frame f1 side-label width 80 row 4 color blue/cyan.

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
    prompt-for estab.etbcod with frame f1.
    find estab using estab.etbcod no-lock.
    display estab.etbnom with frame f1.

    vserie = "TR".
    update vnumero with frame f1.

    find plani where plani.numero = vnumero and
                     plani.emite  = estab.etbcod and
                     plani.movtdc = 17  and
                     plani.serie = vserie and
                     plani.etbcod = estab.etbcod no-error.
    if avail plani
    then do:
        find bplani where bplani.numero = vnumero and
                          bplani.emite  = estab.etbcod and
                          bplani.movtdc = 18  and
                          bplani.serie = vserie and
                          bplani.etbcod = estab.etbcod no-error.
        if not avail bplani
        then do:
            message "Nota Fiscal nao cadastrada".
            undo, retry.
        end.
    end.
    else do:
            message "Nota Fiscal nao cadastrada".
            undo, retry.
    end.
    display vserie with frame f1.
    do on error undo, retry:
        display plani.pladat with frame f1.
        update plani.datexp with frame f1.
        bplani.datexp = plani.datexp.
    end.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/troca" + STRING(day(today)) + 
                            string(estab.etbcod,">>9").
    else varquivo = "..\relat\troca" + STRING(day(today)) + 
                string(estab.etbcod,">>9").

    {mdad.i &Saida     = "value(varquivo)" 
            &Page-Size = "0"
            &Cond-Var  = "130"
            &Page-Line = "0"
            &Nom-Rel   = ""trocac""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """FILIAL "" + string(estab.etbcod,"">>9"") +
                          "" TROCA "" + string(plani.numero,"">>>>>9"")"
            &Width     = "130"
            &Form      = "frame f-cabcab"}


    if plani.vencod <> 0
    then do:
        find func where func.funcod = plani.vencod and
                        func.etbcod = 999      no-lock no-error.
        if avail func
        then do:
            display func.funcod
                    func.funnom with frame f-func side-label.
        end.
    end.
                    
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movdat = plani.pladat and
                         movim.movtdc = plani.movtdc:
        
        movim.datexp = plani.datexp.
        
        find produ where produ.procod = movim.procod no-lock.
        find tipmov where tipmov.movtdc = movim.movtdc no-lock.
        
        disp produ.procod
             produ.pronom format "x(25)"
             movim.movqtm format ">,>>9.99" column-label "Qtd"
             movim.movpc  format ">,>>9.99" column-label "Valor"
             (movim.movpc * movim.movqtm)(total) column-label "SubTotal"
             tipmov.movtnom with frame f-produ2 
                    down overlay centered width 130.
    
        down with frame f-produ2.
    
    end.

    for each movim where movim.etbcod = bplani.etbcod and
                         movim.placod = bplani.placod:
        movim.datexp = plani.datexp.
        find produ where produ.procod = movim.procod no-lock.
        find tipmov where tipmov.movtdc = movim.movtdc no-lock.
        disp produ.procod
             produ.pronom format "x(25)"
             movim.movqtm format ">,>>9.99" column-label "Qtd"
             movim.movpc  format ">,>>9.99" column-label "Valor"
             (movim.movpc * movim.movqtm)(total) column-label "SubTotal"
             tipmov.movtnom with frame f-produ3 
                                down overlay width 130.

        down with frame f-produ3.
    end.
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:     
    {mrod.i}
    end.
end.
