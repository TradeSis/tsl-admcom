{admcab.i}
{difregtab.i new}

def buffer bforne for forne.
def buffer sclase for clase.
def temp-table tt-pedid-a like pedid.
def temp-table tt-pedid-d like pedid.
def var vestilo  as char format "x(30)".
def var vestacao as char format "x(15)".
def var vpreco like liped.lippreco.
def var vsemipi like liped.lippreco.
def var totger like pedid.pedtot.
def var totpen like pedid.pedtot.
def var vnum as char format "x(79)" extent 3.
def var vforcod         like forne.forcod.
def var v-procod-ped    like produ.procod INIT ?.
def var vcomcod         like compr.comcod.

def var recatu1         as recid.
def var reccont         as int.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
  initial ["Consulta","Inclusao","Impressao","Alteracao","Exclusao","Procura"].
def var esqcom2         as char format "x(12)" extent 5
  initial ["Entrada","","","","E-mail"].

def var v-proc-ope as char format "x(12)" extent 4 initial
    [" Pedido", " FORNECEDOR ","PRODUTO","TODOS"].
def var v-proci-ope as int.

def buffer bpedid            for pedid.
def buffer bestab            for estab.
def var vetbcod              like estab.etbcod.
def var vpednum              like pedid.pednum.
def var vpedtdc              like pedid.pedtdc.
def var vrecped              as recid.

    form forne.forcod      colon 18 label "Fornecedor"
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
         pedid.regcod    colon 18 label "Local Entrega"
         bestab.etbnom   no-label
         pedid.vencod    colon 18
         repre.repnom    no-label
         repre.fone      label "Fone"
         pedid.condat    colon 18
         pedid.peddti    colon 18 label "Prazo de Entrega" format "99/99/9999"
         pedid.peddtf    label "A"                         format "99/99/9999"
         pedid.crecod    colon 18 label "Prazo de Pagto" format "9999"
         crepl.crenom    no-label
         pedid.comcod    colon 18 label "Comprador"
         compr.comnom                 no-label
         pedid.frecod    label "Transport." colon 18
         pedid.fobcif
         pedid.condes       label "Frete" 
         pedid.nfdes        colon 18 label "Desc.Nota"
         pedid.dupdes       label "Desc.Duplicata"
         pedid.ipides       label "% IPI" format ">9.99 %"
         pedid.acrfin       label "Acres. Financ." colon 18
         with frame f-dialogo color white/cyan overlay row 6
                side-labels centered.
    form
        pedid.pedobs[1]  format "x(75)"
        pedid.pedobs[2]  format "x(75)"
        pedid.pedobs[3]  format "x(75)"
        pedid.pedobs[4]  format "x(75)"
        pedid.pedobs[5]  format "x(75)"
        with frame fobs color white/cyan overlay row 9
                        no-labels width 80 title "Observacoes".
    form
        esqcom1
            with frame f-com1 centered
                 row 4 no-box no-labels column 1.
    form
        esqcom2
            with frame f-com2 centered
                 row screen-lines no-box no-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
    /*
    if setbcod = 990
    then do:
        message "Voce esta na matriz, operacao invalida". pause.
        undo, leave.
    end.
    */

    vetbcod = setbcod.
    update vetbcod colon 16
        with frame fest color white/cyan 
            side-labels no-box width 80 row 5.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame fest.
    
    update vforcod label "Fornecedor" colon 16
            with frame fest.
    if vforcod = 0
    then disp "GERAL" @ forne.fornom format "x(5)" no-label with frame fest.
    else do:
        find forne where forne.forcod = vforcod no-lock no-error.
        if not avail forne
        then do:
            message "Fornecedor nao cadastrado".
            undo, retry.
        end.
        /****************************
        else do:

            if forne.forpai <> 0
            then do:
                find bforne where bforne.forcod = forne.forpai 
                                no-lock no-error.
                if not avail bforne
                then do:
                    message "Fornecedor pai nao cadastrado".
                    undo, retry.
                end.
                else vforcod = bforne.forcod.
            end.
        end.
        ********************/
    end.    
    
    update vcomcod label "Comprador" with frame fest.
    if vcomcod = 0
    then disp "TODOS" @ compr.comnom no-label with frame fest.
    else do:
        find compr where compr.comcod = vcomcod no-lock.
        display compr.comnom no-label with frame fest.
    end.
    
