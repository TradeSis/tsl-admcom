{admcab.i}
def input parameter vpedrec as recid.
def output parameter vrecped as recid.
def var vpednum like pedid.pednum.
def var vetbcod like estab.etbcod.
def var vdata   like pedid.peddat.
def var vprocod like produ.procod.
def var vlipcor like liped.lipcor.
def var vlipqtd like liped.lipqtd.
def var vqtd    like liped.lipqtd.
def buffer bpedid for pedid.

def temp-table wf-lip
    field lipqtd    like liped.lipqtd
    field procod    like liped.procod
    field lipcor    like liped.lipcor.

find pedid where recid(pedid) = vpedrec.
update pedid.pednum colon 16
       pedid.etbcod colon 16
       pedid.peddat colon 16
       pedid.sitped colon 16 
       pedid.comcod colon 16 label "Ordem Compra" format ">>>>>>>9"
            with frame ff-1 centered side-label
                color message no-validate.

for each wf-lip:
    delete wf-lip.
end.

for each liped of pedid no-lock:
    find produ of liped no-lock.
    find first wf-lip where wf-lip.procod = produ.procod and
                            wf-lip.lipcor = vlipcor no-error.
    if not avail wf-lip
    then do:
        create wf-lip.
        assign wf-lip.procod = produ.procod
               wf-lip.lipqtd = liped.lipqtd
               wf-lip.lipcor = liped.lipcor.
    end.
    else wf-lip.lipqtd = wf-lip.lipqtd + liped.lipqtd.
end.

        

bl-princ:
repeat:
    vetbcod = pedid.etbcod.
    vdata   = pedid.peddat.
    disp vetbcod colon 18 with frame f1 side-label centered color black/cyan
                                        row 4.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label skip with frame f1.
    disp vdata colon 18 skip with frame f1 .

    repeat:
        clear frame f2 all no-pause.
        for each wf-lip:
            find produ where produ.procod = wf-lip.procod no-lock.
            disp produ.procod
                 produ.pronom format "x(40)"
                 wf-lip.lipcor @ vlipcor
                 wf-lip.lipqtd @ vlipqtd format ">>>>9"
                       with frame f2.
                down with frame f2.
        end.
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
            then return. /* leave. */
            else do:
                vrecped = recid(pedid).
                for each wf-lip:
                    find liped where liped.etbcod = pedid.etbcod and
                                     liped.pedtdc = pedid.pedtdc and
                                     liped.pednum = pedid.pednum and
                                     liped.procod = wf-lip.procod and
                                     liped.lipcor = wf-lip.lipcor and
                                     liped.predt  = pedid.peddat no-error.
                    if not avail liped
                    then create liped.
                        assign liped.pednum = pedid.pednum
                               liped.pedtdc = pedid.pedtdc
                               liped.predt  = pedid.peddat
                               liped.etbcod = pedid.etbcod
                               liped.procod = wf-lip.procod
                               liped.lipcor = wf-lip.lipcor
                               liped.lipqtd = wf-lip.lipqtd
                               liped.lipsit = "A".
                end.
                leave bl-princ.
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
            then do:
                find liped where liped.etbcod = pedid.etbcod and
                                 liped.pedtdc = pedid.pedtdc and
                                 liped.pednum = pedid.pednum and
                                 liped.procod = wf-lip.procod and
                                 liped.lipcor = wf-lip.lipcor and
                                 liped.predt  = pedid.peddat no-error.
                if avail liped
                then delete liped.
                delete wf-lip.
            end.
            else wf-lip.lipqtd = wf-lip.lipqtd - vqtd.
            hide frame f-exc no-pause.
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
        end.
        vlipqtd = 0.
        vlipcor = "" .
    end.
end.
