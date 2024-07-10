/*
*
*    zprodu2.p  -    Esqueleto de Programacao
*    TP 24703362
*/
/*
{zoomprod.i produ procod pronom 60 Produtos true}
*/

def var vcampo as char format "x(50)".
def var vrec as recid.
def var vletra as char.
def var recatu1         as recid.
def var reccont         as int.

form
    vcampo
    with frame fcampo col 20 no-label OVERLAY
                 row 5 title color white/black " ZOOM " color black/CYAN.

bl-princ:
repeat:
    if recatu1 = ?
    then run leitura (input "pri").
    else find produ where recid(produ) = recatu1 no-lock.
    if not available produ
    then leave.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(produ).
    repeat:
        run leitura (input "seg").
        if not available produ
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find produ where recid(produ) = recatu1 no-lock.

        color display message
            produ.pronom
            produ.procod
            with frame frame-a.

        disp vcampo with frame fcampo.

        choose field produ.pronom help ""
            go-on(cursor-down cursor-up
                  PF4 F4 ESC return backspace
                  1 2 3 4 5 6 7 8 9 0 " "
                  a b c d e f g h i j k l m n o p q r s t u v x z w y "*"
                  A B C D E F G H I J K L M N O P Q R S T U V X Z W Y "."
                  page-down   page-up).

        color display normal
            produ.pronom
            produ.procod
            with frame frame-a.

        status default "".

        vletra = keyfunction(lastkey).
        if length(vletra) = 1 or
           keyfunction(lastkey) = "BACKSPACE"
        then do:
            if keyfunction(lastkey) = "backspace"
            then do:
                vcampo = substring(vcampo,1,length(vcampo) - 1).
                run campo.
                leave.
            end.
            if (vletra >= "a" and vletra <= "z") or
               (vletra >= "0" and vletra <= "9") or
               vletra = " " or
               vletra = "." or
               vletra = "*"
            then do:
                vcampo = vcampo + vletra.
                run campo.
                leave.
            end.
            else vcampo = "".
        end.
        else vcampo = "".
        pause 0.
        disp vcampo with frame fcampo.
            
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail produ
                    then leave.
                    recatu1 = recid(produ).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail produ
                    then leave.
                    recatu1 = recid(produ).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail produ
                then next.
                color display white/red produ.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail produ
                then next.
                color display white/red produ.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            frame-value = string(produ.procod).
            leave bl-princ.
        end.
        run frame-a.
        recatu1 = recid(produ).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame frame-a no-pause.
hide frame fcampo no-pause.


procedure frame-a.
    display
        produ.pronom format "x(52)"
        produ.procod format ">>>>>>99"
        with frame frame-a 11 down column 15 color white/red row 8 no-label
            title " Produtos " OVERLAY.
end procedure.


procedure leitura.
def input parameter par-tipo as char.

if par-tipo = "busca"
then do:
    find first produ use-index ipronom where
                        produ.pronom begins vcampo no-lock no-error.
    vrec = recid(produ).
end.
else do.        
    if par-tipo = "pri" 
    then find first produ where true use-index ipronom no-lock no-error.
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then find next produ  where true use-index ipronom no-lock no-error.
             
    if par-tipo = "up" 
    then find prev produ where true use-index ipronom no-lock no-error.
end.

end procedure.


procedure campo.

    pause 0.
    disp vcampo with frame fcampo.
    vrec = ?.
    run leitura ("BUSCA").
    if vrec <> ?
    then recatu1 = vrec.
end procedure.

