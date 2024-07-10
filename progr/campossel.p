/* helio 14082023 - M Histórico de alteração - Solicitação compliance */
{admcab.i}
def var ctitle as char init " ESCOLHA OS CAMPOS PARA VERIFICACAO ".
    
def var xtime as int.
def var vconta as int.

def shared temp-table ttcampos no-undo
    field campo as char format "x(20)"     
    field campoLabel as char format "x(20)"
    field marca     as log format "*/ " column-label "*"
    index x is unique primary campo asc.

input from ../progr/clien.campos.txt.
repeat transaction. 
    create ttcampos. 
    import delimiter ";" ttcampos.
    if ttcampos.campo = "" or ttcampos.campo = ? then delete ttcampos.
    else 
        if ttcampos.campo = "Cpf/CNPJ" or
           ttcampos.campo = "clinom" or
           ttcampos.campo = "ciinsc" or
           ttcampos.campo = "email" or
           ttcampos.campo = "fone" or
           ttcampos.campo = "celular" or
           ttcampos.campo = "endereco" or
           ttcampos.campo = "bairro" or
           ttcampos.campo = "cidade" or
           ttcampos.campo = "ufecod" or
           ttcampos.campo = "cep" or
           ttcampos.campo = "compl" or
           ttcampos.campo = "numero"
        then ttcampos.marca = yes.
end.
input close.        
for each ttcampos where ttcampos.campo = "" or ttcampos.campoLabel = ?.
    delete ttcampos.
end.    


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" Pesquisa "," marca" ," ",""].


form
    esqcom1
    with frame f-com1 row 10 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

    disp 
        ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 7
            centered
            no-box
            color messages.


    form   
        ttcampos.marca
        ttcampos.campo
        ttcampos.campoLabel
        with frame frame-a 6 down centered row 11
        no-box.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttcampos where recid(ttcampos) = recatu1 no-lock.
    if not available ttcampos
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttcampos).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttcampos
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttcampos where recid(ttcampos) = recatu1 no-lock.

        status default "".
        if ttcampos.marca 
        then esqcom1[2] = " Desmarca".
        else esqcom1[2] = " Marca".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field ttcampos.campoLabel

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
                    if not avail ttcampos
                    then leave.
                    recatu1 = recid(ttcampos).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttcampos
                    then leave.
                    recatu1 = recid(ttcampos).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttcampos
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttcampos
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            

            if esqcom1[esqpos1] = " Marca " or
               esqcom1[esqpos1] = " Desmarca"
            then do:
                ttcampos.marca = not ttcampos.marca.
            end.
            if  esqcom1[esqpos1] = " Pesquisa "
            then leave bl-princ. 
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttcampos).
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
    display  
        ttcampos.campo
        ttcampos.campoLabel
        ttcampos.marca
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
            ttcampos.campo

        ttcampos.campoLabel
        ttcampos.marca

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
            ttcampos.campo

        ttcampos.campoLabel
        ttcampos.marca
        
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
            ttcampos.campo

        ttcampos.campoLabel
        ttcampos.marca
        
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first ttcampos  where
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next ttcampos  where
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev ttcampos  where
                no-lock no-error.

end.    
        
end procedure.


