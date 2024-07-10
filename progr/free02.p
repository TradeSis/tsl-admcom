{admcab.i}
def buffer bfree for free.
def var totqtd like free.fresal.
def var totpre like free.fresal.
def var x as i.
def var xx as i.
def var xxx as i.
def var vcre as int.
def var vpag as dec.
def var vetbi like plani.etbcod.
def var vetbf like plani.etbcod.
def var vdti like plani.pladat initial today.
def var vdtf like plani.pladat initial today.

def temp-table wf-ven
    field etbcod like estab.etbcod
    field vencod like plani.vencod
    field qtd    like movim.movqtm.
repeat:
    for each wf-ven:
        delete wf-ven.
    end.
    update vetbi label "Filial"  colon 16
           vetbf label "Filial" with frame f1 side-label width 80.

    do on error undo, retry:
        find first free no-lock no-error.
        if avail free
        then do:
            vdti = free.fredtfin + 1.

            update vdti label "Data Inicial" colon 16
                   vdtf label "Data Final" with frame f1.
            if vdti <> free.fredtfin + 1 or
               vdtf <= free.fredtfin
            then do:
                message "Data Invalida".
                undo, retry.
            end.
        end.
        else do:
            vdti = today.
            update vdti label "Data Inicial" colon 16
                   vdtf label "Data Final" with frame f1.
        end.


    end.
         


    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:

        for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 5  and
                             plani.pladat >= vdti and
                             plani.pladat <= vdtf no-lock.

            find last free where free.etbcod   = estab.etbcod and
                                 free.vencod   = plani.vencod and
                                 free.fredtfin >= plani.pladat no-error.
            if avail free
            then next.

            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat no-lock.
                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ
                then next.
                if produ.fabcod <> 5027
                then next.
                find first wf-ven where wf-ven.etbcod = plani.etbcod and
                                        wf-ven.vencod = plani.vencod no-error.
                if not avail wf-ven
                then do:
                    create wf-ven.
                    assign wf-ven.etbcod = plani.etbcod
                           wf-ven.vencod = plani.vencod.
                end.
                wf-ven.qtd = wf-ven.qtd + movim.movqtm.
            
                display plani.datexp format "99/99/9999"
                        movim.procod 
                        plani.etbcod with 1 down. pause 0.
            end.
        end.
    end.
    
    display " V E N D A S    D E    P E C A S     N E W  F R E E "
                with frame f-cc side-label row 7 no-box centered.

    for each wf-ven break by wf-ven.vencod:
        find func where func.funcod = wf-ven.vencod and
                        func.etbcod = wf-ven.etbcod no-lock NO-ERROR.
            
            vpag = 0.
            vcre = 0.
            xx   = 0.
            xxx  = 0.
            do x = 1 to wf-ven.qtd:
               xx = xx + 1.
               if xx = 75
               then do:
                    vpag = vpag + 10.
                    xx = 0.
               end.
            end.
            if wf-ven.qtd < 75
            then vcre = wf-ven.qtd.
            else do:
                repeat:
                    xxx = xxx + 1.
                    if xxx = 1
                    then vcre = wf-ven.qtd - 75.
                    else vcre = vcre - 75.
                    if vcre > 75
                    then next.
                    else leave.
                end.
            end.
            if vcre = 75
            then vcre = 0.
            
            disp wf-ven.vencod
                 func.funnom when avail func format "x(15)"
                 wf-ven.qtd(total) column-label "Pecas"
                 vpag(total) column-label "Comissao" format ">>,>>9.99"
                 vcre(total) column-label "Credito"
                    with frame f3 down no-box
                        color white/yellow centered.
    end.
    
    
    message "Gerar Comissao" update sresp.
    if sresp
    then do:
        
        for each wf-ven break by wf-ven.vencod:
            find func where func.funcod = wf-ven.vencod and
                            func.etbcod = wf-ven.etbcod no-lock NO-ERROR.

            find first free where free.etbcod   = wf-ven.etbcod       and
                                  free.vencod   = wf-ven.vencod no-error.
            if not avail free
            then do transaction:
                create free.
                assign free.etbcod   = wf-ven.etbcod 
                       free.vencod   = wf-ven.vencod
                       free.fredtini = vdti 
                       free.fredtfin = vdtf
                       free.datexp   = today
                       free.fresit   = "ABE".
            end.
            do transaction:
                assign free.fredtfin = vdtf
                       free.freval   = free.freval + wf-ven.qtd
                       free.fresal   = int(((free.freval / 75) - 0.50)).
            end.
        end.
        totqtd = 0.
        totpre = 0.
        for each free where free.vencod < 99 no-lock break by free.etbcod:
            totqtd = totqtd + free.freval.
            totpre = totpre + free.fresal.
            if last-of(free.etbcod) 
            then do transaction:
                find first bfree where bfree.etbcod = free.etbcod and
                                       bfree.vencod = 99 no-error.
                if not avail bfree
                then do:
                    create bfree.
                    assign bfree.etbcod   = free.etbcod 
                           bfree.vencod   = 999
                           bfree.fredtini = vdti 
                           bfree.fredtfin = vdtf
                           bfree.datexp   = today
                           bfree.fresit   = "ABE".
                end.
                assign bfree.fredtfin = vdtf
                       bfree.freval   = totqtd
                       bfree.fresal   = int(((totpre / 4) - 0.50))
                       totqtd = 0.

                totpre = 0.
            end.


        end.    
    end.
end.
