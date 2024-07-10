{admcab.i}

def input parameter vtotal-rat as dec.
def shared temp-table tt-titudesp like titudesp.

form tt-titudesp.etbcod     column-label "Fil"
     tt-titudesp.titnum     column-label "Documento"
     tt-titudesp.titvlcob   column-label "Valor" format ">>,>>9.99"
     with frame f-linha 11 down overlay
     row 6
     .

def var vtot-tit as dec format ">>,>>>,>>9.99" .
def var vdifer as dec format "->>,>>9.99".

{setbrw.i}
     
l1: repeat:
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        .
    vtot-tit = 0.
    for each tt-titudesp:
        vtot-tit = vtot-tit + tt-titudesp.titvlcob.    
    end.
    vdifer = vtot-tit - vtotal-rat.
    disp vtot-tit label "    Total"
         vdifer  no-label
        with frame f-total row 21 side-label no-box.
    pause 0.    
    {sklcls.i
        &file = tt-titudesp
        &help = "Enter=Altera Valor F1=Confirma rateio F4=Cancela Rateio "
        &cfield = tt-titudesp.etbcod
        &noncharacter = /*
        &ofield = " tt-titudesp.titnum
                    tt-titudesp.titvlcob
                  "
        &where = true
        &aftselect1 = "
                if keyfunction(lastkey) = ""RETURN""
                then do:
                    vtot-tit = vtot-tit - tt-titudesp.titvlcob.
                    update tt-titudesp.titvlcob.
                    vtot-tit = vtot-tit + tt-titudesp.titvlcob.
                    vdifer = vtot-tit - vtotal-rat.
                    disp vtot-tit 
                         vdifer
                         with frame f-total.
                    next keys-loop.
                end.
                "
        &otherkeys1 = " 
                      "  
        &form = " frame f-linha "
     }
     if keyfunction(lastkey) = "GO"
     then do:
        vtot-tit = 0.
        for each tt-titudesp:
            vtot-tit = vtot-tit + tt-titudesp.titvlcob.
        end.
        if vtot-tit <> vtotal-rat
        then do on error undo:
            message color red/with
            "Soma do rateio difere do total."
            view-as alert-box.
        end.
        else leave l1.
     end.
     if keyfunction(lastkey) = "END-ERROR"
     then do:
        /*bell.
        sresp = no.
        message "Deseja cancelar o rateio?" update sresp.   
        if sresp 
        then*/ leave l1.
     end.   
end.        
