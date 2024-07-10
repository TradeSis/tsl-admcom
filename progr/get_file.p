def input param par-dir as char.
def input param par-ext as char CASE-SENSITIVE.
def output param par-arq as char.

def temp-table tt-arqs no-undo
    field arquivos as char format "x(75)"
    index arquivo is unique primary arquivos asc.

for each tt-arqs.
    delete tt-arqs.
end.

pause 0.
DEFINE VARIABLE cFileStream AS CHARACTER NO-UNDO.

INPUT FROM OS-DIR (par-dir).
REPEAT:
    IMPORT cFileStream. 
    FILE-INFO:FILE-NAME = par-dir + cFileStream.
    if entry(num-entries(cFileStream,"."),cFileStream,".") <> par-ext
    then next.
    
    if num-entries(cfilestream,"_") >= 2 then if entry(2,cfilestream,"_") = "RESULTADO" then next.
    
    create tt-arqs.
    tt-arqs.arquivos = FILE-INFO:FULL-PATHNAME.
    /*
            DISPLAY cFileStream FORMAT "X(18)" LABEL 'name of the file'
                        FILE-INFO:FULL-PATHNAME FORMAT "X(21)" LABEL 'FULL-PATHNAME'
                                    FILE-INFO:PATHNAME FORMAT "X(21)" LABEL 'PATHNAME'
                                                FILE-INFO:FILE-TYPE FORMAT "X(5)" LABEL 'FILE-TYPE'.
                                                */
                                                END.
input close.

/*

*/

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["Seleciona","" ,"",""].


form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered
        overlay.
assign
    esqpos1  = 1.

find first tt-arqs no-error.
if not avail tt-arqs 
then return.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-arqs where recid(tt-arqs) = recatu1 no-lock.
    if not available tt-arqs
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(tt-arqs).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-arqs
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find tt-arqs where recid(tt-arqs) = recatu1 no-lock.


            status default "".

            choose field tt-arqs.arquivos help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).

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
                    if not avail tt-arqs
                    then leave.
                    recatu1 = recid(tt-arqs).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-arqs
                    then leave.
                    recatu1 = recid(tt-arqs).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-arqs
                then next.
                color display white/red tt-arqs.arquivos with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-arqs
                then next.
                color display white/red tt-arqs.arquivos with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = "Seleciona "
            then do:
                par-arq = tt-arqs.arquivos.
                leave bl-princ.
            end.
        end.
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-arqs).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-sub   no-pause.

procedure frame-a.
    display
        tt-arqs.arquivos
        with frame frame-a 12 down centered color white/red row 6 no-box
            overlay.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-arqs 
                                no-lock no-error.
    else  
        find last tt-arqs 
                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-arqs  
                                no-lock no-error.
    else  
        find prev tt-arqs  
                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-arqs  
                                        no-lock no-error.
    else   
        find next tt-arqs 
                                        no-lock no-error.
end procedure.


