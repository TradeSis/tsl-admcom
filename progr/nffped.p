/*
*
*    Filtra pedido
*
*/
{admcab.i}

def input  parameter vrec       as recid.
def input  parameter par-catcod like pedid.catcod.

def shared workfile  wfped
    field rec       as rec.

def var vpednum         like pedid.pednum initial 0.
def var vast            as log.
def buffer item-produ for produ.

find forne where recid(forne) = vrec no-lock.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(20)" extent 3
            initial ["Seleciona Pedido","Consulta Linhas","Procura"].

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.
pause 0.
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find pedid where recid(pedid) = recatu1 no-lock.
    if not available pedid
    then do.
        message "Nenhum Pedido" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(pedid).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available pedid
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find pedid where recid(pedid) = recatu1 no-lock.

            status default "".
            view frame frame-a.
            run color-message.
            choose field pedid.pednum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            run color-normal.
            status default "".

            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 3 then 3 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
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

        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                    with frame f-com1.

            if esqcom1[esqpos1] = "Seleciona Pedido"
            then do:
                find first wfped where wfped.rec = recid(pedid) no-error.
                if available wfped
                then delete wfped.
                else do:
                    create wfped.
                    wfped.rec = recid(pedid).
                    if par-catcod = 41
                    then leave bl-princ.
                end.
            end.
            if esqcom1[esqpos1] = "Procura" 
            then do:            
                update vpednum label "Pedido"
                       with frame f-proc centered side-labels.
                recatu2 = recatu1.
                /*
                run leitura (input "pri").
                */

                find first  pedid  where
                            pedid.pedtdc = 1 and
                            pedid.pedsit and
                            pedid.clfcod = forne.forcod and
                            pedid.sitped <> "F" and
                            pedid.peddti >= today - 120 and
                            pedid.catcod = par-catcod  and
                            pedid.pednum = vpednum no-lock no-error.
                                      
                if avail pedid
                then recatu1 = recid(pedid).
                else recatu1 = recatu2.
                leave.
            end.            
            if esqcom1[esqpos1] = "Consulta Linhas"
            then do:
                hide frame f-com1 no-pause.
                if pedid.catcod = 41
                then run co_ocpprop.p (recid(pedid)).
                else run consulta_linhas.
                view frame f-com1.
            end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(pedid).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.

    find first wfped where wfped.rec = recid(pedid) no-lock no-error.
    vast = available wfped.
    display
        vast          no-label format "*/"
        pedid.pednum
        pedid.regcod  column-label "Fl.Entrega"
        pedid.clfcod  column-label "Fornec."
        forne.fornom  format "x(20)"
        pedid.peddat  format "99/99/99"
        PEDID.PEDTOT
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
    color display message
        vast
        pedid.pednum
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
        vast
        pedid.pednum
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first  pedid  where
                   pedid.pedtdc = 1 and
                   pedid.pedsit and
                   pedid.clfcod = forne.forcod and
                   pedid.sitped <> "F" and
                   pedid.peddti >= today - 120 and
                   pedid.catcod = par-catcod no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next  pedid  where
                   pedid.pedtdc = 1 and
                   pedid.pedsit and
                   pedid.clfcod = forne.forcod and
                   pedid.sitped <> "F" and
                   pedid.peddti >= today - 120 and
                   pedid.catcod = par-catcod no-lock no-error.
             
if par-tipo = "up" 
then find prev  pedid  where
                   pedid.pedtdc = 1 and
                   pedid.pedsit and
                   pedid.clfcod = forne.forcod and
                   pedid.sitped <> "F" and
                   pedid.peddti >= today - 120 and
                   pedid.catcod = par-catcod no-lock no-error.
end procedure.


procedure consulta_linhas.

    find first wfped where wfped.rec = recid(pedid) no-error.
    if available wfped 
    then find pedid where recid(pedid) = wfped.rec NO-LOCK.
    else find pedid where recid(pedid) = recatu1 NO-LOCK.

    for each liped of pedid NO-LOCK:

        find produ of liped no-lock.
        if produ.itecod = 0
        then find item-produ where item-produ.procod = produ.procod no-lock.
        else find item-produ where item-produ.procod = produ.itecod no-lock.

        disp
            item-produ.procod
            produ.pronom format "x(30)"
            liped.lippreco format ">>>,>>9.99" column-label "Preco"
            liped.lipqtd   format ">>>>9" column-label "Qtd."
            pedid.peddti column-label "Dt.Inicial" format "99/99/9999"
            pedid.peddtf column-label "Dt.Final  " format "99/99/9999"
            with frame flip centered overlay color white/cyan
                title " Linhas do Pedido - Nr. " + string(pedid.pednum) 6 down.
    end.
    pause.

end procedure.
