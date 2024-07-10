/* helio 28032023 - adequacao tipocupom ao projetoi cashback pagamentos */
/* #012023 helio cupom desconto b2b */
/* program~a responsavel pela gerenciamento de cupons */

{admcab.i}

def input param pacao       as char.
def input param ctitle      as char.

def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["filtra","csv",""].

def var pqtd as int.
form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def var vsel as int.
def var vabe as dec.

def var vvlcobrado   as dec.
def var pcla2-cod             like cupomb2b.clacod no-undo label "Cod Mercadologico".
def var vmercadologico as char label "Nivel Mercadologico" format "x(10)" extent 4 init
    ["Setor","Grupo","Classe","SubClasse"].
def var cmercadologico as char format "x(5)" column-label "Nivel".
    form  
    cupomb2b.idCupom  
    cupomb2b.etbcod   column-label "fil"
    cupomb2b.catcod   column-label "DEP" format "99"  
    cmercadologico format "x(5)" column-label "Nivel"
    cupomb2b.clacod column-label "Mercad"
    clase.clanom format "x(8)" column-label "Merc"
    cupomb2b.valorDesconto   column-label "valor"   format ">>>9.99"
    cupomb2b.percentualDesconto column-label "perc" format ">9.99"
    cupomb2b.dataValidade   format "99999999"
    cupomb2b.dataTransacao  format "99999999"
    /*
    cupomb2b.numeroComponente   = {2}.numeroComponente
    cupomb2b.nsuTransacao       = {2}.nsuTransacao
    cupomb2b.dataCriacao        = {2}.dataCriacao
    cupomb2b.horaCriacao        = {2}.horaCriacao
    cupomb2b.sequencia          = {2}.sequencia
    cupomb2b.quantidadeTotal    = {2}.quantidadeTotal.
    */
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





disp 
    pqtd  label "Quantidade"      format "zzzzzzzz9" colon 65
        with frame ftot
            side-labels
            row screen-lines - 2
            width 80
            no-box.
def var vdataTini as date format "99/99/9999" label "de".
def var vdataTfim as date format "99/99/9999" label "ate".
def var vdataGini as date format "99/99/9999" label "de".
def var vdataGfim as date format "99/99/9999" label "ate".


def var petbcod             like cupomb2b.etbcod no-undo.
def var pcatcod             like cupomb2b.catcod no-undo.
def var pdataValidade       like cupomb2b.dataValidade no-undo.

def var pfim as log no-undo.
pfim = no.
run pfiltra.
if not pfim
then return.

