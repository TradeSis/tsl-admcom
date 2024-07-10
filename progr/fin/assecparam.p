
{admcab.i}
def buffer basses_param for asses_param.
    
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" parametros "," assessorias"," inclusao "," executa"," -"].

def var vhriniultproc as char format "x(5)".
def var vhrfimultproc as char format "x(5)".

form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


    form  
        
            asses_param.posicaoCPF 
            atrasomin
            atrasomax
            diasPGTO
            dtiniultproc column-label "Ult Proc!Data Ini" 
             vhriniultproc  column-label "hr ini"
            dtfimultproc column-label "Ult Proc!Data Fim"
            vhrfimultproc  column-label "hr fim"
            
        
        
        with frame frame-a 8 down centered row 8
        no-box.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find asses_param where recid(asses_param) = recatu1 no-lock.
    if not available asses_param
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(asses_param).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available asses_param
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find asses_param where recid(asses_param) = recatu1 no-lock.
        
        if asses_param.dtfim <> ?
        then do:
            esqcom1[1] = "".
            esqcom1[2] = "".
        end.    
        else do:
             esqcom1[1] = " parametros".
             esqcom1[2] = " assessorias".
        end.     
        
        status default "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field asses_param.posicaocpf

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
                    if not avail asses_param
                    then leave.
                    recatu1 = recid(asses_param).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail asses_param
                    then leave.
                    recatu1 = recid(asses_param).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail asses_param
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail asses_param
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
            
            
            if esqcom1[esqpos1] = " assessorias "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run fin/assecenvio.p (input recid(asses_param)).
                
            end. 
            
            if esqcom1[esqpos1] = " executa "
            then do:
                message "confirma executar agora?" update sresp.
                if sresp
                then run fin/assesexpautom.p.
                
            end. 
            
            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(asses_param).
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
            
            asses_param.posicaoCPF 
            atrasomin
            atrasomax
            diasPGTO
            dtiniultproc
            string(hriniultproc,"HH:MM") @ vhriniultproc 
            dtfimultproc
            string(hrfimultproc,"HH:MM") @ vhrfimultproc 
            
            
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
                asses_param.posicaoCPF 
            atrasomin
            atrasomax
            diasPGTO
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
                asses_param.posicaoCPF 
            atrasomin
            atrasomax
            diasPGTO

        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
            asses_param.posicaoCPF 
            atrasomin
            atrasomax
            diasPGTO            
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find last asses_param  where
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find prev asses_param  where
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find next asses_param  where
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo:

        find current asses_param exclusive.
        disp    
            asses_param.dtini colon 20
            asses_param.dtfim
            .

                    
        update 
            
            posicaoCPF colon 20
            atrasomin colon 20
            atrasomax colon 20
            diasPGTO colon 20 
        with side-labels
            row 7
            centered
               overlay.

    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    find last basses_param where basses_param.dtfim = ?  no-error.
    if avail basses_param
    then do:
        basses_param.dtfim = today.
    end.    
    create asses_param.
    prec = recid(asses_param).
    asses_param.dtini = today.
    
    if avail basses_param
    then buffer-copy basses_param except dtini dtfim to asses_param.

end.


end procedure.



