{admcab.i}
def var ordemcompra as int.
def var vt as char format "x(15)".
def input parameter vetb like estab.etbcod.
def input parameter par-pedtdc like pedid.pedtdc.
def output parameter vrecped as recid.
def var vpednum like pedid.pednum.
def var vetbcod like estab.etbcod.
def var vdata   like pedid.peddat.
def var vprocod like produ.procod.
def var vcomcod as int.
def var vlipcor like liped.lipcor.
def var vlipqtd like liped.lipqtd.
def var vqtd    like liped.lipqtd.
def buffer bpedid for pedid.
def var vpedtdc like pedid.pedtdc.
def var vvencod like pedid.vencod.
def var vforcod like forne.forcod.
def var vnf like pedid.pednum.
def var vdt as date.
def temp-table wf-lip
    field lipqtd    like liped.lipqtd
    field procod    like liped.procod
    field lipcor    like liped.lipcor.

    vpedtdc = int(par-pedtdc).

repeat:
    for each wf-lip:
        delete wf-lip.
    end.
    vetbcod = vetb.
    vdata   = today.
    update vetbcod colon 18 with frame f01 side-label centered color black/cyan
                                        row 4.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label skip with frame f01 width 80.
    update vdata colon 18 skip with frame f01 .
    find last bpedid where bpedid.etbcod = vetbcod and
                           bpedid.pedtdc = vpedtdc and
                           bpedid.pednum >= 1000 no-error.
    if avail bpedid
    then vpednum = bpedid.pednum + 1.
    else vpednum =  vetbcod * 10000.
    display vpednum label "Pedido" colon 18 with frame f01.
    update vforcod label "Fornecedor" colon 18 with frame f01.
    find forne where forne.forcod = vforcod no-lock.
    display forne.fornom no-label format "x(25)" with frame f01.
    update vcomcod label "Comprador"  colon 18 with frame f01.
    find compr where compr.comcod = vcomcod no-lock.
    display compr.comnom no-label format "x(25)" with frame f01.
    update vvencod colon 18 label "Vendedor"
            help "[P] Procura" go-on(P p) with frame f01 no-validate.
    if keyfunction(lastkey) = "p" or
       keyfunction(lastkey) = "P"
    then do:
        {zoomesq.i func func.funcod func.funnom 50 Vendedor
                                   "func.etbcod  = estab.etbcod"}
        vvencod = int(frame-value).
        update vvencod with frame f01.
    end.
    find func where func.etbcod = estab.etbcod and
                    func.funcod = vvencod no-lock no-error.
    if avail func
    then display func.funnom no-label with frame f01.
    ordemcompra = 0.
    update  vnf   label "Nota Fiscal" colon 18
            vdt label "Data Venda" 
            /*ordemcompra label "Ordem de Compra"*/
            vcomcod label "Comprador"
            with frame f01.
    find first compr where compr.comcod = vcomcod no-lock no-error.
    if not avail compr then do:
        message "Comprador nao cadastrado ". pause.
        leave.
    end.
    display compr.comnom no-label with frame f01.
    repeat:
        prompt-for produ.procod
                help "F4 ou ESC  Encerra o pedido  [E] Exclui Produto"
                go-on(F4 PF4 ESC e E)
                with no-validate frame f02 width 80.

        if keyfunction(lastkey) = "END-ERROR" or
           keyfunction(lastkey) = "ESC"
        then do:
            bell.
            message "Confirma Encerramento do Pedido ?"
            update sresp.
            if not sresp
            then leave.
            else do:

                create pedid.
                assign pedid.pedtdc    = vpedtdc
                       pedid.pednum    = vpednum
                       pedid.regcod    = estab.regcod
                       pedid.peddat    = vdata
                       pedid.pedsit    = yes
                       pedid.sitped    = "A"
                       pedid.modcod    = "PED"
                       pedid.etbcod    = vetbcod
                       pedid.clfcod    = vforcod
                       pedid.vencod    = vvencod
                       pedid.frecod    = vnf
                       pedid.condat    = vdt
                       pedid.comcod    = vcomcod.



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
                    if produ.catcod = 45
                    then liped.protip = "C".
                end.
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
            clear frame f02 all no-pause.
            for each wf-lip:
                find produ where produ.procod = wf-lip.procod no-lock.
                disp produ.procod
                     produ.pronom format "x(40)"
                     wf-lip.lipcor @ vlipcor
                     wf-lip.lipqtd @ vlipqtd format ">>>>9"
                           with frame f02.
                    down with frame f02.
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
        display produ.pronom format "x(40)" with frame f02.
        update vlipcor column-label "Cor" with frame f02.
        update vlipqtd format ">>>>9" column-label "Qtd."
               validate (vlipqtd > 0, "Quantidade deve ser maior que zero")
               with frame f02 9 down centered color blank/cyan.

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
        clear frame f02 all no-pause.
        for each wf-lip:
            find produ where produ.procod = wf-lip.procod no-lock.
            disp produ.procod
                 produ.pronom
                 wf-lip.lipcor @ vlipcor
                 wf-lip.lipqtd @ vlipqtd
                        with frame f02.
                 down with frame f02.
            pause 0.
        end.
        vlipqtd = 0.
        vlipcor = "" .
    end.
end.
