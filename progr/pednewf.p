
{admcab.i}

def buffer bforne for forne.
def var vfuncod like func.funcod.
def var i as int.
def var vsenha like func.senha.
def var vok as log format "E/F".
def var vpreco like liped.lippreco.
def var vsemipi like liped.lippreco.
def var totger like pedid.pedtot.
def var totpen like pedid.pedtot.
def var vnum as char format "x(79)" extent 3.
def var vforcod         like forne.forcod.
def var vcomcod         like compr.comcod.
def buffer bfunc        for func.
def var recatu1         as recid.
def var reccont         as int.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
initial ["","","","","",""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].

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
                 row 4 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2 centered
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

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
    end.    
    disp forne.fornom no-label with frame fest.

    
    /*
    update vcomcod label "Comprador" with frame fest.
    if vcomcod = 0
    then disp "TODOS" @ compr.comnom no-label with frame fest.
    else do:
        find compr where compr.comcod = vcomcod no-lock.
        display compr.comnom no-label with frame fest.
    end.
    */

    def var vdti as date.
    def var vdtf as date.
    update vdti at 6 label "Periodo de"
           vdtf label "Ate"
           with frame fest.
def temp-table tt-liped like liped.           
vpedtdc = 1.
for each pedid where pedid.etbcod = estab.etbcod and
                              pedid.pedtdc = vpedtdc and
                              (if vforcod = 0
                               then true
                               else pedid.clfcod = vforcod) and
                              (if vcomcod = 0
                               then true
                               else pedid.comcod = vcomcod) AND
                               pedid.peddti >= vdti and
                               pedid.peddti <= vdtf 
                               no-lock.
    if pedid.sitped = "F"
    then next.
    for each liped where 
             liped.etbcod = pedid.etbcod and
             liped.pedtdc = pedid.pedtdc and
             liped.pednum = pedid.pednum
             no-lock:
        if liped.lipsit = "F"
        then next.
        create tt-liped.
        buffer-copy liped to tt-liped.
    end.
end.                               
form with frame frame-a.
             
