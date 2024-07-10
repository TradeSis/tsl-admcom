/* helio 05042023 - complementos */
/* #012023 helio cupom desconto b2b */
/* programa responsavel pela gerenciamento de cupons */

{admcab.i}

def input param pacao       as char.
def input param ctitle      as char.
def var pcpf    like neuclien.cpf.
def var pclicod  as int.
def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["","",""].

def var pqtd as int.
form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def var vsel as int.
def var vabe as dec.
def var vvlcobrado   as dec.
    form
    cupomb2b.idCupom  
    cupomb2b.etbcriacao column-label "fil!ger"
    cupomb2b.dataCriacao column-label "Dt Ger"
    cupomb2b.clicod

    cupomb2b.valorDesconto   column-label "valor"   format ">>>9.99"
    cupomb2b.percentualDesconto column-label "perc" format ">9.99"
    cupomb2b.dataValidade   format "99999999"
    cupomb2b.dataTransacao  format "99999999"
    cupomb2b.nsutransacao format "x(04)" column-label "NSU"
    cupomb2b.etbcod   column-label "fil!uso"

        with frame frame-a 9 down centered row 7
        no-box.



disp 
    ctitle + " / " + pacao @ ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.



def var pfim as log no-undo.
pfim = no.
update pcpf label "codigo/cpf"  format ">>>>>>>>>>>>>>9"
    with frame fcli centered row 4 width 80 side-labels.

find clien where clien.clicod = int64(pcpf) no-lock no-error.
if not avail clien
then do:
    find neuclien where neuclien.cpf = pcpf no-lock no-error.
    if avail neuclien
    then pclicod = neuclien.clicod.
    else do:
        message "cliente nao encontrado".
        undo.
    end.
end.
else pclicod = clien.clicod.

disp 
    pqtd  label "Quantidade"      format "zzzzzzzz9" colon 65
        with frame ftot
            side-labels
            row screen-lines - 2
            width 80
            no-box.


