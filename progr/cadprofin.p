/*
*
*    profin.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 6
    initial [" Inclusao "," Alteracao "," Parametros ", " TFC "," Condicoes",
    " Situacao "].

def buffer bprofin       for profin.
def buffer seg-produ for produ.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find profin where recid(profin) = recatu1 no-lock.
    if not available profin
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(profin).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available profin
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
            find profin where recid(profin) = recatu1 no-lock.
            find last profinparam of profin no-lock no-error.
            if avail profinparam
            then disp profinparam except fincod dtinclu
                    with frame f-sub row 13 centered
                    title " Parametros ".
            pause 0.
            find last profintaxa of profin no-lock no-error.
            if avail profintaxa
            then disp profintaxa except fincod dtinclu
                    with frame f-sub2 row 18 centered overlay
                    title " TFC ".

            status default "".
            run color-message.
            choose field profin.fincod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
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
                    if not avail profin
                    then leave.
                    recatu1 = recid(profin).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail profin
                    then leave.
                    recatu1 = recid(profin).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail profin
                then next.
                color display white/red profin.fincod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail profin
                then next.
                color display white/red profin.fincod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form
                profin.fincod   colon 17
                profin.findesc  colon 45
                profin.procod   colon 17
                produ.pronom    no-label
                profin.modcod   colon 17
                modal.modnom    no-label
                profin.situacao colon 17
                profin.obrigadeposito colon 17
                profin.limite_token   colon 45
                profin.procod_seguro  colon 17
                seg-produ.pronom      no-label
                profin.dtinclu  colon 17
                with frame f-profin color black/cyan
                      centered side-label row 5.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
            hide frame frame-a no-pause.
            if esqcom1[esqpos1] = " Inclusao " or esqvazio
            then do with frame f-profin on error undo.
                create profin.
                update profin except dtinclu situacao.
                recatu1 = recid(profin).
                leave.
            end.
            if esqcom1[esqpos1] = " Consulta " or
               esqcom1[esqpos1] = " Situacao " or
               esqcom1[esqpos1] = " Alteracao "
            then do with frame f-profin.
                disp profin.
                find modal of profin no-lock no-error.
                find produ of profin no-lock no-error.
                find seg-produ where seg-produ.procod = profin.procod_seguro
                           no-lock no-error.
                disp
                    modal.modnom when avail modal
                    produ.pronom when avail produ
                    seg-produ.pronom when avail seg-produ.
            end.
            if esqcom1[esqpos1] = " Alteracao "
            then do with frame f-profin on error undo.
                find profin where recid(profin) = recatu1 exclusive.
                update profin except fincod dtinclu.
            end.
            if esqcom1[esqpos1] = " Situacao "
            then do on error undo.
                message "Confirma Alterar Situacao de" profin.findesc "?"
                        update sresp.
                if not sresp
                then undo, leave.
                find profin where recid(profin) = recatu1 exclusive.
                profin.situacao = not profin.situacao.
                leave.
            end.
            if esqcom1[esqpos1] = " Parametros "
            then do:
                hide frame f-com1 no-pause.
                hide frame f-sub no-pause.
                hide frame f-sub2 no-pause.
                run cadprofinpar.p (recid(profin)).
                leave.
            end.

            if esqcom1[esqpos1] = " Condicoes "
            then do:
                hide frame f-com1 no-pause.
                hide frame f-sub no-pause.
                hide frame f-sub2 no-pause.
                run cadprofincond.p (recid(profin)).
                leave.
            end.

            if esqcom1[esqpos1] = " TFC "
            then do:
                hide frame f-com1 no-pause.
                hide frame f-sub no-pause.
                hide frame f-sub2 no-pause.
                run cadprofintaxa.p (recid(profin)).
                leave.
            end.
        end.
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(profin).
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
hide frame f-sub2  no-pause.


procedure frame-a.
    display profin except procod dtinclu
           with frame frame-a 4 down centered color white/red row 5.
end procedure.


procedure color-message.
    color display message
        profin.fincod
        profin.findesc
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        profin.fincod
        profin.findesc
        with frame frame-a.
end procedure.


procedure leitura.

def input parameter par-tipo as char.

if par-tipo = "pri" 
then
    if esqascend
    then   find first profin where true no-lock no-error.
    else   find last profin  where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then
    if esqascend
    then   find next profin  where true no-lock no-error.
    else   find prev profin  where true no-lock no-error.
             
if par-tipo = "up" 
then
    if esqascend
    then   find prev profin where true  no-lock no-error.
    else   find next profin where true  no-lock no-error.

end procedure.

