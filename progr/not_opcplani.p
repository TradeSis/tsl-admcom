{admcab.i}

def input parameter par-rec as recid.

find plani where recid(plani) = par-rec no-lock.
find tipmov of plani no-lock.

def var i       as int.
def temp-table ttopc
    field titulo    as char format "x(50)"
    field programa  as char format "x(20)"
    index tt is primary unique titulo asc.

find first planiaux where planiaux.movtdc = plani.movtdc
                      and planiaux.etbcod = plani.etbcod
                      and planiaux.placod = plani.placod
                    no-lock no-error.
if avail planiaux
then do.
    i = i + 1.
    create ttopc.
    ttopc.titulo = string(i, "9") + ".Dados.Adicionais".
    ttopc.programa = "not_planidad.p".
end.

/*
*
*    ttopc.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var recatu1         as recid.
def var reccont         as int.

bl-princ:
repeat:
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttopc where recid(ttopc) = recatu1 no-lock.
    if not available ttopc
    then do.
        message "Sem opcoes disponiveis" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttopc).
    repeat:
        run leitura (input "seg").
        if not available ttopc
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find ttopc where recid(ttopc) = recatu1 no-lock.

            status default "".

            choose field ttopc.titulo help ""
                go-on(cursor-down cursor-up
                      PF4 F4 ESC return) .

            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttopc
                then next.
                color display white/red ttopc.titulo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttopc
                then next.
                color display white/red ttopc.titulo with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            pause 0.
            if substr(ttopc.programa, length(ttopc.programa) - 1, 2) = ".p"
            then do.
                if search(ttopc.programa) <> ?
                then run value(ttopc.programa) (input recid(plani)).
                else message ttopc.programa "nao encontrado" view-as alert-box.
            end.
            else run value(ttopc.programa).
            leave bl-princ.
        end.
        run frame-a.
        recatu1 = recid(ttopc).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame frame-a no-pause.

procedure frame-a.
display ttopc.titulo
        with frame frame-a 11 down centered color white/red row 5 no-label.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then   find first ttopc where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then   find next ttopc  where true no-lock no-error.
             
if par-tipo = "up" 
then   find prev ttopc where true   no-lock no-error.
        
end procedure.
         
