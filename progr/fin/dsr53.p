
{admcab.i}

def var xtime as int.

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" consulta"," baixados"," arquivo"," ",""].

def var vbaixados as log.
vbaixados = no.
def var par-dtini as date.

def new shared frame f-banco.
    form
        CMon.bancod    colon 12    label "Bco/Age/Cta"
        CMon.agecod             no-label
        CMon.ccornum            no-label format "x(15)"
        CMon.cxanom              format "x(16)" no-label
        func.funape             format "x(10)" no-label
        CMon.cxadt          format "99/99/9999" no-label
         with frame f-banco row 3 width 81 /*color messages*/
                         side-labels no-box.



def new shared frame f-cmon.
    form cmon.etbcod    label "Etb" format ">>9"
         CMon.cxacod    label "PDV" format ">>9"
         CMon.cxanom    no-label
         par-dtini          label "Dt Ini"
         CMon.cxadt         colon 65 format "99/99/9999" label "Data"
         with frame f-CMon row 3 width 81
                         side-labels no-box.

form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

    form 
        desenr53.cpf
        desenr53.FeeOperador     
        desenr53.FeeAF           
        desenr53.valorlancamento 
        desenr53.dataMovimento   
        desenr53.ctmcod column-label "TPB" desenr53.sequencia column-label "Seq" format "999"
        with frame frame-a 8 down centered row 8 title if vbaixados then " BAIXADOS " else " ABERTOS ".


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find desenr53 where recid(desenr53) = recatu1 no-lock.
    if not available desenr53
    then do.
        hide message no-pause.
        message "Registro nao localizado".
        pause.
        run fin/dsrroda.p.
        return.

    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(desenr53).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available desenr53
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find desenr53 where recid(desenr53) = recatu1 no-lock.

        status default "".
        if desenr53.sequencia <> ?
        then esqcom1[1] = " consulta".
        else esqcom1[1] = "".
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field desenr53.cpf

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
                    if not avail desenr53
                    then leave.
                    recatu1 = recid(desenr53).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail desenr53
                    then leave.
                    recatu1 = recid(desenr53).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail desenr53
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail desenr53
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            

            if esqcom1[esqpos1] = " arquivo"
            then do:
                run fin/dsrroda.p.
                recatu1 = ?.
                leave.
            end.
            if esqcom1[esqpos1] = " baixados "
            then do:
                vbaixados = yes.
                esqcom1[esqpos1] = " abertos ".
                color disp normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = 1.
                hide frame frame-a no-pause.
                recatu1 = ?.
                leave.
            end.
            if esqcom1[esqpos1] = " abertos "
            then do:
                vbaixados = no.
                esqcom1[esqpos1] = " baixados ".
                                hide frame frame-a no-pause.
                recatu1 = ?.
                leave.
            end. 

            if  esqcom1[esqpos1] = " Consulta"
            then do:
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.
                                
                                find first pdvtmov where pdvtmov.ctmcod = desenr53.ctmcod no-lock.

                find cmon where cmon.etbcod = 999 and cmon.cxacod = 99 no-lock.
                                                          
                find first pdvmov where   pdvmov.etbcod = cmon.etbcod and
                                    pdvmov.cmocod = cmon.cmocod and
                                    pdvmov.datamov = desenr53.dataMovimento and
                                    pdvmov.sequencia = desenr53.sequencia and
                                    pdvmov.ctmcod = desenr53.ctmcod
                                    no-lock no-error.
                if avail pdvmov
                then do:    
                    run dpdv/pdvcope.p (recid(pdvmov))            .
                end.                    
                
                
            end.    
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(desenr53).
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
procedure frame-a.
    display  
        desenr53.cpf
        desenr53.FeeOperador     
        desenr53.FeeAF           
        desenr53.valorlancamento 
        desenr53.dataMovimento   
        desenr53.ctmcod
        desenr53.sequencia
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        desenr53.cpf
        desenr53.FeeOperador     
        desenr53.FeeAF           
        desenr53.valorlancamento 
        desenr53.dataMovimento   
        desenr53.ctmcod
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        desenr53.cpf
        desenr53.FeeOperador     
        desenr53.FeeAF           
        desenr53.valorlancamento 
        desenr53.dataMovimento   
        desenr53.ctmcod

        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        desenr53.cpf
        desenr53.FeeOperador     
        desenr53.FeeAF           
        desenr53.valorlancamento 
        desenr53.dataMovimento   
        desenr53.ctmcod
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find last desenr53  where (if not vbaixados 
                                   then (desenr53.sequencia = ?)
                                   else (desenr53.sequencia <> ?))
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find prev desenr53 where (if not vbaixados 
                                   then (desenr53.sequencia = ?)
                                   else (desenr53.sequencia <> ?))

                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find next desenr53 where (if not vbaixados 
                                   then (desenr53.sequencia = ?)
                                   else (desenr53.sequencia <> ?))

                no-lock no-error.

end.    
        
end procedure.

