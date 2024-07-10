/*
*
*    envfidc.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-recid as recid.

find titulo where recid(titulo) = par-recid no-lock.


def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5.

form
    esqcom1
    with frame f-com1
                 row 9 no-box no-labels side-labels column 1 centered overlay.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ctbtrocart where recid(ctbtrocart) = recatu1 no-lock.
    if not available ctbtrocart
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ctbtrocart).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ctbtrocart
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find ctbtrocart where recid(ctbtrocart) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field ctbtrocart.Dtinc   help ""
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
                    if not avail ctbtrocart
                    then leave.
                    recatu1 = recid(ctbtrocart).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ctbtrocart
                    then leave.
                    recatu1 = recid(ctbtrocart).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ctbtrocart
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ctbtrocart
                then next.
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

                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-ctbtrocart.
                    disp ctbtrocart.
                end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ctbtrocart).
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
        ctbtrocart.dtinc
        string(ctbtrocart.hrinc,"HH:MM:SS")    
    
        ctbtrocart.dtref
        ctbtrocart.dtrefSAIDA

        ctbtrocart.cobcodSAIDA   column-label "Cart!Orig"
        ctbtrocart.cobcodENTRADA column-label "Nova!Cart"
        
        ctbtrocart.Valor
        ctbtrocart.DtEnvSap
        
        with frame frame-a 7 down centered row 10 overlay width 80
        title "TROCAS/VENDAS DE CARTEIRAS".
end procedure.


procedure color-message.
color display message
        ctbtrocart.dtinc
    
        ctbtrocart.dtref
        ctbtrocart.dtrefSAIDA

        ctbtrocart.cobcodENTRADA
        ctbtrocart.cobcodSAIDA
        
        ctbtrocart.Valor
        ctbtrocart.DtEnvSap

        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        ctbtrocart.dtinc
    
        ctbtrocart.dtref
        ctbtrocart.dtrefSAIDA

        ctbtrocart.cobcodENTRADA
        ctbtrocart.cobcodSAIDA
        
        ctbtrocart.Valor
        ctbtrocart.DtEnvSap

        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then find first ctbtrocart where ctbtrocart.contnum = int(titulo.titnum) and ctbtrocart.titpar = titulo.titpar  no-lock no-error.
    else find last  ctbtrocart where ctbtrocart.contnum = int(titulo.titnum) and ctbtrocart.titpar = titulo.titpar  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then find next ctbtrocart where ctbtrocart.contnum = int(titulo.titnum) and ctbtrocart.titpar = titulo.titpar   no-lock no-error.
    else find prev ctbtrocart where ctbtrocart.contnum = int(titulo.titnum) and ctbtrocart.titpar = titulo.titpar  no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then find prev ctbtrocart where ctbtrocart.contnum = int(titulo.titnum) and ctbtrocart.titpar = titulo.titpar  no-lock no-error.
    else find next ctbtrocart where ctbtrocart.contnum = int(titulo.titnum) and ctbtrocart.titpar = titulo.titpar  no-lock no-error.
        
end procedure.