{segregua.i}

bl-princ:
repeat:
    vpedtdc = 1 /*integer(par-pedtdc)*/ .
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then
        find last pedid where pedid.etbcod = vetbcod and
                              pedid.pedtdc = vpedtdc and
                              (if vforcod = 0
                               then true
                               else pedid.clfcod = vforcod) and
                              (if vcomcod = 0
                               then true
                               else pedid.comcod = vcomcod) no-lock no-error.
     else
        find pedid where recid(pedid) = recatu1 no-lock.
    
    if not available pedid
    then do:
        message "Cadastro de pedidos Vazio".
        if vetbcod <> 996
        then do.
            message "Deseja Incluir " update sresp.
            if not sresp
            then do.
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run pedcomin.p (input vetbcod, output vrecped).
            end.
        end.
    end.

    clear frame frame-a all no-pause.
    run frame-a.
    
    recatu1 = recid(pedid).

    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        find prev pedid where pedid.etbcod = vetbcod and
                              pedid.pedtdc = vpedtdc and
                              (if vforcod = 0
                               then true
                               else pedid.clfcod = vforcod) and
                              (if vcomcod = 0
                               then true
                               else pedid.comcod = vcomcod) no-lock no-error.
        if not available pedid
        then leave.

        if v-procod-ped <> ?
        then do:
            find first liped of pedid where liped.procod = v-procod-ped
                    no-lock no-error.
            if not avail liped then next.
        end.

        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.

        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:
        disp esqcom2[esqpos2] with frame f-com2.
        find pedid where recid(pedid) = recatu1 no-lock no-error.

        if vnum[1] <> ""
        then disp vnum[1]
                  vnum[2]
                  /*vnum[3]*/
                  with frame f-ped row screen-lines - 2 no-box color white/cyan
                                           no-label overlay centered.

        on f7 recall.
        choose field pedid.pednum
            go-on(cursor-down cursor-up
                  cursor-left cursor-right S s
                  page-up page-down  F7 PF7
                  tab PF4 F4 ESC return).
 
        color display white/red pedid.pednum.
        pause 0.
        if keyfunction(lastkey) = "RECALL"
        then do WITH FRAME fproc centered row 7 color message overlay.
            pause 0.
            prompt-for pedid.pednum.
            find last pedid where pedid.etbcod = vetbcod and
                                  pedid.pedtdc = vpedtdc and
                                  pedid.pednum = input pedid.pednum and
                                 (if vforcod = 0
                                  then true
                                  else pedid.clfcod = vforcod) and
                                 (if vcomcod = 0
                                  then true
                                  else pedid.comcod = vcomcod) no-lock no-error.
            if avail pedid
            then do:
                 if v-procod-ped <> ?
                 then do:
                        find first liped of pedid 
                            where liped.procod = v-procod-ped
                                    no-lock no-error.
                        if avail liped then recatu1 = recid(pedid).
                 end.
                 else recatu1 = recid(pedid).             
                 recatu1 = recid(pedid).
            end.
            leave.
        end.
        on f7 help.
        if keyfunction(lastkey) = "TAB" /*and esqpos1 = 6*/
        then do:
            if esqregua = yes
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                color display message esqcom2[esqpos2] with frame f-com2.
            end.
            else do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                color display message esqcom1[esqpos1] with frame f-com1.
            end.
            pause 0.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right" /*or
          ( keyfunction(lastkey) = "TAB" and esqpos1 <> 6 )*/
        then do:
            if esqregua
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
            end.
            else do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                color display messages esqcom2[esqpos2] with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
            end.
            else do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                color display messages esqcom2[esqpos2] with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "S" or
           keyfunction(lastkey) = "s"
        then do ON ERROR UNDO:
            find pedid where recid(pedid) = recatu1 exclusive-lock no-error.
            update pedid.sitped with frame frame-a no-validate.
            find pedid where recid(pedid) = recatu1 no-lock.
            leave.
        end.
        /********************** anterior - antonio 
        if keyfunction(lastkey) = "cursor-down"
        then do:
              find prev pedid where  pedid.etbcod = vetbcod
                              and  pedid.pedtdc = vpedtdc
                              and (if vforcod = 0 
                                   then true 
                                   else pedid.clfcod = vforcod)
                              and (if vcomcod = 0 
                                   then true 
                                   else pedid.comcod = vcomcod)
                              no-lock no-error.
              if not avail pedid
              then next.
            color display white/red pedid.pednum.
            pause 0.    
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        ***************************/

        /*************************** anterior
        if keyfunction(lastkey) = "cursor-up"
        then do:
              find next pedid where pedid.etbcod = vetbcod and
                              pedid.pedtdc = vpedtdc and
                              (if vforcod = 0
                               then true
                               else pedid.clfcod = vforcod) and
                              (if vcomcod = 0
                               then true
                               else pedid.comcod = vcomcod) no-lock no-error.
             if not avail pedid
             then next.
             color display white/red
                pedid.pednum.
            pause 0.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        ***************************/
        /* antonio - Sol. apenas Pedidos com Produto selecionado */
        if keyfunction(lastkey) = "cursor-down"
        then do: 
            repeat:
              find prev pedid where  pedid.etbcod = vetbcod
                              and  pedid.pedtdc = vpedtdc
                              and (if vforcod = 0 
                                   then true 
                                   else pedid.clfcod = vforcod)
                              and (if vcomcod = 0 
                                   then true 
                                   else pedid.comcod = vcomcod)
                              no-lock no-error.
              if not avail pedid
              then leave.
              if v-procod-ped <> ?
              then do:
                   find first liped of pedid where liped.procod = v-procod-ped
                       no-lock no-error.
                   /*recatu1 = recid(pedid).*/
                   if not avail liped then next. 
              end.
              /**/
            color display white/red pedid.pednum.
            pause 0.    
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
            leave.
        end.
        if not avail pedid then next.
        else recatu1 = recid(pedid).
        end.
        /* antonio - Sol. apenas Pedidos com Produto selecionado */
        if keyfunction(lastkey) = "cursor-up"
        then do:
        repeat:
              find next pedid where pedid.etbcod = vetbcod and
                              pedid.pedtdc = vpedtdc and
                              (if vforcod = 0
                               then true
                               else pedid.clfcod = vforcod) and
                              (if vcomcod = 0
                               then true
                               else pedid.comcod = vcomcod) no-lock no-error.

              if not avail pedid
              then leave.
             
              if v-procod-ped <> ?
              then do:
                   find first liped of pedid where liped.procod = v-procod-ped
                       no-lock no-error.
                   if not avail liped then next. 
              end.

             color display white/red
                pedid.pednum.
            pause 0.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
            leave.
        end.
        if not avail pedid then next.
        else recatu1 = recid(pedid).
        end.
        
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev pedid where pedid.etbcod = vetbcod and
                              pedid.pedtdc = vpedtdc and
                              (if vforcod = 0
                               then true
                               else pedid.clfcod = vforcod) and
                              (if vcomcod = 0
                               then true
                               else pedid.comcod = vcomcod) no-lock no-error.
                if not avail pedid
                then leave.
                recatu1 = recid(pedid).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next pedid where pedid.etbcod = vetbcod and
                              pedid.pedtdc = vpedtdc and
                              (if vforcod = 0
                               then true
                               else pedid.clfcod = vforcod) and
                              (if vcomcod = 0
                               then true
                               else pedid.comcod = vcomcod) no-lock no-error.
                if not avail pedid
                then leave.
                recatu1 = recid(pedid).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do /*on error undo, retry on endkey undo, leave*/.
          hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.
            if esqcom1[esqpos1] = "Inclusao"
            then do.
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.

                run versenha.p ("", "D.COMPRAS,TELEFONIA",
                                "Inclusao de pedido",
                                output sresp).
                if not sresp
                then leave.

                if false and vetbcod = 996
                then do.
                    run co_ocn.p (input vetbcod,
                                  output vrecped).
                    if vrecped = ?
                    then leave.
                    recatu1 = vrecped.
                    find pedid where recid(pedid) = recatu1 no-lock.
                    find categoria of pedid no-lock.
                    if categoria.grade
                    then run co_ocpprop.p (recatu1).
