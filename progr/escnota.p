{admcab.i}

def var vcont-rec as int. 
def var vcont-fre as int. 
def var vcont-val as int.


def shared temp-table tt-nota
    field flag as log format "*/ "
    field nota as char format "XXX"
    field rec  as int 
    field fre  as int 
    field val  as int 
    index inota is primary unique nota desc.

for each tt-nota:  
    delete tt-nota.  
end.    

assign vcont-rec = 0
       vcont-fre = 0
       vcont-val = 0.
       
do vcont-rec = 1 to 5:  
    do vcont-fre = 1 to 5:  
        do vcont-val = 1 to 5:  
            
            create tt-nota.  
            assign tt-nota.rec  = vcont-rec  
                   tt-nota.fre  = vcont-fre 
                   tt-nota.val  = vcont-val  
                   tt-nota.nota = string(vcont-rec) 
                                + string(vcont-fre)  
                                + string(vcont-val).  
            /*if sparam = "0"
            then tt-nota.flag = yes. 
            */
        end.  
    end. 
end.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Selecionar "," "," "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" ",
             " ",
             " ",
             " ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].


def buffer btt-nota       for tt-nota.
def var vtt-nota         like tt-nota.nota.


form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-nota where recid(tt-nota) = recatu1 no-lock.
    if not available tt-nota
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-nota).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-nota
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
            find tt-nota where recid(tt-nota) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-nota.nota)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-nota.nota)
                                        else "".
            run color-message.
            choose field tt-nota.flag
                         tt-nota.rec
                         tt-nota.fre
                         tt-nota.val 
                         help "[Enter] Seleciona as notas    [F4] Confirma "
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-nota
                    then leave.
                    recatu1 = recid(tt-nota).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-nota
                    then leave.
                    recatu1 = recid(tt-nota).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-nota
                then next.
                color display white/red tt-nota.flag
                                        tt-nota.rec
                                        tt-nota.fre
                                        tt-nota.val
                                        with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-nota
                then next.
                color display white/red tt-nota.flag tt-nota.rec
                                        tt-nota.fre
                                        tt-nota.val
                                        with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:

            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Selecionar "
                then do:

                    if tt-nota.flag = no 
                    then assign tt-nota.flag = yes. 
                    else assign tt-nota.flag = no.
                            
                    recatu1 = recid(tt-nota).
                    leave.
                    
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-nota).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    display tt-nota.flag column-label "*"
            help "[Enter] Seleciona as notas    [F4] Confirma "
            tt-nota.rec  column-label "Recencia"
            tt-nota.fre  column-label "Frequencia"
            tt-nota.val  column-label "Valor"
            with frame frame-a 11 down centered color white/red row 5
                            title " Notas " overlay.
end procedure.
procedure color-message.
    color display message
                  tt-nota.flag column-label "*"
                  tt-nota.rec  column-label "Recencia"
                  tt-nota.fre  column-label "Frequencia"
                  tt-nota.val  column-label "Valor"
                  with frame frame-a.
end procedure.
procedure color-normal.
    color display normal
                  tt-nota.flag column-label "*"
                  tt-nota.rec  column-label "Recencia"
                  tt-nota.fre  column-label "Frequencia"
                  tt-nota.val  column-label "Valor"
                  with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-nota where true
                                                no-lock no-error.
    else  
        find last tt-nota  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-nota  where true
                                                no-lock no-error.
    else  
        find prev tt-nota   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-nota where true  
                                        no-lock no-error.
    else   
        find next tt-nota where true 
                                        no-lock no-error.
        
end procedure.
         
