/* helio 23022022 - iepro */

{admcab.i}

def input param par-rec as recid. 
    
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" inclusao"," exclusao  ","-"," "].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


find novcampanha where recid(novcampanha) = par-rec no-lock.
def var vemprotesto as log format "Protesto/".

    form  
        
        novcampctr.clicod
        clien.clinom format "x(15)"
        novcampctr.contnum
        vemprotesto column-label "prot"        
        with frame frame-a 8 down centered row 8
            title novcampanha.camnom.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find novcampctr where recid(novcampctr) = recatu1 no-lock.
    if not available novcampctr
    then do.
        hide frame frame-a no-pause.
        if novcampanha.tpcampanha = "PRO"
        then message "sem nenhum cliente definido, a negociacao vale para todos os clientes em protesto.".
        else message "sem nenhum cliente definido, a campanha vale para todos os clientes.".
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(novcampctr).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available novcampctr
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find novcampctr where recid(novcampctr) = recatu1 no-lock.

        status default "".
        
                        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field novcampctr.clicod

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
                    if not avail novcampctr
                    then leave.
                    recatu1 = recid(novcampctr).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail novcampctr
                    then leave.
                    recatu1 = recid(novcampctr).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail novcampctr
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail novcampctr
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
                run pexclui.    
                recatu1 = ?.
                leave.
            end.
            if esqcom1[esqpos1] = " inclusao "
            then do:
                hide frame f-com1 no-pause.
                run pinclui (output recatu1).
                leave.
                
            end. 
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(novcampctr).
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
    find clien where clien.clicod = novcampctr.clicod no-lock.

    find first titprotesto where 
                titprotesto.operacao = "IEPRO" and
                titprotesto.clicod   = clien.clicod
                no-lock no-error.
    vemprotesto = avail titprotesto.
    
    display  
        novcampctr.clicod
        clien.clinom
        novcampctr.contnum
        vemprotesto 
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        novcampctr.clicod
        clien.clinom
        novcampctr.contnum

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        novcampctr.clicod
        clien.clinom
        novcampctr.contnum

        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        novcampctr.clicod
        clien.clinom
        novcampctr.contnum

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first novcampctr  of novcampanha
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next novcampctr  of novcampanha
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev novcampctr of novcampanha
                no-lock no-error.

end.    
        
end procedure.



procedure pexclui.

    do on error undo:

        find current novcampctr exclusive.
        delete novcampctr.
    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    create novcampctr.
    prec = recid(novcampctr).
    novcampctr.camcod = novcampanha.camcod.
    
    update
        novcampctr.clicod validate (novcampctr.clicod > 0,"digite um codigo valido")
        with row 9 
        centered
        overlay.

    find clien where clien.clicod = novcampctr.clicod no-lock no-error.
    if not avail estab
    then do:
        message "cliente nao cadastrado".
        pause.
        undo.
    end.


    if novcampanha.tpcampanha = "PRO"
    then do:

        find first titprotesto where 
                titprotesto.operacao = "IEPRO" and
                titprotesto.clicod   = clien.clicod
                no-lock no-error.
        if not avail titprotesto
        then do:
            message "cliente NAO TEM contrato em protesto! continuar o cadastramento?" update sresp.
            if not sresp
            then undo.
        end.
    end.
    else do: 
    
        find first titprotesto where 
                titprotesto.operacao = "IEPRO" and
                titprotesto.clicod   = clien.clicod
                no-lock no-error.
        if avail titprotesto
        then do:
            if novcampanha.PermiteTitProtesto = yes
            then do:
                message "cliente POSSUI contrato em protesto! continuar o cadastramento?" update sresp.
                if not sresp
                then undo.
            end.
            else do:
                message "cliente POSSUI contrato em protesto! cadastramento NAO permitido!".
                if not sresp
                then undo.
            
            end.
        end.
    end.
    
    update novcampctr.contnum.
end.


end procedure.


