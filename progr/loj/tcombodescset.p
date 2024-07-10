/* helio 28032023 - adequacao tipocupom ao projetoi cashback pagamentos */
/* #012023 helio cupom desconto b2b */
/* program~a responsavel pela gerenciamento de cupons */

{admcab.i}
def input param precid as recid.

def var pcla2-cod like combodescset.clacod label "Setor".
def buffer bcombodescset for combodescset.
def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" parametros "," inclusao "," exclui","",""].

form
    esqcom1
    with frame f-com1 row 7 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def buffer ufinan for finan.

find combodescplan where recid(combodescplan) = precid no-lock.
    find  finan where  finan.fincod = combodescplan.fincod no-lock.
    find ufinan where ufinan.fincod = combodescplan.finusar no-lock.   

disp  
    combodescplan.etbcod   column-label "fil"
    combodescplan.fincod  
    finan.finnom format "x(15)"
    finan.finnpc
    combodescplan.finusar 
    ufinan.finnom format "x(15)"
    combodescplan.percdesc 
        with frame ftit
            row 5
            centered
            no-box
            color messages 1 down no-underline.

form  
    combodescset.catcod   column-label "categ"
    categoria.catnom    
    combodescset.clacod column-label "setor"
    clase.clanom format "x(15)" column-label "setor"
    combodescset.percdesc 
        with frame frame-a 5 down centered row 8
        no-box.


bl-princ:
repeat:
    
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find combodescset where recid(combodescset) = recatu1 no-lock.
    if not available combodescset
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(combodescset).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available combodescset
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find combodescset where recid(combodescset) = recatu1 no-lock.
        /*
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 6.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 6.
            esqcom1[vx] = "".
        end.     
        */
        
        disp esqcom1 with frame f-com1.
        
        run color-message.

        choose field combodescset.catcod                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

        if keyfunction(lastkey) <> "return"
        then run color-normal.

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
                    if not avail combodescset
                    then leave.
                    recatu1 = recid(combodescset).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail combodescset
                    then leave.
                    recatu1 = recid(combodescset).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail combodescset
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail combodescset
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
                recatu1 = ?.
                leave.
                
            end. 
            if esqcom1[esqpos1] = " exclui "
            then do:
                do on error undo:
                    message "confirme exclusao?" update sresp.
                    if sresp
                    then do:
                        find current combodescset.
                        delete combodescset.    
                    end.                
                end.
                recatu1 = ?.
                leave.
                
            end. 

        end. 
        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(combodescset).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame ftit no-pause.
hide frame ftot no-pause.
return.
 
procedure frame-a.
  

    find categoria where categoria.catcod = combodescset.catcod no-lock.
    find clase     where clase.clacod     = combodescset.clacod no-lock no-error.
    disp
    combodescset.catcod 
    categoria.catnom    
    combodescset.clacod 
    clase.clanom when avail clase
    combodescset.percdesc 

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
    combodescset.catcod 
    categoria.catnom    
    combodescset.clacod
    clase.clanom 
    combodescset.percdesc 
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
    combodescset.catcod 
    categoria.catnom    
    combodescset.clacod
    clase.clanom 
    combodescset.percdesc 
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
    combodescset.catcod 
    categoria.catnom    
    combodescset.clacod
    clase.clanom 
    combodescset.percdesc 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find first combodescset of combodescplan
                        no-lock no-error.
    end.    
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find next combodescset of combodescplan
            no-lock no-error.
    end.    
    if par-tipo = "up" 
    then do:
        find prev combodescset of combodescplan
            no-lock no-error.
    end.    

        
end procedure.





procedure pparametros.

    do on error undo:

        find current combodescset exclusive.
        disp combodescset.etbcod.
        disp    
                   combodescset.etbcod
                           combodescset.fincod
                                   combodescset.catcod
                                           combodescset.clacod @ pcla2-cod
                                           
                   with row 9 
        centered
        overlay 1 column.
                    
        update combodescset.percdesc.

        if  combodescset.percdesc > 100
        then do:
            message "percentual invalido.".
            undo, retry.
        end.   

    end.

end.


procedure pinclui.
def output param prec as recid.
do on error undo.

    create combodescset.
    prec = recid(combodescset).
    combodescset.etbcod = combodescplan.etbcod.
    combodescset.fincod = combodescplan.fincod.
    disp
        combodescset.etbcod
        combodescset.fincod
        combodescset.catcod 
        with row 9 
        centered
        overlay 1 column.
        update
            combodescset.catcod.
            

        find categoria where categoria.catcod = combodescset.catcod no-lock no-error.
        if not avail categoria or combodescset.catcod = 0
        then do:
            message "categoria invalida".
            undo, retry.
        end.   

        pcla2-cod = combodescset.clacod.
        update pcla2-cod label "Setor".

            find clase where clase.clacod = pcla2-cod no-lock no-error.
            if not avail clase and pcla2-cod > 0 then do:
                message "mercadologico" pcla2-cod "nao cadastrado".
                undo.
            end.

            combodescset.clacod = pcla2-cod.

        if avail clase and not clase.clagrau = 1 /* setor */
        then do:
            message "codigo nao eh setor".
            undo, retry.
        end.   
        
        /*
        if combodescset.clacod = 0
        then do:
            find first bcombodescset of combodescplan where  bcombodescset.catcod = combodescset.catcod and
                                                             bcombodescset.clacod > 0 no-lock no-error.
            if avail bcombodescset
            then do:
                message "ja existe configuracao para setor, nao pode deixar geral".  
                undo, retry.
            end.
        end.
        */
        update combodescset.percdesc.
        if combodescset.percdesc > 100
        then do:
            message "percentual invalido.".
            undo, retry.
        end.   
                                              


end.


end procedure.


