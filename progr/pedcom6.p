/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def var totger like pedid.pedtot.
def var totpen like pedid.pedtot.
def var vnum as char format "x(79)" extent 3.
def var vforcod         like forne.forcod.
def buffer bfunc        for func.
def var recatu1         as recid.
def var reccont         as int.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
initial ["Inclusao","Impressao","Alteracao","Exclusao","Consulta","Procura"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].

/*def input parameter par-pedtdc as char.*/

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
         pedid.condat    colon 18
         pedid.peddti    colon 18 label "Prazo de Entrega" format "99/99/9999"
         pedid.peddtf    label "A"                         format "99/99/9999"
         pedid.crecod    colon 18 label "Prazo de Pagto"
         crepl.crenom    no-label
         pedid.comcod    colon 18 label "Comprador"
         func.funnom                 no-label
         pedid.frecod    label "Transport." colon 18
         pedid.fobcif
         pedid.nfdes        colon 18 label "Desc.Nota"
         pedid.dupdes       label "Desc.Duplicata"
         pedid.acrfin       label "Acres. Financ."
          with frame f-dialogo color white/cyan overlay row 6
                                                     side-labels centered.
    form
        pedid.pedobs[1] at 1
        pedid.pedobs[2] at 1
        pedid.pedobs[3] at 1
        pedid.pedobs[4] at 1
        pedid.pedobs[5] at 1 with frame fobs color white/cyan overlay row 9
                                no-labels centered title "Observacoes".
    form
        esqcom1
            with frame f-com1 centered
                 row 4 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2 centered
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
    /*
    if setbcod = 990
    then do:
        bell.
        message "Voce esta na matriz, operacao invalida". pause.
        undo, leave.
    end.
    */

    vetbcod = 22.
    update vetbcod
    with frame fest centered color white/cyan side-labels no-box width 66 row 5.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame fest.
