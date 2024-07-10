/*
*
*    docrefer.p    -    Esqueleto de Programacao
*
*/
{admcab.i}

def input parameter par-rec as recid.

def buffer plani-produ     for plani.
def buffer plani-frete     for plani.

find plani-produ where recid(plani-produ) = par-rec no-lock.

pause 0.

display
    plani-produ.numero
    plani-produ.serie
    plani-produ.notsit no-label
    skip
    plani-produ.platot colon 15
    plani-produ.desaces label "Desp.Aces" skip
    with frame f-subcab color message side-labels width 80 no-box row 3
                                        overlay.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(14)" extent 5
    initial [" Consulta Nota"," "].

def buffer bdocrefer       for docrefer.

form
    esqcom1
    with frame f-com1
                 row 6 no-box no-labels side-labels column 1 centered.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find docrefer where recid(docrefer) = recatu1 no-lock.
    if not available docrefer
    then do.
        message "Sem associacoes" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(docrefer).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available docrefer
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find docrefer where recid(docrefer) = recatu1 no-lock.

            run color-message.
            choose field docrefer.numerodr help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

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
                    if not avail docrefer
                    then leave.
                    recatu1 = recid(docrefer).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail docrefer
                    then leave.
                    recatu1 = recid(docrefer).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail docrefer
                then next.
                color display white/red docrefer.numerodr with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail docrefer
                then next.
                color display white/red docrefer.numerodr with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form docrefer.etbcod
                 with frame f-docrefer color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Consulta Nota"
            then do:
                hide frame f-com1 no-pause.
                find first plani-frete
                              where plani-frete.etbcod = docrefer.etbcod
                                and plani-frete.emite  = int(docrefer.codrefer)
                                and plani-frete.serie  = docrefer.serierefer
                                and plani-frete.numero = int(docrefer.numerodr)
                              no-lock no-error.
                if avail plani-frete
                then run not_consnota.p (input recid(plani-frete)).
                view frame f-com1.
            end.

                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-docrefer.
                    disp docrefer.etbcod.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-docrefer on error undo.
                    find docrefer where recid(docrefer) = recatu1 exclusive.
                    update docrefer.etbcod.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" docrefer.numerodr
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next docrefer where true no-error.
                    if not available docrefer
                    then do:
                        find docrefer where recid(docrefer) = recatu1.
                        find prev docrefer where true no-error.
                    end.
                    recatu2 = if available docrefer
                              then recid(docrefer)
                              else ?.
                    find docrefer where recid(docrefer) = recatu1
                            exclusive.
                    delete docrefer.
                    recatu1 = recatu2.
                    leave.
                end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(docrefer).
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
    display
        docrefer.etbcod     column-label "Etb"
        docrefer.codrefer   column-label "Emite"  format "x(8)"
        docrefer.serierefer column-label "Serie"
        docrefer.numerodr   column-label "Numero" format ">>>>>>9"
        docrefer.datadr     column-label "Emissao"
        docrefer.tiporefer
        with frame frame-a 11 down centered color white/red row 7
            title " Notas Associadas ".
end procedure.

procedure color-message.
color display message
        docrefer.numerodr
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        docrefer.numerodr
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first docrefer where 
               docrefer.numori      = plani-produ.numero and
               docrefer.serieori    = plani-produ.serie  and
               docrefer.codedori    = plani-produ.emite  and
               docrefer.dtemiori    = plani-produ.pladat
                                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next docrefer  where
               docrefer.numori      = plani-produ.numero and
               docrefer.serieori    = plani-produ.serie  and
               docrefer.codedori    = plani-produ.emite  and
               docrefer.dtemiori    = plani-produ.pladat
                                                no-lock no-error.
             
if par-tipo = "up" 
then find prev docrefer where
               docrefer.numori      = plani-produ.numero and
               docrefer.serieori    = plani-produ.serie  and
               docrefer.codedori    = plani-produ.emite  and
               docrefer.dtemiori    = plani-produ.pladat
                                        no-lock no-error.
        
end procedure.
