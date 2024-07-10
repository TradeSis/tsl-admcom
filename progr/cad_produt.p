/*
*
*    categoria.p    -    Esqueleto de Programacao
*
*/
{admcab.i}

def var recatu1    as recid.

bl-princ:
repeat:
    if recatu1 = ?
    then run leitura (input "pri").
    else find categoria where recid(categoria) = recatu1 no-lock.
    if not available categoria
    then leave.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(categoria).
    repeat:
        run leitura (input "seg").
        if not available categoria
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find categoria where recid(categoria) = recatu1 no-lock.

        status default "".

        color display message
                categoria.catcod
                categoria.catnom
                with frame frame-a.

        choose field categoria.catcod help "ENTER=Produtos  F4=Retorna"
                go-on(cursor-down cursor-up
                      PF4 F4 ESC return).
        color display normal
                categoria.catcod
                categoria.catnom
                with frame frame-a.

        if keyfunction(lastkey) = "cursor-down"
        then do:
            run leitura (input "down").
            if not avail categoria
            then next.
            color display white/red categoria.catcod with frame frame-a.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            run leitura (input "up").
            if not avail categoria
            then next.
            color display white/red categoria.catcod with frame frame-a.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause.
            /***if categoria.catcod = 41
            then run cad_produpai.p (input categoria.catcod).
            else***/ run cad_produ.p (input categoria.catcod).
        end.
        run frame-a.
        recatu1 = recid(categoria).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame frame-a no-pause.

procedure frame-a.
display categoria.catcod
        categoria.catnom
        with frame frame-a 11 down centered color white/red row 9 no-label
            title " CATEGORIA ".
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first categoria where categoria.situacao no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next categoria  where categoria.situacao no-lock no-error.
             
if par-tipo = "up" 
then find prev categoria where categoria.situacao  no-lock no-error.
        
end procedure.

