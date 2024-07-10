/*               to                   sfpl
*                                 R
*
*/

{admcab.i}

def input param par-rec as recid. 
    
def var xtime as int.
def var vconta as int.

def var vqtdparcel as int.
def var vvlr_PARCELA as dec.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" altera "," "," "," "," "].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.
def shared temp-table ttcondicoes no-undo
    field planom        like novplanos.planom
    field plaord        like novplanos.plaord
    field vlr_entrada   as dec
    field min_entrada    as dec
    field vlr_acordo    as dec
    field vlr_juroacordo as dec
    field dtvenc1       as date
    field vlr_parcela   as dec
    field especial as log
    index idx is unique primary plaord asc planom asc.

def shared temp-table ttparcelas no-undo
    field planom        like novplanos.planom
    field plaord        like novplanos.plaord
    field titpar        as int format ">>9" label "parc"
    field perc_parcela  as dec decimals 6 format ">>>9.999999%" label "perc"
    field vlr_parcela   as dec format ">>>>>9.99" label "vlr parcela"
    index idx is unique primary  plaord asc planom asc titpar asc.


def buffer bttparcelas for ttparcelas.
find ttcondicoes where recid(ttcondicoes) = par-rec no-lock.

    form  
        ttparcelas.titpar
        ttparcelas.vlr_parcela
        space(10)
        ttparcelas.perc_parcel

        

        with frame frame-a 7 down centered row 9
            title ttcondicoes.planom overlay.

def var vtotal as dec format "->>>>9.99".

    vtotal = 0.
    for each ttparcelas of ttcondicoes no-lock.
        vtotal = vtotal + ttparcelas.perc_parcel.
    end.        

bl-princ:
repeat:

    disp vtotal no-label
        with frame ftotal
        row screen-lines - 1
        centered
        side-labels no-box.
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttparcelas where recid(ttparcelas) = recatu1 no-lock.
    if not available ttparcelas
    then do.
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttparcelas).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttparcelas
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttparcelas where recid(ttparcelas) = recatu1 no-lock.

        status default "".
        
                        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field ttparcelas.titpar

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
                    if not avail ttparcelas
                    then leave.
                    recatu1 = recid(ttparcelas).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttparcelas
                    then leave.
                    recatu1 = recid(ttparcelas).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttparcelas
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttparcelas
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            

            if esqcom1[esqpos1] = " altera"
            then do:

                run paltera.
                recatu1 = ?.
                leave.
            end.
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttparcelas).
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
        ttparcelas.titpar
        ttparcelas.perc_parcel
        ttparcelas.vlr_parcela
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        ttparcelas.titpar
        ttparcelas.perc_parcel
        ttparcelas.vlr_parcela
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        ttparcelas.titpar
        ttparcelas.perc_parcel
        ttparcelas.vlr_parcela        
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
                ttparcelas.titpar
        ttparcelas.perc_parcel
        ttparcelas.vlr_parcela
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first ttparcelas  of ttcondicoes
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next ttparcelas  of ttcondicoes
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev ttparcelas of ttcondicoes
                no-lock no-error.

end.    
        
end procedure.



procedure paltera.

    do on error undo:

        find current ttparcelas exclusive.
        update  ttparcelas.vlr_parcela
            with frame frame-a.

        ttparcelas.perc_parcel = ttparcelas.vlr_parcela / (ttcondicoes.vlr_acordo - ttcondicoes.vlr_entrada) * 100.
        vtotal = 100. 
        for each bttparcelas of ttcondicoes where 
            bttparcelas.titpar <= ttparcelas.titpar. 
            vtotal = vtotal - bttparcelas.perc_parcel.
        end. 
        vqtdparcel = 0. 
        for each bttparcelas of ttcondicoes where
                bttparcelas.titpar > ttparcelas.titpar.
            vqtdparcel = vqtdparcel + 1.                
        end.

        if vtotal <= 0 or vqtdparcel = 0
        then do:
            ttparcelas.perc_parcel = ttparcelas.perc_parcel + vtotal.
            vtotal = 100.
            for each bttparcelas of ttcondicoes where
                    bttparcelas.titpar <= ttparcelas.titpar.
                vtotal = vtotal - bttparcelas.perc_parcel.
            end. 
            
        end.

        for each bttparcelas of ttcondicoes where
                bttparcelas.titpar > ttparcelas.titpar.
            bttparcelas.perc_parcel = vtotal / vqtdparcel.
            bttparcelas.vlr_parcela = round((ttcondicoes.vlr_acordo - ttcondicoes.vlr_entrada) * bttparcelas.perc_parcel / 100,2). 
            
        end.
          
    end.    
    
    vtotal = 0.
    for each ttparcelas of ttcondicoes no-lock.
        vtotal = vtotal + ttparcelas.perc_parcel.
    end.        

    pause 0.
    disp vtotal 
    with frame ftotal.
    pause 0.
    
end.