bl-princ:
repeat:
    
    pqtd = 0.
    if pacao = "ABERTOS"
    then do:
        for each cupomb2b where 
                        cupomb2b.tipocupom = "CASHB" and cupomb2b.clicod = pclicod and 
                cupomb2b.dataTransacao = ? 
        no-lock.
            pqtd = pqtd + 1.

        end.
    end.
    if pacao = "USADOS"
    then do:
        for each cupomb2b where 
                        cupomb2b.tipocupom = "CASHB" and cupomb2b.clicod = pclicod and
                cupomb2b.dataTransacao <> ?
        no-lock.
            pqtd = pqtd + 1.

        end.
    end.
    if pacao = "reabertura"
    then do:
        for each cupomb2b where 
                        cupomb2b.tipocupom = "CASHB" and cupomb2b.clicod = pclicod and
                cupomb2b.dataTransacao <> ?
                and cupomb2b.nsuTransacao = ?
            no-lock.
            pqtd = pqtd + 1.

        end.
    end.
    
    
    if pacao = "TODOS"
    then do:
        for each cupomb2b where
                        cupomb2b.tipocupom = "CASHB" and cupomb2b.clicod = pclicod 
        
        no-lock.
            pqtd = pqtd + 1.
        end.
    end.
       
    disp
        pqtd
        with frame ftot.

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find cupomb2b where recid(cupomb2b) = recatu1 no-lock.
    if not available cupomb2b
    then do.
        message "nenhum registro encontrato".
        pause.
        return.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(cupomb2b).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available cupomb2b
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find cupomb2b where recid(cupomb2b) = recatu1 no-lock.
        esqcom1[1] = if pacao = "REABERTURA"
                     then "reabre"
                         else "".
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

        choose field cupomb2b.idcupom
                go-on(cursor-down cursor-up
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
                    if not avail cupomb2b
                    then leave.
                    recatu1 = recid(cupomb2b).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cupomb2b
                    then leave.
                    recatu1 = recid(cupomb2b).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cupomb2b
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cupomb2b
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            if esqcom1[esqpos1] = "reabre"
            then do on error undo:
                find current cupomb2b.
                if cupomb2b.nsutransacao = ?
                then do:
                    message "confirma reabertura?" update sresp.
                    cupomb2b.datatransacao = ?.
                end.    
            end.
            
        end. 
        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(cupomb2b).
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
  
    
    display  
    cupomb2b.idCupom  
    cupomb2b.etbcriacao
    cupomb2b.dataCriacao
        cupomb2b.clicod
    /*
    cupomb2b.catcod   
    cupomb2b.clacod   
    cmercadologico
    clase.clanom when avail clase
    */
    cupomb2b.valorDesconto   when cupomb2b.valorDesconto <> 0 
    cupomb2b.percentualDesconto when cupomb2b.percentualDesconto <> 0
    cupomb2b.dataValidade   
    cupomb2b.etbcod   
    cupomb2b.dataTransacao  
    cupomb2b.nsutransacao    
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
    cupomb2b.idCupom  
    cupomb2b.valorDesconto   
    cupomb2b.percentualDesconto 
    cupomb2b.dataValidade   
    cupomb2b.etbcod   
    cupomb2b.dataTransacao  
                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
    cupomb2b.idCupom  
    cupomb2b.valorDesconto   
    cupomb2b.percentualDesconto 
    cupomb2b.dataValidade   
    cupomb2b.etbcod   
    cupomb2b.dataTransacao  

        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
    cupomb2b.idCupom  
    cupomb2b.valorDesconto   
    cupomb2b.percentualDesconto 
    cupomb2b.dataValidade   
    cupomb2b.etbcod   
    cupomb2b.dataTransacao  
 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

if pacao = "ABERTOS"
then do:
    if par-tipo = "pri" 
    then do:
        find first cupomb2b where  
                cupomb2b.tipocupom = "CASHB" and cupomb2b.clicod = pclicod and
                cupomb2b.dataTransacao = ?
        
                        no-lock no-error.
    end.    
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find next cupomb2b where   
                        cupomb2b.tipocupom = "CASHB" and cupomb2b.clicod = pclicod and
        cupomb2b.dataTransacao = ?

            no-lock no-error.
    end.    
    if par-tipo = "up" 
    then do:
        find prev cupomb2b where 
                        cupomb2b.tipocupom = "CASHB" and cupomb2b.clicod = pclicod and
         cupomb2b.dataTransacao = ?
        
            no-lock no-error.
    end.    

end.
if pacao = "USADOS"
then do:
    if par-tipo = "pri" 
    then do:
        find first cupomb2b where
                         cupomb2b.tipocupom = "CASHB" and cupomb2b.clicod = pclicod and
                    cupomb2b.dataTransacao <> ?
                        no-lock no-error.
    end.    
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find next cupomb2b where 
                        cupomb2b.tipocupom = "CASHB" and cupomb2b.clicod = pclicod and
        cupomb2b.dataTransacao <> ?

            no-lock no-error.
    end.    
    if par-tipo = "up" 
    then do:
        find prev cupomb2b where 
                        cupomb2b.tipocupom = "CASHB" and cupomb2b.clicod = pclicod and
        cupomb2b.dataTransacao <> ?
        
            no-lock no-error.
    end.    

end.

if pacao = "TODOS"
then do:
    if par-tipo = "pri" 
    then do:
        find first cupomb2b where
                        cupomb2b.tipocupom = "CASHB"  and cupomb2b.clicod = pclicod 
        
            no-lock no-error.
    end.    
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find next cupomb2b where
                        cupomb2b.tipocupom = "CASHB" and cupomb2b.clicod = pclicod 
            no-lock no-error.
    end.    

    if par-tipo = "up" 
    then do:
        find prev cupomb2b where  
                        cupomb2b.tipocupom = "CASHB" and cupomb2b.clicod = pclicod 
        
            no-lock no-error.
    end.    
end.
if pacao = "REABERTURA"
then do:
    if par-tipo = "pri" 
    then do:
        find first cupomb2b where
                         cupomb2b.tipocupom = "CASHB" and cupomb2b.clicod = pclicod and
                    cupomb2b.dataTransacao <> ?
                   and cupomb2b.nsutransacao = ?
                        no-lock no-error.
    end.    
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find next cupomb2b where 
                        cupomb2b.tipocupom = "CASHB" and cupomb2b.clicod = pclicod and
        cupomb2b.dataTransacao <> ?
                   and cupomb2b.nsutransacao = ?

            no-lock no-error.
    end.    
    if par-tipo = "up" 
    then do:
        find prev cupomb2b where 
                        cupomb2b.tipocupom = "CASHB" and cupomb2b.clicod = pclicod and
        cupomb2b.dataTransacao <> ?
                   and cupomb2b.nsutransacao = ?
        
            no-lock no-error.
    end.    

end.
        
end procedure.






