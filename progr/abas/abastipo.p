/*
*
*    abastipo.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 6
    initial [" Inclusao "," Alteracao "," Wms ", " Classes "," Condicoes",
    " Situacao "].

def buffer babastipo       for abastipo.
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
    else find abastipo where recid(abastipo) = recatu1 no-lock.
    if not available abastipo
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(abastipo).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available abastipo
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
            find abastipo where recid(abastipo) = recatu1 no-lock.
            def var vi as int.
            vi = 0.
            for each abastwms of abastipo no-lock .
                find abaswms of abastwms no-lock.
                display abastwms.abatipo
                        abastwms.wms
                        abastwms.catcod
                        abaswms.etbcd
                        abaswms.interface
                        abaswms.diretorio
                    with frame f-sub row 13 centered
                    no-underline
                    no-box down.
                vi = vi + 1.
                if vi = 3 then leave.
            end.
            pause 0.
            find last abastcla of abastipo no-lock no-error.
            if avail abastcla
            then disp abastcla 
                    with frame f-sub2 row 18 centered overlay
                        no-underline
                    title " CLASSES ".

            status default "".
            run color-message.
            choose field abastipo.abatipo help ""
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
                    if not avail abastipo
                    then leave.
                    recatu1 = recid(abastipo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail abastipo
                    then leave.
                    recatu1 = recid(abastipo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail abastipo
                then next.
                color display white/red abastipo.abatipo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail abastipo
                then next.
                color display white/red abastipo.abatipo with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form
                abastipo.abatipo   colon 17
                abastipo.abatnom  no-label
                with frame f-abastipo color black/cyan
                      centered side-label row 5.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
            hide frame frame-a no-pause.
            if esqcom1[esqpos1] = " Inclusao " or esqvazio
            then do with frame f-abastipo on error undo.
                create abastipo.
                update abastipo.
                recatu1 = recid(abastipo).
                leave.
            end.
            if esqcom1[esqpos1] = " Consulta " or
               esqcom1[esqpos1] = " Situacao " or
               esqcom1[esqpos1] = " Alteracao "
            then do with frame f-abastipo.
                disp abastipo.
            end.
            if esqcom1[esqpos1] = " Alteracao "
            then do with frame f-abastipo on error undo.
                find abastipo where recid(abastipo) = recatu1 exclusive.
                update abastipo.
            end.
            if esqcom1[esqpos1] = " WMS "
            then do:
                hide frame f-com1 no-pause.
                hide frame f-sub no-pause.
                hide frame f-sub2 no-pause.
                run abas/abastwms.p (recid(abastipo)).
                leave.
            end.

            if esqcom1[esqpos1] = " Condicoes "
            then do:
                hide frame f-com1 no-pause.
                hide frame f-sub no-pause.
                hide frame f-sub2 no-pause.
                run cadabastipocond.p (recid(abastipo)).
                leave.
            end.

            if esqcom1[esqpos1] = " Classes "
            then do:
                hide frame f-com1 no-pause.
                hide frame f-sub no-pause.
                hide frame f-sub2 no-pause.
                run abas/abastcla.p (recid(abastipo)).
                leave.
            end.
        end.
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(abastipo).
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

disp
  AbasTipo.AbaTipo
  AbasTipo.AbaTnom 
  AbasTipo.AbaTpri 
  AbasTipo.AbatCompra
  AbasTipo.PermiteIncManual
  AbasTipo.OrigemVenda 
  AbasTipo.TipoSugCompra
  AbasTipo.IniSit
           with frame frame-a 4 down centered color white/red row 5.
end procedure.


procedure color-message.
    color display message
        abastipo.abatipo
        abastipo.abatnom
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        abastipo.abatipo
        abastipo.abatnom
        with frame frame-a.
end procedure.


procedure leitura.

def input parameter par-tipo as char.

if par-tipo = "pri" 
then
    if esqascend
    then   find first abastipo use-index abastpri no-lock no-error.
    else   find last abastipo  where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then
    if esqascend
    then   find next abastipo  use-index abastpri no-lock no-error.
    else   find prev abastipo  where true no-lock no-error.
             
if par-tipo = "up" 
then
    if esqascend
    then   find prev abastipo use-index abastpri  no-lock no-error.
    else   find next abastipo where true  no-lock no-error.

end procedure.

