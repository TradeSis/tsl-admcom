/*
*
*    ttarq.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}
{tpalcis-wms.i}
/*
def input parameter par-tipo as char.
*/
def var par-tipo as char.
def temp-table ttarq
    field Arquivo   as char format "x(25)"
    field tm        like tipo-alcis.tm format "x(45)" label "Tipo"
    field seq       as int.
    
def var vtm like ttarq.tm.
vtm = "".

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," Acao "," Filtro",""].

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

run diretorio.    

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttarq where recid(ttarq) = recatu1 no-lock.
    if not available ttarq
    then do.
        message "Sem arquivos para confirmar " par-tipo view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttarq).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttarq
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttarq where recid(ttarq) = recatu1 no-lock.
        find first tipo-alcis where tipo-alcis.tp = substr(ttarq.arquivo,1,4) 
            no-lock no-error.
        if not avail tipo-alcis
        then next.    

            status default "".

            run color-message.
            choose field ttarq.Arquivo 
                help "Refresh de 15 segundos"
                pause 15
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
            pause 0. 
            if lastkey = -1 
            then do:  
                hide frame frame-a no-pause.
                run diretorio.
                recatu1 = ?.
                next bl-princ. 
            end.
                                                                
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
                    if not avail ttarq
                    then leave.
                    recatu1 = recid(ttarq).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttarq
                    then leave.
                    recatu1 = recid(ttarq).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttarq
                then next.
                color display white/red ttarq.Arquivo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttarq
                then next.
                color display white/red ttarq.Arquivo with frame frame-a.
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

            if esqcom1[esqpos1] = " Acao "
            then do.
                sresp = no.
                message "Confirma" tipo-alcis.tm "?" update sresp.
                if sresp and search(tipo-alcis.acao) <> ?
                then do.
                    run value(tipo-alcis.acao) (ttarq.arquivo).
                    pause 1 no-message.
                    run diretorio.
                    recatu1 = ?. 
                    next bl-princ.
                end.
            end.
            if esqcom1[esqpos1] = " Consulta "
            then run value(tipo-alcis.consulta) (ttarq.arquivo).
            if esqcom1[esqpos1] = " Filtro"
            then do:
                disp v-filtro format "x(40)"
                    with frame f-filtro centered no-label 1 column
                    overlay.
                choose field v-filtro with frame f-filtro.
                vtm = v-filtro[frame-index].
                recatu1 = ?.
                next bl-princ.
            end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttarq).
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
    display ttarq except seq
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
    color display message
        ttarq.Arquivo
        ttarq.tm
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
        ttarq.Arquivo
        ttarq.tm
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first ttarq where (if vtm <> "" 
                             then ttarq.tm = vtm else true)
                    no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next  ttarq where (if vtm <> "" 
                             then ttarq.tm = vtm else true)
                    no-lock no-error.
             
if par-tipo = "up" 
then find prev  ttarq where (if vtm <> "" 
                             then ttarq.tm = vtm else true)
                         no-lock no-error.
        
end procedure.


procedure diretorio.
    def var vi as int.
    def var varquivo as char.

    for each ttarq.
        delete ttarq.
    end.

    varquivo = "/admcom/relat/lealcis." + string(time).
    unix silent value("ls " + alcis-diretorio + " > " + varquivo).
    input from value(varquivo).
    
    repeat transaction.
        create ttarq.
        import ttarq.
        /****
        if par-tipo <> substr(ttarq.arquivo,1,4)
        then do.
            delete ttarq.
            next.
        end.
        ****/
        find first tipo-alcis where tipo-alcis.tp = substr(ttarq.arquivo,1,4)
                        no-lock no-error.
        if avail tipo-alcis and
            (if vtm <> "" then tipo-alcis.tm = vtm else true)
        then do:                
            ttarq.tm  = tipo-alcis.tm.
            ttarq.seq = int(substr(ttarq.arquivo,5,5)).
            do vi = 1 to 5:
                if v-filtro[vi] = ""
                then do:
                    v-filtro[vi] = ttarq.tm.
                    leave.
                end.
                else if v-filtro[vi] = ttarq.tm
                     then leave.
            end.
        end.
        else do:
            delete ttarq.
        end.
    end.
    input close.
    unix silent value("rm -f " + varquivo).

end procedure.