/***
                    else run co_ocppro.p (input recatu1,?).
***/
                    find pedid where recid(pedid) = recatu1 no-lock.
                    if not can-find(first liped of pedid)
                    then do on error undo:
                        pause 3 message "deletando".
                        pause.
                        find pedid where recid(pedid) = recatu1 exclusive.
                        for each liped of pedid.
                            delete liped.
                        end.
                        for each lipedpai of pedid.
                            delete lipedpai.
                        end.
                        delete pedid.
                        recatu1 = ?.
                        leave.
                    end.
                
                    message "Finaliza ORDEM DE COMPRA?" update sresp.
                    if sresp
                    then run co_ocefet01.p (recatu1).
                end.
                else do.
                    run pedcomin.p (input vetbcod,
                                    output vrecped).
                    if vrecped <> ?
                    then recatu1 = vrecped.
                end.
                next bl-princ.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run versenha.p ("", "D.COMPRAS,TELEFONIA",
                                "Alteracao de Pedido",
                                output sresp).
                if not sresp
                then next.

                find categoria of pedid no-lock no-error.
                if avail categoria and categoria.grade
                then run co_occons.p (input recid(pedid)).
                else run pedcomal.p (input recid(pedid),
                                     output vrecped ).
                leave.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do:
                hide frame f-com1  no-pause.
                hide frame f-com2  no-pause.
                hide frame frame-a no-pause.
                find categoria of pedid no-lock no-error.
                if avail categoria and categoria.grade
                then run co_occons.p (input recid(pedid)).
                else do.

                find forne where forne.forcod = pedid.clfcod no-lock.
                find crepl where crepl.crecod = pedid.crecod no-lock.
                find bestab where bestab.etbcod = pedid.regcod no-lock.
                find compr where compr.comcod = pedid.comcod no-lock.
                find repre where repre.repcod = pedid.vencod no-lock.
                disp forne.forcod
                     forne.fornom
                     forne.forcgc
                     forne.forinest
                     forne.forrua
                     forne.fornum
                     forne.forcomp
                     forne.formunic
                     forne.ufecod
                     forne.forcep
                     forne.forfone
                     pedid.regcod
                     bestab.etbnom
                     pedid.vencod
                     repre.repnom
                     repre.fone
                     pedid.condat format "99/99/9999"
                     pedid.peddti format "99/99/9999"
                     pedid.peddtf format "99/99/9999"
                     pedid.crecod format "9999"
                     crepl.crenom
                     pedid.comcod
                     compr.comnom
                     pedid.frecod
                     pedid.fobcif
                     pedid.condes
                     pedid.nfdes
                     pedid.dupdes
                     pedid.ipides
                     pedid.acrfin
                        with frame f-dialogo color white/cyan overlay row 6
                                                        side-labels centered.
                pause.
                display pedid.pedobs[1]
                        pedid.pedobs[2]
                        pedid.pedobs[3]
                        pedid.pedobs[4]
                        pedid.pedobs[5]
                    with frame fobs color white/cyan overlay row 9
                                        no-labels centered title "Observacoes".
                pause.
                run cons-tablog.
                totpen = 0.
                totger = 0.
                for each liped of pedid no-lock,
                    each produ where produ.procod = liped.procod
                            no-lock by produ.pronom.

                    /* antonio - Sol 26337 */
                    find first sclase 
                         where sclase.clacod = produ.clacod no-lock no-error.
                    find first clase 
                         where clase.clacod = sclase.clasup no-lock no-error.
                    vestacao = "".
                    find estac where estac.etccod = produ.etccod
                     no-lock no-error.
                    if avail estac
                    then vestacao = estac.etcnom.
                    else vestacao = "".
                    vestilo = "".
                    find first procaract 
                      where procaract.procod = produ.procod no-lock no-error.
                    if avail procaract
                    then do:
                            find first subcaract where
                                /* subcaract.carcod = 2 and */
                                subcaract.subcar = procaract.subcod
                                no-lock no-error.
                            if avail subcaract
                            then vestilo = subcaract.subdes.            
                    end.
                    /***/
                    vsemipi = 0.
                    vpreco = 0.
                    vsemipi = (liped.lippreco - 
                              (liped.lippreco * (pedid.nfdes / 100))).
                    
                    vpreco = (liped.lippreco - 
                              (liped.lippreco * (pedid.nfdes / 100))).

                    vpreco = (vpreco + 
                              (vpreco * (pedid.ipides / 100))).
                    
                    disp liped.procod
                         produ.pronom format "x(35)" when avail produ
                         produ.proindice format "x(13)" 
                                        column-label "Cod.Barras"
                         vpreco format ">,>>9.99" column-label "Preco"
                         liped.lipqtd column-label "Qtd!Ped" format ">>>>9"
                         liped.lipent column-label "Qtd!Ent" format ">>>>9"
                         sclase.clacod column-label "Sub-Clase" at 3
                                when avail sclase
                         vestacao column-label "Estacao"
                         subcaract.carcod column-label "Cod.Carac." when
                            avail subcaract
                         vestilo  column-label "Sub-Carac."              
                                 with frame f-con 4 down row 7
                                        color black/cyan title " Produtos "
                                        width 80.
                    /* antonio */
                    totpen = totpen + ((liped.lipqtd - liped.lipent) *
                                        liped.lippreco /*vpreco*/).
                    totger = totger + (liped.lipqtd * liped.lippreco 
                                                       /*vpreco*/).
                end.
                display totger
                        totpen label "Total Pendente" format "->>>,>>9.99"
                        with frame f-tot row 22 side-label centered
                                            color black/cyan no-box.

                pause.
                hide frame f-tot no-pause.
                hide frame f-dialogo no-pause.
                hide frame fobs no-pause.
                end. /* grade */
                leave.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do.
                if pedid.sitped = "F"
                then do:
                    message "Pedido ja Entregue nao pode ser Excluido".
                    pause.
                    leave.
                end.
                else do:
                    run versenha.p ("", "D.COMPRAS,TELEFONIA",
                                    "Exclusao de Pedido",
                                    output sresp).
                    if not sresp
                    then leave.
                    message "Confirma Exclusao de" pedid.pednum update sresp.
                    if not sresp
                    then leave.
                    find prev pedid where pedid.etbcod = vetbcod and
                               pedid.pedtdc = vpedtdc and
                              (if vforcod = 0
                               then true
                               else pedid.clfcod = vforcod) and
                              (if vcomcod = 0
                               then true
                               else pedid.comcod = vcomcod) NO-LOCK no-error.
                    if not available pedid
                    then do:
                        find pedid where recid(pedid) = recatu1 NO-LOCK.
                        find next pedid where pedid.etbcod = vetbcod and
                               pedid.pedtdc = vpedtdc and
                              (if vforcod = 0
                               then true
                               else pedid.clfcod = vforcod) and
                              (if vcomcod = 0
                               then true
                               else pedid.comcod = vcomcod) NO-LOCK no-error.
                    end.
                    recatu2 = if available pedid
                            then recid(pedid)
                            else ?.
                    do transaction.
                        find pedid where recid(pedid) = recatu1 exclusive.
                        for each liped of pedid.
                            delete liped.
                        end.
                        for each lipedpai of pedid.
                            delete lipedpai.
                        end.
                        delete pedid.
                    end.
                    recatu1 = recatu2.
                    leave.
                end.
            end.
            if esqcom1[esqpos1] = "Impressao"
            then do.
                find categoria of pedid no-lock.
                if categoria.grade
                then run lpedidmoda.p (recid(pedid)).
                else do.
                    message "Escritorio/Fornecedor?" update sresp format "E/F".
                    if sresp
                    then run lpedid5.p (input recid(pedid)).
                    else run lpedid7.p (input recid(pedid)).
                end.
                leave.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do :
                vnum = "".
                v-procod-ped = ?.
                /* antonio - Sol 26337 */
                hide frame f-com2 no-pause.
                disp v-proc-ope no-labels 
                    with frame f-proc-ope centered row 9 no-box .
                choose field v-proc-ope with frame f-proc-ope.
                hide frame v-proc-ope no-pause.
                if frame-index = 4
                then do:
                     recatu1 = ?.
                     v-procod-ped = ?.
                     leave.
                end.
                if frame-index = 1
                then do.
                    prompt-for pedid.pednum
                        with frame fproc1 centered row 11 color message overlay.

                    find first pedid where pedid.etbcod = vetbcod and
                              pedid.pedtdc = vpedtdc and
                              pedid.pednum = input pedid.pednum and
                              (if vforcod = 0
                               then true
                               else pedid.clfcod = vforcod) and
                              (if vcomcod = 0
                               then true
                               else pedid.comcod = vcomcod) no-lock no-error.


                    hide frame fproc1 no-pause.
                end.
                else if frame-index = 2
                then do:
                    update vforcod
                     WITH FRAME fproc2 centered row 11 color message overlay.
                     find last pedid where pedid.etbcod = vetbcod and
                                          pedid.pedtdc = vpedtdc      and
                                          pedid.clfcod = vforcod
                              no-lock no-error.
                     hide frame fproc2 no-pause.
                end.
                else do:
                    update v-procod-ped label "Produto" 
                            WITH FRAME fproc3 centered row 11 
                            color message overlay.
                    hide frame fproc3 no-pause.
