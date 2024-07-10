{admcab.i}
def temp-table wclase like clase.
def buffer cprodu for produ.
def buffer cestoq for estoq.
def buffer bfunc for func.
def buffer bestab for estab.
def buffer bprodu for produ.
def var vdtbase    like pedid.condat.
def var vestcusto  like estoq.estcusto.
def var vestmgoper like estoq.estmgoper.
def var vestmgluc  like estoq.estmgluc.
def var vtabcod    like estoq.tabcod.
def var vestvenda  like estoq.estvenda.
def var vcatcod like produ.catcod.
def var vprocod like produ.procod.
def var vpedpro like produ.procod.
def var vclacod like produ.clacod.
def var vfabcod like produ.fabcod.
def var vregcod like pedid.regcod.
def var vforcod like forne.forcod.
def var vpeddat as date.
def var vpeddti as date.
def var vpeddtf as date.
def var vcrecod like crepl.crecod format ">99".
def var vcomcod like pedid.comcod.
def var vrepcod like pedid.vencod.
def var vnfdes  like pedid.nfdes.
def var vdupdes like pedid.dupdes.
def var vacrfin like pedid.acrfin.
def var vcondat like pedid.condat format "99/99/9999".
def var vcondes like pedid.condes.
def var vfrecod like pedid.frecod.
def var vfobcif like pedid.fobcif initial no.
def var vpedtot like pedid.pedtot.
def var vpedobs like pedid.pedobs.
def input parameter vetb like estab.etbcod.
def output parameter vrecped as recid.
def var vpednum like pedid.pednum.
def var vetbcod like estab.etbcod.
def var vdata   like pedid.peddat.
def var vlippre like liped.lippreco.
def var vlipqtd like liped.lipqtd.
def var vqtd    like liped.lipqtd.
def buffer bpedid for pedid.
form with frame ff2.
def temp-table wf-lip
    field lipqtd    like liped.lipqtd
    field procod    like liped.procod
    field lippre    like liped.lippreco.

    form vforcod      colon 18 label "Fornecedor"
         forne.fornom      no-label format "x(30)"
         forne.forcgc      colon 18
         forne.forinest    colon 50 label "I.E" format "x(17)"
         forne.forrua      colon 18 label "Endereco"
         forne.fornum
         forne.forcomp no-label
         forne.formunic   colon 18 label "Cidade"
         forne.ufecod   label "UF"
         forne.forcep      label "Cep"
         forne.forfone        colon 18 label "Fone"
         vregcod colon 18 label "Local Entrega"
         bestab.etbnom no-label
         vrepcod    colon 18
         repre.repnom no-label
         vdtbase    colon 18 label "Data Base" format "99/99/9999"
         vpeddti    colon 18 label "Prazo de Entrega" format "99/99/9999"
         vpeddtf    label "A"                         format "99/99/9999"
         vcrecod       colon 18 label "Prazo de Pagto"
         crepl.crenom       no-label
         vcomcod       colon 18 label "Comprador"
         compr.comnom                 no-label
         vfobcif       colon 18
         vfrecod       label "Transport."
         frete.frenom no-label
         vnfdes        colon 18 label "Desc.Nota"
         vdupdes       label "Desc.Duplicata"
         vacrfin       label "Acres. Financ."
         with frame f-dialogo color white/cyan overlay row 6
            side-labels centered.
    form
        vpedobs[1] at 1 vpedobs[2] at 1 vpedobs[3] at 1
        vpedobs[4] at 1 vpedobs[5] at 1
                 with frame fobs color white/cyan overlay row 9
                                no-labels centered title "Observacoes".
