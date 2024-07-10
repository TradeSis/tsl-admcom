{admcab.i}

def shared temp-table tt-contrato
    field contnum as char.


/*
*
*    tt-contrato.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" "," Consulta "," Contrato "," "].

def buffer btt-contrato       for tt-contrato.
def var vtt-contrato         like tt-contrato.contnum.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-contrato where recid(tt-contrato) = recatu1 no-lock.
    if not available tt-contrato
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-contrato).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-contrato
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
            find tt-contrato where recid(tt-contrato) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field tt-contrato.contnum help ""
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
                    if not avail tt-contrato
                    then leave.
                    recatu1 = recid(tt-contrato).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-contrato
                    then leave.
                    recatu1 = recid(tt-contrato).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-contrato
                then next.
                color display white/red tt-contrato.contnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-contrato
                then next.
                color display white/red tt-contrato.contnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-contrato
                 with frame f-tt-contrato color black/cyan
                      centered side-label row 5 .

            form cyber_controle
                 with frame f-cyber_controle color black/cyan
                      centered side-label row 5 .

            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Consulta "
            then do with frame f-tt-contrato.
                find first cyber_controle 
                      where cyber_controle.contnum = int64(tt-contrato.contnum)
                        no-lock no-error.
                if avail cyber_controle
                then disp cyber_controle.
            end.
            if esqcom1[esqpos1] = " Contrato "
            then do.
                hide frame f-com1 no-pause.
                run conco_v1701.p (tt-contrato.contnum).
            end.
        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-contrato).
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
    find first cyber_controle
                     where cyber_controle.contnum = int64(tt-contrato.contnum)
                    no-lock no-error.


    find contrato where contrato.contnum = cyber_controle.contnum
                  no-lock no-error.

 
if avail cyber_controle
then do.
    disp
        cyber_controle.loja        format ">>9"
        tt-contrato.contnum        format "x(10)"
        cyber_controle.situacao    format "x(10)"
        cyber_controle.vlraberto   format ">>>>9.99" column-label "Vlr!Aberto"
        cyber_controle.vlratrasado format ">>>>9.99" column-label "Vlr!Atrasad"
        cyber_controle.cybatrasado format ">>>>9.99" column-label "Cyb!Atrasad"
        cyber_controle.dtenvio     format "999999"   column-label "Envio"
        contrato.dtinicial when avail contrato column-label "D.Inic"
                           format "999999"
        contrato.datexp    when avail contrato format "999999"
                           column-label "Dt.Exp"
        with frame frame-a 11 down centered color white/red row 5.
end.
else
    display tt-contrato.contnum
        with frame frame-a 11 down centered color white/red row 5.
end procedure.


procedure color-message.
color display message
        tt-contrato.contnum
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        tt-contrato.contnum
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-contrato where true
                                                no-lock no-error.
    else  
        find last tt-contrato  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-contrato  where true
                                                no-lock no-error.
    else  
        find prev tt-contrato   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-contrato where true  
                                        no-lock no-error.
    else   
        find next tt-contrato where true 
                                        no-lock no-error.
        
end procedure.
         


