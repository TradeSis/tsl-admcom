{admcab.i}

def input parameter par-rec as recid.

find titulo where recid(titulo) = par-rec no-lock.

/*
*
*    titulolog.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend       as log.
def var esqcom1         as char format "x(12)" extent 5.

form
    esqcom1
    with frame f-com1 row 8 no-box no-labels column 1 centered overlay.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find titulolog where recid(titulolog) = recatu1 no-lock.
    if not available titulolog
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(titulolog).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available titulolog
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find titulolog where recid(titulolog) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field titulolog.data help ""
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
                    if not avail titulolog
                    then leave.
                    recatu1 = recid(titulolog).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail titulolog
                    then leave.
                    recatu1 = recid(titulolog).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail titulolog
                then next.
                color display white/red titulolog.data with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail titulolog
                then next.
                color display white/red titulolog.data with frame frame-a.
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

                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    leave.
                end.
        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(titulolog).
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
        titulolog.data
        string(titulolog.hora, "hh:mm:ss")
        titulolog.funcod
        titulolog.campo format "x(10)"
        titulolog.valor format "x(10)"
        titulolog.obs
        with frame frame-a 8 down centered color white/red row 9 overlay.
end procedure.


procedure color-message.
color display message
        titulolog.data
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        titulolog.data
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first titulolog where   titulolog.empcod = titulo.empcod and
                                     titulolog.titnat = titulo.titnat and
                                     titulolog.modcod = titulo.modcod and
                                     titulolog.etbcod = titulo.etbcod and
                                     titulolog.clifor = titulo.clifor and
                                     titulolog.titnum = titulo.titnum and
                                     titulolog.titpar = titulo.titpar
                                                no-lock no-error.
    else  
        find last titulolog  where   titulolog.empcod = titulo.empcod and
                                     titulolog.titnat = titulo.titnat and
                                     titulolog.modcod = titulo.modcod and
                                     titulolog.etbcod = titulo.etbcod and
                                     titulolog.clifor = titulo.clifor and
                                     titulolog.titnum = titulo.titnum and
                                     titulolog.titpar = titulo.titpar
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next titulolog  where   titulolog.empcod = titulo.empcod and
                                     titulolog.titnat = titulo.titnat and
                                     titulolog.modcod = titulo.modcod and
                                     titulolog.etbcod = titulo.etbcod and
                                     titulolog.clifor = titulo.clifor and
                                     titulolog.titnum = titulo.titnum and
                                     titulolog.titpar = titulo.titpar
                                                no-lock no-error.
    else  
        find prev titulolog   where  titulolog.empcod = titulo.empcod and
                                     titulolog.titnat = titulo.titnat and
                                     titulolog.modcod = titulo.modcod and
                                     titulolog.etbcod = titulo.etbcod and
                                     titulolog.clifor = titulo.clifor and
                                     titulolog.titnum = titulo.titnum and
                                     titulolog.titpar = titulo.titpar
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev titulolog where    titulolog.empcod = titulo.empcod and
                                     titulolog.titnat = titulo.titnat and
                                     titulolog.modcod = titulo.modcod and
                                     titulolog.etbcod = titulo.etbcod and
                                     titulolog.clifor = titulo.clifor and
                                     titulolog.titnum = titulo.titnum and
                                     titulolog.titpar = titulo.titpar
                                        no-lock no-error.
    else   
        find next titulolog where    titulolog.empcod = titulo.empcod and
                                     titulolog.titnat = titulo.titnat and
                                     titulolog.modcod = titulo.modcod and
                                     titulolog.etbcod = titulo.etbcod and
                                     titulolog.clifor = titulo.clifor and
                                     titulolog.titnum = titulo.titnum and
                                     titulolog.titpar = titulo.titpar
                                        no-lock no-error.

end procedure.
