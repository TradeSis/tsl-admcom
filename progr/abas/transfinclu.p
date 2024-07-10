/*
*
*
*/
{admcab.i}

def input param par-abatipo like abastipo.abatipo.
def input param par-etbcod  like abastransf.etbcod.
def var vdttransf like abastransf.dttransf.
def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Cancela", " ",""].

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.

def var pabtcod like abastransf.abtcod.

def temp-table ttabastransf no-undo
    field abtcod    like abastransf.abtcod
    field etbcod    like abastransf.etbcod
    field dttransf  like abastransf.dttransf
    field procod    like abastransf.procod
    field abtqtd    like abastransf.abtqtd
    field lipcor    like abastransf.lipcor
    index idx is unique primary etbcod asc abtcod asc.

form 
    par-abatipo label "Tipo"
    abastipo.abatnom no-label
    par-etbcod label "Estab"
     estab.etbnom no-label format "x(15)" 
     with frame f-estab row  3 no-box color message side-label centered.
find abastipo where abastipo.abatipo = if par-abatipo = "" then "MAN" else par-abatipo no-lock.

find estab where estab.etbcod = par-etbcod no-lock no-error.
pause 0.
disp par-abatipo abastipo.abatnom no-label 
    with frame f-estab.
disp par-etbcod
     estab.etbnom  when avail estab
     with frame f-estab.

run monta-tt.
                           
form
        ttabastransf.etbcod
        ttabastransf.abtcod column-label "Pedido"

        abastransf.abatipo 
        ttabastransf.dttransf  
        
        ttabastransf.procod
        produ.pronom       format "x(11)" column-label "Nome"
        ttabastransf.abtqtd 
        ttabastransf.lipcor
        abastransf.abtsit
        
        with frame frame-a 10 down centered row 5.
