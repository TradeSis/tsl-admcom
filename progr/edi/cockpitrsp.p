/*
*
*    edipedid.p    -    Esqueleto de Programacao    com esqvazio
*
*/

{admcab.i}

def var par-pendente   as log init yes.

def var vhora   as char format "x(05)" column-label "Hora".

   
def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(15)" extent 5
    initial [" ", " Todas ", " ","  ", ""].

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

/*find tipo-alcis where tipo-alcis.tp = par-interface no-lock.*/

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find edipedid where recid(edipedid) = recatu1 no-lock.
    if not available edipedid
    then do.
        message "Sem arquivos " string(par-pendente,"PENDENTES/ NO GERAL") view-as alert-box.
        if par-pendente = no
        then leave.
        
        par-pendente = no.
        recatu1 = ?.
        next.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(edipedid).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available edipedid
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find edipedid where recid(edipedid) = recatu1 no-lock.

        status default "".

        esqcom1[1] = "".
        esqcom1[2] = if par-pendente 
                     then " Todas"
                     else " So Pendentes".
        esqcom1[3] = " "             .
        esqcom1[4] = "Roda Importador ".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.

        choose field edipedid.rspArquivocsv 
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
                    if not avail edipedid
                    then leave.
                    recatu1 = recid(edipedid).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail edipedid
                    then leave.
                    recatu1 = recid(edipedid).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail edipedid
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail edipedid
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

            if esqcom1[esqpos1] = " So Pendentes "
            then do.
                par-pendente = yes.
                recatu1 = ?.
                 leave.
            end.
            if esqcom1[esqpos1] = " Todas "
            then do.
                par-pendente = no.
                recatu1 = ?.
                leave.
            end.
            
            if esqcom1[esqpos1] = " Cons.NFE "
            then do.
                
                run not_consnota.p (recid(plani)).
                
            end.
            
            if esqcom1[esqpos1] = " Emissao NFE "
            then do.
                /* ABAS */
                

                recatu1 = ?.
                clear  frame frame-a all no-pause.
                next bl-princ.
            end.
            
            if esqcom1[esqpos1] = "Roda Importador"
            then run edi/importadorrsp.p.
            
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(edipedid).
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
    release pedid.
    find pedid where pedid.pedtdc = edipedid.pedtdc and
                               pedid.etbcod = edipedid.etbcod and
                               pedid.pednum = edipedid.pednum
                               no-lock no-error.

    find forne where forne.forcod = pedid.clfcod no-lock.
    display 
              edipedid.clfcod
            forne.fornom                        format "x(12)"
                    edipedid.etbcod
                    edipedid.pednum
                    edipedid.dtenvio  format "999999"
                    edipedid.rspdtarq format "999999"
                    string(edipedid.rsphrarq,"HH:MM") @ vhora
                    edipedid.rsparquivocsv format "x(18)"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
    color display message
              edipedid.clfcod
            forne.fornom     
                    edipedid.etbcod
                    edipedid.pednum
                    edipedid.dtenvio 
                    edipedid.rspdtarq 
                    vhora
                    edipedid.rsparquivocsv 

        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
              edipedid.clfcod
            forne.fornom     
                    edipedid.etbcod
                    edipedid.pednum
                    edipedid.dtenvio 
                    edipedid.rspdtarq 
                    vhora
                    edipedid.rsparquivocsv 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
    if par-pendente
    then do:
        find first edipedid  where
                edipedid.rspdtarq    = ?
                no-lock no-error.
    end.
    else do:
        find first edipedid use-index resposta where
            true
            no-lock no-error.
    end.        
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if par-pendente
    then do:
        find next edipedid  where
                edipedid.rspdtarq    = ?
                no-lock no-error.
    end.
    else do:
        find next edipedid use-index resposta where
            true
            no-lock no-error.
    end.        
end.    
             
if par-tipo = "up" 
then do:
    if par-pendente
    then do:
        find prev edipedid  where
                edipedid.rspdtarq    = ?
                no-lock no-error.
    end.
    else do:
        find prev edipedid use-index resposta where
            true
            no-lock no-error.
    end.        

end.    
        
end procedure.



