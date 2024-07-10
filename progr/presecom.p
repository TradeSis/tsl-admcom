/*
*
*    pedid.p    -    Esqueleto de Programacao    com esqvazio
* Cadastro reserva para o e-commerce - 05/10/2012
*/
{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Cancela "," Consulta "," Finaliza "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" Produtos "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

def buffer bpedid       for pedid.
def var vpedid         like pedid.pednum.
def var par-etbcod     like pedid.etbcod init 200.
def var par-pedtdc     like pedid.pedtdc init 10.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find pedid where recid(pedid) = recatu1 no-lock.
    if not available pedid
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(pedid).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available pedid
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find pedid where recid(pedid) = recatu1 no-lock.
            find first liped of pedid where liped.lipsit = "A"
                              no-lock no-error.
            if avail liped
            then assign
                    esqcom1[2] = " Alteracao "
                    esqcom1[3] = " Exclusao "
                    esqcom1[5] = " Finaliza ".
            else assign
                    esqcom1[2] = ""
                    esqcom1[3] = " Cancela " 
                    esqcom1[5] = "".
            disp esqcom1 with frame f-com1.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(pedid.pednum)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(pedid.pednum)
                                        else "".
            run color-message.
            choose field pedid.pednum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
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
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail pedid
                    then leave.
                    recatu1 = recid(pedid).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail pedid
                    then leave.
                    recatu1 = recid(pedid).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail pedid
                then next.
                color display white/red pedid.pednum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail pedid
                then next.
                color display white/red pedid.pednum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form 
                pedid.pednum
                pedid.peddti label "Inicial" format "99/99/9999"
                            validate(pedid.peddti >= today,"")
                pedid.peddtf label "Final"   format "99/99/9999"
                             validate(pedid.peddtf >= pedid.peddti and
                                      pedid.peddtf <= pedid.peddti + 31
                        ,"O Tempo máximo permitido para uma reserva é 30 dias")
                pedid.pedobs
                 with frame f-pedid color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-pedid on error undo.
                    find last bpedid where bpedid.pedtdc = par-pedtdc
                                     no-lock use-index ped no-error.
                    create pedid.
                    assign
                        pedid.pednum = if avail bpedid then bpedid.pednum + 1
                                       else 1
                        pedid.pedtdc = par-pedtdc
                        pedid.etbcod = par-etbcod
                        pedid.peddat = today
                        pedid.vencod = sfuncod.
                    disp pedid.pednum.
                    update pedid.peddti.
                    update pedid.peddtf.
                    update pedid.pedobs.
                    recatu1 = recid(pedid).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao " or
                   esqcom1[esqpos1] = " Finaliza "
                then do with frame f-pedid.
                    disp
                        pedid.pednum
                        pedid.peddat
                        pedid.peddti
                        pedid.peddtf
                        pedid.vencod.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-pedid on error undo.
                    find pedid where recid(pedid) = recatu1 exclusive.
                    update pedid.pedobs.
                end.

                if esqcom1[esqpos1] = " Exclusao "
                then do.
                    sresp = no.
                    message "EXCLUIR pedido" pedid.pednum "?" update sresp.
                    if sresp
                    then do ON ERROR UNDO.
                        find current pedid exclusive.
                        for each liped of pedid.
                            delete liped.
                        end.
                        delete pedid.
                        recatu1 = ?.
                    end.
                    leave.
                end.

                if esqcom1[esqpos1] = " Cancela "
                then do on error undo.
                    message "Confirma Cancelamento de" pedid.pednum "?"
                            update sresp.
                    if not sresp
                    then undo, leave.
                    recatu2 = if available pedid
                              then recid(pedid)
                              else ?.
                    find pedid where recid(pedid) = recatu1 exclusive.
                    for each liped of pedid.
                        liped.lipsit = "C".
                    end.
                    pedid.sitped = "C".
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Finaliza "
                then do:
                    sresp = no.
                    message "Finalizar pedido" pedid.pednum "?" update sresp.
                    if sresp
                    then do.
                        find current pedid exclusive.
                        for each liped of pedid.
                            liped.lipsit = "P".
                        end.
                        pedid.sitped = "P".
                        message "Finalizado" view-as alert-box.
                    end.
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " Produtos "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run pedresecomlin.p (recid(pedid)).
                    view frame f-com1.
                    view frame f-com2.
                end.
                
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(pedid).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    display
        pedid.pednum column-label "Reserva"
        pedid.peddat column-label "Dt.Incl"
        pedid.vencod column-label "Func"
        pedid.peddti column-label "Inicial" format "99/99/9999"
        pedid.peddtf column-label "Final"   format "99/99/9999"
        pedid.sitped column-label "Sit"
        pedid.pedobs[1] format "x(20)"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
color display message
        pedid.pednum
        pedid.peddat
        pedid.vencod
        pedid.peddti
        pedid.peddtf
        pedid.sitped
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        pedid.pednum
        pedid.peddat
        pedid.vencod
        pedid.peddti
        pedid.peddtf
        pedid.sitped
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first pedid where pedid.pedtdc = par-pedtdc
                           and pedid.peddtf >= today no-lock no-error.
    else  
        find last pedid  where pedid.pedtdc = par-pedtdc
                           and pedid.peddtf >= today no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next pedid  where pedid.pedtdc = par-pedtdc
                           and pedid.peddtf >= today no-lock no-error.
    else  
        find prev pedid  where pedid.pedtdc = par-pedtdc
                           and pedid.peddtf >= today no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev pedid where pedid.pedtdc = par-pedtdc
                          and pedid.peddtf >= today no-lock no-error.
    else   
        find next pedid where pedid.pedtdc = par-pedtdc
                          and pedid.peddtf >= today no-lock no-error.
        
end procedure.
         
