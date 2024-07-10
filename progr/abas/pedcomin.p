{admcab.i}

def input parameter par-etbcod  like estab.etbcod.
def input parameter par-forcod  like forne.forcod.
def output parameter vrecped as recid.

def var par-tipo as char.
def shared temp-table tt-marca  no-undo
    field marca as log format "*/ "
    field rec as recid
    field procod like abascompra.procod
    field etbcod like abascompra.etbcod
        index x is unique primary procod asc etbcod asc rec asc.

def var vcorcod like cor.corcod.
def var vtam like lipgra.tamcod.
def var produ-novo as log.
def temp-table wclase like clase.
def buffer cprodu for produ.
def buffer cestoq for estoq.
def buffer bfunc for func.
def buffer bestab for estab.
def buffer bprodu for produ.
def buffer bforne for forne.
def var vdtbase    like pedid.condat.
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
def var vcrecod like crepl.crecod format ">999".
def var vcomcod like pedid.comcod.
def var vrepcod like pedid.vencod.
def var vnfdes  like pedid.nfdes.
def var vfrete  like pedid.condes.
def var vipi    as dec .
def var vdupdes like pedid.dupdes.
def var vacrfin like pedid.acrfin.
def var vcondat like pedid.condat format "99/99/9999".
def var vcondes like pedid.condes.
def var vfrecod like pedid.frecod.
def var vfobcif like pedid.fobcif initial no.
def var vpedtot like pedid.pedtot.
def var vpedobs like pedid.pedobs.
def var vpednum like pedid.pednum.
def var vetbcod like estab.etbcod.
def var vlippre like liped.lippreco format ">>>,>>9.99".
def var vlipqtd like liped.lipqtd.
def var vqtd    like liped.lipqtd.
def var vpedido-especial as log.
def var vetb-ori like estab.etbcod.
def var vetb-des like estab.etbcod.
def buffer bpedid for pedid.
def buffer destoq for estoq.

form with frame ff2.

def temp-table tt-grade
    field procod like liped.procod
    field corcod like lipgra.corcod
    field tamcod like lipgra.tamcod
    field lipqtd like lipgra.lipqtd.

def temp-table wf-lip
    field lipqtd    like liped.lipqtd
    field procod    like liped.procod
    field lippre    like liped.lippreco format ">>>,>>9.99"
    field abatipo   like abascompra.abatipo.

par-tipo = "". 
for each tt-marca,
    abascompra where recid(abascompra) = tt-marca.rec no-lock:
    create wf-lip.
    wf-lip.procod = abascompra.procod.
    wf-lip.lipqtd = abascompra.abcqtd.
    wf-lip.lippre = abascompra.lippreco.
    
    wf-lip.abatipo = abascompra.abatipo.
    
    par-tipo = abascompra.abatipo.   
end.

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
                             validate (vpeddti >= today - 30, "Dt.Invalida")
         vpeddtf    label "A"                         format "99/99/9999"
                             validate (vpeddtf >= vpeddti and
                                       vpeddtf < today + 365, "")
         vcrecod       colon 18 label "Prazo de Pagto" format "9999"
         crepl.crenom       no-label
         vcomcod       colon 18 label "Comprador"
         compr.comnom                 no-label
         vfobcif       colon 18
         vfrecod       label "Transport."
         frete.frenom no-label
         vfrete         label "Frete"
         vnfdes        colon 18 label "Desc.Nota"
         vdupdes       label "Desc.Duplicata"
         vipi          label "IPI" format ">9.99%" 
         vacrfin       label "Acres. Financ." colon 18
         with frame f-dialogo color white/cyan overlay row 6
            side-labels centered.
    form
        vpedobs[1] format "x(78)"
        vpedobs[2] format "x(78)"
        vpedobs[3] format "x(78)"
        vpedobs[4] format "x(78)"
        vpedobs[5] format "x(78)"
                 with frame fobs color white/cyan overlay row 9
                                no-labels width 80 title "Observacoes".

