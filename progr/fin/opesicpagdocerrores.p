/*               to
*                                 R
*
*/

{admcab.i}

def var pfiltro as char.
/*def input param poperacao   like sicred_contrato.operacao.*/
/*def input param pcobcod     like sicred_contrato.cobcod.*/
def input param pstatus     like sicred_contrato.sstatus.
/*
def input param pdatamov    like sicred_contrato.datamov.
def input param pctmcod     like sicred_contrato.ctmcod.
def input param pmodcod     like contrato.modcod.
def input param ptpcontrato like contrato.tpcontrato.
def shared var vdtini as date format "99/99/9999" label "De".
def shared var vdtfin as date format "99/99/9999" label "Ate".              
*/

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["<registros>",""," "," "," "].
form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def var par-dtini as date.
def new shared frame f-cmon.
    form cmon.etbcod    label "Etb" format ">>9"
         CMon.cxacod    label "PDV" format ">>9"
         CMon.cxanom    no-label
         par-dtini          label "Dt Ini"
         CMon.cxadt         colon 65 format "99/99/9999" label "Data"
         with frame f-CMon row 3 width 81
                         side-labels no-box.
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


def new shared temp-table ttnovacao no-undo
    field tipo      as char
    field contnum   like contrato.contnum format ">>>>>>>>>>9"
    field valor     like contrato.vltotal
    index idx is unique primary tipo desc contnum asc.


def  temp-table tterro no-undo
    field descerro  like sicred_pagam.descerro
    field qtd       as int
    index idx is unique primary 
        descerro asc.
        
def buffer btterro for tterro.

        /*
def var vfiltro as char.

    vfiltro = /*caps(poperacao) + "/" +*/ caps(pstatus).
    
disp
    vfiltro no-label format "x(50)"

    with frame fcab
    row 4 no-box
        side-labels
        width 80
        color underline.
          */
    form  

        tterro.descerro column-label "erro"
        tterro.qtd  column-label "registros" format ">>>>>>>>9"
        with frame frame-a 12 down centered row 5
        no-box.


run montatt.


/**disp 
    space(32)
    vtitvlcob    no-label          format   "-zzzzzzz9.99"
    vjuros       no-label           format     "-zzzzz9.99"
    vdescontos   no-label        format     "-zzzzz9.99"
    vtotal       no-label          format   "-zzzzzzz9.99"
        with frame ftot
            side-labels
            row screen-lines - 1
            width 80
            no-box.
**/


bl-princ:
repeat:


/**disp
    vtitvlcob
    vjuros
    vdescontos
    vtotal   

        with frame ftot.
**/

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tterro where recid(tterro) = recatu1 no-lock.
    if not available tterro
    then do.
        message "nenhum registro encontrato".
        pause.
        return.
        /*
        if pfiltro = ""
        then do: 
            return.
        end.    
        pfiltro = "".
        recatu1 = ?.
        next.
        */
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(tterro).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tterro
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tterro where recid(tterro) = recatu1 no-lock.

        status default "".

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
        
        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.

        choose field tterro.descerro
/*            help "Pressione L para Listar" */

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

        pause 0. 
        run color-normal.

                                                                
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
                    if not avail tterro
                    then leave.
                    recatu1 = recid(tterro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tterro
                    then leave.
                    recatu1 = recid(tterro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tterro
                then next.
                color display white/red tterro.descerro with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tterro
                then next.
                color display white/red tterro.descerro with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
            if esqcom1[esqpos1] = "<registros>"
            then do:
                run fin/opesicpagdocerro.p (pstatus,tterro.descerro).
                run montatt.
                recatu1 = ?.
                leave.
            end.
                
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tterro).
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
        tterro.descerro
        tterro.qtd
        with frame frame-a.





end procedure.

procedure color-message.
    color display message
        tterro.descerro
        tterro.qtd

        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        tterro.descerro
        tterro.qtd

        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        tterro.descerro
        tterro.qtd

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find first tterro  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find first tterro where
            no-lock no-error.
    end.
    else do:
        find first tterro
            no-lock no-error.
    end.    
    
            
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find next tterro  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find next tterro where
            no-lock no-error.
    end.
    else do:
        find next tterro
            no-lock no-error.
    end.    

end.    
             
if par-tipo = "up" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find prev tterro  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find prev tterro where
            no-lock no-error.
    end.
    else do:
        find prev tterro
            no-lock no-error.
    end.    

end.    
        
end procedure.


procedure montatt.
hide message no-pause.
message color normal "fazendo calculos... aguarde...".


for each sicred_pagam where
/*        sicred_pagam.operacao = poperacao and
        sicred_pagam.cobcod   = pcobcod   and*/
        sicred_pagam.sstatus  = pstatus /*and
        sicred_pagam.datamov  = pdatamov and
        sicred_pagam.ctmcod    = pctmcod*/
         no-lock.
    
    find first tterro where tterro.descerro = sicred_pagam.descerro no-error.
    if not avail tterro
    then do:
        create tterro.
        tterro.descerro = sicred_pagam.descerro.
    end.
    tterro.qtd = tterro.qtd + 1.            
end.

hide message no-pause.
           
end procedure.

