
{admcab.i}
{api/acentos.i}

def input param prec as recid.

def buffer basses_envio for asses_envio.
    
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" parametros "," inclusao"," exclusao "," "," "].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


find asses_param where recid(asses_param) = prec no-lock.

    form   
            assessoria 
            
        enviaCDC 
        enviaNOV
        
        enviaEP 
        enviaCPN 
        digito5 no-labels
        with frame frame-a 8 down centered row 8 width 80
        title "ASSESSORIAS            DIGITOS CPF POSICAO " + string(asses_param.posicaoCPF) + "    ".


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find asses_envio where recid(asses_envio) = recatu1 no-lock.
    if not available asses_envio
    then do.
        run pinclui (output recatu1).
        run pparametros.
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(asses_envio).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available asses_envio
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find asses_envio where recid(asses_envio) = recatu1 no-lock.

        status default "".
        
                        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        status default asses_envio.arquivoult.
            
        choose field asses_envio.assessoria

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

                run color-normal.
        hide message no-pause.
                 
        pause 0. 

                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
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
                    if not avail asses_envio
                    then leave.
                    recatu1 = recid(asses_envio).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail asses_envio
                    then leave.
                    recatu1 = recid(asses_envio).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail asses_envio
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail asses_envio
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            

            if esqcom1[esqpos1] = " parametros "
            then do:
                hide frame f-com1 no-pause.

                run pparametros.    
                leave.
            end.
            if esqcom1[esqpos1] = " inclusao "
            then do:
                hide frame f-com1 no-pause.
                run pinclui (output recatu1).
                run pparametros.
                leave.
                
            end. 
            if esqcom1[esqpos1] = " exclusao "
            then do on error undo:
                find current asses_envio.
                delete asses_envio.
                recatu1 = ?.
                leave.
                
            end. 
            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(asses_envio).
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
        asses_envio.assessoria
            
        enviaCDC 
        enviaNOV
        
        enviaEP 
        enviaCPN 
        asses_envio.digito5[1] when asses_envio.digito5[1] <> ?
        asses_envio.digito5[2] when asses_envio.digito5[2] <> ?
        asses_envio.digito5[3] when asses_envio.digito5[3] <> ?
        asses_envio.digito5[4] when asses_envio.digito5[4] <> ?
        asses_envio.digito5[5] when asses_envio.digito5[5] <> ?
        asses_envio.digito5[6] when asses_envio.digito5[6] <> ?
        asses_envio.digito5[7] when asses_envio.digito5[7] <> ?
        asses_envio.digito5[8] when asses_envio.digito5[8] <> ?
        asses_envio.digito5[9] when asses_envio.digito5[9] <> ?
        asses_envio.digito5[10] when asses_envio.digito5[10] <> ?
        
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        asses_envio.assessoria
        asses_envio.assessoria
            
        enviaCDC 
        enviaNOV
        
        enviaEP 
        enviaCPN 

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        asses_envio.assessoria
                asses_envio.assessoria
            
        enviaCDC 
        enviaNOV
        
        enviaEP 
        enviaCPN 
        digito5

        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        asses_envio.assessoria
            
        enviaCDC 
        enviaNOV
        
        enviaEP 
        enviaCPN 

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first asses_envio
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next asses_envio 
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev asses_envio 
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo:

        find current asses_envio exclusive.
        
        disp 
        assessoria colon 20
            
        enviaCDC   colon 20
        enviaNOV   colon 20 
        
        enviaEP  colon 20
        enviaCPN colon 20
        skip
        asses_envio.digito5[1] colon 20 no-label when asses_envio.digito5[1] <> ?
        asses_envio.digito5[2] no-label  when asses_envio.digito5[2] <> ?
        asses_envio.digito5[3] no-label when asses_envio.digito5[3] <> ?
        asses_envio.digito5[4] no-label when asses_envio.digito5[4] <> ?
        asses_envio.digito5[5] no-label when asses_envio.digito5[5] <> ?
        asses_envio.digito5[6] no-label when asses_envio.digito5[6] <> ?
        asses_envio.digito5[7] no-label when asses_envio.digito5[7] <> ?
        asses_envio.digito5[8] no-label when asses_envio.digito5[8] <> ?
        asses_envio.digito5[9] no-label when asses_envio.digito5[9] <> ?
        asses_envio.digito5[10] no-label when asses_envio.digito5[10] <> ?


        .

        update 
        asses_envio.assessoria = removeAcento(replace(caps(asses_envio.assessoria)," ","")).
        disp asses_envio.assessoria.
                
        update
        
                enviaCDC
                        enviaNOV
                        
                                enviaEP
                                        enviaCPN
                                        
        with side-labels 
            row 9
            centered
               overlay.

    sresp = yes.
    if asses_envio.digito5[1] <> ?
    then message "Alterar Digitos de CPF?" update sresp.    
    if sresp
    then do:
            asses_envio.digito5 = ?.
            disp asses_envio.digito5.
            disp   
        asses_envio.digito5[1] colon 20 no-label when asses_envio.digito5[1] <> ?
        asses_envio.digito5[2] no-label  when asses_envio.digito5[2] <> ?
        asses_envio.digito5[3] no-label when asses_envio.digito5[3] <> ?
        asses_envio.digito5[4] no-label when asses_envio.digito5[4] <> ?
        asses_envio.digito5[5] no-label when asses_envio.digito5[5] <> ?
        asses_envio.digito5[6] no-label when asses_envio.digito5[6] <> ?
        asses_envio.digito5[7] no-label when asses_envio.digito5[7] <> ?
        asses_envio.digito5[8] no-label when asses_envio.digito5[8] <> ?
        asses_envio.digito5[9] no-label when asses_envio.digito5[9] <> ?
        asses_envio.digito5[10] no-label when asses_envio.digito5[10] <> ?
                .
            
    update asses_envio.digito5[1]. if asses_envio.digito5[1] = ? then do: down. leave. end.
    update asses_envio.digito5[2]. if asses_envio.digito5[2] = ? then do: down. leave. end.
        if asses_envio.digito5[2] = asses_envio.digito5[1] then undo.
    update asses_envio.digito5[3]. if asses_envio.digito5[3] = ? then do: down. leave. end.
        if asses_envio.digito5[3] = asses_envio.digito5[1] or  asses_envio.digito5[3] = asses_envio.digito5[2]
        then undo.
    update asses_envio.digito5[4]. if asses_envio.digito5[4] = ? then do: down. leave. end.
        if asses_envio.digito5[4] = asses_envio.digito5[1] or  asses_envio.digito5[4] = asses_envio.digito5[2] or  asses_envio.digito5[4] = asses_envio.digito5[3]
        then undo.
    update asses_envio.digito5[5]. if asses_envio.digito5[5] = ? then do: down. leave. end.
        if asses_envio.digito5[5] = asses_envio.digito5[1] or  asses_envio.digito5[5] = asses_envio.digito5[2] or  asses_envio.digito5[5] = asses_envio.digito5[3] or asses_envio.digito5[5] = asses_envio.digito5[4]
        then undo.
    update asses_envio.digito5[6]. if asses_envio.digito5[6] = ? then do: down. leave. end.
        if asses_envio.digito5[6] = asses_envio.digito5[1] or  asses_envio.digito5[6] = asses_envio.digito5[2] or  asses_envio.digito5[6] = asses_envio.digito5[3] or asses_envio.digito5[6] = asses_envio.digito5[4]
        or asses_envio.digito5[6] = asses_envio.digito5[5]
        then undo.
    update asses_envio.digito5[7]. if asses_envio.digito5[7] = ? then do: down. leave. end.
        if asses_envio.digito5[7] = asses_envio.digito5[1] or  asses_envio.digito5[7] = asses_envio.digito5[2] or  asses_envio.digito5[7] = asses_envio.digito5[3] or asses_envio.digito5[7] = asses_envio.digito5[4]
        or asses_envio.digito5[7] = asses_envio.digito5[5] or asses_envio.digito5[7] = asses_envio.digito5[6]
        then undo.
    update asses_envio.digito5[8]. if asses_envio.digito5[8] = ? then do: down. leave. end.
        if asses_envio.digito5[8] = asses_envio.digito5[1] or asses_envio.digito5[8] = asses_envio.digito5[2] or  asses_envio.digito5[8] = asses_envio.digito5[3] or asses_envio.digito5[8] = asses_envio.digito5[4]
        or asses_envio.digito5[8] = asses_envio.digito5[5] or asses_envio.digito5[8] = asses_envio.digito5[6] or asses_envio.digito5[8] = asses_envio.digito5[7]
        then undo.
    update asses_envio.digito5[9]. if asses_envio.digito5[9] = ? then do: down. leave. end.
        if asses_envio.digito5[9] = asses_envio.digito5[1] or asses_envio.digito5[9] = asses_envio.digito5[2] or asses_envio.digito5[9] = asses_envio.digito5[3] or asses_envio.digito5[9] = asses_envio.digito5[4]
        or asses_envio.digito5[9] = asses_envio.digito5[5] or asses_envio.digito5[9] = asses_envio.digito5[6] or asses_envio.digito5[9] = asses_envio.digito5[7] or asses_envio.digito5[9] = asses_envio.digito5[8]
        then undo.
    update asses_envio.digito5[10]. 
        if asses_envio.digito5[10] = asses_envio.digito5[1] or asses_envio.digito5[10] = asses_envio.digito5[2] or asses_envio.digito5[10] = asses_envio.digito5[3] or asses_envio.digito5[10] = asses_envio.digito5[4]
        or asses_envio.digito5[10] = asses_envio.digito5[5] or asses_envio.digito5[10] = asses_envio.digito5[6] or asses_envio.digito5[10] = asses_envio.digito5[7] or asses_envio.digito5[10] = asses_envio.digito5[8]
        or asses_envio.digito5[10] = asses_envio.digito5[9]
        then undo.

    end.
    
    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    create asses_envio.
    
    update
        asses_envio.assessoria      colon 20
        with row 9 
        centered
        overlay.
        update 
        asses_envio.assessoria = removeAcento(replace(caps(asses_envio.assessoria)," ","")).


end.


end procedure.


