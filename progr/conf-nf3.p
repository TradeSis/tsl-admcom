{admcab.i} 
def var vtip      as log format "Sim/Nao" initial no.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vprotot   like  plani.protot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(3)" /*like  plani.serie*/.
def var vprocod   like  produ.procod.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.

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
    vtip         label "Almoxarifado" colon 15
    estab.etbcod label "Emitente" colon 15
    estab.etbnom  no-label
    vnumero   colon 15
    vserie
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
    vtip = no.
    
    update vtip with frame f1.
    
    prompt-for estab.etbcod label "Emitente" with frame f1.
    find estab where estab.etbcod = input estab.etbcod no-lock no-error.
    if not avail estab
    then do:
        message "estabelecimento nao cadastrado".
        undo, retry.
    end.
    vserie = "".
    display estab.etbnom with frame f1.
    update vnumero
           vserie with frame f1.
    if vtip
    then do:
        find plani where plani.numero = vnumero and
                         plani.emite  = estab.etbcod and
                         plani.movtdc = 9   and
                         plani.serie  = vserie and
                         plani.etbcod = estab.etbcod NO-LOCK no-error.
        if not avail plani
        then do: 
            message "Nota nao cadastrada na matriz". 
            pause.  
            undo, retry.
        end.
        if setbcod <> plani.desti 
        then do:
            message "Esta filial nao pode confirmar esta nota".
            undo, retry.
        end.
        
        if plani.modcod = "CAN"
        then do:
            message "Nota Cancelada! Nao será possível confirmá-la.".
            undo,retry.
        end.
        
        display plani.desti format ">>>>>>>99"
                plani.pladat
                plani.datexp format "99/99/9999" with frame f1.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
            find produ where produ.procod = movim.procod no-lock.
            disp produ.procod
                 produ.pronom format "x(25)"
                 movim.movqtm format ">,>>9.99" column-label "Qtd"
                 movim.movpc  format ">,>>9.99" column-label "Custo"
                ((movim.movpc * movim.movqtm) -
                 ((movim.movpc * movim.movqtm) * (movim.movpdesc / 100)))
                    format ">>,>>9.99" column-label "TOTAL"
                            with frame f-produ2  9 down  overlay
                              centered color message width 80.
        
            down with frame f-produ2.

        end.
        
        message "confirma nota fiscal" update sresp.
        if sresp 
        then do transaction: 
            find first nottra where nottra.etbcod = plani.etbcod and
                                    nottra.desti  = plani.desti  and
                                    nottra.numero = plani.numero and
                                    nottra.serie  = plani.serie  and
                                    nottra.movtdc = plani.movtdc
                              NO-LOCK no-error.
            if avail nottra
            then do:
                message "Nota Fiscal ja confirmada".
                undo, retry.
            end.
            else do:
                create nottra.
                assign nottra.etbcod = plani.etbcod
                       nottra.desti  = plani.desti
                       nottra.movtdc = plani.movtdc
                       nottra.numero = plani.numero
                       nottra.serie  = plani.serie
                       nottra.datexp = today.
            end.
        end.
    end.
    else do:    
        find plani where plani.numero = vnumero and
                         plani.emite  = estab.etbcod and
                         plani.movtdc = 6   and
                         plani.serie  = vserie and
                         plani.etbcod = estab.etbcod NO-LOCK no-error.
        if not avail plani
        then do:
                    message "Nota nao cadastrada na matriz".
                    pause. 
                    undo.
        end.
        if setbcod <> plani.desti 
        then do:
            message "Esta filial nao pode confirmar esta nota".
            undo, retry.
        end.
        
        if plani.modcod = "CAN"
        then do:
            message "Nota Cancelada! Nao será possível confirmá-la.".
            undo,retry.
        end.
        
        display plani.desti format ">>>>>>>99"
                plani.pladat
                plani.datexp format "99/99/9999" with frame f1.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
            find produ where produ.procod = movim.procod no-lock.
            disp produ.procod
                 produ.pronom format "x(25)"
                 movim.movqtm format ">,>>9.99" column-label "Qtd"
                 movim.movpc  format ">,>>9.99" column-label "Custo"
                ((movim.movpc * movim.movqtm) -
                 ((movim.movpc * movim.movqtm) * (movim.movpdesc / 100)))
                    format ">>,>>9.99" column-label "TOTAL"
                            with frame f-produ3  9 down  overlay
                              centered color message width 80.
        
            down with frame f-produ3.
        end.
        
        message "confirma nota fiscal" update sresp.
        if sresp 
        then do transaction: 
            find first nottra where nottra.etbcod = plani.etbcod and
                                    nottra.desti  = plani.desti  and
                                    nottra.numero = plani.numero and
                                    nottra.serie  = plani.serie  and
                                    nottra.movtdc = plani.movtdc
                              NO-LOCK no-error.
            if avail nottra
            then do:
                message "Nota Fiscal ja confirmada".
                undo, retry.
            end.
            else do:
                create nottra.
                assign nottra.etbcod = plani.etbcod
                       nottra.desti  = plani.desti
                       nottra.movtdc = plani.movtdc
                       nottra.numero = plani.numero
                       nottra.serie  = plani.serie
                       nottra.datexp = today.
            end.
        end.
    end.
end.    