bl-princ:
repeat:

    vpedtdc = 6 /*integer(par-pedtdc)*/ .
    disp esqcom1 with frame f-com1.


    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find last pedid  where pedid.etbcod = estab.etbcod and
                               pedid.pedtdc = vpedtdc no-error.
    else
        find pedid where recid(pedid) = recatu1.
    if not available pedid
    then do:
        message "Cadastro de pedidos Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 9 1 column centered
            color black/cyan.
               hide frame f-com1 no-pause.
               hide frame f-com2 no-pause.
               run pedin06.p ( input estab.etbcod,
                                output vrecped ).
        end.
    end.
    clear frame frame-a all no-pause.
    find forne where forne.forcod = pedid.clfcod no-lock no-error.
    if vnum[1] <> ""
    then disp vnum[1] no-label
              vnum[2] no-label
              vnum[3] no-label
              with frame f-ped row 20 no-box color white/cyan
                                           side-label overlay centered.

    display pedid.pednum
            forne.forcod when avail forne
            forne.fornom when avail forne format "x(35)"
            pedid.peddti format "99/99/9999"
            pedid.sitped column-label "Sit"
            with frame frame-a 10 down centered color white/red.

    recatu1 = recid(pedid).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find prev pedid  where pedid.etbcod = estab.etbcod and
                               pedid.pedtdc = vpedtdc.
        if not available pedid
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.

        find forne where forne.forcod = pedid.clfcod no-lock no-error.
        display pedid.pednum
                forne.forcod when avail forne
                forne.fornom when avail forne format "x(35)"
                pedid.peddti format "99/99/9999"
                pedid.sitped
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find pedid where recid(pedid) = recatu1 no-lock.

        on f7 recall.
        choose field pedid.pednum
            go-on(cursor-down cursor-up
                  cursor-left cursor-right S s
                  page-up page-down  F7 PF7
                  tab PF4 F4 ESC return).

        color display white/red pedid.pednum.

        if keyfunction(lastkey) = "RECALL"
        then do WITH FRAME fproc centered row 7 color message overlay.
        pause 0.
            prompt-for pedid.pednum.
            find last pedid where pedid.etbcod = estab.etbcod and
                                  pedid.pedtdc = vpedtdc and
                                  pedid.pednum = input pedid.pednum
                                                            no-lock no-error.
            if avail pedid
            then recatu1 = recid(pedid).
            leave.
        end.
        on f7 help.
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 6
                          then 6
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "S" or
           keyfunction(lastkey) = "s"
        then do:
            find pedid where recid(pedid) = recatu1.
            update pedid.sitped with frame frame-a no-validate.
            find pedid where recid(pedid) = recatu1 no-lock.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find prev pedid where pedid.etbcod = estab.etbcod and
                                  pedid.pedtdc = vpedtdc no-lock no-error.
            if not avail pedid
            then next.
            color display white/red
                pedid.pednum.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find next pedid  where pedid.etbcod = estab.etbcod and
                                   pedid.pedtdc = vpedtdc no-lock no-error.
            if not avail pedid
            then next.
            color display white/red
                pedid.pednum.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev pedid where pedid.etbcod = estab.etbcod and
                                      pedid.pedtdc = vpedtdc no-lock no-error.
                if not avail pedid
                then leave.
                recatu1 = recid(pedid).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next pedid where pedid.etbcod = estab.etbcod and
                                      pedid.pedtdc = vpedtdc no-lock no-error.
                if not avail pedid
                then leave.
                recatu1 = recid(pedid).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame  frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 9 1 column centered
                color black/cyan.
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.

                run pedin06.p ( input estab.etbcod,
                              output vrecped ).
                recatu1 = vrecped.

                /*
                recatu1 = recid(pedid).
                */
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run pedcomal.p ( input recid(pedid),
                                 output vrecped ).
                leave.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                find forne where forne.forcod = pedid.clfcod no-lock.
                find crepl where crepl.crecod = pedid.crecod no-lock.
                find bestab where bestab.etbcod = pedid.regcod no-lock.
                find func where func.etbcod = 990 and
                                func.funcod = pedid.comcod no-lock.
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
                     pedid.condat
                     pedid.peddti format "99/99/9999"
                     pedid.peddtf format "99/99/9999"
                     pedid.crecod
                     crepl.crenom
                     pedid.comcod
                     func.funnom
                     pedid.frecod
                     pedid.fobcif
                     pedid.nfdes
                     pedid.dupdes
                     pedid.acrfin
                        with frame f-dialogo color white/cyan overlay row 6
                                                        side-labels centered.
                display pedid.pedobs[1]
                        pedid.pedobs[2]
                        pedid.pedobs[3]
                        pedid.pedobs[4]
                        pedid.pedobs[5]
                    with frame fobs color white/cyan overlay row 9
                                        no-labels centered title "Observacoes".
                totpen = 0.
                totger = 0.
                for each liped of pedid NO-LOCK,
                    each produ where produ.procod = liped.procod
                            no-lock by produ.pronom.
                    disp liped.procod
                         produ.pronom format "x(44)" when avail produ
                         liped.lippreco format ">,>>9.99"
                         liped.lipqtd column-label "Qtd.Ped" format ">>>9"
                         liped.lipent column-label "Qtd.Ent" format ">>>9"
                                with frame f-con 10 down row 7
                                        color black/cyan title " Produtos "
                                        width 80.
                    totpen = totpen + ((liped.lipqtd - liped.lipent) *
                                        liped.lippreco).
                    totger = totger + (liped.lipqtd * liped.lippreco).
                end.
                display totger
                        totpen label "Total Pendente" format "->>>,>>9.99"
                        with frame f-tot  row 21 side-label centered
                                            color black/cyan no-box.

                pause.
                hide frame f-tot no-pause.
                hide frame f-dialogo no-pause.
                hide frame fobs no-pause.
                leave.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 9 1 column centered.
                if pedid.sitped = "F"
                then do:
                    message "Pedido ja Entregue nao pode ser Excluido".
                    pause. leave.
                end.
                else do on error undo:
                    message "Confirma Exclusao de" pedid.pednum update sresp.
                    if not sresp
                    then undo.
                    find prev pedid where pedid.etbcod = estab.etbcod and
                                          pedid.pedtdc = vpedtdc
                                          NO-LOCK no-error.
                    if not available pedid
                    then do:
                        find pedid where recid(pedid) = recatu1 NO-LOCK.
                        find next pedid where true NO-LOCK no-error.
                    end.
                    recatu2 = if available pedid
                            then recid(pedid)
                            else ?.
                    find pedid where recid(pedid) = recatu1.
                    for each liped of pedid.
                        delete liped.
                    end.
                    delete pedid.
                    recatu1 = recatu2.
                    leave.
                end.
            end.
            if esqcom1[esqpos1] = "Impressao"
            then do with frame f-Lista overlay row 9 1 column centered.
                message "Confirma Impressao do Pedido" update sresp.
                if not sresp
                then undo.
                run lpedid6.p (input recid(pedid)).
                leave.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do WITH FRAME fproc1 centered row 7 color message overlay.
                vnum[1] = "".
                vnum[2] = "".
                vnum[3] = "".

                update vforcod.
                find last pedid where pedid.etbcod = estab.etbcod and
                                      pedid.pedtdc = vpedtdc and
                                      pedid.clfcod = vforcod
                                                            no-lock no-error.
                if avail pedid
                then do:
                    recatu1 = recid(pedid).
                    for each pedid where pedid.etbcod = estab.etbcod and
                                         pedid.pedtdc = vpedtdc and
                                         pedid.clfcod = vforcod
                                         no-lock by pedid.pednum desc.
                        vnum[1] = string(vnum[1]) + ", " + string(pedid.pednum).
                        if length(vnum[1]) >= 80
                        then
                        vnum[2] = string(vnum[2]) + ", " + string(pedid.pednum).
                        if length(vnum[2]) >= 80
                        then
                        vnum[3] = string(vnum[3]) + ", " + string(pedid.pednum).
                    end.
                end.
                pause 0.
                leave.
            end.
          end.
          else do:
            if esqcom2[esqpos2] = "Extrato"
            then do:
                message "Confirma Impressao do Extrato" update sresp.
                if not sresp
                then undo.
                run lextped5.p (input recid(pedid)).
                leave.
            end.
            if  esqcom2[esqpos2] = "Duplicacao"
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run peddup.p (input recatu1).
                disp esqcom1 with frame f-com1.
            end.
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
          end.
          view frame frame-a.
          view frame fest.
        end.
          if keyfunction(lastkey) = "end-error"
          then do:
            view frame frame-a.
            view frame fest.
        end.
        find forne where forne.forcod = pedid.clfcod no-lock no-error.
        view frame f-ped.
        display pedid.pednum
                forne.forcod when avail forne
                forne.fornom when avail forne
                pedid.peddti format "99/99/9999"
                pedid.sitped
                    with frame frame-a overlay.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(pedid).
   end.
end.
