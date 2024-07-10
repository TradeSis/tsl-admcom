/*
*
*    tt-box.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var vconta as int.
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
        tt-box.sel format "*/" column-label "*"
        tt-box.box
        tt-box.listaETB format "x(40)"
        with frame frame-a 12 down color white/red row 5.
 
form
    tt-estab.sim format "*/" column-label "*"
    tt-estab.etbcod
    estab.etbnom format "x(28)"
    tt-estab.ordem column-label "OR" format ">>"
    with frame freee 12 down column 40 color white/red row 5.


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(38)" extent 2
    initial [" Marca Box "," Marca Filial "].
def var esqcom2         as char format "x(12)" extent 5
    initial [" "," "," ","",""].
def var esqhel1         as char format "x(80)" extent 2
    initial [" F4 - Continua",
             ""].
def var esqhel2         as char format "x(12)" extent 5.

def buffer btt-box       for tt-box.

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

    for each tt-box.
        listaETB = "".
        for each tab_box where tab_box.box = tt-box.box no-lock.
            listaETB = listaETB + 
                (if listaETB = ""
                then ""
                 else ",") + string(tab_box.etbcod).
        end.            
    end.    

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-box where recid(tt-box) = recatu1 no-lock.
    if not available tt-box
    then do.
        esqvazio = yes.
        if sretorno = "ZOOM"
        then do.
            message "Cadastro de tt-box Vazio" view-as alert-box.
            leave.
        end.
    end.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-box).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-box
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
            find tt-box where recid(tt-box) = recatu1 no-lock.

            clear frame freee  all no-pause.
            vconta = 0.
            for each tt-estab of tt-box no-lock.
                pause 0.
                find estab where estab.etbcod = tt-estab.etbcod no-lock.
                display 
                    tt-estab.sim
                    tt-estab.etbcod
                    estab.etbnom
                    tt-estab.ordem
                    with frame freee.
                vconta = vconta + 1.
                if vconta = 12
                then leave.
                down with frame freee.                    
            end.
            if tt-box.sel = no
            then do:
                esqcom1[1] = " Marca Box".
                esqcom1[2] = "".
            end.    
            if tt-box.sel
            then do:
                esqcom1[1] = " Desmarca Box".
                esqcom1[2] = " Marca Filial".
            end.

            display esqcom1 with frame f-com1.
            display esqcom2 with frame f-com2.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-box.listaETB)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-box.listaETB)
                                        else "".
            run color-message.
            choose field tt-box.box help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
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
                    esqpos1 = if esqpos1 = 2 then 2 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                    next.
                end.
                /*
                next.
                */
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
                    if not avail tt-box
                    then leave.
                    recatu1 = recid(tt-box).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-box
                    then leave.
                    recatu1 = recid(tt-box).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-box
                then next.
                color display white/red tt-box.box with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-box
                then next.
                color display white/red tt-box.box with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if  keyfunction(lastkey) = "cursor-right" or
            keyfunction(lastkey) = "return" or 
            esqvazio
        then do:
            form tt-box
                 with frame f-tt-box color black/cyan
                      centered side-label row 5 1 col.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " marca box " or
                   esqcom1[esqpos1] = " desmarca box " 
                then do on error undo.
                    tt-box.sel = not tt-box.sel.
                    for each tt-estab of tt-box.
                        tt-estab.sim = tt-box.sel.
                    end.
                end. 
                
                if esqcom1[esqpos1] = " Marca Filial"
                then do on error undo:
                    pause 0.
                    run abas/selestab.p (tt-box.box).
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.

            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                if esqcom2[esqpos2] = " Tamanhos " 
                then do .
                    run cad_tt-estab.p (input tt-box.box).  
                end.
                if esqcom2[esqpos2] = " Grupos " 
                then do .
                    hide frame frame-a no-pause.
                    run cad_graclasse.p (input recid(tt-box)).
                end.
                if esqcom2[esqpos2] = " Fabricantes " 
                then do .
                    hide frame frame-a no-pause.
                    run cad_grafabri.p (input recid(tt-box)).
                end.
                view frame f-com1.
                view frame f-com2.

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
        recatu1 = recid(tt-box).
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
hide frame freee no-pause.

procedure frame-a.

    display
        tt-box.sel format "*/"
        tt-box.box
        tt-box.listaETB format "x(30)"
        with frame frame-a 12 down color white/red row 5.
end procedure.


procedure color-message.
color display message
        tt-box.box
        tt-box.listaETB
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        tt-box.box
        tt-box.listaETB
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then   find first tt-box 
                                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then   find next tt-box  
                                                no-lock no-error.
             
if par-tipo = "up" 
then   find prev tt-box 
                                        no-lock no-error.
        
end procedure.

         
