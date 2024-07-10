/*
*
*    tt-pedid.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-recid as recid.

def temp-table tt-pedid
    field pednum    like pedid.pednum
    field rec       as recid.

find plani where recid(plani) = par-recid no-lock.

run monta-tt.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," "].

def buffer btt-pedid       for tt-pedid.

form
    esqcom1
    with frame f-com1 row screen-lines /*4*/ no-box no-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-pedid where recid(tt-pedid) = recatu1 no-lock.
    if not available tt-pedid
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(tt-pedid).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tt-pedid
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find tt-pedid where recid(tt-pedid) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field tt-pedid.pednum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
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
                    if not avail tt-pedid
                    then leave.
                    recatu1 = recid(tt-pedid).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-pedid
                    then leave.
                    recatu1 = recid(tt-pedid).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-pedid
                then next.
                color display white/red tt-pedid.pednum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-pedid
                then next.
                color display white/red tt-pedid.pednum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form tt-pedid
                 with frame f-tt-pedid color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-tt-pedid.
                    run co_occons.p (tt-pedid.rec).
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    leave.
                end.
        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-pedid).
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
    find pedid where recid(pedid) = tt-pedid.rec no-lock.
    display
        tt-pedid.pednum
        pedid.pedtdc
        pedid.etbcod
        pedid.peddat
        pedid.clfcod
        pedid.sitped
        with frame frame-a 11 down centered color white/red row 5.
end procedure.


procedure color-message.
    color display message
        tt-pedid.pednum
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        tt-pedid.pednum
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then find first tt-pedid where true no-lock no-error.
    else find last tt-pedid  where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then find next tt-pedid  where true no-lock no-error.
    else find prev tt-pedid  where true no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then find prev tt-pedid where true no-lock no-error.
    else find next tt-pedid where true no-lock no-error.
        
end procedure.
         
procedure monta-tt.
    message "Pesquisando...".

    def var vct     as int.
    def var mpedtdc as int extent 2 init [3, 6].
    do vct = 1 to 2.

/***
        for each pedid where /*pedid.pedtdc = mpedtdc[vct]*/
                     /*    and pedid.etbcod = plani.etbcod*/
                     /*and pedid.peddat = plani.pladat*/
                     /*    and pedid.modcod = "PEDF"
                         and pedid.condat = plani.pladat */
                         /*and*/ pedid.frecod = plani.placod
                      no-lock.
            create tt-pedid.
            tt-pedid.rec = recid(pedid).
            tt-pedid.pednum = pedid.pednum.
        end.
***/
        for each liped where liped.pedtdc = mpedtdc[vct]
                         and liped.etbcod = plani.etbcod
                         and liped.venda-placod = plani.placod
                       no-lock.
            find pedid of liped no-lock.
            create tt-pedid.
            tt-pedid.rec = recid(pedid).
            tt-pedid.pednum = pedid.pednum.
        end.
    end.
    hide message no-pause.

end procedure.
