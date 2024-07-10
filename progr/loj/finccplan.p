
{admcab.i}
def input param prec as recid.

def buffer bfincotaclplan for fincotaclplan.

def var xtime as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" inclusao "," exclusao",""].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

find fincotacluster where recid(fincotacluster) = prec no-lock.

    disp 
        fincotacluster.fcccod no-label fincotacluster.fccnom no-label
        with frame ftit
            side-labels
            row 4
            centered
            no-box
            color messages.
    form  
        fincotaclplan.fincod
        finan.finnom
        with frame frame-a 8 down centered row 8
        no-box.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find fincotaclplan where recid(fincotaclplan) = recatu1 no-lock.
    if not available fincotaclplan
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(fincotaclplan).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available fincotaclplan
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find fincotaclplan where recid(fincotaclplan) = recatu1 no-lock.

        status default "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field fincotaclplan.fincod

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
                    if not avail fincotaclplan
                    then leave.
                    recatu1 = recid(fincotaclplan).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail fincotaclplan
                    then leave.
                    recatu1 = recid(fincotaclplan).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail fincotaclplan
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail fincotaclplan
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            

            if esqcom1[esqpos1] = " exclusao "
            then do:
                hide frame f-com1 no-pause.

                run pexclusao.    
                recatu1 = ?.
                leave.
            end.
            if esqcom1[esqpos1] = " inclusao "
            then do:
                hide frame f-com1 no-pause.
                run pinclui (output recatu1).
                leave.
                
            end. 
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(fincotaclplan).
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
    find finan where finan.fincod = fincotaclplan.fincod no-lock.
    display  
        fincotaclplan.fincod
        finan.finnom
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        fincotaclplan.fincod
        finan.finnom

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        fincotaclplan.fincod
        finan.finnom
        
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        fincotaclplan.fincod
        finan.finnom
        
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find last fincotaclplan  of fincotacluster
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find prev fincotaclplan  of fincotacluster
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find next fincotaclplan  of fincotacluster
                no-lock no-error.

end.    
        
end procedure.



procedure pexclusao.

    message "confirma?" update sresp.
    if sresp
    then do on error undo:

        find current fincotaclplan exclusive.
        /* atualiza fincotaetb */
        for each fincotacllib of fincotacluster no-lock.
            find fincotaetb where
                fincotaetb.etbcod = fincotacllib.etbcod and
                fincotaetb.fincod = fincotaclplan.fincod and
                fincotaetb.dtivig = fincotacllib.dtivig 
                no-error.
            if avail fincotaetb
            then do:
                fincotaetb.ativo = no.
            end.                                  
        end.                            
        
        delete fincotaclplan.
            
    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    find last bfincotaclplan no-lock no-error.
    create fincotaclplan.
    prec = recid(fincotaclplan).
    fincotaclplan.fcccod = fincotacluster.fcccod. 
    
    
    update fincotaclplan.fincod.
    
    find finan of fincotaclplan no-lock no-error.
    
    if not avail finan
    then do:
        message "plano nao cadastrado".
        undo.
    end.
        
        /* atualiza fincotaetb */
        for each fincotacllib of fincotacluster no-lock.
            find fincotaetb where
                fincotaetb.etbcod = fincotacllib.etbcod and
                fincotaetb.fincod = fincotaclplan.fincod and
                fincotaetb.dtivig = fincotacllib.dtivig 
                no-error.
            if not avail fincotaetb
            then do:
                create fincotaetb.
                fincotaetb.etbcod = fincotacllib.etbcod.
                fincotaetb.fincod = fincotaclplan.fincod.
                fincotaetb.dtivig = fincotacllib.dtivig. 
            end.                                   
            
            fincotaetb.Ativo    = yes.

            fincotaetb.DtFVig   = fincotacllib.DtFVig .
            fincotaetb.CotasLib = 0. /*fincotacllib.CotasLib. // Controle por Cluster */
        end.                            

    disp
        finan.finnom
        with row 9 
        centered
        overlay 1 column.
    pause 0.
    
end.


end procedure.