repeat:
    vetbcod = vetb.
    vdata   = today.
    /*
    update vetbcod colon 18 with frame ff1 side-label centered color black/cyan
                                        row 4.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label skip with frame ff1.
    update vdata colon 18 skip with frame ff1 .
    */
    update vforcod      colon 18 label "Fornecedor" with frame f-dialogo.
    find forne where forne.forcod = vforcod no-lock no-error.
    display
           forne.fornom
           forne.forcgc
           forne.forinest
           forne.forrua
           forne.fornum
           forne.forcomp
           forne.formunic
           forne.ufecod
           forne.forcep
           forne.forfone with frame f-dialogo.
    do on error undo:
        vregcod = vetb.
        update vregcod with frame f-dialogo.
        find bestab where bestab.etbcod = vregcod no-lock no-error.
        if not avail bestab
        then do:
            message "Local nao Cadastrado".
            undo, retry.
        end.
        disp bestab.etbnom with frame f-dialogo.
        find repre where repre.repcod = forne.repcod no-lock no-error.
        if avail repre
        then vrepcod = repre.repcod.
        else update vrepcod with frame f-dialogo.
        find repre where repre.repcod = vrepcod no-lock.
        display vrepcod
                repre.repnom no-label with frame f-dialogo.
    end.
    if bestab.etbcod = 996
    then vcatcod = 41.
    else vcatcod = 31.
    update vdtbase
           vpeddti
           vpeddtf with frame f-dialogo.
    do on error undo:
        update vcrecod  colon 18 label "Prazo de Pagto"
                    with frame f-dialogo.
        find crepl where crepl.crecod = vcrecod no-lock no-error.
        display crepl.crenom       no-label with frame f-dialogo.
    end.
    do on error undo:
        update vcomcod with frame f-dialogo.
        find compr where compr.comcod = vcomcod no-lock no-error.
        display compr.comnom no-label with frame f-dialogo.
    end.
    update vfobcif
               with frame f-dialogo color white/cyan overlay row 6
                            side-labels centered.
    if vfobcif
    then do on error undo:
        update vfrecod
               with frame f-dialogo color white/cyan overlay row 6
                            side-labels centered.
        find frete where frete.frecod = vfrecod no-lock no-error.
        if not avail frete
        then do:
            message "Transportadora nao cadastrada".
            undo, retry.
        end.
        display frete.frenom no-label with frame f-dialogo.
    end.
    update vnfdes
           vdupdes
           vacrfin with frame f-dialogo color white/cyan overlay row 6
                            side-labels centered.
    update vpedobs[1] at 1 vpedobs[2] at 1 vpedobs[3] at 1
           vpedobs[4] at 1 vpedobs[5] at 1
                 with frame fobs color white/cyan overlay row 9
                                no-labels centered title "Observacoes".

    repeat:
        display vpedtot with frame f-tot column 50 width 30 row 5 side-label
                                        color black/cyan.
        vprocod = 0.
        update vprocod
        /* prompt-for produ.procod */