do:
    vetbcod = par-etbcod.
    vpedido-especial = no.
    for each tt-grade:
        delete tt-grade.
    end.
    vforcod = par-forcod.
    
    disp vforcod colon 18 label "Fornecedor" with frame f-dialogo.

    if par-tipo <> "ESP"
    then update vforcod with frame f-dialogo.
         
    find forne where forne.forcod = vforcod no-lock no-error.
    /* antonio */
    if not avail forne
    then do:
        message "Fornecedor nao Cadastrado" view-as alert-box.
        undo, retry.
    end.
    if forne.forpai <> 0
    then do:
          find bforne where bforne.forcod = forne.forpai 
                                no-lock no-error.
          if not avail bforne
          then do:
                message "Fornecedor pai nao cadastrado".
                 undo, retry.
          end.
          else do:
            vforcod = bforne.forcod.
            find forne where forne.forcod = vforcod no-lock no-error.
            disp vforcod with frame f-dialogo.
          end.  
    end.
    /**/
    
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
        vregcod = par-etbcod.
        
        disp vregcod with frame f-dialogo.
        if par-tipo <> "ESP"
        then update vregcod with frame f-dialogo.
        
        /* 99 e 96 nao sao mais depositos, agora sao filiais
        if vregcod = 99 or
           vregcod = 96
        then undo.
        */
        
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
    vdtbase = today.
    vpeddti = vdtbase.
    vpeddtf = vpeddti.
       
    disp vdtbase
         with frame f-dialogo.
    if par-tipo <> "ESP"
    then update vdtbase with frame f-dialogo.
         
    do on error undo with frame f-dialogo:
        disp vpeddti vpeddtf.
        if par-tipo <> "ESP"
        then  update vpeddti vpeddtf.
        
        if vpeddtf < vpeddti
        then do:
            message "Prazo de entrega invalido".
            pause.
            undo.
        end.
    end.
    do on error undo:
        vcrecod = 1.
        disp vcrecod  colon 18 label "Prazo de Pagto" format "9999"
                    with frame f-dialogo.
        if par-tipo <> "ESP"
        then update vcrecod with frame f-dialogo.
                            
        find crepl where crepl.crecod = vcrecod no-lock no-error.
        display crepl.crenom       no-label with frame f-dialogo.
    end.
    do on error undo:
        update vcomcod with frame f-dialogo.
        find compr where compr.comcod = vcomcod no-lock no-error.
        display compr.comnom no-label with frame f-dialogo.
    end.
    vfobcif = no.
    
    disp vfobcif
               with frame f-dialogo color white/cyan overlay row 6
                            side-labels centered.
    if par-tipo <> "ESP"
    then update vfobcif with frame f-dialogo.
      
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
    if par-tipo <> "ESP"
    then update vfrete
           vnfdes
           vdupdes
           vipi
           vacrfin with frame f-dialogo color white/cyan overlay row 6
                            side-labels centered.
    pause 0.
    update vpedobs[1] format "x(78)"
           vpedobs[2] format "x(78)"
           vpedobs[3] format "x(78)"
           vpedobs[4] format "x(78)"
           vpedobs[5] format "x(78)"
                 with frame fobs color white/cyan overlay row 9
                                no-labels width 80 title "Observacoes".

            vpedtot = 0.
            for each wf-lip:
                find produ where produ.procod = wf-lip.procod no-lock.

                disp produ.procod @ vprocod
                     produ.proindice column-label "Cod.Barra" format "x(13)"
                     produ.pronom format "x(35)"
                     wf-lip.lipqtd @ vlipqtd format ">>>>9"
                     wf-lip.lippre @ vlippre
                     with frame ff2 row 7.
            
                    if wf-lip.abatipo = "NEO"
                    then do:    
                        vlippre = wf-lip.lippre.
                        update vlippre with frame ff2.
                        wf-lip.lippre = vlippre.   
                    end.      

                down with frame ff2.
                vpedtot = vpedtot + (wf-lip.lippre * wf-lip.lipqtd).
            end.
        
    repeat:
        display vpedtot with frame f-tot column 50 width 30 row 4 side-label
                                        color black/cyan.
        vprocod = 0.
        find first tt-marca no-error.
        if not avail tt-marca
        then do:
            update vprocod
                help "[F4] Encerra  [E] Exclui  [ENTER] Inclui Novo [P] Procura"
                go-on(F4 PF4 ESC e E P p) 
                with no-validate frame ff2 width 80.
        
            if can-find(first produ where produ.procod = vprocod
                                  and produ.opentobuy = no)
            then do:
                                                          
                find first produ where produ.procod = vprocod no-lock no-error.

                 message "O Produto: " produ.pronom
                     "esta bloqueado para compra, consulte o Controller " 
                     "responsavel pela area." view-as alert-box.
                                 next.
                                 
            end.
        end.
            
        if avail tt-marca or
           keyfunction(lastkey) = "end-error" or
           keyfunction(lastkey) = "ESC" or
           lastkey = keycode("F4")  or
           lastkey = keycode("PF4")
        then do:
            message "Confirma Encerramento do Pedido?"
            update sresp.
            if not sresp
            then leave.
            else do:
                
                if vpedido-especial = yes
                then repeat on endkey undo on error undo, retry:
                    update sresp label "Pedido especial?"
                            with frame f-esp.
                    if not sresp  
                    then vpedido-especial = no.  
                    update vetb-ori at 1 when sresp label "Filial Origem"
                    vetb-des      when sresp label "Filial Destino"
                        with frame f-esp side-label overlay centered row 15
                        color message. 
                    if vpedido-especial and
                        (vetb-ori = 0 or vetb-des = 0)
                    then.
                    else leave.
                end.
                
                do transaction:
                find last bpedid use-index ped
                             where bpedid.etbcod = bestab.etbcod and
                                   bpedid.pedtdc = 1 
                                        no-lock no-error.
                if avail bpedid
                then vpednum = bpedid.pednum + 1.
                else vpednum = 1.
                create pedid.
                assign pedid.pedtdc   = 1
                       pedid.pednum   = vpednum
                       pedid.clfcod   = forne.forcod
                       pedid.regcod   = bestab.etbcod
                       pedid.peddat   = today
                       pedid.pedsit   = yes /* true */
                       pedid.sitped   = "A"
                       pedid.etbcod   = bestab.etbcod
                       pedid.condat   = vdtbase
                       pedid.peddti   = vpeddti
                       pedid.peddtf   = vpeddtf
                       pedid.crecod   = vcrecod
                       pedid.comcod   = vcomcod
                       pedid.condes   = vfrete
                       pedid.nfdes    = vnfdes
                       pedid.dupdes   = vdupdes
                       pedid.ipides   = vipi
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
                    vrecped = recid(pedid).
                    if vetb-ori > 0 or
                       vetb-des > 0
                    then pedid.pedobs[1] =  
                            "Filial Origem=" + string(vetb-ori) + "|" +
                            "Filial Destino=" + string(vetb-des) + "|"
                            + pedid.pedobs[1]
                            .
   
                    
                end.
                find pedid where recid(pedid) = vrecped no-lock.
                vpedtot = 0.
                for each wf-lip:
                    find produ where produ.procod = wf-lip.procod no-lock.
                    find first simil where simil.procod = wf-lip.procod 
                            no-error.
                    if avail simil
                    then do transaction:
                        delete simil.
                    end.
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
                        find first destoq where
                             destoq.procod = liped.procod  and
                             destoq.etbcod = 93
                             no-lock no-error.
                        if avail cestoq
                        then liped.lipsep = destoq.estvenda.
                    end.
                    do transaction:
                        assign liped.lipqtd   = wf-lip.lipqtd
                               liped.lippreco = wf-lip.lippre.
                    end.
                    
                    for each tt-grade where tt-grade.procod = produ.procod:
                        find lipgra where lipgra.etbcod = liped.etbcod and
                                          lipgra.pedtdc = liped.pedtdc and
                                          lipgra.pednum = liped.pednum and 
                                          lipgra.procod = liped.procod and
                                          lipgra.lipcor = liped.lipcor and
                                          lipgra.predt  = liped.predt  and
                                          lipgra.corcod = tt-grade.corcod and
                                          lipgra.tamcod = tt-grade.tamcod
                                                no-error.
                        if not avail lipgra
                        then do transaction:
                            create lipgra. 
                            assign lipgra.etbcod = liped.etbcod 
                                   lipgra.pedtdc = liped.pedtdc
                                   lipgra.pednum = liped.pednum
                                   lipgra.procod = liped.procod
                                   lipgra.lipcor = liped.lipcor
                                   lipgra.predt  = liped.predt
                                   lipgra.corcod = tt-grade.corcod
                                   lipgra.tamcod = tt-grade.tamcod
                                   lipgra.lipqtd = tt-grade.lipqtd.
                                    
                        
                        end.
                                                

                    end.
                    vpedtot = vpedtot + (wf-lip.lippre * wf-lip.lipqtd).
                    if produ.proseq = 99
                    then do on error undo:
                        find current produ exclusive no-error.
                        if avail produ
                        then produ.proseq = 98.
                        find current produ no-lock. 
                    end.
                    if vpedido-especial
                    then do transaction:
                        create pedcompe.
                        assign
                            pedcompe.etbcod = pedid.etbcod
                            pedcompe.pedtdc = pedid.pedtdc
                            pedcompe.pednum = pedid.pednum
                            pedcompe.etbcod_ori = vetb-ori
                            pedcompe.etbcod_des = vetb-des
                            pedcompe.procod = liped.procod
                            .
                        
                    end.
                end.
                if forne.forcod = 5027
                then run exp_new.p (input pedid.etbcod,
                                    input pedid.pedtdc,
                                    input compr.comnom).
                if vcatcod = 41
                then run alcis/pedch.p (recid(pedid)).

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
            then do:
                delete wf-lip.
                for each tt-grade where tt-grade.procod = vprocod:
                    delete tt-grade.
                end.
            end.    
            else wf-lip.lipqtd = wf-lip.lipqtd - vqtd.
            hide frame f-exc no-pause.
            clear frame ff2 all no-pause.
            vpedtot = 0.
            for each wf-lip:
                find produ where produ.procod = wf-lip.procod no-lock.

                disp produ.procod @ vprocod
                     produ.proindice column-label "Cod.Barra" format "x(13)"
                     produ.pronom format "x(35)"
                     wf-lip.lipqtd @ vlipqtd format ">>>>9"
                     wf-lip.lippre @ vlippre
                     with frame ff2.
                    down with frame ff2.
                pause 0.
                vpedtot = vpedtot + (wf-lip.lippre * wf-lip.lipqtd).
            end.
            next.
        end.
        produ-novo = no.
        if vprocod = 0
        then
            run pedpro.p (input vcatcod,
                          input vforcod,
                          input vfrete,
                          input vnfdes,
                          input vacrfin,
                          output vprocod,
                          output produ-novo).

        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao Cadastrado".
            undo, retry.
        end.        
        if produ.proipival = 1
        then vpedido-especial = yes.
                    
        display produ.procod @ vprocod
                produ.proindice
                produ.pronom format "x(35)" with frame ff2.               
                
        update vlipqtd format ">>>>9" column-label "Qtd."
                   validate (vlipqtd > 0, "Quantidade deve ser maior que zero")
                       with frame ff2 9 down centered color blank/cyan.
        find last estoq where estoq.procod = produ.procod no-lock no-error.
        if avail estoq and produ-novo = no
        then do.
            assign
                vlippre = estoq.estcusto - (estoq.estcusto * (vnfdes / 100))
                vlippre = estoq.estcusto - (estoq.estcusto * (vdupdes / 100))
                vlippre = vlippre + (estoq.estcusto * (vacrfin / 100)).
            vlippre = vlippre + (estoq.estcusto * (vfrete / 100)).
        end.
        else vlippre = estoq.estcusto.
        update vlippre column-label "Preco" with frame ff2.
       
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
        
        if forne.forcod = 5027
        then do:
            vqtd = 0.
            hide frame f-grade no-pause.
            repeat:
        
                assign vcorcod = ""
                       vtam    = ""
                       vqtd    = 0.
                update vcorcod column-label "COR" with 
                            with frame f-grade 10 down centered row 10
                                title "GRADE".
                            
                find cor where cor.corcod = vcorcod no-lock no-error.
                if not avail cor
                then do:
                    message "Cor nao cadastrada".
                    undo, retry.
                end.

                display cor.cornom with frame f-grade.
    
                update vtam column-label "TAMANHO"
                       vqtd column-label "QUANTIDADE"
                        with frame f-grade.
                find first tt-grade where tt-grade.procod = produ.procod and
                                          tt-grade.corcod = vcorcod      and
                                          tt-grade.tamcod = vtam no-error.
                if not avail tt-grade
                then do:
                    create tt-grade.
                    assign tt-grade.procod = produ.procod 
                           tt-grade.corcod = vcorcod
                           tt-grade.tamcod = vtam
                           tt-grade.lipqtd = vqtd.
                end.
                else tt-grade.lipqtd = vqtd.

                down with frame f-grade.                
            end.        
            hide frame f-grade no-pause.
        end.
        
        vpedtot = 0.
        for each wf-lip:
            find produ where produ.procod = wf-lip.procod no-lock.
            disp produ.procod @ vprocod
                 produ.pronom
                 produ.proindice
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
