
{admcab.i}
def input param prec as recid.

def buffer bfincotaetb for fincotaetb.

def var xtime as int.
def temp-table ttcotas no-undo
    field rec as recid.

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" alteracao"," "," ",""].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

find fincotacllib where recid(fincotacllib) = prec no-lock.
find fincotacluster of fincotacllib no-lock.


    find estab of fincotacllib no-lock.
    pause 0.
    display  
        fincotacllib.etbcod no-label
        estab.munic format "x(12)" no-label
        fincotacllib.dtivig
        fincotacllib.dtfvig
        fincotacllib.CotasLib
        
        with frame ftit
            side-labels
            row 5
            centered
            no-box
            color messages.
    
    form  
        fincotaetb.fincod
        finan.finnom format "x(10)"
       fincotaetb.dtivig
        fincotaetb.dtfvig
        fincotaetb.ativo        
        /*fincotaetb.CotasLib*/ 
        fincotaetb.CotasUso
 
        with frame frame-a 8 down centered row 8
        no-box.

    
    pause 0.

run montatt.

bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttcotas where recid(ttcotas) = recatu1 no-lock.
    if not available ttcotas
    then do.
        message "utilizacao nao encontrada".
        pause 1.
        hide frame f-com1 no-pause.
        hide frame frame-a no-pause.
        hide frame ftit no-pause.
        
        return.        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttcotas).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttcotas
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttcotas where recid(ttcotas) = recatu1 no-lock.
        find fincotaetb where recid(fincotaetb) = ttcotas.rec no-lock.

        status default "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field fincotaetb.dtivig

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

                run color-normal.
        hide message no-pause.
                 
        pause 0. 

                                                                
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
                    if not avail ttcotas
                    then leave.
                    recatu1 = recid(ttcotas).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttcotas
                    then leave.
                    recatu1 = recid(ttcotas).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttcotas
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttcotas
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            

        if esqcom1[esqpos1] = " alteracao" 
        then do:
            run paltera.        
        end.
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttcotas).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame ftit no-pause.
procedure frame-a.
    
    find fincotaetb where recid(fincotaetb) = ttcotas.rec no-lock.

    find finan of fincotaetb no-lock.
    display  
        fincotaetb.fincod
        finan.finnom 
        fincotaetb.dtivig
        fincotaetb.dtfvig
        fincotaetb.ativo        
        /*fincotaetb.CotasLib*/
        fincotaetb.CotasUso

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
                fincotaetb.fincod
        finan.finnom 
        fincotaetb.dtivig
        fincotaetb.dtfvig
        fincotaetb.ativo        
        /*fincotaetb.CotasLib*/
        fincotaetb.CotasUso

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        fincotaetb.fincod
        finan.finnom 
        fincotaetb.dtivig
        fincotaetb.dtfvig
        fincotaetb.ativo        
        /*fincotaetb.CotasLib*/
        fincotaetb.CotasUso

        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        fincotaetb.fincod
        finan.finnom 
        fincotaetb.dtivig
        fincotaetb.dtfvig
        fincotaetb.ativo        
        /*fincotaetb.CotasLib*/
        fincotaetb.CotasUso

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find last ttcotas
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find prev ttcotas
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find next ttcotas
                no-lock no-error.

end.    
        
end procedure.


procedure paltera.

    do on error undo:

        find current fincotaetb exclusive.
        update 
            fincotaetb.ativo
                               with row 9 
        centered
        overlay 1 column.


    end.
end procedure.



procedure montatt.

empty temp-table ttcotas.

for each fincotaclplan of fincotacluster no-lock.
    for each fincotaetb where
            fincotaetb.etbcod = fincotacllib.etbcod and
            fincotaetb.fincod = fincotaclplan.fincod and
            fincotaetb.dtivig = fincotacllib.dtivig
            no-lock.
        create ttcotas.
        ttcotas.rec = recid(fincotaetb).
    end.
end.


end procedure.
