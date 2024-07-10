/*
*
*    ediagendam.p    -    Esqueleto de Programacao    com esqvazio
*
*/

{admcab.i}
/*{tpalcis-wms.i}*/


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



bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ediagendam where recid(ediagendam) = recatu1 no-lock.
    if not available ediagendam
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

    recatu1 = recid(ediagendam).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ediagendam
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ediagendam where recid(ediagendam) = recatu1 no-lock.

        status default "".

        esqcom1[1] = "".
        esqcom1[2] = if par-pendente 
                     then " Todas"
                     else " So Pendentes".
        esqcom1[3] = " "             .
        esqcom1[4] = "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.

        choose field ediagendam.numero_ticket 
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
                    if not avail ediagendam
                    then leave.
                    recatu1 = recid(ediagendam).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ediagendam
                    then leave.
                    recatu1 = recid(ediagendam).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ediagendam
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ediagendam
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
            
            
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ediagendam).
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
    find pedid where pedid.pedtdc = ediagendam.pedtdc and
                               pedid.etbcod = ediagendam.etbcod and
                               pedid.pednum = ediagendam.pednum
                               no-lock no-error.

    find forne where forne.forcod = ediagendam.clfcod no-lock no-error.
    display  
        ediagendam.NUMERO_TICKET
        ediagendam.CGC_FORNECEDOR
        ediagendam.NUMERO_DOCUMENTO
        ediagendam.clfcod label "Forne" 
        forne.fornom                        format "x(12)" when avail forne
        
                    ediagendam.pednum
                    ediagendam.dtinc format "999999"
                    string(ediagendam.hrinc,"HH:MM") @ vhora
                    ediagendam.arquivo format "x(18)"
            ediagendam.dtagenda                    
        with frame frame-a 6 down centered color white/red row 5.
end procedure.

procedure color-message.
    color display message
              ediagendam.clfcod
            forne.fornom     
                    ediagendam.pednum
                    ediagendam.dtinc 
                    vhora
                    ediagendam.arquivo 

        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
              ediagendam.clfcod
            forne.fornom     
                    ediagendam.pednum
                    ediagendam.dtinc 
                    vhora
                    ediagendam.arquivo
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
    if par-pendente
    then do:
        find first ediagendam  where
                ediagendam.dtinc    = ?
                no-lock no-error.
    end.
    else do:
        find first ediagendam where
            true
            no-lock no-error.
    end.        
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if par-pendente
    then do:
        find next ediagendam  where
                ediagendam.dtinc    = ?
                no-lock no-error.
    end.
    else do:
        find next ediagendam where
            true
            no-lock no-error.
    end.        
end.    
             
if par-tipo = "up" 
then do:
    if par-pendente
    then do:
        find prev ediagendam  where
                ediagendam.dtinc    = ?
                no-lock no-error.
    end.
    else do:
        find prev ediagendam where
            true
            no-lock no-error.
    end.        

end.    
        
end procedure.



