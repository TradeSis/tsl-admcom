/*
*
*    cobdata.p    -    Esqueleto de Programacao    com esqvazio
*
*/

{admcab.i}
def var par-loja   as log init yes.
par-loja = setbcod <> 999.



def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Clientes","Gera Cobranca ", "Elimina Cobranca","Exclui Cliente", "Relatorio"].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

    form 
        cobdata.etbcod
        cobdata.cobcod
        cobfil.cobnom
        cobdata.cobgera
        cobdata.fase1 column-label "1"
        cobdata.fase2 column-label "2"
        cobdata.fase3 column-label "3"
        cobdata.cobqtd column-label "Qtd!Cli"
        with frame frame-a 9 down centered color white/red row 6.


bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find cobdata where recid(cobdata) = recatu1 no-lock.
    if not available cobdata
    then do.
        hide message no-pause.
        message "Nenhuma cobranca Encontrada,Gerar Cobranca" update sresp.
        if not sresp
        then leave.
        
        run cob/geracob2.p (setbcod).
        recatu1 = ?.
        next.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(cobdata).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available cobdata
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find cobdata where recid(cobdata) = recatu1 no-lock.

        status default "".

        
        disp esqcom1 with frame f-com1.
        
        run color-message.

        choose field cobdata.cobgera
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
        run color-normal.
        pause 0. 

                                                                
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
                    if not avail cobdata
                    then leave.
                    recatu1 = recid(cobdata).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cobdata
                    then leave.
                    recatu1 = recid(cobdata).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cobdata
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cobdata
                then next.
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

            if esqcom1[esqpos1] = "Gera Cobranca"
            then do:
                message "Gerar Cobranca" update sresp.
                if not sresp
                then leave.
            
                run cob/geracob2.p (cobdata.etbcod).
                leave.
            end.
            if esqcom1[esqpos1] = "Elimina Cobranca"
            then do:
                run cob/exccob.p (recid(cobdata)).
                recatu1 = ?.
                leave.
            end.
            if esqcom1[esqpos1] = "Exclui Cliente"
            then do:
                run cob/exccob2.p (input ?).
                recatu1 = ?.
                leave.
            end.
            
            
            if esqcom1[esqpos1] = " Clientes "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run cob/vercobdata.p (recid(cobdata)).
                leave.
            end.

            if esqcom1[esqpos1] = "Relatorio "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run cob/relcob-b.p (recid(cobdata)).
                leave.
            end.
            
        end.
        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(cobdata).
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
    find cobfil of cobdata no-lock.
    disp 
        cobdata.etbcod
        cobdata.cobcod
        cobfil.cobnom
        cobdata.cobgera
        cobdata.cobqtd
        cobdata.fase1
        cobdata.fase2
        cobdata.fase3
        with frame frame-a.
end procedure.

procedure color-message.
    color display message
        cobdata.etbcod
        cobdata.cobcod
        cobfil.cobnom
        cobdata.cobgera
        cobdata.cobqtd
        cobdata.fase1
        cobdata.fase2
        cobdata.fase3

        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
            cobdata.etbcod
        cobdata.cobcod
        cobfil.cobnom
        cobdata.cobgera
        cobdata.cobqtd
        cobdata.fase1
        cobdata.fase2
        cobdata.fase3

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
    if par-loja
    then do:
        find first cobdata  where cobdata.etbcod = setbcod
                no-lock no-error.
    end.
    else do:
        find first cobdata where
            true
            no-lock no-error.
    end.        
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if par-loja
    then do:
        find next cobdata 
             where cobdata.etbcod = setbcod

                no-lock no-error.
    end.
    else do:
        find next cobdata where
            true
            no-lock no-error.
    end.        
end.    
             
if par-tipo = "up" 
then do:
    if par-loja
    then do:
       find prev cobdata  where
                cobdata.etbcod = setbcod
                no-lock no-error.
    end.
    else do:
        find prev cobdata where
            true
            no-lock no-error.
    end.        

end.    
        
end procedure.



