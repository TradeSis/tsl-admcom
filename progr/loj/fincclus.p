
{admcab.i}
def input param ctitle as char.

def buffer bfincotacluster for fincotacluster.

def var xtime as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" filiais", " planos "," inclusao "," alteracao"," carga planos",""].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


    disp 
        ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.

    form  
        fincotacluster.fcccod
        fincotacluster.fccnom
        with frame frame-a 8 down centered row 8
        no-box.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find fincotacluster where recid(fincotacluster) = recatu1 no-lock.
    if not available fincotacluster
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(fincotacluster).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available fincotacluster
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find fincotacluster where recid(fincotacluster) = recatu1 no-lock.

        status default "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field fincotacluster.fcccod

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
                    if not avail fincotacluster
                    then leave.
                    recatu1 = recid(fincotacluster).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail fincotacluster
                    then leave.
                    recatu1 = recid(fincotacluster).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail fincotacluster
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail fincotacluster
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            

            if esqcom1[esqpos1] = " alteracao "
            then do:
                hide frame f-com1 no-pause.

                run pparametros.    
                leave.
            end.
            if esqcom1[esqpos1] = " inclusao "
            then do:
                hide frame f-com1 no-pause.
                run pinclui (output recatu1).
                leave.
                
            end. 
            if esqcom1[esqpos1] = " planos "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run loj/finccplan.p (input recid(fincotacluster)).
                
            end. 
            if esqcom1[esqpos1] = " carga planos "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run pcarga.
                recatu1 = ?.
                leave.
                
            end. 

            if esqcom1[esqpos1] = " filiais "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run loj/fincclib.p (input recid(fincotacluster)).
                
            end. 
            
            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(fincotacluster).
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
        fincotacluster.fcccod
        fincotacluster.fccnom
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        fincotacluster.fcccod
        fincotacluster.fccnom

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        fincotacluster.fcccod
        fincotacluster.fccnom
        
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        fincotacluster.fcccod
        fincotacluster.fccnom
        
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find last fincotacluster  where true
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find prev fincotacluster  where true
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find next fincotacluster  where true
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo:

        find current fincotacluster exclusive.
        disp fincotacluster.fcccod.
        disp    
            fincotacluster  
                   with row 9 
        centered
        overlay 1 column.
                    
        update fincotacluster.fccnom.


    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    find last bfincotacluster no-lock no-error.
    create fincotacluster.
    prec = recid(fincotacluster).
        update fincotacluster.fcccod.
    disp
        fincotacluster.fcccod 
        with row 9 
        centered
        overlay 1 column.
        update
            fincotacluster.fccnom.

end.


end procedure.

procedure pcarga.
def var vcotas as int.
def var vpasta as char format "x(40)".
disp "                  Cluster;Plano;" skip
    with frame fff.

update vpasta label "Pasta /admcom/" colon 20
    with side-labels frame fff.
def var varquivo as char format "x(50)" label "Arquivo CSV (;)" .
hide frame  fff no-pause.

run   /admcom/progr/get_file.p ("/admcom/" + trim(lc(vpasta) + "/"), "csv", output varquivo) .

disp varquivo colon 20
    with row 3
        centered
        with frame fff.
if search(varquivo) = ?
then do:
    message "arquivo nao encontrado"
        view-as alert-box.
    return.
end.            
def var vfcccod as char.
def var vfincod as int.
def var vokcluster as log.
def var vokfinan as log.
vokfinan = yes.
vokcluster = yes.
def var vconta as int.
vconta = 0.
input from value(varquivo).
repeat on error undo, leave.
    vconta = vconta + 1.
    if vconta = 1 then next.
    
    import delimiter ";" vfcccod vfincod no-error.
    if vfcccod = "" or vfcccod = ? or vfincod = 0 or vfincod = ? then next.
    find fincotacluster where fincotacluster.fcccod = vfcccod no-lock no-error.
    if not avail fincotacluster
    then do:
        vokcluster = no.
    end.
    find finan where finan.fincod = vfincod no-lock no-error.
    if not avail finan
    then do:
        vokfinan = no.
    end.

end.
input close.

if vokcluster = no or vokfinan = no
then do:
    message "erro no arquivo, provavelmente formatacao"
        view-as alert-box.
    undo.
end.
 
sresp = no.
message "carga com" vconta - 2 "registros".
pause 1.
hide message no-pause.
message "aguarde....".
vconta = 0.

input from value(varquivo).
repeat on error undo, next.
    vconta = vconta + 1.
    if vconta = 1 then next.
    
    import delimiter ";" vfcccod vfincod no-error.
    if vfcccod = "" or vfcccod = ? or vfincod = 0 or vfincod = ? then next.
    disp vfcccod vfincod. pause.
    find fincotacluster where fincotacluster.fcccod = vfcccod no-lock no-error.
    if avail fincotacluster
    then do:    
        disp "ok" vfincod. pause.
        create fincotaclplan.
        fincotaclplan.fcccod = fincotacluster.fcccod. 
        fincotaclplan.fincod = vfincod.
        disp fincotaclplan. pause.
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
            fincotaetb.CotasLib = 0 . /*fincotacllib.CotasLib. // Controle por Cluster */
        end.                            
    
    end.        
        
end.
input close.


hide message no-pause.

end procedure.



