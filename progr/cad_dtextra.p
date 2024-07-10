/*
*
*    dtextra.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial no.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao","" ].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de dtextra ",
             " Alteracao da dtextra ",
             " Exclusao  da dtextra ",
             " Consulta  da dtextra ",
             " "].

def buffer bdtextra       for dtextra.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
assign
    esqregua = yes
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find dtextra where recid(dtextra) = recatu1 no-lock.
    if not available dtextra
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(dtextra).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available dtextra
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
            find dtextra where recid(dtextra) = recatu1 no-lock.

            status default
                esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(dtextra.dtexobs)
                                        else "".
            run color-message.
            choose field dtextra.exdata help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

        end.
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
                    if not avail dtextra
                    then leave.
                    recatu1 = recid(dtextra).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail dtextra
                    then leave.
                    recatu1 = recid(dtextra).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail dtextra
                then next.
                color display white/red dtextra.exdata with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail dtextra
                then next.
                color display white/red dtextra.exdata with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form dtextra
                 with frame f-dtextra color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-dtextra on error undo.
                    create dtextra.
                    update dtextra.
                    recatu1 = recid(dtextra).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-dtextra.
                    disp dtextra.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-dtextra on error undo.
                    find dtextra where recid(dtextra) = recatu1  exclusive.
                    update dtextra.dtexobs.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    leave.
                end.
                if esqcom1[esqpos1] = " Exclusao"
                then do:
                    sresp = no.
                    find dtextra where recid(dtextra) = recatu1  exclusive.
                    message "Confirma exclusao " dtextra.exdata " ?"
                        update sresp.
                    if sresp
                    then do on error undo:
                        find prev dtextra where true no-lock no-error.
                        if avail dtextra
                        then recatu2 = recid(dtextra).
                        find dtextra where recid(dtextra) = recatu1  exclusive.

                        create hiscampotb.
                        assign
                            hiscampotb.xtabela = "dtextra"
                            hiscampotb.xcampo  = "excluido"
                            hiscampotb.data    = today
                            hiscampotb.hora    = time
                            hiscampotb.etbusuario = func.etbcod
                            hiscampotb.codusuario = func.funcod
                            /*hiscampotb.registro = rowid(dtextra)*/
                            hiscampotb.valor_campo = 
                                string(dtextra.exdata) + " " +
                                dtextra.dtexobs.
                        raw-transfer dtextra to hiscampotb.registro.
                        delete dtextra.
                        recatu1 = recatu2.
                        leave.
                    end.
                end.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(dtextra).
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
    display
        dtextra.exdata
        vsemabr[weekday(dtextra.exdata)] no-label
        dtextra.dtexobs
        with frame frame-a 11 down centered color white/red row 5.
end procedure.


procedure color-message.
    color display message
        dtextra.exdata
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        dtextra.exdata
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then find first dtextra where true no-lock no-error.
    else find last dtextra  where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then find next dtextra  where true no-lock no-error.
    else find prev dtextra  where true no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then find prev dtextra where true  no-lock no-error.
    else find next dtextra where true  no-lock no-error.

end procedure.
         
