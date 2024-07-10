{admcab.i}


def shared temp-table tt-devolver
    field procod like movim.procod
    field etbcod like movim.etbcod
    field movtdc like plani.movtdc
    field placod like plani.placod
    field pladat like plani.pladat
    field movpc  like movim.movpc
    field movqtm like movim.movqtm
    field serie  like plani.serie
    field numero like plani.numero
    field notped like plani.notped
    field movdev like movim.movdev.

def var vprocod-nf      like movim.procod format ">>>>>>>>>9".

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-devolver where recid(tt-devolver) = recatu1 no-lock.
        
    if not available tt-devolver
    then esqvazio = yes.
    else esqvazio = no.

    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid( tt-devolver).

    if not esqvazio
    then repeat:
        run leitura (input "seg").
        
        if not available tt-devolver
        then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        
        down with frame frame-a.
        run frame-a.
    end.
    
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find tt-devolver where recid( tt-devolver ) = recatu1 no-lock.
            
            run color-message.

            choose field tt-devolver.procod
                         produ.pronom
                         tt-devolver.movqtm
                         tt-devolver.movpc
                         help "" go-on(cursor-down cursor-up
                                       page-down   page-up
                                       PF4 F4 ESC return).
            
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    
                    if not avail tt-devolver
                    then leave.
                    
                    recatu1 = recid(tt-devolver).
                end.
                leave.
            end.
            
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail  tt-devolver
                    then leave.
                    recatu1 = recid( tt-devolver ).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-devolver
                then next.
        
                color display white/red tt-devolver.procod 
                                        produ.pronom 
                                        tt-devolver.movqtm 
                                        tt-devolver.movpc 
                                        with frame frame-a.
                                        
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail  tt-devolver
                then next.

                color display white/red tt-devolver.procod 
                                        produ.pronom 
                                        tt-devolver.movqtm 
                                        tt-devolver.movpc
                                        with frame frame-a.
                                        
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
                /*
                if esqcom1[esqpos1] = " Procura "
                then do with frame f-procura centered overlay
                             side-labels row 8 on error undo.
                    
                    view frame frame-a. pause 0.

                    update vprocod-nf label "Produto".  

                    find tt-devolver where 
                           and tt-devolver.procod = vprocod-nf no-lock no-error.
                               
                    if not avail tt-devolver
                    then do: 
                        message "Produto nao encontrado.". pause 1.
                        undo.
                    end.
                    
                    hide frame f-procura no-pause.
                    
                    recatu1 = recid( tt-devolver ).
                    leave.
                end.
                */                
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        recatu1 = recid(tt-devolver).
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
    find produ where produ.procod = tt-devolver.procod no-lock no-error.
    
    display
        tt-devolver.numero column-label "Numero NF" format ">>>>>>>9"
        tt-devolver.procod column-label "Produto" format ">>>>>>>9"
        produ.pronom       column-label "Descricao" format "x(30)"
                                        when avail produ
        tt-devolver.movqtm column-label "Quant"
        tt-devolver.movpc  column-label "Pc.Unit"
        with frame frame-a 11 down centered color white/red row 5
                                 title " Produtos Selecionados ".
end procedure.

procedure color-message.
    find produ where produ.procod = tt-devolver.procod no-lock no-error.

    color display message
            tt-devolver.numero
            tt-devolver.procod
            produ.pronom
            tt-devolver.movqtm
            tt-devolver.movpc
            with frame frame-a.
end procedure.

procedure color-normal.
    find produ where produ.procod = tt-devolver.procod no-lock no-error.

    color display normal
            tt-devolver.numero
            tt-devolver.procod
            produ.pronom
            tt-devolver.movqtm
            tt-devolver.movpc
            with frame frame-a.
            
end procedure.


procedure leitura.
def input parameter par-tipo as char.

if par-tipo = "pri" 
then   find first tt-devolver where true no-lock no-error.

if par-tipo = "seg" or par-tipo = "down" 
then   find next tt-devolver where true no-lock no-error.

if par-tipo = "up" 
then   find prev tt-devolver where true no-lock no-error.

end procedure.
