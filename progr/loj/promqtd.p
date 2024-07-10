/*               to                   sfpl
*                                 R
*
*/

{admcab.i}
def input param ctitle as char.
def buffer bpromqtd for promqtd.
    
def var xtime as int.
def var vconta as int.


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
        promqtd.sequencia
        promqtd.etbcod
        estab.munic format "x(10)"
        promqtd.procod
        produ.pronom format "x(20)"
        promqtd.qtdlimite        
        
        with frame frame-a 8 down centered row 8
        no-box.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find promqtd where recid(promqtd) = recatu1 no-lock.
    if not available promqtd
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(promqtd).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available promqtd
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find promqtd where recid(promqtd) = recatu1 no-lock.

        status default "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field promqtd.etbcod

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
                    if not avail promqtd
                    then leave.
                    recatu1 = recid(promqtd).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail promqtd
                    then leave.
                    recatu1 = recid(promqtd).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail promqtd
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail promqtd
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
        recatu1 = recid(promqtd).
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
    find estab of promqtd no-lock no-error. 
    find produ of promqtd no-lock.
    display  
        promqtd.sequencia
        promqtd.etbcod
        estab.munic when avail estab
        promqtd.procod
        produ.pronom 
        promqtd.qtdlimite        
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
            promqtd.sequencia

        promqtd.etbcod
        estab.munic 
        promqtd.procod
        produ.pronom 
        promqtd.qtdlimite        

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
            promqtd.sequencia

        promqtd.etbcod
        estab.munic 
        promqtd.procod
        produ.pronom 
        promqtd.qtdlimite        
        
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
            promqtd.sequencia

        promqtd.etbcod
        estab.munic 
        promqtd.procod
        produ.pronom 
        promqtd.qtdlimite        
        
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first promqtd  where
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next promqtd  where
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev promqtd  where
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo:

        find current promqtd exclusive.
        disp promqtd.etbcod.
        disp    
            promqtd  
                   with row 9 
        centered
        overlay 1 column.
.
                    
        update
            promqtd.qtdlimite.

    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    find last bpromqtd no-lock no-error.
    create promqtd.
    prec = recid(promqtd).
    
    update
        promqtd.sequencia.
    
    find first ctpromoc where 
            ctpromoc.sequencia = promqtd.sequencia and
            ctpromoc.linha = 0 
            no-lock no-error.
    if not avail ctpromoc
    then do:
        message "campanha ainda não foi criada".
        undo.
    end.        
                            
    update        
        promqtd.etbcod
        with row 9 
        centered
        overlay 1 column.
        update
            promqtd
                except sequenci etbcod.

end.


end procedure.



procedure pexclui.
sresp = yes.
message color normal "confirma?" update sresp.
if sresp
then do on error undo:
    find current promqtd exclusive no-wait no-error.
    if avail promqtd
    then do:
        delete promqtd.    
    end.        
end.
end procedure.



procedure pcarga.

def var vpasta as char format "x(40)".
disp "           Sequencia;Filial;Produto;QtdLimite" skip
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
sresp = no.
message "Antes da Carga, Eliminar os registros antigos na tabela qtd?" update sresp.
if sresp
then do:
    for each promqtd.
        delete promqtd.
    end.    
end.
hide message no-pause.
message "aguarde....".
def var vsequencia as int.
def var vetbcod as int.
def var vprocod as int.
def var vqtdlimite as int.

def var vconta as int.
input from value(varquivo).
repeat on error undo, leave.
    vconta = vconta + 1.
    if vconta = 1 then next.
    
    import delimiter ";" 
        vsequencia vetbcod vprocod vqtdlimite no-error.

    if vprocod = 0 or vprocod = ? then next.
    
    
    find promqtd where 
            promqtd.sequencia = vsequencia and
            promqtd.etbcod = vetbcod and promqtd.procod = vprocod no-error.
    if not avail promqtd
    then do:
        create promqtd.
        promqtd.sequencia = vsequencia.    
        promqtd.etbcod = vetbcod.
        promqtd.procod = vprocod.
    end.
    promqtd.qtdlimite = vqtdlimite.    
end.
input close.

hide message no-pause.

end procedure.