/*** TP 21491351
                    for each pedid no-lock where pedid.etbcod = vetbcod and
                                         pedid.pedtdc = vpedtdc and
                                         pedid.clfcod = (if vforcod <> 0
                                         then vforcod 
                                         else pedid.clfcod) and 
                                         (if vcomcod = 0
                                          then true
                                          else pedid.comcod = vcomcod)
                                          by pedid.pedtdc desc
                                          by pedid.etbcod desc
                                          by pedid.clfcod desc:
        
                        find last liped of pedid where 
                              liped.procod = v-procod-ped no-lock no-error.
                        if avail liped
                        then do.
                            assign recatu1 = recid(pedid).
                            leave.
                        end.
                    end.
***/
                    /*** TP 21491351 ***/
                    for each liped where liped.pedtdc = vpedtdc
                                     and liped.procod = v-procod-ped
                                     and liped.etbcod = vetbcod
                                     use-index liped2
                                   no-lock.
                        find bpedid of liped no-lock no-error.
                        if not avail bpedid
                        then next.

                        if (vforcod > 0 and pedid.clfcod <> vforcod) or
                            (vcomcod > 0 and pedid.comcod <> vcomcod)
                        then next.

                        recatu1 = recid(pedid).
                        leave.
                    end.
                end.
                /**/
                
                if not avail pedid 
                then do:                          
                    message "Inexistente tente outro filtro" view-as alert-box.
                    hide frame fproc1 no-pause.
                    hide frame fproc2 no-pause.
                    undo,retry.
                end.
                if avail pedid
                then do:
                    recatu1 = recid(pedid).
                    for each pedid where pedid.etbcod = vetbcod and
                                         pedid.pedtdc = vpedtdc and
                                         pedid.clfcod = vforcod
                                         no-lock
                                         by pedid.pednum desc.
                        if length(vnum[1]) >= 80
                        then do:
                            if length(vnum[2]) >= 80
                            then do:
                                if length(vnum[2]) >= 80
                                then.
                                else vnum[3] = string(vnum[3]) + ", " +
                                              string(pedid.pednum).
                            end.
                            else vnum[2] = string(vnum[2]) + ", " +
                                          string(pedid.pednum).
                        end.
                        else vnum[1] = string(vnum[1]) + ", " +
                                      string(pedid.pednum).
                    end.
                end.
                pause 0.
                leave.
            end.
          end.
          else do:
            pause 0.
            if esqcom2[esqpos2] = "Entrada"
            then do:
                run nfentped.p (input recid(pedid)).
                leave.
            end.
            if esqcom2[esqpos2] = "Duplicacao"
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run peddup.p (input recatu1).
                disp esqcom1 with frame f-com1.
            end.
            if esqcom2[esqpos2] = "E-mail"
            then run ped_email.p (input recid(pedid)).
            
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2] with frame f-com2.
                pause 0.
          end.
          view frame frame-a.
          pause 0.
          view frame fest.
          pause 0.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            view frame frame-a.
            view frame fest.
        end.

        run frame-a.
        pause 0.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        pause 0.
        recatu1 = recid(pedid).
   end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.

    find forne where forne.forcod = pedid.clfcod no-lock no-error.
