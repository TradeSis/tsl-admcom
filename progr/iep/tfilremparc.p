/* helio 30052023 310 - Alteração de regra para visualização de contratos IEPRO */
/* 05012022 helio iepro */

{admcab.i}
def input param precid as recid.

def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["parcela","juros",""].

form
    esqcom1
    with frame f-com1 row 7 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def buffer btitulo for titulo.
def var vsel as int.
def var vabe as dec.

{iep/tfilsel.i}
def var vdias as int format "->>>>9" column-label "dias!atraso". 
def var vvlcobrado   as dec.
    form  
        ttparcela.contnum
        ttparcela.titpar
        titulo.modcod
        titulo.titdtven
        titulo.titvlcob
        ttparcela.titvljur label "juros"
        vdias
        with frame frame-a 8 down centered row 8.



find ttcontrato where recid(ttcontrato) = precid no-lock.
find contrato where contrato.contnum = ttcontrato.contnum no-lock.
disp 
        contrato.etbcod                         column-label "fil"
        contrato.modcod  format "x(03)"           column-label "mod" space(0)
        contrato.tpcontrato format "x"            column-label "t"
        ttcontrato.clicod                         column-label "cliente"

        ttcontrato.nossonumero 
        ttcontrato.titdtemi format "999999"         column-label "dtemi"
        
        ttcontrato.titdtven format "999999"         column-label "venc"
        
        ttcontrato.diasatraso column-label "d atr"     format "-99999"
        ttcontrato.vlratr      column-label "vl atras"    format ">>>>9.99" 
        ttcontrato.vlrdiv      column-label "vl divid"    format ">>>>>9.99" 


        with frame ftit
            row 5
            no-underline
            centered
            no-box
            color messages.




disp 
    vvlcobrado    label "Filtrado"      format "zzzzzzzz9.99" colon 65
        with frame ftot
            side-labels
            row screen-lines - 2
            width 80
            no-box.



bl-princ:
repeat:
    
   vvlcobrado = 0.
   for each ttparcela where ttparcela.contnum = ttcontrato.contnum no-lock.
        /*
        vvlcobrado = vvlcobrado + ttparcela.titvlcob.
        */
   end.
    disp
        vvlcobrado
        with frame ftot.

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttparcela where recid(ttparcela) = recatu1 no-lock.
    if not available ttparcela
    then do.
        message "nenhum registro encontrato".
        pause.
        return.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttparcela).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttparcela
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttparcela where recid(ttparcela) = recatu1 no-lock.
        find titulo where recid(titulo) = ttparcela.trecid no-lock.

        
                        
                     
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
        
    hide message no-pause.

    
        disp esqcom1 with frame f-com1.
        
        run color-message.
/*        vhelp = "".
        
        status default vhelp. */
        choose field ttparcela.contnum
                      help ""
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
                    if not avail ttparcela
                    then leave.
                    recatu1 = recid(ttparcela).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttparcela
                    then leave.
                    recatu1 = recid(ttparcela).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttparcela
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttparcela
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
            

            if esqcom1[esqpos1] = "parcela"
            then do:
                find contrato of ttparcela no-lock.
                find titulo where titulo.empcod = 19 and titulo.titnat = no and
                    titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
                    titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum) and
                    titulo.titpar = ttparcela.titpar
                no-lock.       

                 run bsfqtitulo.p (recid(titulo)).

                disp 
                        with frame ftit.
                
            end.
            if esqcom1[esqpos1] = "juros"
            then do:
                def var vtitvljur as dec.
                vtitvljur = ttparcela.titvljur.
                update ttparcela.titvljur.
                ttcontrato.vlrdiv = ttcontrato.vlrdiv - vtitvljur + ttparcela.titvljur.
                disp ttcontrato.vlrdiv 
                    with frame ftit.
            end.
                        
             
        end. 
        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttparcela).
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
  
    find clien where clien.clicod = ttcontrato.clicod no-lock.
    find titulo where recid(titulo) = ttparcela.trecid no-lock.
    vdias = if titulo.titsit = "LIB" and titulo.titdtven < today
            then today - titulo.titdtven
            else 0.
    display  
        
        ttparcela.contnum
        ttparcela.titpar
        titulo.titvlcob
        titulo.titdtven
        ttparcela.titvljur
        vdias when vdias > 0 
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        ttparcela.contnum
        ttparcela.titpar
        titulo.titvlcob
        ttparcela.titvljur
                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        ttparcela.contnum
        ttparcela.titpar
        titulo.titvlcob
        ttparcela.titvljur
                     
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        ttparcela.contnum
        ttparcela.titpar
        titulo.titvlcob
        ttparcela.titvljur
 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find first ttparcela where ttparcela.contnum = ttcontrato.contnum
            no-lock no-error.
    end.    
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find next ttparcela  where ttparcela.contnum = ttcontrato.contnum
            no-lock no-error.
    end.    
    if par-tipo = "up" 
    then do:
        find prev ttparcela where ttparcela.contnum = ttcontrato.contnum

            no-lock no-error.
    end.    

        
end procedure.