bl-princ:
repeat:
    
    pqtd = 0.
    if pacao = "ABERTOS"
    then do:
        for each cupomb2b where 
                        cupomb2b.tipocupom = "" and
                cupomb2b.dataTransacao = ? 
        and (if petbcod <> 0 then cupomb2b.etbcod = petbcod  else true)
        and (if pcla2-cod <> 0 then cupomb2b.clacod = pcla2-cod  else true ) 
        and (if pcatcod <> 0 then cupomb2b.catcod = pcatcod  else true) 
        and (if pdataValidade <> ? then cupomb2b.dataValidade <= pdataValidade else true) 
        no-lock.
            pqtd = pqtd + 1.

        end.
    end.
    if pacao = "USADOS"
    then do:
        for each cupomb2b where 
                        cupomb2b.tipocupom = "" and
                cupomb2b.dataTransacao >= vdataTini and cupomb2b.dataTransacao <= vdataTfim 
        and (if petbcod <> 0 then cupomb2b.etbcod = petbcod  else true)
        and (if pcla2-cod <> 0 then cupomb2b.clacod = pcla2-cod  else true ) 
        and (if pcatcod <> 0 then cupomb2b.catcod = pcatcod  else true) 
        and (if pdataValidade <> ? then cupomb2b.dataValidade <= pdataValidade else true) 
        no-lock.
            pqtd = pqtd + 1.

        end.
    end.
    
    if pacao = "TODOS"
    then do:
        for each cupomb2b where
                        cupomb2b.tipocupom = "" and
         (if petbcod <> 0 then cupomb2b.etbcod = petbcod  else true)
        and (if pcla2-cod <> 0 then cupomb2b.clacod = pcla2-cod  else true ) 
        and (if pcatcod <> 0 then cupomb2b.catcod = pcatcod  else true) 
        and (if pdataValidade <> ? then cupomb2b.dataValidade <= pdataValidade else true) 
        
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
            if esqcom1[esqpos1]  = "filtra"
            then do:
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.
                pfim = no.
                run pfiltra.
                if not pfim
                then leave.
                recatu1 = ?.
                leave.
            end.
            if esqcom1[esqpos1]  = "csv"
            then do:
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.
                run pcsv.
                recatu1 = ?.
                leave.
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
  
    cmercadologico = "".
    release clase.
    if cupomb2b.clacod > 0
    then do:
        find clase where clase.clacod =  cupomb2b.clacod no-lock no-error.
        cmercadologico = if avail clase
                         then vmercadologico[clase.clagrau]
                         else "".    
    end.    
    display  
    cupomb2b.idCupom  
    cupomb2b.catcod   
    cupomb2b.clacod   
    cmercadologico
    clase.clanom when avail clase
    cupomb2b.valorDesconto   when cupomb2b.valorDesconto <> 0 
    cupomb2b.percentualDesconto when cupomb2b.percentualDesconto <> 0
    cupomb2b.dataValidade   
    cupomb2b.etbcod   
    cupomb2b.dataTransacao  

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
    cupomb2b.idCupom  
    cupomb2b.catcod   
    cupomb2b.clacod   
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
    cupomb2b.catcod   
    cupomb2b.clacod   
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
    cupomb2b.catcod   
    cupomb2b.clacod   
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
                cupomb2b.tipocupom = "" and
                cupomb2b.dataTransacao = ?
        and (if petbcod <> 0 then cupomb2b.etbcod = petbcod  else true)
        and (if pcla2-cod <> 0 then cupomb2b.clacod = pcla2-cod  else true ) 
        and (if pcatcod <> 0 then cupomb2b.catcod = pcatcod  else true) 
        and (if pdataValidade <> ? then cupomb2b.dataValidade <= pdataValidade else true) 
        
                        no-lock no-error.
    end.    
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find next cupomb2b where   
                        cupomb2b.tipocupom = "" and
        cupomb2b.dataTransacao = ?
        and (if petbcod <> 0 then cupomb2b.etbcod = petbcod  else true)
        and (if pcla2-cod <> 0 then cupomb2b.clacod = pcla2-cod  else true ) 
        and (if pcatcod <> 0 then cupomb2b.catcod = pcatcod  else true) 
        and (if pdataValidade <> ? then cupomb2b.dataValidade <= pdataValidade else true) 

            no-lock no-error.
    end.    
    if par-tipo = "up" 
    then do:
        find prev cupomb2b where 
                        cupomb2b.tipocupom = "" and
         cupomb2b.dataTransacao = ?
        and (if petbcod <> 0 then cupomb2b.etbcod = petbcod  else true)
        and (if pcla2-cod <> 0 then cupomb2b.clacod = pcla2-cod  else true ) 
        and (if pcatcod <> 0 then cupomb2b.catcod = pcatcod  else true) 
        and (if pdataValidade <> ? then cupomb2b.dataValidade <= pdataValidade else true) 
        
            no-lock no-error.
    end.    

end.
if pacao = "USADOS"
then do:
    if par-tipo = "pri" 
    then do:
        find first cupomb2b where
                         cupomb2b.tipocupom = "" and
                    cupomb2b.dataTransacao >= vdataTini and cupomb2b.dataTransacao <= vdataTfim 
        and (if petbcod <> 0 then cupomb2b.etbcod = petbcod  else true)
        and (if pcla2-cod <> 0 then cupomb2b.clacod = pcla2-cod  else true ) 
        and (if pcatcod <> 0 then cupomb2b.catcod = pcatcod  else true) 
        and (if pdataValidade <> ? then cupomb2b.dataValidade <= pdataValidade else true) 
        
                        no-lock no-error.
    end.    
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find next cupomb2b where 
                        cupomb2b.tipocupom = "" and
        cupomb2b.dataTransacao >= vdataTini and cupomb2b.dataTransacao <= vdataTfim 
        and (if petbcod <> 0 then cupomb2b.etbcod = petbcod  else true)
        and (if pcla2-cod <> 0 then cupomb2b.clacod = pcla2-cod  else true ) 
        and (if pcatcod <> 0 then cupomb2b.catcod = pcatcod  else true) 
        and (if pdataValidade <> ? then cupomb2b.dataValidade <= pdataValidade else true) 

            no-lock no-error.
    end.    
    if par-tipo = "up" 
    then do:
        find prev cupomb2b where 
                        cupomb2b.tipocupom = "" and
        cupomb2b.dataTransacao >= vdataTini and cupomb2b.dataTransacao <= vdataTfim 
        and (if petbcod <> 0 then cupomb2b.etbcod = petbcod  else true)
        and (if pcla2-cod <> 0 then cupomb2b.clacod = pcla2-cod  else true ) 
        and (if pcatcod <> 0 then cupomb2b.catcod = pcatcod  else true) 
        and (if pdataValidade <> ? then cupomb2b.dataValidade <= pdataValidade else true) 
        
            no-lock no-error.
    end.    