help "[F4] Encerra  [E] Exclui  [ENTER] Inclui Novo [P] Procura"
                go-on(F4 ESC e E P p) with no-validate frame ff2 width 80.
        /* vprocod = input produ.procod. */
        if keyfunction(lastkey) = "end-error" or
           keyfunction(lastkey) = "ESC"
        then do:
            bell.
            message "Confirma Encerramento do Pedido ?"
            update sresp.
            if not sresp
            then leave.
            else do:
                find last bpedid where bpedid.etbcod = bestab.etbcod and
                                       bpedid.pedtdc = 6 no-error.
                if avail bpedid
                then vpednum = bpedid.pednum + 1.
                else vpednum = 1.
                do transaction:
                create pedid.
                assign pedid.pedtdc    = 6
                       pedid.pednum    = vpednum
                       pedid.clfcod    = forne.forcod
                       pedid.regcod    = bestab.etbcod
                       pedid.peddat    = vdata
                       pedid.pedsit    = yes
                       pedid.sitped    = "A"
                       pedid.etbcod    = bestab.etbcod
                       pedid.condat   = vdtbase
                       pedid.peddti   = vpeddti
                       pedid.peddtf   = vpeddtf
                       pedid.crecod   = vcrecod
                       pedid.comcod   = vcomcod
                       pedid.nfdes    = vnfdes
                       pedid.dupdes   = vdupdes
                       pedid.acrfin   = vacrfin
                       pedid.frecod   = vfrecod
                       pedid.fobcif   = vfobcif
                       pedid.modcod   = "PED"
                       pedid.vencod   = vrepcod
                       pedid.pedtot   = vpedtot
                       pedid.pedobs[1] = vpedobs[1]
                       pedid.pedobs[2] = vpedobs[2]
                       pedid.pedobs[3] = vpedobs[3]
                       pedid.pedobs[4] = vpedobs[4]
                       pedid.pedobs[5] = vpedobs[5].
                end.
                vrecped = recid(pedid).
                vpedtot = 0.
                for each wf-lip:
                    find produ where produ.procod = wf-lip.procod no-lock.
                    find clase where clase.clacod = produ.clacod no-lock.
                    find liped where liped.etbcod = pedid.etbcod and
                                     liped.pedtdc = pedid.pedtdc and
                                     liped.pednum = pedid.pednum and
                                     liped.procod = produ.procod and
                                     liped.lipcor = ""           and
                                     liped.predt  = pedid.peddat no-error.
                    if not avail liped
                    then do transaction:
                        create liped.
                        assign liped.pednum = pedid.pednum
                               liped.pedtdc = pedid.pedtdc
                               liped.predt  = pedid.peddat
                               liped.predtf = pedid.peddtf
                               liped.etbcod = pedid.etbcod
                               liped.procod = wf-lip.procod
                               liped.lippreco = wf-lip.lippre
                               liped.lipqtd = wf-lip.lipqtd
                               liped.lipsit = "A"
                               liped.protip = if clase.claordem = yes
                                              then "M"
                                              else "C".
                    end.
                    do transaction:
                        assign liped.lipqtd   = wf-lip.lipqtd
                               liped.lippreco = wf-lip.lippre.
                    end.

                    vpedtot = vpedtot + (wf-lip.lippre * wf-lip.lipqtd).

                end.
                /* display pedid.pednum colon 18 with frame ff1. */
                leave.
            end.
        end.
        if keyfunction(lastkey) = "p" or
           keyfunction(lastkey) = "P"
        then do:
            {zoomesq.i produ produ.procod pronom 50 Produtos
                                          "produ.catcod = vcatcod and
                                           produ.fabcod = vforcod"}
             vpedpro = int(frame-value).
             vprocod = int(frame-value).
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
            find first wf-lip where wf-lip.procod = produ.procod no-error.
            if not avail wf-lip
            then do:
                message "Produto nao esta no Pedido".
                undo.
            end.
            else update vqtd label "Quant"
                        validate(vqtd <= wf-lip.lipqtd,
                                       "Quantidade Invalida") with frame f-exc.
            update vlippre column-label "Valor" with frame f-exc.
            if vqtd = wf-lip.lipqtd
            then delete wf-lip.
            else wf-lip.lipqtd = wf-lip.lipqtd - vqtd.
            hide frame f-exc no-pause.
            clear frame ff2 all no-pause.
            vpedtot = 0.
            for each wf-lip:
                find produ where produ.procod = wf-lip.procod no-lock.
                disp produ.procod @ vprocod
                     produ.pronom format "x(40)"
                     wf-lip.lipqtd @ vlipqtd format ">>>>9"
                     wf-lip.lippre @ vlippre
                           with frame ff2.
                    down with frame ff2.
                pause 0.
                vpedtot = vpedtot + (wf-lip.lippre * wf-lip.lipqtd).
            end.
            next.
        end.
        if vprocod = 0
        then
        run pedpro.p (input vcatcod,
                      input vforcod,
                      input vnfdes,
                      input vacrfin,
                      input vtabcod,
                      output vprocod).

        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao Cadastrado".
            undo, retry.
        end.
        display produ.procod @ vprocod
                produ.pronom format "x(40)" with frame ff2.
        update vlipqtd format ">>>>9" column-label "Qtd."
               validate (vlipqtd > 0, "Quantidade deve ser maior que zero")
               with frame ff2 9 down centered color blank/cyan.
        find last estoq where estoq.procod = produ.procod no-lock no-error.
        if avail estoq
        then do:
            assign
                vlippre = estoq.estcusto - (estoq.estcusto * (vnfdes / 100))
                vlippre = estoq.estcusto - (estoq.estcusto * (vdupdes / 100))
                vlippre = vlippre + (estoq.estcusto * (vacrfin / 100)).
        end.
        update vlippre column-label "Preco" with frame ff2.
        if vlippre <> estoq.estcusto
        then do:
            for each cestoq where cestoq.procod = produ.procod:
                cestoq.estcusto = vlippre.
            end.
        end.

        find first wf-lip where wf-lip.procod = produ.procod no-error.
        if not avail wf-lip
        then do:
            create wf-lip.
            assign wf-lip.procod = produ.procod
                   wf-lip.lipqtd = vlipqtd
                   wf-lip.lippre = vlippre.
        end.
        else wf-lip.lipqtd = wf-lip.lipqtd + vlipqtd.
        clear frame ff2 all no-pause.
        vpedtot = 0.
        for each wf-lip:
            find produ where produ.procod = wf-lip.procod no-lock.
            disp produ.procod @ vprocod
                 produ.pronom
                 wf-lip.lipqtd @ vlipqtd
                 wf-lip.lippre @ vlippre
                        with frame ff2.
                 down with frame ff2.
            pause 0.
            vpedtot = vpedtot + (wf-lip.lippre * wf-lip.lipqtd).
        end.
        vlipqtd = 0.
        vlippre = 0.
    end.
end.
