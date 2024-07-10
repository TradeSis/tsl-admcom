/* selcores.p     */
/* selecao de cores que um produto pode utilizar                            */
/*  gcorclasse gcorestacao gcorfabri                                        */
{admcab.i}  

def input parameter par-fabcod   like produ.fabcod.
def input parameter par-clacod   like produ.clacod.
def input parameter par-temp-cod like produ.temp-cod.
def input parameter par-itecod   like produpai.itecod.

def temp-table ttgru_cores
    field GruCCod    like gru_cores.GruCCod
    index ttgru_coress is primary unique GruCCod.
    
def shared temp-table ttcores
    field corcod   like cor.corcod
    field marc     as log init no
    field perm     as log

    index cor   is primary unique corcod.

for each ttcores.
    delete ttcores.
end.

def buffer sclase for clase.    
def buffer nivel2 for clase.
def buffer nivel1 for clase.

for each ttgru_cores.
    delete ttgru_cores.
end.
 
    for each gcorfabri where gcorfabri.fabcod = par-fabcod
                         and gcorfabri.situacao no-lock.
        find ttgru_cores where 
                    ttgru_cores.GruCCod = gcorfabri.GruCCod no-error .
        if not avail ttgru_cores
        then create ttgru_cores.
        ttgru_cores.GruCCod = gcorfabri.GruCCod.
    end.
    
    for each gcorestacao where gcorestacao.temp-cod = par-temp-cod
                           and gcorestacao.situacao no-lock.
        find ttgru_cores where 
                    ttgru_cores.GruCCod = gcorestacao.GruCCod no-error .
        if not avail ttgru_cores
        then create ttgru_cores.
        ttgru_cores.GruCCod = gcorestacao.GruCCod.
    end.
 
    find sclase where sclase.clacod = par-clacod no-lock no-error. 
    if avail sclase 
    then do.
        find clase where clase.clacod = sclase.clasup no-lock. 
        find nivel2 where nivel2.clacod = clase.clasup no-lock. 
        find nivel1 where nivel1.clacod = nivel2.clasup no-lock.

        for each gcorclasse of nivel2 where gcorclasse.situacao no-lock.
            find ttgru_cores where 
                    ttgru_cores.GruCCod = gcorclasse.GruCCod no-error .
            if not avail ttgru_cores
            then create ttgru_cores.
            ttgru_cores.GruCCod = gcorclasse.GruCCod.
        end.
    end.

    for each ttgru_cores.
        find gru_cores of ttgru_cores no-lock no-error.
        if not avail gru_cores or
           gru_cores.situacao = no
        then delete ttgru_cores.
    end.

    find first ttgru_cores no-lock no-error.
    if not avail ttgru_cores
    then do.
        message "Nenhuma COR disponivel para o produto PAI"
                view-as alert-box.
        leave.
    end.
    
    for each ttgru_cores.
        for each gcorcores of ttgru_cores no-lock.
            find cor of gcorcores no-lock no-error.
            if not avail cor or
               cor.situacao = no
            then next.

            find ttcores where ttcores.cor = gcorcores.cor no-error.
            if not avail ttcores
            then create ttcores.

            assign ttcores.cor  = gcorcores.cor
                   ttcores.marc = no
                   ttcores.perm = yes.
            find first produ where produ.itecod = par-itecod
                               and produ.corcod = ttcores.corcod
                             no-lock no-error.
            if avail produ
            then assign ttcores.marc = yes
                        ttcores.perm = no.
        end.
    end.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Marca "," "].

form
    esqcom1
    with frame f-com1
                 row 7 no-box no-labels side-labels column 1 centered.

assign
    esqpos1  = 1.

form    ttcores.marc format "*/" no-label
        ttcores.cor
        cor.cornom
        with frame frame-a.

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
            choose field ttcores.cor help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                      PF4 F4 ESC return).
            run color-normal.
            status default "".

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
                color display white/red ttcores.cor with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttcores
                then next.
                color display white/red ttcores.cor with frame frame-a.
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

                if esqcom1[esqpos1] = " Marca " and 
                   ttcores.perm
                then do with frame frame-a on error undo.
                    ttcores.marc = not ttcores.marc.
                    recatu1 = recid(ttcores).
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
find cor of ttcores no-lock.
display ttcores.marc format "*/" no-label
        ttcores.cor
        cor.cornom
        cor.pantone
        with frame frame-a 7 down  color white/red row 8.
end procedure.

procedure color-message.
color display message
        ttcores.cor
        cor.cornom
        cor.pantone
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        ttcores.cor
        cor.cornom
        cor.pantone
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
         
