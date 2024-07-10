/* Projeto MDF-e - marco/2017
*
*    valepedagio.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-placa like veiculo.placa.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Situacao "," Consulta "," "].
def var esqcom2         as char format "x(14)" extent 5
            initial [" Vale Pedagio "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de valepedagio ",
             " Alteracao da valepedagio ",
             " Situacao  da valepedagio ",
             " Consulta  da valepedagio ",
             ""].
def var esqhel2         as char format "x(12)" extent 5.

def buffer bvalepedagio       for valepedagio.

form
    esqcom1
    with frame f-com1
                 row 6 no-box no-labels side-labels column 1 centered.
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
        find valepedagio where recid(valepedagio) = recatu1 no-lock.
    if not available valepedagio
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(valepedagio).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available valepedagio
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
            find valepedagio where recid(valepedagio) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(valepedagio.placa)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(cnpj_fornecedor)
                                        else "".
            run color-message.
            choose field valepedagio.placa help ""
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
                    if not avail valepedagio
                    then leave.
                    recatu1 = recid(valepedagio).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail valepedagio
                    then leave.
                    recatu1 = recid(valepedagio).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail valepedagio
                then next.
                color display white/red valepedagio.cnpj_fornecedor with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail valepedagio
                then next.
                color display white/red valepedagio.cnpj_fornecedor with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form valepedagio
                 with frame f-valepedagio color black/cyan
                      centered side-label row 7 1 col.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-valepedagio on error undo.
                    create valepedagio.
                    valepedagio.placa = par-placa.
                    disp valepedagio.placa.
                    update valepedagio except placa situacao.
                    recatu1 = recid(valepedagio).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Situacao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-valepedagio.
                    disp valepedagio.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-valepedagio on error undo.
                    find valepedagio where recid(valepedagio) = recatu1
                         exclusive.
                    update valepedagio except placa.
                end.

                if esqcom1[esqpos1] = " Situacao "
                then do on error undo.
                    message "Confirma Alteracao de Situacao de"
                        valepedagio.cnpj_fornecedor "?"
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find valepedagio where recid(valepedagio) = recatu1
                            exclusive.
                    valepedagio.situacao = not valepedagio.situacao.
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
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
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
        recatu1 = recid(valepedagio).
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
    display valepedagio 
        with frame frame-a 11 down centered color white/red row 7.
end procedure.


procedure color-message.
color display message
        valepedagio.placa
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        valepedagio.placa
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend
    then find first valepedagio where valepedagio.placa = par-placa
                                                no-lock no-error.
    else find last valepedagio  where valepedagio.placa = par-placa
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend
    then find next valepedagio  where valepedagio.placa = par-placa
                                                no-lock no-error.
    else find prev valepedagio  where valepedagio.placa = par-placa
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend
    then find prev valepedagio where valepedagio.placa = par-placa  
                                        no-lock no-error.
    else find next valepedagio where valepedagio.placa = par-placa 
                                        no-lock no-error.
        
end procedure.
         