bl-princ:
repeat:

    disp esqcom1 with frame f-com1.


    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find last tt-liped.
    else
        find tt-liped where recid(tt-liped) = recatu1 no-lock no-error.
    
    if not available tt-liped
    then do:
    end.
    clear frame frame-a all no-pause.
    /*
    find forne where forne.forcod = pedid.clfcod no-lock no-error.
    if vnum[1] <> ""
    then disp vnum[1] no-label
              vnum[2] no-label
              vnum[3] no-label
              with frame f-ped row 20 no-box color white/cyan
                                           side-label overlay centered.
    */
    hide frame f-senha no-pause.
    find produ where produ.procod = tt-liped.procod no-lock.
    display tt-liped.pednum
            tt-liped.predt  format "99/99/99"
            tt-liped.predtf format "99/99/99"
            tt-liped.lipsit column-label "Sit"
            tt-liped.procod
            produ.pronom format "x(25)"
            tt-liped.lipqtd
            /*tt-liped.lipent*/
            with frame frame-a 09 down centered color white/red
            width 80.

    recatu1 = recid(tt-liped).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        hide frame f-senha no-pause.

        find prev tt-liped.

        if not available tt-liped
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.

        hide frame f-senha no-pause.
        find produ where produ.procod = tt-liped.procod no-lock.
        display tt-liped.pednum
            tt-liped.predt  
            tt-liped.predtf 
            tt-liped.lipsit 
            tt-liped.procod
            produ.pronom 
            tt-liped.lipqtd
            /*tt-liped.lipent*/
            with frame frame-a .

    end.
    up frame-line(frame-a) - 1 with frame frame-a.

   repeat with frame frame-a:

        hide frame f-senha no-pause.
        find tt-liped where recid(tt-liped) = recatu1 no-lock no-error.

        on f7 recall.
        choose field tt-liped.pednum
            go-on(cursor-down cursor-up
                  cursor-left cursor-right S s
                  page-up page-down  F7 PF7
                  tab PF4 F4 ESC return).

        color display white/red tt-liped.pednum.
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
        /*
        if keyfunction(lastkey) = "S" or
           keyfunction(lastkey) = "s"
        then do:
            find pedid where recid(pedid) = recatu1 exclusive-lock no-error.
            update pedid.sitped with frame frame-a no-validate.
            find pedid where recid(pedid) = recatu1 no-lock.
            leave.
        end.*/
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find prev tt-liped.
            if not avail tt-liped
            then next.

            color display white/red tt-liped.pednum.
                
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find next tt-liped.
            if not avail tt-liped
            then next.
            color display white/red
                tt-liped.pednum.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-liped.
                if not avail tt-liped
                then leave.
                recatu1 = recid(tt-liped).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-liped.
                if not avail tt-liped
                then leave.
                recatu1 = recid(tt-liped).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
          hide frame f-senha no-pause.
          hide frame  frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.
            /**
            if esqcom1[esqpos1] = "Consulta"
            then do:
                hide frame f-senha no-pause.

                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
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
                display pedid.pedobs[1]
                        pedid.pedobs[2]
                        pedid.pedobs[3]
                        pedid.pedobs[4]
                        pedid.pedobs[5]
                    with frame fobs color white/cyan overlay row 9
                                        no-labels centered title "Observacoes".
                totpen = 0.
                totger = 0.
                for each liped of pedid no-lock,
                    each produ where produ.procod = liped.procod
                            no-lock by produ.pronom.
                    
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
                                with frame f-con 10 down row 7
                                        color black/cyan title " Produtos "
                                        width 80.
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
                hide frame f-senha no-pause.

                hide frame f-tot no-pause.
                hide frame f-dialogo no-pause.
                hide frame fobs no-pause.
                leave.
            end. */
          end.
          else do:
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
        find produ where produ.procod = tt-liped.procod no-lock.
        display tt-liped.pednum
            tt-liped.predt  
            tt-liped.predtf 
            tt-liped.lipsit 
            tt-liped.procod
            produ.pronom 
            tt-liped.lipqtd
            /*tt-liped.lipent*/
            with frame frame-a .

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-liped).
   end.
