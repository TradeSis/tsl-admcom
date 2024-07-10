/*
*
*    Gru_cores.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

form
    gcorestacao.temp-cod
    with frame freee 12 down column 47 color white/red row 5.

form
    gcorfabri.fabcod
    with frame freee2 12 down column 59 color white/red row 5.

form
    gcorclasse.clacod column-label "Grupo"
    with frame freee3 12 down column 68 color white/red row 5.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao ","  "," Consulta "," "].
def var esqcom2         as char format "x(12)" extent 5
    initial [" Cores ", " Temporadas "," Fabricantes "," Grupos ",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

def buffer bGru_cores       for Gru_cores.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels column 1 centered.
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
        find Gru_cores where recid(Gru_cores) = recatu1 no-lock.
    if not available Gru_cores
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(Gru_cores).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available Gru_cores
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
            find Gru_cores where recid(Gru_cores) = recatu1 no-lock.

            clear frame freee  all no-pause.
            clear frame freee2 all no-pause.
            clear frame freee3 all no-pause.
            for each gcorestacao of gru_cores no-lock.
                display gcorestacao.temp-cod with frame freee.
                down with frame freee.                    
                pause 0.                    
            end.
            for each gcorfabri of gru_cores no-lock.
                disp gcorfabri.fabcod with frame freee2.
                down with frame freee2.
            end.
            for each gcorclasse of gru_cores no-lock.
                display gcorclasse.clacod with frame freee3.
                down with frame freee3.                    
                pause 0.
            end.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(Gru_cores.GruCCod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(Gru_cores.GruCCod)
                                        else "".
            run color-message.
            choose field Gru_cores.GruCCod help ""
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
                    if not avail Gru_cores
                    then leave.
                    recatu1 = recid(Gru_cores).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail Gru_cores
                    then leave.
                    recatu1 = recid(Gru_cores).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail Gru_cores
                then next.
                color display white/red Gru_cores.GruCCod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail Gru_cores
                then next.
                color display white/red Gru_cores.GruCCod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form Gru_cores
                 with frame f-Gru_cores color black/cyan
                      centered side-label row 5 1 col.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-Gru_cores on error undo.
                    find last bGru_cores no-lock no-error.
                    create Gru_cores.
                    Gru_cores.gruccod = if avail bGru_cores
                                        then bGru_cores.gruccod + 1
                                        else 1.
                    disp Gru_cores.gruccod. 
                    update Gru_cores except Gru_cores.gruccod.
                    Gru_cores.grucnom = caps(Gru_cores.grucnom).
                    recatu1 = recid(Gru_cores).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-Gru_cores.
                    disp Gru_cores.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-Gru_cores on error undo.
                    find Gru_cores where recid(Gru_cores) = recatu1 exclusive.
                    update Gru_cores except Gru_cores.gruccod.
                    Gru_cores.grucnom = caps(Gru_cores.grucnom).
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do on error undo.
                    message "Confirma Exclusao de" Gru_cores.GruCCod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next Gru_cores where true no-error.
                    if not available Gru_cores
                    then do:
                        find Gru_cores where recid(Gru_cores) = recatu1.
                        find prev Gru_cores where true no-error.
                    end.
                    recatu2 = if available Gru_cores
                              then recid(Gru_cores)
                              else ?.
                    find Gru_cores where recid(Gru_cores) = recatu1
                            exclusive.
                    delete Gru_cores.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                hide frame f-com1  no-pause.
                hide frame f-com2  no-pause.
                if esqcom2[esqpos2] = " Cores "
                then run cad_gcorcores.p (input recid(Gru_cores)). 
                if esqcom2[esqpos2] = " Temporadas "
                then run cad_gcorestacao.p (input recid(Gru_cores)). 
                if esqcom2[esqpos2] = " Fabricantes "
                then run cad_gcorfabri.p (input recid(Gru_cores)). 
                if esqcom2[esqpos2] = " Grupos "
                then run cad_gcorgrupo.p (input recid(Gru_cores)). 
                view frame f-com1.
                view frame f-com2.
                leave.
            end.
        end.
        if not esqvazio
        then run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(Gru_cores).
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
    display
        Gru_cores.gruccod
        Gru_cores.grucnom
        Gru_cores.situacao column-label "Situac"
        with frame frame-a 12 down /*centered*/ color white/red row 5.
end procedure.


procedure color-message.
    color display message
        Gru_cores.GruCCod
        Gru_cores.grucnom
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        Gru_cores.GruCCod
        Gru_cores.grucnom
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
        find first Gru_cores where true
                                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
        find next Gru_cores  where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
        find prev Gru_cores where true  
                                        no-lock no-error.
        
end procedure.
         
