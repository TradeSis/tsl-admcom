/*               to                   sfpl
*                                 R
*
*/

{admcab.i}
def input param ctitle as char.
def buffer bprodubloq for produbloq.
def var vetbcod as int.
def var vprocod as int.
def var vdtini as date.
def var vdtfim as date.
def var vconta as int.
    
def var xtime as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" parametros "," inclusao "," exclusao"," carga",""].


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
        produbloq.etbcod
        estab.munic format "x(10)"
        produbloq.procod
        produ.pronom format "x(20)"
        produbloq.dtivig
        produbloq.dtfvig
        produbloq.ativo        
        
        with frame frame-a 8 down centered row 8
        no-box.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find produbloq where recid(produbloq) = recatu1 no-lock.
    if not available produbloq
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(produbloq).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available produbloq
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find produbloq where recid(produbloq) = recatu1 no-lock.

        status default "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field produbloq.etbcod

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
                    if not avail produbloq
                    then leave.
                    recatu1 = recid(produbloq).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail produbloq
                    then leave.
                    recatu1 = recid(produbloq).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail produbloq
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail produbloq
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            

            if esqcom1[esqpos1] = " parametros "
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
            if esqcom1[esqpos1] = " exclusao "
            then do:
                run color-message.

                run pexclui.
                recatu1 = ?.
                leave.
            end. 
            
            
            if esqcom1[esqpos1] = " carga "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run pcarga.
                recatu1 = ?.
                leave.
                
            end. 
            
            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(produbloq).
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
    find estab of produbloq no-lock no-error. 
    find produ of produbloq no-lock.
    display  
        produbloq.etbcod
        estab.munic when avail estab
        produbloq.procod
        produ.pronom 
        produbloq.dtivig
        produbloq.dtfvig
        produbloq.ativo        
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        produbloq.etbcod
        estab.munic 
        produbloq.procod
        produ.pronom 
        produbloq.dtivig
        produbloq.dtfvig
        produbloq.ativo        

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        produbloq.etbcod
        estab.munic 
        produbloq.procod
        produ.pronom 
        produbloq.dtivig
        produbloq.dtfvig
        produbloq.ativo        
        
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        produbloq.etbcod
        estab.munic 
        produbloq.procod
        produ.pronom 
        produbloq.dtivig
        produbloq.dtfvig
        produbloq.ativo        
        
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first produbloq  where
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next produbloq  where
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev produbloq  where
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo:

        find current produbloq exclusive.
        disp produbloq.etbcod.
        disp    
            produbloq  
                   with row 9 
        centered
        overlay 1 column.
.
                    
        update
            produbloq.dtivig produbloq.dtfvig produbloq.ativo.

    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    find last bprodubloq no-lock no-error.
    create produbloq.
    prec = recid(produbloq).
    
    update
        produbloq.etbcod
        with row 9 
        centered
        overlay 1 column.
        update
            produbloq
                except etbcod.


end.


end procedure.



procedure pexclui.
sresp = yes.
message color normal "confirma?" update sresp.
if sresp
then do on error undo:
    find current produbloq exclusive no-wait no-error.
    if avail produbloq
    then do:
        delete produbloq.    
    end.        
end.
end procedure.



procedure pcarga.

def var vpasta as char format "x(40)".
disp "                  Filial;Produto;data inicio;data final" skip
    with frame fff.
vpasta = "/admcom/tmp/import/".
disp vpasta label "Pasta" colon 20
    with side-labels frame fff.
def var varquivo as char format "x(50)" label "Arquivo CSV (;)" .
hide frame  fff no-pause.

run   /admcom/progr/get_file.p (trim(lc(vpasta)), "csv", output varquivo) .

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
def var vokestab as log.
def var vokprodu as log.
vokprodu = yes.
vokestab = no.
vconta = 0.
input from value(varquivo).
repeat on error undo, leave.
    vconta = vconta + 1.
    if vconta = 1 then next.
    
    import delimiter ";" vetbcod vprocod vdtini vdtfim no-error.

    if vprocod = 0 or vprocod = ? then next.
    find produ where produ.procod = vprocod no-lock no-error.
    if not avail produ
    then do:
        vokprodu = no.
    end.
    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if avail estab
        then vokestab = yes. 
    end.
    else do:
        vokestab = yes.
    end.
end.
input close.

if vokestab = no or vokprodu = no
then do:
    message "erro no arquivo, provavelmente formatacao"
        view-as alert-box.
    undo.
end.
 
sresp = no.
message "carga com" vconta - 2 "registros".
message "Antes da Carga, Eliminar os registros antigos na tabela de bloqueios?" update sresp.
if sresp
then do:
    for each produbloq.
        delete produbloq.
    end.    
end.
hide message no-pause.
message "aguarde....".
vconta = 0.
input from value(varquivo).
repeat on error undo, leave.
    vconta = vconta + 1.
    if vconta = 1 then next.
    
    import delimiter ";" vetbcod vprocod vdtini vdtfim no-error.

    if vprocod = 0 or vprocod = ? then next.
    
    
    find produbloq where produbloq.etbcod = vetbcod and produbloq.procod = vprocod no-error.
    if not avail produbloq
    then do:
        create produbloq.
        produbloq.etbcod = vetbcod.
        produbloq.procod = vprocod.
    end.
    produbloq.dtivig = vdtini.
    produbloq.dtfvig = vdtfim.
    produbloq.ativo = yes.    
end.
input close.

hide message no-pause.

end procedure.
