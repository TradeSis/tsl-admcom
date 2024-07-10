/*
*
*    cyber_parcela.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-rec as recid.

def var vhora as char.

find cyber_contrato where recid(cyber_contrato) = par-rec no-lock.
find cyber_clien of cyber_contrato no-lock.
find clien of cyber_clien no-lock.    
find last cyber_contrato_h of cyber_contrato no-lock no-error.
find contrato of cyber_contrato no-lock.

if avail cyber_contrato_h
then vhora = string(cyber_contrato_h.hrEnvio,"HH:MM").

display
    cyber_clien.clicod   label "Cliente"
    clien.clinom    no-label 
    cyber_contrato.contnum label "Contrato" format ">>>>>>>>>>>>"
    cyber_contrato_h.DtEnvio label "Ult.Envio" when avail cyber_contrato_h
    vhora no-label format "x(5)"
    with frame frame-vab side-label row 3 color message width 81 no-box.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    init [" ", " Historico ", " Consulta ", ""].

form
    esqcom1
    with frame f-com1
                 row 5 no-box no-labels side-labels column 1 centered.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find cyber_parcela where recid(cyber_parcela) = recatu1 no-lock.
    if not available cyber_parcela
    then do.
        message "Sem parcelas" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(cyber_parcela).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available cyber_parcela
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find cyber_parcela where recid(cyber_parcela) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field cyber_parcela.titpar help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
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
                    if not avail cyber_parcela
                    then leave.
                    recatu1 = recid(cyber_parcela).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cyber_parcela
                    then leave.
                    recatu1 = recid(cyber_parcela).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cyber_parcela
                then next.
                color display white/red cyber_parcela.titpar with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cyber_parcela
                then next.
                color display white/red cyber_parcela.titpar with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form cyber_parcela
                 with frame f-cyber_parcela color black/cyan
                      centered side-label row 6 2 col.
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Historico "
                then do.
                    hide frame f-com1 no-pause.
                    run cyber/cyber_parcela_h.p (recid(cyber_parcela)).
                    view frame f-com1.
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-cyber_parcela.
                    disp cyber_parcela.
                end.
        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(cyber_parcela).
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

    find titulo of cyber_parcela no-lock.
    find last cyber_parcela_h of cyber_parcela no-lock no-error.
    if avail cyber_parcela_h
    then vhora = string(cyber_parcela_h.HrEnvio, "hh:mm").
    else vhora = "".

    display
        cyber_parcela.titpar 
        titulo.titdtven
        titulo.titvlcob format ">>,>>9.99"
        titulo.titsit
        titulo.titdtpag
        titulo.titvlpag format ">>,>>9.99"
        cyber_parcela_h.DtEnvio when avail cyber_parcela_h
        vhora format "x(5)"
        with frame frame-a 8 down centered color white/red row 7
                title " Parcelas ".
end procedure.


procedure color-message.
color display message
        cyber_parcela.titpar
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        cyber_parcela.titpar
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first cyber_parcela where of cyber_contrato no-lock no-error.
    else  
        find last cyber_parcela  where of cyber_contrato no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next cyber_parcela  where of cyber_contrato no-lock no-error.
    else  
        find prev cyber_parcela  where of cyber_contrato no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev cyber_parcela where of cyber_contrato no-lock no-error.
    else   
        find next cyber_parcela where of cyber_contrato no-lock no-error.
        
end procedure.

