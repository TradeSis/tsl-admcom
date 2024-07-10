{admcab.i}
def var x as i.
def var xx as i.
def var xxx as i.
def var vcre as int.
def var vpag as dec.
def var vetbcod like plani.etbcod.
def var vdti like plani.pladat initial today.
def var vdtf like plani.pladat initial today.

def temp-table wf-ven
    field vencod like plani.vencod
    field qtd    like movim.movqtm.
repeat:
    for each wf-ven:
        delete wf-ven.
    end.
    update vetbcod with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1.
    for each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = 5  and
                         plani.pladat >= vdti and
                         plani.pladat <= vdtf no-lock.


        for each movim where movim.etbcod = plani.etbcod and
                               movim.placod = plani.placod and
                               movim.movtdc = plani.movtdc and
                               movim.movdat = plani.pladat no-lock.
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ
            then next.
            if produ.fabcod <> 5027
            then next.
            find first wf-ven where wf-ven.vencod = plani.vencod no-error.
            if not avail wf-ven
            then do:
                create wf-ven.
                assign wf-ven.vencod = plani.vencod.
            end.
            wf-ven.qtd = wf-ven.qtd + movim.movqtm.

            display plani.datexp format "99/99/9999"
                    movim.procod with 1 down. pause 0.
        end.
    end.
    display " V E N D A S    D E    P E C A S     N E W  F R E E "
                with frame f-cc side-label row 7 no-box centered.

    for each wf-ven break by wf-ven.vencod:
        find func where func.funcod = wf-ven.vencod and
                        func.etbcod = estab.etbcod no-lock NO-ERROR.
            
            
            
            vpag = 0.
            vcre = 0.
            xx = 0.
            xxx = 0.
            find last free where free.etbcod = estab.etbcod and
                                 free.vencod = wf-ven.vencod no-lock no-error.
            if avail free
            then wf-ven.qtd = wf-ven.qtd + free.freant.


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
    /*
    message "Gerar Comissao" update sresp.
    if sresp
    then do:
        
        for each wf-ven break by wf-ven.vencod:
            find func where func.funcod = wf-ven.vencod and
                            func.etbcod = estab.etbcod no-lock NO-ERROR.
            vpag = 0.
            vcre = 0.
            xx = 0.
            xxx = 0.

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

            find free where free.etbcod   = vetbcod       and
                            free.vencod   = wf-ven.vencod and
                            free.fredtini = vdti          and
                            free.fredtfin = vdtf  no-error.
            if not avail free
            then do:
                create free.
                assign free.etbcod   = vetbcod 
                       free.vencod   = wf-ven.vencod
                       free.fredtini = vdti 
                       free.fredtfin = vdtf
                       free.datexp   = today
                       free.freval   = vpag
                       free.freant   = vcre
                       free.fresal   = wf-ven.qtd
                       free.fresit   = "ABE".
            end.

        end.
    end.
    */
end.