vdttransf = today.
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttabastransf where recid(ttabastransf) = recatu1 no-lock.
    if not available ttabastransf
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(ttabastransf).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttabastransf
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
            find ttabastransf where recid(ttabastransf) = recatu1 no-lock.
            find abastransf   where 
                abastransf.etbcod = ttabastransf.etbcod and
                abastransf.abtcod = ttabastransf.abtcod no-lock.

            status default "".
            run color-message.
            choose field ttabastransf.etbcod help ""
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
                    if not avail ttabastransf
                    then leave.
                    recatu1 = recid(ttabastransf).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttabastransf
                    then leave.
                    recatu1 = recid(ttabastransf).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttabastransf
                then next.
                color display white/red ttabastransf.abtcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttabastransf
                then next.
                color display white/red ttabastransf.abtcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form
                with frame f-ttabastransf color black/cyan
                      centered side-label row 5.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
            hide frame frame-a no-pause.
            
            if esqcom1[esqpos1] = " Inclusao " or esqvazio
            then do:
                clear frame frame-a all no-pause.
                if par-abatipo = "MAN"
                then do:
                    hide frame frame-a no-pause.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                
                    run abas/fipedido.p (par-abatipo).
                    recatu1 = ?.
                    run monta-tt.
                    leave.
                end.            
                else repeat with frame frame-a on error undo, leave on endkey undo, leave transaction.
                    create ttabastransf.
                    ttabastransf.abtcod = ?.
                    
                    ttabastransf.etbcod = if par-etbcod = 0 then setbcod else par-etbcod.

                    disp ttabastransf.etbcod.                    
                    
                    if par-etbcod = 0
                    then update ttabastransf.etbcod.
                    
                    ttabastransf.dttransf = vdttransf.
                    update ttabastransf.dttransf.
                    vdttransf = ttabastransf.dttransf.
                    update 
                        ttabastransf.procod label "Codigo".
                    find produ where produ.procod = ttabastransf.procod no-lock no-error.
                    if not avail produ
                    then do:
                        message "produto nao cadastrado.".
                        pause. 
                        undo.
                    end.
                    disp produ.pronom.
                                    
                    if produ.proipival = 1  and par-abatipo = "MAN"
                    then do:
                        message  "Bloqueado pedido manual para produto de pedido especial.".
                        pause.
                        undo.
                    end.
        
                    ttabastransf.abtqtd = 1.
                    update ttabastransf.abtqtd.
                    update ttabastransf.lipcor.

                    run abas/transfcreate.p (par-abatipo,
                                                ttabastransf.etbcod,
                                                ttabastransf.procod,
                                                ttabastransf.abtqtd,
                                                ttabastransf.lipcor,
                                                ttabastransf.dttransf,
                                                "DIGITADO",  /* ORIGEM DIGITADO,MOVIM,EXTERNO*/
                                                "",
                                                output pabtcod).
                                             
                    
                    ttabastransf.abtcod = pabtcod.

                    recatu1 = recid(ttabastransf).
                    down with frame frame-a.
                end.

                run monta-tt.
                recatu1 = ?.
                leave.
                
            end.
            if esqcom1[esqpos1] = " Alteracao " 
            then do with frame frame-a on error undo.
                find abastransf where 
                    abastransf.etbcod = ttabastransf.etbcod and
                    abastransf.abtcod = ttabastransf.abtcod 
                    exclusive.
                if abastransf.abtsit = "AC" and
                    abastransf.qtdatend = 0 and
                    abastransf.qtdemwms = 0
                then do:
                    update ttabastransf.abtqtd.
                    abastransf.abtqtd = ttabastransf.abtqtd. 
                    update ttabastransf.lipcor.
                    abastransf.lipcor = ttabastransf.lipcor.
                end.
            end.
            if esqcom1[esqpos1] = " Cancela " 
            then do with frame frame-a on error undo.
                find abastransf where 
                    abastransf.etbcod = ttabastransf.etbcod and
                    abastransf.abtcod = ttabastransf.abtcod 
                    exclusive.
                if abastransf.abtsit = "AC" and
                    abastransf.qtdatend = 0 and
                    abastransf.qtdemwms = 0
                then do:
                    message "Confirma Cancelamento?" update sresp.
                    if sresp
                    then do:
                        abastransf.abtsit = "CA".
                        abastransf.canfuncod = sfuncod.
                        abastransf.candt     = today.
                        abastransf.canhr     = time.
                    end.
                end.
            end.
            
        end.
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttabastransf).
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

    find abastransf where 
            abastransf.etbcod = ttabastransf.etbcod and
            abastransf.abtcod = ttabastransf.abtcod no-lock no-error.
    
    if avail abastransf
    then do:
    find produ of abastransf no-lock.

    display 

        abastransf.dttransf @ ttabastransf.dttransf  
        
        ttabastransf.abtcod
        abastransf.abatipo 
        abastransf.etbcod  @ ttabastransf.etbcod

        abastransf.procod  @ ttabastransf.procod
        produ.pronom       format "x(11)" column-label "Nome"
        abastransf.abtqtd  @ ttabastransf.abtqtd 
        abastransf.lipcor  @ ttabastransf.lipcor
        abastransf.abtsit
        
        with frame frame-a .

    end.
end procedure.


procedure color-message.
    color display message
        ttabastransf.abtcod
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        ttabastransf.abtcod
        with frame frame-a.
end procedure.


procedure leitura.

def input parameter par-tipo as char.

if par-tipo = "pri" 
then
    if esqascend
    then   find first ttabastransf where true no-lock no-error.
    else   find last ttabastransf  where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then
    if esqascend
    then   find next ttabastransf  where true no-lock no-error.
    else   find prev ttabastransf  where true no-lock no-error.
             
if par-tipo = "up" 
then
    if esqascend
    then   find prev ttabastransf where true  no-lock no-error.
    else   find next ttabastransf where true  no-lock no-error.

end procedure.



procedure monta-tt.
    for each ttabastransf.
        delete ttabastransf.
    end.
    for each abastransf where 
            abastransf.abtsit = "AC" and
            abastransf.abatipo = par-abatipo and
            (if par-etbcod <> 0
             then abastransf.etbcod  = par-etbcod
             else true)
            no-lock.
        create ttabastransf.
        ttabastransf.abtcod = abastransf.abtcod.
        ttabastransf.etbcod  = abastransf.etbcod.
        ttabastransf.dttransf = abastransf.dttransf.
        ttabastransf.procod  = abastransf.procod.
        ttabastransf.abtqtd = abastransf.abtqtd.
        ttabastransf.lipcor = abastransf.lipcor.
                   
    end.        
end procedure.
 
