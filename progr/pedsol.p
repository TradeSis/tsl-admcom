{admcab.i}
def var vpedtot like plani.platot.
def var vrepcod like repre.repcod.
def buffer bliped for liped.
def buffer cpedid for pedid.
def var varquivo as char.
def var recatu1         as recid.
def var reccont         as int.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Impressao"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Gera Compra","","","",""].

def var par-pedtdc as char initial 4.

def buffer bpedid            for pedid.
def var vetbcod              like estab.etbcod.
def var vpednum              like pedid.pednum.
def var vpedtdc              like pedid.pedtdc.
def var vrecped              as recid.

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

update vetbcod
    with frame fest centered color white/cyan side-labels no-box width 66 row 6.
find estab where estab.etbcod = vetbcod no-lock.
disp estab.etbnom no-label with frame fest.

bl-princ:
repeat:
    vpedtdc = integer(par-pedtdc).
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then find last pedid  where pedid.etbcod = estab.etbcod and
                                pedid.pedtdc = vpedtdc NO-LOCK no-error.
    else find pedid where recid(pedid) = recatu1 NO-LOCK.
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
               run pedsoli.p ( input estab.etbcod,
                               input  vpedtdc,
                               output vrecped).
        end.
    end.
    clear frame frame-a all no-pause.
    display pedid.pednum  format ">>>>>>>>9"
            estab.etbcod
            pedid.peddat
            pedid.sitped column-label "Sit"
            pedid.comcod column-label "Ordem Compra" format ">>>>>>>9"
            with frame frame-a 10 down centered color white/red.

    recatu1 = recid(pedid).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find prev pedid  where pedid.etbcod = estab.etbcod and
                               pedid.pedtdc = vpedtdc NO-LOCK no-error.
        if not available pedid
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        display pedid.pednum
                estab.etbcod
                pedid.peddat
                pedid.sitped
                pedid.comcod
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find pedid where recid(pedid) = recatu1 NO-LOCK.

        on f7 recall.
        choose field pedid.pednum
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-up page-down F7 PF7
                  tab PF4 F4 ESC return).

        color display white/red pedid.pednum.

        if keyfunction(lastkey) = "RECALL"
        then do WITH FRAME fproc centered row 7 color message overlay.
        pause 0.
            prompt-for pedid.pednum.
            find last bpedid where bpedid.etbcod = estab.etbcod and
                                   bpedid.pedtdc = vpedtdc and
                                   bpedid.pednum = input pedid.pednum
                            NO-LOCK no-error.
            if avail bpedid
            then recatu1 = recid(bpedid).
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
                esqpos1 = if esqpos1 = 5
                          then 5
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
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find prev pedid where pedid.etbcod = estab.etbcod and
                                  pedid.pedtdc = vpedtdc NO-LOCK no-error.
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
                                   pedid.pedtdc = vpedtdc NO-LOCK no-error.
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
                                      pedid.pedtdc = vpedtdc NO-LOCK no-error.
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
                                      pedid.pedtdc = vpedtdc NO-LOCK no-error.
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
                run pedsoli.p ( input estab.etbcod,
                                input vpedtdc,
                                output vrecped).
                recatu1 = vrecped.
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                run pedsola.p ( input recid(pedid),
                                output vrecped ).
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do:
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                for each liped of pedid where liped.predt = pedid.peddat
                                no-lock.
                    find produ where produ.procod = liped.procod no-lock.
                    disp liped.procod
                         produ.pronom format "x(30)"
                         liped.lipcor
                         liped.lipqtd column-label "Qtd.Ped" format ">>>9"
                         liped.lipent column-label "Qtd.Ent" format ">>>9"
                                with frame f-con 10 down row 7 centered
                                        color black/cyan title " Produtos ".
                end.
                pause.
                leave.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do transaction
                with frame f-exclui overlay row 9 1 column centered.
                if pedid.sitped = "F"
                then do:
                    message "Pedido ja Entregue nao pode ser Excluido".
                    pause. leave.
                end.
                else do:
                    message "Confirma Exclusao de" pedid.pednum update sresp.
                    if not sresp
                    then undo.
                    find prev pedid where pedid.etbcod = estab.etbcod and
                                          pedid.pedtdc = vpedtdc
                                    NO-LOCK no-error.
                    if not available pedid
                    then do:
                        find pedid where recid(pedid) = recatu1 NO-LOCK.
                        find prev pedid where pedid.etbcod = estab.etbcod and
                                              pedid.pedtdc = vpedtdc
                                         NO-LOCK no-error.
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
            then do with frame f-Lista.
                if opsys = "UNIX"
                then varquivo = "../relat/pedsol" + string(time).
                else varquivo = "..\relat\pedsol" + string(time).
        
                {mdad.i 
                    &Saida     = "value(varquivo)"
                    &Page-Size = "63"
                    &Cond-Var  = "120" 
                    &Page-Line = "66" 
                    &Nom-Rel   = ""pedsol"" 
                    &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO""" 
                    &Tit-Rel   = """REQUISICAO DE MERCADORIA VENDA"""
                    &Width     = "120"
                    &Form      = "frame f-cabcab"}

                put skip(5)
                    "        DREBES & CIA LTDA         " at 40 skip(2).
                put "  REQUISI€AO DE MERCADORIA VENDA  " at 40 skip(2).
                find first liped where liped.pedtdc = pedid.pedtdc and
                                       liped.etbcod = pedid.etbcod and
                                       liped.pednum = pedid.pednum .
                find produ of liped no-lock.
                find fabri where fabri.fabcod = produ.fabcod no-lock.
                put fabri.fabfant at 40 skip(2).
                do transaction:
                    find current pedid exclusive.
                    pedid.sitped = "L".
                end.
                for each liped where liped.pedtdc = pedid.pedtdc and
                                     liped.etbcod = pedid.etbcod and
                                     liped.pednum = pedid.pednum and
                                     liped.predt  = pedid.peddat.
                    do transaction:
                        liped.lipsit = "L".                 
                    end.
                    find estoq where estoq.etbcod = pedid.etbcod and
                                     estoq.procod = liped.procod no-lock.
                    find produ of liped no-lock.
                    disp produ.procod at 10
                         produ.pronom
                         liped.lipcor column-label "Cor"
                         liped.lipqtd column-label "QTD"
                         estoq.estvenda column-label "Preco"
                                 with frame f-rom width 200 down.
                end.

                find func where func.etbcod = pedid.etbcod and
                                func.funcod = pedid.vencod no-lock no-error.
                put skip(7)
                "PEDIDO: " at 10 pedid.pednum 
                "    ORDEM DE COMPRA: " pedid.comcod format ">>>>>>>9" SKIP(1)
                "NF: " at 10 pedid.frecod
                "         DATA VENDA: " pedid.condat format "99/99/9999"
                                SKIP(1).
                if pedid.vencod <> 0 and avail func
                then put "NOME: " at 10 func.funnom skip(1).
                else put "NOME:............... " at 10 skip(1).
                put "DATA: " at 10 today format "99/99/9999"
                    " FILIAL: " at 40
                estab.etbnom skip(1).
                output close.                

                if opsys = "UNIX"
                then do:
                    run visurel.p(varquivo,"").
                end.
                else do:
                    {mrod.i}
                end.
                
                leave.
            end.
          end.
          else do:
            if esqcom2[esqpos2] = "Gera Compra"
            then do:
                message "Confirma Pedido de Compra" update sresp.
                if not sresp
                then undo, leave.
                do transaction: 
                    vpedtot = 0.
                    find current pedid.
                    for each liped of pedid where liped.predt = pedid.peddat 
                                no-lock.
                        find produ where produ.procod = liped.procod no-lock.
                        find forne where forne.forcod = produ.fabcod no-lock.
                        find repre where repre.repcod = forne.repcod no-lock 
                                no-error. 
                        if avail repre 
                        then vrepcod = repre.repcod.
                        else vrepcod = 0.
                        vpedtot = vpedtot + (liped.lippre * liped.lipqtd).
                    end.
                    find last cpedid use-index ped
                                 where cpedid.etbcod = 999 and
                                       cpedid.pedtdc = 1 no-error.
                    if avail cpedid
                    then vpednum = cpedid.pednum + 1.
                    else vpednum = 1.
                    pedid.comcod = vpednum.
                    
                    create bpedid.
                    assign bpedid.pedtdc    = 1
                           bpedid.pednum    = vpednum
                           bpedid.clfcod    = forne.forcod
                           bpedid.regcod    = 999
                           bpedid.peddat    = today 
                           bpedid.pedsit    = yes 
                           bpedid.sitped    = "A" 
                           bpedid.etbcod    = 999 
                           bpedid.condat   = today
                           bpedid.peddti   = today + 10
                           bpedid.peddtf   = today + 15
                           bpedid.crecod   = 60
                           bpedid.comcod   = 6
                           bpedid.fobcif   = no
                           bpedid.modcod   = "PED" 
                           bpedid.vencod   = vrepcod
                           bpedid.pedtot   = vpedtot
                           bpedid.pedobs[1] = ""
                           bpedid.pedobs[2] = ""
                           bpedid.pedobs[3] = ""
                           bpedid.pedobs[4] = ""
                           bpedid.pedobs[5] = ""
                           bpedid.pedobs[1] = "Pedido: " + 
                                        string(pedid.pednum) 
                                        +  " Filial: " + 
                                        string(pedid.etbcod,">>9").
                    for each liped of pedid where liped.predt = pedid.peddat 
                            no-lock.
 
                        find bliped where bliped.etbcod = 999           and
                                          bliped.pedtdc = 1            and
                                          bliped.pednum = vpednum      and
                                          bliped.procod = liped.procod and
                                          bliped.lipcor = ""           and
                                          bliped.predt  = today no-error.
                        if not avail bliped
                        then do:
                            create bliped.
                            assign bliped.pednum = vpednum
                                   bliped.pedtdc = 1
                                   bliped.predt  = today
                                   bliped.predtf = bpedid.peddtf 
                                   bliped.etbcod = 999
                                   bliped.procod = liped.procod 
                                   bliped.lippreco = liped.lippre 
                                   bliped.lipqtd = liped.lipqtd 
                                   bliped.lipsit = "A" 
                                   bliped.protip = "M".
                            find estoq where estoq.etbcod = pedid.etbcod and
                                             estoq.procod = liped.procod
                                                    no-lock no-error.
                            if avail estoq
                            then bliped.lippreco = estoq.estcusto.
                                                    
                        
                        end.
                                 
                    end.
                end.
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
        display pedid.pednum
                estab.etbcod
                pedid.peddat
                pedid.sitped
                pedid.comcod 
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(pedid).
   end.
end.
