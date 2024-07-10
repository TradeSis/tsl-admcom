{admcab.i}

def output param pstatus as log.

{seg/defhubperfildin.i}

FUNCTION acha2 returns character
    (input par-oque as char, 
    input par-onde as char).   
    def var vx as int. 
    def var vret as char. 
    vret = ?. 
    do vx = 1 to num-entries(par-onde,"|"). 
        
        if num-entries( entry(vx,par-onde,"|"),"#") = 2 and 
           entry(1,entry(vx,par-onde,"|"),"#") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"#"). 
            leave. 
        end. 
     end. 
     return vret. 
END FUNCTION.


run api/segbuscaprodutos.p .


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Seleciona",""].
def var esqcom2         as char format "x(12)" extent 5.


form
    esqcom1
    with frame f-com1
                 row 5 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels column 1 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

    form
        skip(1)
        ttsegprodu.procod
        ttsegprodu.pronom
        ttsegprodu.idseguro
            with frame frame-a 5 down centered row 7 no-box
            no-labels.


bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttsegprodu where recid(ttsegprodu) = recatu1 no-lock.

    if not available ttsegprodu
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(ttsegprodu).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttsegprodu
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
            find ttsegprodu where recid(ttsegprodu) = recatu1 no-lock.

            status default
                "Selecione o Seguro".
                
            run color-message.
            choose field
                    ttsegprodu.procod
                    help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) /*color white/black*/ .
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
                    if not avail ttsegprodu
                    then leave.
                    recatu1 = recid(ttsegprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttsegprodu
                    then leave.
                    recatu1 = recid(ttsegprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttsegprodu
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttsegprodu
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" 
        then do:                      
            
            run api/segbuscaseguro.p (input   ttsegprodu.idseguro,
                                      output  pstatus).
                                       
            if pstatus = yes
            then  do: 
                pprocod = ttsegprodu.procod. 
                leave bl-princ.
            end.            
            message "Seguro " ttsegprodu.idseguro pronom
                "Nao esta ativo no HUB"
                view-as alert-box.
        
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(ttsegprodu).
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

    display ttsegprodu.procod
            ttsegprodu.pronom
            ttsegprodu.idseguro
            with frame frame-a.
            
end procedure.
procedure color-message.
    color display message
            ttsegprodu.procod
            ttsegprodu.pronom
            ttsegprodu.idseguro

            with frame frame-a.
end procedure.

procedure color-normal.

    color display normal
            ttsegprodu.procod
            ttsegprodu.pronom
            ttsegprodu.idseguro
            with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
    if par-tipo = "pri" 
    then  
        if esqascend  
        then      
            find first ttsegprodu where
                       no-lock no-error.
        else  
            find last ttsegprodu  where
                      no-lock no-error.
    if par-tipo = "seg" or par-tipo = "down" 
    then      
        if esqascend  
        then  
            find next ttsegprodu  where
                      no-lock no-error.
        else  
            find prev ttsegprodu  where
                      no-lock no-error.
    if par-tipo = "up" 
    then                  
        if esqascend   
        then   
            find prev ttsegprodu  where
                      no-lock no-error.
        else   
            find next ttsegprodu  where 
                  no-lock no-error.

 
end procedure.
         


