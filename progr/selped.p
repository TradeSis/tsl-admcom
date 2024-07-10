/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def var vmarca as char format "x(01)".
def shared temp-table tt-pedid
    field pedrec as recid.
def input parameter vetbcod like estab.etbcod.
def var varquivo    as char.
def var fila        as char.
def var recatu1         as recid.
def var reccont         as int.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 1
            initial ["Seleciona"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bpedid            for pedid.
def buffer bestab            for estab.
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
bl-princ:
repeat:

    vpedtdc = 3.
    find first pedid where pedid.pedtdc = vpedtdc and
                           /**pedid.sitped <> "R" and**/
                           pedid.sitped = "L" and
                           pedid.etbcod = vetbcod no-lock no-error.

    if not avail pedid 
    then return.
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then find first pedid where pedid.pedtdc = vpedtdc and
                                /*pedid.sitped <> "R"    and*/
                                pedid.sitped = "L" and
                                pedid.etbcod = vetbcod no-lock no-error.
    else find pedid where recid(pedid) = recatu1 no-lock no-error.
    if not available pedid
    then do:
        message "Nenhum pedido para esta filial".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.
    
    find first tt-pedid where tt-pedid.pedrec = recid(pedid) no-error.
    if avail tt-pedid
    then vmarca = "*".
    else vmarca = "".
    
    display vmarca no-label 
            pedid.etbcod
            pedid.pednum
            pedid.peddat
            pedid.sitped column-label "Sit"
            with frame frame-a 10 down centered color white/red.

    recatu1 = recid(pedid).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next pedid where pedid.pedtdc = vpedtdc and
                              /*pedid.sitped <> "R"    and*/
                              pedid.sitped = "L" and 
                              pedid.etbcod = vetbcod no-lock no-error.
        if not available pedid
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        
        find first tt-pedid where tt-pedid.pedrec = recid(pedid) no-error.
        if avail tt-pedid
        then vmarca = "*".
        else vmarca = "".
    


        display vmarca
                pedid.etbcod
                pedid.pednum
                pedid.peddat
                pedid.sitped
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find pedid where recid(pedid) = recatu1 no-lock.

        on f7 recall.
        choose field pedid.pednum
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-up page-down  F7 PF7
                  tab PF4 F4 ESC return).

        color display white/red pedid.pednum.

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
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 + 1.
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
            find next pedid where pedid.pedtdc = vpedtdc and
                                  /*pedid.sitped <> "R"    and*/
                                  pedid.sitped = "L" and
                                  pedid.etbcod = vetbcod no-lock no-error.
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
            find prev pedid where pedid.pedtdc = vpedtdc and
                                  /*pedid.sitped <> "R"    and*/
                                  pedid.sitped = "L" and
                                  pedid.etbcod = vetbcod no-lock no-error.
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
                find next pedid where pedid.pedtdc = vpedtdc and
                                      /*pedid.sitped <> "R"    and*/
                                      pedid.sitped = "L" and
                                      pedid.etbcod = vetbcod no-lock no-error.
                if not avail pedid
                then leave.
                recatu1 = recid(pedid).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev pedid where pedid.pedtdc = vpedtdc and
                                      /*pedid.sitped <> "R"    and*/
                                      pedid.sitped = "L" and
                                      pedid.etbcod = vetbcod no-lock no-error.
                if not avail pedid
                then leave.
                recatu1 = recid(pedid).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            hide frame frame-a no-pause.
            hide frame f-com1  no-pause.
            leave bl-princ.
        end.    

        if keyfunction(lastkey) = "return"
        then do:
            hide frame  frame-a no-pause.

            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                    with frame f-com1.

                if esqcom1[esqpos1] = "Seleciona"
                then do:
                    find first tt-pedid where tt-pedid.pedrec = recid(pedid)                                                         no-error.
                    if not avail tt-pedid
                    then do:
                        create tt-pedid.
                        assign tt-pedid.pedrec = recid(pedid).
                    end.
                    else delete tt-pedid.
                end.
        
                if esqcom1[esqpos1] = "Consulta"
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.

                    display pedid.etbcod
                            pedid.pednum with frame f-tit
                                    centered side-label 
                                        color black/cyan row 4.

                    for each liped of pedid no-lock.
                        find produ where produ.procod = liped.procod no-lock.
                        disp liped.procod
                             produ.pronom format "x(25)"
                             liped.lipcor format "x(15)"
                             liped.lipqtd column-label "Qtd.P" format ">>>9"
                             liped.lipent column-label "Qtd.E" format ">>>9"
                             liped.lipsit
                                    with frame f-con 10 down row 7 centered
                                        color black/cyan title " Produtos ".
                    end.
                    pause.
                    leave.
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
        
        find first tt-pedid where tt-pedid.pedrec = recid(pedid) no-error.
        if avail tt-pedid
        then vmarca = "*".
        else vmarca = "".
    
        display vmarca
                pedid.etbcod
                pedid.pednum
                pedid.peddat
                pedid.sitped
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(pedid).
   end.
end. 