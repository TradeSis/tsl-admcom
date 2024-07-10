/*               to                   sfpl
*                                 R
*
*/

{admcab.i}
{api/sicredplanos.i new}
def var vcomjuros as log format "Sim/Nao".

def var ctitle as char init "Parametros De Para Planos".
def buffer bfindepara for findepara.
def var vprazo as int.
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
    initial [" parametros "," inclusao "," exclusao", " atualiza", ""].


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
/* 23/01/23 COPY assignment */


    form  
        findepara.prazo
    
        findepara.comentrada column-label "Com!Entra"
        vcomjuros column-label "Com!Juros" format "Sim/Nao" 
    
/*        findepara.taxa_juros*/
        findepara.fincod    
        finan.finnom                                                               
        with frame frame-a 8 down centered row 8
        no-box.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find findepara where recid(findepara) = recatu1 no-lock.
    if not available findepara
    then do.
        /*
        run patualiza.
        find first findepara no-lock no-error.
        if not avail findepara then return.
        next.
        */
        run pinclui (output recatu1).
        find  findepara where recid(findepara) = recatu1 no-lock no-error.
         if not avail findepara then return.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(findepara).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available findepara
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find findepara where recid(findepara) = recatu1 no-lock.

        status default "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field findepara.prazo

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
                    if not avail findepara
                    then leave.
                    recatu1 = recid(findepara).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail findepara
                    then leave.
                    recatu1 = recid(findepara).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail findepara
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail findepara
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
            
            
            if esqcom1[esqpos1] = " atualiza "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run patualiza.
                recatu1 = ?.
                leave.
                
            end. 
            
            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(findepara).
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
    find finan where finan.fincod = findepara.fincod no-lock no-error.
    vcomjuros = findepara.taxa_juros > 0.
    display  
        findepara.prazo
        findepara.comentrada
        findepara.fincod        
        
        finan.finnom when avail finan
        finan.finnpc when avail finan
        vcomjuros  
/*        findepara.taxa_juros   when findepara.taxa_juros <> 100     */
        
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        findepara.prazo
        findepara.comentrada
        findepara.fincod        
/*        findepara.taxa_juros        */

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        findepara.prazo
        findepara.comentrada
        findepara.fincod        
/*        findepara.taxa_juros        */
        
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        findepara.prazo
        findepara.comentrada
        findepara.fincod        
/*        findepara.taxa_juros        */
        
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first findepara  where
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next findepara  where
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev findepara  where
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.
    do on error undo:

        find current findepara exclusive.
        disp findepara.prazo.
        disp    
            findepara.fincod
            findepara.comentrada
/*                       findepara.taxa_juros        */

                   with row 9 
        centered
        overlay 1 column.
        
        update findepara.fincod.
        find finan where finan.fincod = findepara.fincod no-lock no-error.
        if not avail finan
        then do:
            message "plano nao cadastrado".
            undo.
        end.
        if finan.finnpc <> findepara.prazo
        then do:
            message "quantidade de parcelas do plano " finan.finnpc "diferente do digitado".
            undo.
        end.
        findepara.comentrada = finan.finent.
        disp findepara.comentrada.
        update vcomjuros.
        taxa_juros = if vcomjuros then 100 else 0.

    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    find last bfindepara no-lock no-error.
    create findepara.
    prec = recid(findepara).
    
    update
        findepara.prazo
        with row 9 
        centered
        overlay 1 column.
        update findepara.fincod.
        find finan where finan.fincod = findepara.fincod no-lock no-error.
        if not avail finan
        then do:
            message "plano nao cadastrado".
            undo.
        end.
        if finan.finnpc <> findepara.prazo
        then do:
            message "quantidade de parcelas do plano " finan.finnpc "diferente do digitado".
            undo.
        end.
        findepara.comentrada = finan.finent.
        disp findepara.comentrada.
        update vcomjuros.
        findepara.taxa_juros = if vcomjuros then 100 else 0.


end.


end procedure.



procedure pexclui.
sresp = yes.
message color normal "confirma?" update sresp.
if sresp
then do on error undo:
    find current findepara exclusive no-wait no-error.
    if avail findepara
    then do:
        delete findepara.    
    end.        
end.
end procedure.


procedure patualiza.
def var vtaxajuros as int.
sresp = no.
hide message no-pause.
message "DExPARA sera apagado!". 
message "Confirma atualizar com os dados do SICRED todo o DExPARA?" update sresp.


if sresp
then do:
    hide message no-pause.
    message "Conectando Sicred...".
    
    run api/sicredplanos.p.
    find first ttplanos no-error.
    if not avail ttplanos
    then do:
        hide message no-pause.
        message "Ocorreu um erro".
        return.
    end.
    hide message no-pause.
    message "Apagando base DExPARA...".
        
        for each findepara.
            delete findepara.
        end.    
    hide message no-pause.
    message "Atualizando base DExPARA...".

    for each ttplanos by  ttplanos.prazo by ttplanos.taxa by ttplanos.codigoPlano.

        
        /* Padrao Inicial de depara eh 100 para com juros, pois o p2k nao tah enviando juros */
        vtaxajuros = if ttplanos.taxa > 0
                    then 100
                    else 0.
        find finan where finan.fincod =  int(codigoPlano) and 
                         finan.finnpc = ttplanos.prazo no-lock no-error.
        if not avail finan then next.                 
        
        find first findepara where 
            findepara.prazo         = ttplanos.prazo and
            findepara.comentrada    = no and
            findepara.taxa_juros    = vtaxajuros
           no-lock no-error.
        if avail findepara then next.
    
        create findepara.
        findepara.prazo      = ttplanos.prazo.
        findepara.comEntrada = no.
        findepara.fincod     = int(codigoPlano).
        findepara.taxa_juros = vtaxajuros.
    
    end.

end.
hide message no-pause.

end procedure.