end.

if pacao = "TODOS"
then do:
    if par-tipo = "pri" 
    then do:
        find first cupomb2b where
                        cupomb2b.tipocupom = "" and
         (if petbcod <> 0 then cupomb2b.etbcod = petbcod  else true)
        and (if pcla2-cod <> 0 then cupomb2b.clacod = pcla2-cod  else true ) 
        and (if pcatcod <> 0 then cupomb2b.catcod = pcatcod  else true) 
        and (if pdataValidade <> ? then cupomb2b.dataValidade <= pdataValidade else true) 
        
            no-lock no-error.
    end.    
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find next cupomb2b where
                        cupomb2b.tipocupom = "" and
         (if petbcod <> 0 then cupomb2b.etbcod = petbcod  else true)
        and (if pcla2-cod <> 0 then cupomb2b.clacod = pcla2-cod  else true ) 
        and (if pcatcod <> 0 then cupomb2b.catcod = pcatcod  else true) 
        and (if pdataValidade <> ? then cupomb2b.dataValidade <= pdataValidade else true) 
        
            no-lock no-error.
    end.    

    if par-tipo = "up" 
    then do:
        find prev cupomb2b where  
                        cupomb2b.tipocupom = "" and
        (if petbcod <> 0 then cupomb2b.etbcod = petbcod  else true)
        and (if pcla2-cod <> 0 then cupomb2b.clacod = pcla2-cod  else true ) 
        and (if pcatcod <> 0 then cupomb2b.catcod = pcatcod  else true) 
        and (if pdataValidade <> ? then cupomb2b.dataValidade <= pdataValidade else true) 
        
            no-lock no-error.
    end.    
end.
        
end procedure.




procedure pfiltra.
pfim = no.

repeat with frame fcab
    centered 1 down 1 col
    title "filtro de descontos b2b".

    update petbcod label "filial"
        help "filial ou zero para geral".
    if petbcod <> 0 then do:
        find estab where estab.etbcod = petbcod no-lock no-error.
        if not avail estab then do:
            message "filial" petbcod "nao cadastrada".
            undo.
        end.
    end.
    update pcatcod.
    if pcatcod <> 0 then do:
        find categoria where categoria.catcod = pcatcod no-lock no-error.
        if not avail categoria then do:
            message "categoria" petbcod "nao cadastrada".
            undo.
        end.
    end.
    else do:
        update pcla2-cod.
        if pcla2-cod <> 0 then do:
            find clase where clase.clacod = pcla2-cod no-lock no-error.
            if not avail clase then do:
                message "mercadologico" petbcod "nao cadastrado".
                undo.
            end.

            disp vmercadologico[clase.clagrau].
            
            disp clase.clanom label "Mercadologico".
        
        
        end.
    end.
        
    update pdataValidade.
    
    
    if pacao <> "USADOS"
    then do:
       update vdataGini label "geracao-> de" vdataGfim.
       if vdataGini = ?
       then disp  ctitle + " / " + pacao  @ ctitle format "x(70)" no-label with frame ftit.
       else do:
            if vdataGfim = ? then do:
                message "informe uma data final".
                undo.
            end.

            disp  ctitle + " / " + pacao + " Periodo: " + string(vdataGini,"99/99/9999") + " ate " + string(vdataGfim,"99/99/9999") 
                @ ctitle format "x(70)" no-label with frame ftit.
       end.
        
    end.    
    
    if pacao = "USADOS"
    then do:
        update vdataTini 
            with frame fdatat centered side-labels.
       if vdataTini = ?
       then do:
            message "informe um inicio para o periodo".
            undo.
       end.     
       else do:
            update vdataTfim with frame fdatat.
            
            if vdataTfim = ? then do:
                message "informe uma data final".
                undo.
            end.
            disp  ctitle + " / " + pacao + " Periodo: " + string(vdataTini,"99/99/9999") + " ate " + string(vdataTfim,"99/99/9999") 
                @ ctitle format "x(70)" no-label with frame ftit.
       end.
            
    end.
    pfim = yes.     
    
    
    leave.    
    
