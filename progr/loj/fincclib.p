
{admcab.i}
def input param prec as recid.

def buffer bfincotacllib for fincotacllib.

def var xtime as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" utilizacao"," alteracao"," inclusao "," exclusao",""].


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
        fincotacllib.etbcod
        estab.munic format "x(10)"
    
        fincotacllib.dtivig
        fincotacllib.dtfvig 
        fincotacllib.CotasLib
        
        with frame frame-a 8 down centered row 8
        no-box.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find fincotacllib where recid(fincotacllib) = recatu1 no-lock.
    if not available fincotacllib
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(fincotacllib).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available fincotacllib
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find fincotacllib where recid(fincotacllib) = recatu1 no-lock.

        status default "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field fincotacllib.dtivig

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
                    if not avail fincotacllib
                    then leave.
                    recatu1 = recid(fincotacllib).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail fincotacllib
                    then leave.
                    recatu1 = recid(fincotacllib).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail fincotacllib
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail fincotacllib
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
            if esqcom1[esqpos1] = " alteracao "
            then do:
                hide frame f-com1 no-pause.
                run paltera.
                
            end. 
            
            if esqcom1[esqpos1] = " utilizacao "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause. 
                run loj/finccuso.p (input recid(fincotacllib)).
                
            end. 

            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(fincotacllib).
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
    def var vcotasuso like fincotaetb.cotasuso.

    find estab of fincotacllib no-lock.
    find fincotacluster of fincotacllib no-lock.    
            vcotasuso = 0.
            for each fincotaclplan of fincotacluster no-lock.
                for each fincotaetb where 
                    fincotaetb.etbcod = fincotacllib.etbcod and
                    fincotaetb.fincod = fincotaclplan.fincod and
                    fincotaetb.dtivig = fincotacllib.dtivig and
                    fincotaetb.dtfvig = fincotacllib.dtfvig 
                    no-lock.
                    vcotasuso = vcotasuso + fincotaetb.cotasuso.
                end.
            end.              
    
    display  
        fincotacllib.etbcod
        estab.munic
        fincotacllib.dtivig
        fincotacllib.dtfvig
        fincotacllib.CotasLib
        vcotasuso
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
            fincotacllib.etbcod
        estab.munic

        fincotacllib.dtivig
        fincotacllib.dtfvig
        fincotacllib.CotasLib
        
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
            fincotacllib.etbcod
        estab.munic

        fincotacllib.dtivig
        fincotacllib.dtfvig
        fincotacllib.CotasLib

        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
            fincotacllib.etbcod
        estab.munic

        fincotacllib.dtivig
        fincotacllib.dtfvig
        fincotacllib.CotasLib

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find last fincotacllib  of fincotacluster
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find prev fincotacllib  of fincotacluster
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find next fincotacllib  of fincotacluster
                no-lock no-error.

end.    
        
end procedure.



procedure pexclusao.

    message "confirma?" update sresp.
    if sresp
    then do on error undo:

        find current fincotacllib exclusive.

        /* atualiza fincotaetb */
        for each fincotaclplan of fincotacluster no-lock.
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
        
        delete fincotacllib.
            
    end.

end.



procedure paltera.

    do on error undo:

        find current fincotacllib exclusive.
        update 
            fincotacllib.dtfvig
            fincotacllib.cotaslib
                               with row 9 
        centered
        overlay 1 column.

    find last bfincotacllib of fincotacluster where 
                bfincotacllib.etbcod = fincotacllib.etbcod and
            bfincotacllib.dtivig <=   fincotacllib.dtfvig and
            bfincotacllib.dtfvig >= fincotacllib.dtfvig
            and recid(bfincotacllib) <> recid(fincotacllib)
            no-lock no-error.

        if avail bfincotacllib
        then do:
            message "ja existe cota neste periodo para este cluster" bfincotacllib.dtivig bfincotacllib.dtfvig.
            
            undo.
        end.
          
        /* atualiza fincotaetb */
        for each fincotaclplan of fincotacluster no-lock.
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
                fincotaetb.Ativo    = yes.
            end.                                  
            fincotaetb.DtFVig   = fincotacllib.DtFVig .
            fincotaetb.CotasLib = 0 /*fincotacllib.CotasLib*/ . /* Controle por Cluster */
        end.                            
    end.

end.



procedure pinclui.
def output param prec as recid.
do on error undo.

    create fincotacllib.
    prec = recid(fincotacllib).
    fincotacllib.fcccod = fincotacluster.fcccod. 

        update fincotacllib.etbcod.
        find estab of fincotacllib no-lock no-error.
        if not avail estab
        then do:
            message "filial invalida".
            undo.
        end.    
    
    
    update fincotacllib.dtivig
            with row 9 
        centered
        overlay 1 column.

    find last bfincotacllib of fincotacluster where 
            bfincotacllib.etbcod = fincotacllib.etbcod and
            bfincotacllib.dtivig <=   fincotacllib.dtivig and
            bfincotacllib.dtfvig >= fincotacllib.dtivig
            no-lock no-error.

        if avail bfincotacllib
        then do:
            message "ja existe cota neste periodo para este cluster" bfincotacllib.dtivig bfincotacllib.dtfvig.
            undo.
        end.

        update 
            fincotacllib.dtfvig
            fincotacllib.cotaslib
                               with row 9 
        centered
        overlay 1 column.

    find last bfincotacllib of fincotacluster where 
                bfincotacllib.etbcod = fincotacllib.etbcod and
            bfincotacllib.dtivig <=   fincotacllib.dtfvig and
            bfincotacllib.dtfvig >= fincotacllib.dtfvig
            and recid(bfincotacllib) <> recid(fincotacllib)
            no-lock no-error.

        if avail bfincotacllib
        then do:
            message "ja existe cota neste periodo para este cluster" bfincotacllib.dtivig bfincotacllib.dtfvig.
            
            undo.
        end.
        /* atualiza fincotaetb */
        for each fincotaclplan of fincotacluster no-lock.
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
            fincotaetb.CotasLib = ? . /*fincotacllib.CotasLib. // Controle por Cluster */
        end.                            

    
end.


end procedure.







