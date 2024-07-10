/*
*
*    tt-estab.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-box like tab_box.box.

def shared temp-table tt-box no-undo
    field box    like tab_box.box
    field listaEtb as char format "x(60)"
    field sel    as log format "*/"
    index tt-estab is unique primary box asc.

def shared temp-table tt-estab no-undo
    field box       like tab_box.box
    field etbcod    like estab.etbcod
    field Ordem     as int
    field sim       as log format "*/"
    index idx is unique primary sim desc etbcod asc
    index idx2 is unique box asc etbcod asc.
    
form    
    tt-estab.sim format "*/" column-label "*"
    tt-estab.etbcod
    estab.etbnom format "x(28)"
    tt-estab.ordem column-label "OR" format ">>"
    with frame frame-a  down column 40 color white/red row 5.


def var vct as int.
find tt-box where tt-box.box = par-box no-lock.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(38)" extent 2
    initial [" "," Marca Filial"].

def buffer btt-estab       for tt-estab.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.

assign
    esqregua = yes
    esqpos1  = 2.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-estab where recid(tt-estab) = recatu1 no-lock.
    if not available tt-estab
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-estab).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-estab
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
            find tt-estab where recid(tt-estab) = recatu1 no-lock.
            find estab where estab.etbcod = tt-estab.etbcod no-lock.

            status default "".

            run color-message.
            choose field estab.etbnom help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            run color-normal.
            status default "".

        end.
            /*
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 2 then 2 else esqpos1 + 1.
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
            */
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-estab
                    then leave.
                    recatu1 = recid(tt-estab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-estab
                    then leave.
                    recatu1 = recid(tt-estab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-estab
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-estab
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error" or
          keyfunction(lastkey) = "cursor-left"

        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-estab
                 with frame f-tt-estab color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " marca filial "
                then do with frame frame-a on error undo.
                    find tt-estab where recid(tt-estab) = recatu1 exclusive.
                    tt-estab.sim = not tt-estab.sim.
                end.
                do on error undo.
                    find current tt-box exclusive.
                    find first tt-estab of tt-box
                            where tt-estab.sim = yes
                            no-error.
                    if not avail tt-estab
                    then tt-box.sel = no. 
                    else tt-box.sel = yes.
                    find current tt-box no-lock.
                    find tt-estab where recid(tt-estab) = recatu1 no-lock.
                end.
                          
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-estab).
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
    find estab where estab.etbcod = tt-estab.etbcod no-lock.

 display
    tt-estab.sim 
    tt-estab.etbcod
    estab.etbnom 
    tt-estab.ordem 
    with frame frame-a.

end procedure.

procedure color-message.
    color display message
        tt-estab.sim 
    tt-estab.etbcod
    estab.etbnom 
    tt-estab.ordem 
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
        tt-estab.sim 
    tt-estab.etbcod
    estab.etbnom 
    tt-estab.ordem 

        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-estab of tt-box  no-lock no-error.
    else  
        find last tt-estab  of tt-box  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-estab  of tt-box  no-lock no-error.
    else  
        find prev tt-estab   of tt-box  no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-estab of tt-box    no-lock no-error.
    else   
        find next tt-estab of tt-box   no-lock no-error.
        
end procedure.