end.


end procedure.

procedure pcsv.
 
def var varqcsv as char format "x(65)".
    varqcsv = "/admcom/relat/cupomb2b_" + lc(pacao) + "_" + 
                string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".csv".
    
    update varqcsv no-label colon 12
                            with side-labels width 80 frame f1
                            row 15 title "csv cupons b2b"
                            overlay.


message "Aguarde...". 
pause 1 no-message.

output to value(varqcsv).
put unformatted 
    "IDCupom;categoria;nivel mercadologico;codigo Mercadologico;nome mercadologico;" +
    "valorDesconto;percentualDesconto;dataValidade;codigoLoja;dataTransacao;numeroComponente;nsuTransacao;dataCriacao"
    skip.

    if pacao = "ABERTOS"
    then do:
        for each cupomb2b where
                        cupomb2b.tipocupom = "" and
         cupomb2b.dataTransacao = ? 
        and (if petbcod <> 0 then cupomb2b.etbcod = petbcod  else true)
        and (if pcla2-cod <> 0 then cupomb2b.clacod = pcla2-cod  else true ) 
        and (if pcatcod <> 0 then cupomb2b.catcod = pcatcod  else true) 
        and (if pdataValidade <> ? then cupomb2b.dataValidade <= pdataValidade else true) 
        no-lock.
            run pcsvimp.
        end.
    end.
    if pacao = "USADOS"
    then do:
        for each cupomb2b where 
                        cupomb2b.tipocupom = "" and
        cupomb2b.dataTransacao >= vdataTini and cupomb2b.dataTransacao <= vdataTfim 
        and (if petbcod <> 0 then cupomb2b.etbcod = petbcod  else true)
        and (if pcla2-cod <> 0 then cupomb2b.clacod = pcla2-cod  else true ) 
        and (if pcatcod <> 0 then cupomb2b.catcod = pcatcod  else true) 
        and (if pdataValidade <> ? then cupomb2b.dataValidade <= pdataValidade else true) 
        no-lock.
            run pcsvimp.
        end.
    end.
    
    if pacao = "TODOS"
    then do:
        for each cupomb2b where
                        cupomb2b.tipocupom = "" and
         (if petbcod <> 0 then cupomb2b.etbcod = petbcod  else true)
        and (if pcla2-cod <> 0 then cupomb2b.clacod = pcla2-cod  else true ) 
        and (if pcatcod <> 0 then cupomb2b.catcod = pcatcod  else true) 
        and (if pdataValidade <> ? then cupomb2b.dataValidade <= pdataValidade else true) 
        
        no-lock.
            run pcsvimp.
        end.
    end.


output close.

end procedure.

procedure pcsvimp.

    find clase where clase.clacod = cupomb2b.clacod no-lock no-error.
    put unformatted skip
        cupomb2b.IDCupom            ";"
        cupomb2b.catcod             ";"
        (if avail clase then vmercadologico[clase.clagrau]   else "") ";" 
        cupomb2b.clacod             ";"
        (if avail clase then clase.clanom else "") ";"
        trim(string(cupomb2b.valorDesconto,"->>>>>>>>>9.99"))      ";"
        trim(string(cupomb2b.percentualDesconto,"->>>>>>>>>9.99")) ";"
        cupomb2b.dataValidade       ";"
        cupomb2b.etbcod             ";"
        cupomb2b.dataTransacao      ";"
        cupomb2b.numeroComponente   ";"
        cupomb2b.nsuTransacao       ";"
        cupomb2b.dataCriacao        ";"
        skip.

end procedure.
