/* selgrade.p                                                               */
/* selecao de grades que um produpaito pode utilizar                        */
/* com base em graclasse e grafabri                                         */
{admcab.i}  

def input parameter par-fabcod like produ.fabcod.
def input parameter par-clacod like produ.clacod.
def output parameter par-gracod like grade.gracod.

def temp-table ttgrade
    field gracod    like grade.gracod
    index ttgrades is primary unique gracod.
    
def buffer sclase for clase.    
def buffer nivel2 for clase.
def buffer nivel1 for clase.

for each ttgrade.
    delete ttgrade.
end.
 
    for each grafabri where grafabri.fabcod = par-fabcod no-lock.
        find ttgrade where ttgrade.gracod = grafabri.gracod no-error .
        if not avail ttgrade
        then create ttgrade.
        ttgrade.gracod = grafabri.gracod.
    end.
 
    find sclase where sclase.clacod = par-clacod no-lock no-error. 
    if avail sclase 
    then do.
        find clase  where clase.clacod = sclase.clasup no-lock. 
        find nivel2 where nivel2.clacod = clase.clasup no-lock. 
        find nivel1 where nivel1.clacod = nivel2.clasup no-lock.

        for each graclasse of nivel2 no-lock.
            find ttgrade where ttgrade.gracod = graclasse.gracod no-error .
            if not avail ttgrade
            then create ttgrade.
            ttgrade.gracod = graclasse.gracod.
        end.
    end.

    for each ttgrade.
        find grade of ttgrade no-lock no-error.
        if grade.situacao = no
        then delete ttgrade.
    end.

    find first ttgrade no-lock no-error.
    if not avail ttgrade
    then do.
        message "Nenhuma grade disponivel para o produto"
                view-as alert-box.
        leave.
    end.
    
def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.

def buffer bttgrade       for ttgrade.

assign
    esqpos1  = 1.

pause 0.

bl-princ:
repeat:
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find ttgrade where recid(ttgrade) = recatu1 no-lock.
    if not available ttgrade
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(ttgrade).
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttgrade
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
            find ttgrade where recid(ttgrade) = recatu1 no-lock.

            run color-message.
            choose field ttgrade.gracod help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                      PF4 F4 ESC return).
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttgrade
                    then leave.
                    recatu1 = recid(ttgrade).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttgrade
                    then leave.
                    recatu1 = recid(ttgrade).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttgrade
                then next.
                color display white/red ttgrade.gracod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttgrade
                then next.
                color display white/red ttgrade.gracod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            sresp = no.
            run message.p (input-output sresp,
                           input "Confirma a escolha da GRADE ? ",
                                   input "ATENCAO").            
            if sresp
            then par-gracod = ttgrade.gracod.
            else par-gracod = ?.
            hide frame f-com1  no-pause.
            hide frame frame-a no-pause.
            return.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        recatu1 = recid(ttgrade).
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

def var vtamanhos as char format "x(50)".

find grade of ttgrade no-lock.
for each gratam of grade no-lock break by gratam.graord.
    if first(gratam.graord)
    then vtamanhos = gratam.tamcod.
    else vtamanhos = vtamanhos + "," + gratam.tamcod.
end.
display ttgrade.gracod
        grade.granom 
        vtamanhos      column-label "Tamanhos"
        with frame frame-a overlay row 8 
                    5 down centered title " Selecione a Grade ".
end procedure.                                           

procedure color-message.
color display message
        ttgrade.gracod
        grade.granom
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        ttgrade.gracod
        grade.granom
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first ttgrade where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next ttgrade  where true no-lock no-error.
             
if par-tipo = "up" 
then find prev ttgrade where true   no-lock no-error.
        
end procedure.