/***
    if vnum[1] <> ""
    then disp vnum[1] no-label
              vnum[2] no-label
              vnum[3] no-label
              with frame f-ped row 20 no-box color white/cyan
                                           side-label overlay centered.
    pause 0.
***/
    display pedid.pednum
            forne.forcod when avail forne
            forne.fornom when avail forne format "x(35)"
            pedid.peddti format "99/99/9999"
            pedid.peddat format "99/99/9999"
            pedid.sitped column-label "Sit"
            pedid.pedsit format "/*" column-label "A"
            with frame frame-a 09 down centered color white/red.

end procedure.


procedure cons-tablog.


    for each tablog where tablog.tabela = "pedid"
                      and tablog.etbcod = pedid.etbcod
                      and tablog.char1  = string(pedid.pedtdc)
                      and tablog.char2  = string(pedid.pednum)
                    no-lock.

        for each tt-pedid-a. delete tt-pedid-a. end.
        for each tt-pedid-d. delete tt-pedid-d. end.

        create tt-pedid-a.
        raw-transfer tablog.antes to tt-pedid-a no-error.
        create tt-pedid-d.
        raw-transfer tablog.depois to tt-pedid-d no-error.

        if avail tt-pedid-a and avail tt-pedid-d
        then do:
        if tt-pedid-a.peddti <> tt-pedid-d.peddti or
           tt-pedid-a.peddtf <> tt-pedid-d.peddtf
        then
            disp
                tablog.data
                string(tablog.hora, "hh:mm:ss")
                tablog.funcod
                tt-pedid-a.peddti column-label "|  Antes!|Prz.De"
                tt-pedid-a.peddtf column-label "!Ate"
                tt-pedid-d.peddti column-label "| Depois!|Prz.De"
                tt-pedid-d.peddtf column-label "!Ate"
                with frame f-log down centered title " Log de Alterações - " +
                            string(pedid.pednum).
        end.
    end.

end procedure.