end.
/**********
bl-princ:
repeat:

    vpedtdc = 1 /*integer(par-pedtdc)*/ .
    disp esqcom1 with frame f-com1.


    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find last pedid where pedid.etbcod = estab.etbcod and
                              pedid.pedtdc = vpedtdc and
                              (if vforcod = 0
                               then true
                               else pedid.clfcod = vforcod) and
                              (if vcomcod = 0
                               then true
                               else pedid.comcod = vcomcod) AND
                               pedid.peddti >= vdti and
                               pedid.peddti <= vdtf 
                               no-lock no-error.
    else
        find pedid where recid(pedid) = recatu1 no-lock no-error.
    
    if not available pedid
    then do:
    end.
    clear frame frame-a all no-pause.
    find forne where forne.forcod = pedid.clfcod no-lock no-error.
    if vnum[1] <> ""
    then disp vnum[1] no-label
              vnum[2] no-label
              vnum[3] no-label
              with frame f-ped row 20 no-box color white/cyan
                                           side-label overlay centered.
    hide frame f-senha no-pause.
    display pedid.pednum
            forne.forcod when avail forne
            forne.fornom when avail forne format "x(35)"
            pedid.peddti format "99/99/9999"
            pedid.peddat format "99/99/9999"
            pedid.sitped column-label "Sit"
            with frame frame-a 09 down centered color white/red.

    recatu1 = recid(pedid).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        hide frame f-senha no-pause.

        find prev pedid where pedid.etbcod = estab.etbcod and
                              pedid.pedtdc = vpedtdc and
                              (if vforcod = 0
                               then true
                               else pedid.clfcod = vforcod) and
                              (if vcomcod = 0
                               then true
                               else pedid.comcod = vcomcod) and
                               pedid.peddti >= vdti and
                               pedid.peddti <= vdtf  
                               no-lock no-error.

        if not available pedid
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.

        find forne where forne.forcod = pedid.clfcod no-lock no-error.
        hide frame f-senha no-pause.

        display pedid.pednum
                forne.forcod when avail forne
                forne.fornom when avail forne format "x(35)"
                pedid.peddti format "99/99/9999"
                pedid.peddat format "99/99/9999"
                pedid.sitped
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        hide frame f-senha no-pause.
        find pedid where recid(pedid) = recatu1 no-lock no-error.

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
                                  pedid.pednum = input pedid.pednum and
                                 (if vforcod = 0
                                  then true
                                  else pedid.clfcod = vforcod) and
                                 (if vcomcod = 0
                                  then true
                                  else pedid.comcod = vcomcod) and
                                  pedid.peddti >= vdti and
                                  pedid.peddti <= vdtf 
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
            find pedid where recid(pedid) = recatu1 exclusive-lock no-error.
            update pedid.sitped with frame frame-a no-validate.
            find pedid where recid(pedid) = recatu1 no-lock.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find prev pedid where  pedid.etbcod = estab.etbcod
                              and  pedid.pedtdc = vpedtdc
                              and (if vforcod = 0 
                                   then true 
                                   else pedid.clfcod = vforcod)
                              and (if vcomcod = 0 
                                   then true 
                                   else pedid.comcod = vcomcod)
                              and  pedid.peddti >= vdti 
                              and  pedid.peddti <= vdtf    
                              no-lock no-error.
            if not avail pedid
            then next.

            color display white/red pedid.pednum.
                
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find next pedid where pedid.etbcod = estab.etbcod and
                              pedid.pedtdc = vpedtdc and
                              (if vforcod = 0
                               then true
                               else pedid.clfcod = vforcod) and
                              (if vcomcod = 0
                               then true
                               else pedid.comcod = vcomcod) and
                               pedid.peddti >= vdti and
                               pedid.peddti <= vdtf 
                               no-lock no-error.
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
                              pedid.pedtdc = vpedtdc and
                              (if vforcod = 0
                               then true
                               else pedid.clfcod = vforcod) and
                              (if vcomcod = 0
                               then true
                               else pedid.comcod = vcomcod) and
                               pedid.peddti >= vdti and
                               pedid.peddti <= vdtf 
                               no-lock no-error.
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
                              pedid.pedtdc = vpedtdc and
                              (if vforcod = 0
                               then true
                               else pedid.clfcod = vforcod) and
                              (if vcomcod = 0
                               then true
                               else pedid.comcod = vcomcod) and
                               pedid.peddti >= vdti and
                               pedid.peddti <= vdtf 
                               no-lock no-error.
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
          hide frame f-senha no-pause.
          hide frame  frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Consulta"
            then do:
                hide frame f-senha no-pause.

                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
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
                display pedid.pedobs[1]
                        pedid.pedobs[2]
                        pedid.pedobs[3]
                        pedid.pedobs[4]
                        pedid.pedobs[5]
                    with frame fobs color white/cyan overlay row 9
                                        no-labels centered title "Observacoes".
                totpen = 0.
                totger = 0.
                for each liped of pedid no-lock,
                    each produ where produ.procod = liped.procod
                            no-lock by produ.pronom.
                    
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
                                with frame f-con 10 down row 7
                                        color black/cyan title " Produtos "
                                        width 80.
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
                hide frame f-senha no-pause.

                hide frame f-tot no-pause.
                hide frame f-dialogo no-pause.
                hide frame fobs no-pause.
                leave.
            end.
          end.
          else do:
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
                pedid.peddat format "99/99/9999"
                pedid.sitped
                    with frame frame-a overlay.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(pedid).
   end.
end.

***********/
