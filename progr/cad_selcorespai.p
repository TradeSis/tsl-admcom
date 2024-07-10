/* selcores.p     */
/* selecao de cores que um produto pode utilizar                            */
{admcab.i}  

def input parameter par-itecod   like produpai.itecod.
def input parameter par-modpcod  like modpack.modpcod.
    
def shared temp-table ttcores
    field corcod   like cor.corcod
    field corseq   as int

    index cor   is primary unique corcod
    index seq   corseq.

def buffer bttcores for ttcores.

def var vgrade as char.

for each ttcores.
    delete ttcores.
end.

find modpack where modpack.modpcod = par-modpcod no-lock.

for each produ where produ.itecod = par-itecod no-lock.
    find cor of produ no-lock no-error.
    if not avail cor or cor.situacao = no
    then next.
    find ttcores of produ no-error.
    if not avail ttcores
    then do.
        create ttcores.
        ttcores.corcod = produ.corcod.
    end.
end.        

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Marca "," Desmarca "," "].

form
    esqcom1
    with frame f-com1
                 row 8 no-box no-labels side-labels column 1 centered.

assign
    esqpos1  = 1.

pause 0.
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find ttcores where recid(ttcores) = recatu1 no-lock.
    if not available ttcores
    then do.
        message "Nenhuma COR disponivel para o produto PAI"
                view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(ttcores).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttcores
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:
            find ttcores where recid(ttcores) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field ttcores.corcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
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
                    if not avail ttcores
                    then leave.
                    recatu1 = recid(ttcores).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttcores
                    then leave.
                    recatu1 = recid(ttcores).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttcores
                then next.
                color display white/red ttcores.corcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttcores
                then next.
                color display white/red ttcores.corcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Marca "
            then do on error undo.
                find last bttcores use-index seq no-error.
                if bttcores.corseq = modpack.cores
                then do.
                    message "Limite de cores do modelo atingido"
                            view-as alert-box.
                    next.
                end.
                ttcores.corseq = bttcores.corseq + 1.
            end.
            if esqcom1[esqpos1] = " DesMarca "
            then do on error undo.
                for each bttcores where bttcores.corseq > ttcores.corseq.
                    bttcores.corseq = bttcores.corseq - 1.
                end.
                ttcores.corseq = 0.
                leave.
            end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttcores).
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
    vgrade = "".
    if ttcores.corseq > 0
    then
        for each modpackcortam of modpack
                               where modpackcortam.cor = ttcores.corseq
                               no-lock,
           taman of modpackcortam no-lock
           break by taman.pos.
            vgrade = vgrade + modpackcortam.tamcod + "=" + 
                     string(modpackcortam.qtd) + " ".
        end.

    find cor of ttcores no-lock.
    display
        ttcores.corseq format "9" column-label "Seq" when ttcores.corseq > 0
        ttcores.corcod
        cor.cornom
        cor.pantone
        vgrade         format "x(32)" column-label "Grade"
        with frame frame-a 7 down  color white/red row 9
            title " Cores do produto PAI ".

end procedure.

procedure color-message.
color display message
        ttcores.corcod
        cor.cornom
        cor.pantone
        ttcores.corseq
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        ttcores.corcod
        cor.cornom
        cor.pantone
        ttcores.corseq
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first ttcores  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next ttcores   no-lock no-error.
             
if par-tipo = "up" 
then find prev ttcores   no-lock no-error.
        
end procedure.
