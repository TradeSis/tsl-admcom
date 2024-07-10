{admcab.i}
def input parameter vetb like estab.etbcod.
def input parameter par-pedtdc like pedid.pedtdc.
def output parameter vrecped as recid.
def var vpednum like pedid.pednum.
def var vetbcod like estab.etbcod.
def var vdata   like pedid.peddat.
def var vprocod like produ.procod.
def var vlipcor like liped.lipcor.
def var vlipqtd like liped.lipqtd.
def var vqtd    like liped.lipqtd.
def buffer bpedid for pedid.
def var vpedtdc like pedid.pedtdc.
def temp-table wf-lip
    field lipqtd    like liped.lipqtd
    field procod    like liped.procod
    field lipcor    like liped.lipcor.

    vpedtdc = int(par-pedtdc).

repeat:
    vetbcod = vetb.
    vdata   = today.
    update vetbcod colon 18 with frame f1 side-label centered color black/cyan
                                        row 4.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label skip with frame f1.
    update vdata colon 18 skip with frame f1 .

    repeat:
        prompt-for produ.procod
                help "F4 ou ESC  Encerra o pedido  [E] Exclui Produto"
                go-on(F4 ESC e E)
                with no-validate frame f2 width 80.

        if keyfunction(lastkey) = "end-error" or
           keyfunction(lastkey) = "ESC"
        then do:
            bell.
            message "Confirma Encerramento do Pedido ?"
            update sresp.
            if not sresp
            then leave.
            else do:

                find last bpedid where bpedid.etbcod = vetbcod and
                                       bpedid.pedtdc = vpedtdc no-error.
                if avail bpedid
                then vpednum = bpedid.pednum + 1.
                else vpednum = 1.

                create pedid.
                assign pedid.pedtdc    = vpedtdc
                       pedid.pednum    = vpednum
                       pedid.regcod    = estab.regcod
                       pedid.peddat    = vdata
                       pedid.pedsit    = yes
                       pedid.sitped    = "A"
                       pedid.modcod    = "PED"
                       pedid.etbcod    = vetbcod.
                vrecped = recid(pedid).

                for each wf-lip:
                    find produ where produ.procod = wf-lip.procod no-lock.
                    find clase where clase.clacod = produ.clacod no-lock.
                    create liped.
                    assign liped.pednum = pedid.pednum
                           liped.pedtdc = pedid.pedtdc
                           liped.predt  = pedid.peddat
                           liped.etbcod = pedid.etbcod
                           liped.procod = wf-lip.procod
                           liped.lipcor = wf-lip.lipcor
                           liped.lipqtd = wf-lip.lipqtd
                           liped.lipsit = "A"
                           liped.protip = if clase.claordem = yes
                                          then "M"
                                          else "C".
                    if produ.catcod = 35
                    then liped.protip = "M".
                    if produ.catcod = 45  or
                       produ.catcod = 51
                    then liped.protip = "C".
                end.
                display pedid.pednum colon 18 with frame f1.
                leave.
            end.
        end.


        if keyfunction(lastkey) = "E" or
           keyfunction(lastkey) = "e"
        then do:
            update vprocod with frame f-exc side-label no-box width 81.
            find produ where produ.procod = vprocod no-lock no-error.
            if not avail produ
            then do:
                message "Produto nao Cadastrado".
                undo, retry.
            end.
            display produ.pronom no-label format "x(20)" with frame f-exc.
            update vlipcor column-label "Cor" with frame f-exc.
            find first wf-lip where wf-lip.procod = produ.procod and
                                    wf-lip.lipcor = vlipcor no-error.
            if not avail wf-lip
            then do:
                message "Produto nao esta no Pedido".
                undo.
            end.
            else update vqtd label "Quant"
                        validate(vqtd <= wf-lip.lipqtd,
                                       "Quantidade Invalida") with frame f-exc.
            if vqtd = wf-lip.lipqtd
            then delete wf-lip.
            else wf-lip.lipqtd = wf-lip.lipqtd - vqtd.
            hide frame f-exc no-pause.
            clear frame f2 all no-pause.
            for each wf-lip:
                find produ where produ.procod = wf-lip.procod no-lock.
                disp produ.procod
                     produ.pronom format "x(40)"
                     wf-lip.lipcor @ vlipcor
                     wf-lip.lipqtd @ vlipqtd format ">>>>9"
                           with frame f2.
                    down with frame f2.
                pause 0.
            end.
            next.
        end.

        find produ using produ.procod no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao Cadastrado".
            undo, retry.
        end.
        display produ.pronom format "x(40)" with frame f2.
        update vlipcor column-label "Cor" with frame f2.
        update vlipqtd format ">>>>9" column-label "Qtd."
               validate (vlipqtd > 0, "Quantidade deve ser maior que zero")
               with frame f2 9 down centered color blank/cyan.

        find first wf-lip where wf-lip.procod = produ.procod and
                                wf-lip.lipcor = vlipcor no-error.
        if not avail wf-lip
        then do:
            create wf-lip.
            assign wf-lip.procod = produ.procod
                   wf-lip.lipqtd = vlipqtd
                   wf-lip.lipcor = vlipcor.
        end.
        else wf-lip.lipqtd = wf-lip.lipqtd + vlipqtd.
        clear frame f2 all no-pause.
        for each wf-lip:
            find produ where produ.procod = wf-lip.procod no-lock.
            disp produ.procod
                 produ.pronom
                 wf-lip.lipcor @ vlipcor
                 wf-lip.lipqtd @ vlipqtd
                        with frame f2.
                 down with frame f2.
            pause 0.
        end.
        vlipqtd = 0.
        vlipcor = "" .
    end.
end.
