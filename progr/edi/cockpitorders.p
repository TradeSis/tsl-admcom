/*
*
*    edipedid.p    -    Esqueleto de Programacao    com esqvazio
*
*/

{admcab.i}

def var par-pendente   as log init yes.

def var vhora   as char format "x(05)" column-label "Hora".

def new shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char     
    field Arquivo       as char initial ?
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.
    
def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(15)" extent 5
    initial [" ", " Todas ", " Cons.NFE","", ""].

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


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

        esqcom1[1] = if edipedid.dtenvio = ? 
                     then " Exporta" 
                     else "" .


        esqcom1[2] = if par-pendente 
                     then " Todas"
                     else " So Pendentes".
        esqcom1[3] = " "             .
        release pedid.
        find pedid where pedid.pedtdc = edipedid.pedtdc and
                               pedid.etbcod = edipedid.etbcod and
                               pedid.pednum = edipedid.pednum
                               no-lock no-error.
        if avail pedid 
        then do:
            esqcom1[3]= " Cons.Pedid".
        end.
        
        esqcom1[5] = " Altera".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.

        disp edipedid.clfcod column-label "Forne".
        
        
        choose field edipedid.clfcod 
                help "Refresh de 15 segundos"
                pause 15
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
        run color-normal.
        pause 0. 

        if lastkey = -1 
        then do:  
             next bl-princ. 
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
                
                run not_consnota.p (recid(pedid)).
                
            end.
            
            if esqcom1[esqpos1] = " Exporta "
            then do.
                /* EDI */

                run edi/exporders.p (input recid(edipedid)).

                recatu1 = ?.
                clear  frame frame-a all no-pause.
                next bl-princ.
            end.
            
            
            
            if esqcom1[esqpos1] = " Altera"
            then do on error undo:
                find current edipedid exclusive.
                
                def  var vtipo as log format "1-Orders/2-OrdChg".
                    
                message "1-Orders/2-OrdChg" update vtipo.
                if vtipo then edipedid.acao = "INSERT". else edipedid.acao = "ENVIADO".
                disp edipedid.acao with frame frame-a .
                
                edipedid.dtenvio = ?.
                edipedid.diretorio = "".
                edipedid.arquivo = "".
                edipedid.hrenvio = ?.
                
            
            end.
            
            
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

    find forne where forne.forcod = pedid.clfcod no-lock no-error.
    display 
                    edipedid.clfcod
            forne.fornom                        format "x(12)"   when avail forne
                    edipedid.etbcod
                    edipedid.pednum
                    edipedid.acao format "x(10)"
                    edipedid.dtenvio  format "999999"
                    string(edipedid.hrenvio,"HH:MM") @ vhora
                    edipedid.arquivo format "x(18)"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
    color display message
edipedid.clfcod
                    edipedid.etbcod
                    edipedid.pednum
                    edipedid.acao 
                    edipedid.dtenvio vhora
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
edipedid.clfcod
                    edipedid.etbcod
                    edipedid.pednum
                    edipedid.acao 
                    edipedid.dtenvio 
            vhora
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
    if par-pendente
    then do:
        find first edipedid  where
                edipedid.dtenvio = ?
                and edipedid.pedtdc = 1 /*and
           (edipedid.clfcod = 185 or
            edipedid.clfcod = 110480 or
            edipedid.clfcod = 11 or
            edipedid.clfcod = 119425 or
            edipedid.clfcod = 118398 or
            edipedid.clfcod = 32) */

                no-lock no-error.
    end.
    else do:
        find first edipedid where
                edipedid.pedtdc = 1 /*and
           (edipedid.clfcod = 185 or
            edipedid.clfcod = 110480 or
            edipedid.clfcod = 11 or
            edipedid.clfcod = 119425 or
            edipedid.clfcod = 118398 or
            edipedid.clfcod = 32)  */

            no-lock no-error.
    end.        
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if par-pendente
    then do:
        find next edipedid  where
                edipedid.dtenvio     = ?
                and edipedid.pedtdc = 1 /*and
           (edipedid.clfcod = 185 or
            edipedid.clfcod = 110480 or
            edipedid.clfcod = 11 or
            edipedid.clfcod = 119425 or
            edipedid.clfcod = 118398 or
            edipedid.clfcod = 32) */

                no-lock no-error.
    end.
    else do:
        find next edipedid where    
                edipedid.pedtdc = 1 /* and
           (edipedid.clfcod = 185 or
            edipedid.clfcod = 110480 or
            edipedid.clfcod = 11 or
            edipedid.clfcod = 119425 or
            edipedid.clfcod = 118398 or
            edipedid.clfcod = 32)      */

                            no-lock no-error.
    end.        
end.    
             
if par-tipo = "up" 
then do:
    if par-pendente
    then do:
        find prev edipedid  where
                edipedid.dtenvio     = ? /*and
           (edipedid.clfcod = 185 or
            edipedid.clfcod = 110480 or
            edipedid.clfcod = 11 or
            edipedid.clfcod = 119425) */

                and edipedid.pedtdc = 1
                no-lock no-error.
    end.
    else do:
        find prev edipedid where
                edipedid.pedtdc = 1 /*and
           (edipedid.clfcod = 185 or
            edipedid.clfcod = 110480 or
            edipedid.clfcod = 11 or
            edipedid.clfcod = 119425) */

            no-lock no-error.
    end.        

end.    
        
end procedure.

