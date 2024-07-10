if keyfunction(lastkey) = "GO"                                    
then do transaction: 
    find tbcntgen where recid(tbcntgen) = a-seerec[frame-line].
    disp tbcntgen.etbcod         label "Codigo    "       skip
        with frame f-alt.
    update tbcntgen.campo1[1]    label "Descricao " format "x(30)" skip
           tbcntgen.campo1[2]    label "Processa  " format "x(30)" skip
           tbcntgen.valor        label "Valor     " skip
           tbcntgen.campo3[3]    label "Parametros" format "x(60)" skip
           tbcntgen.datini       label "Periodo de"
           tbcntgen.datfim       label "       Ate" skip
           tbcntgen.validade     label "Validade  "               skip
           tbcntgen.campo1[3]    label "Programa  " format "x(15)"
           tbcntgen.campo2[1]    label "Texto     "
           tbcntgen.campo2[2]    label "          "
           with frame f-alt centered 1 down side-label
           color message row 6 title "    ALTERACAO   " .
    /*
    OUTPUT TO value(varq) .
    for each btbcntgen where
             btbcntgen.tipcon > 0 no-lock.
        export btbcntgen.
    end.
    output close.
    */             
    hide frame f-alt no-pause.                                             
    next keys-loop.                                                     
                                                                                
end.
if keyfunction(lastkey) = "CLEAR"                                    
then do transaction: 
    find tbcntgen where recid(tbcntgen) = a-seerec[frame-line].
    disp tbcntgen.etbcod       label "Codigo    "       skip
         tbcntgen.campo1[1]    label "Descricao " format "x(30)" skip
        with frame f-mail.
    assign
        e-mail[1] = acha("email1",tbcntgen.campo3[1]) 
        e-mail[2] = acha("email2",tbcntgen.campo3[1])
        e-mail[3] = acha("email3",tbcntgen.campo3[1])
        e-mail[4] = acha("email4",tbcntgen.campo3[1])
        e-mail[5] = acha("email5",tbcntgen.campo3[1])
        e-mail[6] = acha("email6",tbcntgen.campo3[1])
        e-mail[7] = acha("email7",tbcntgen.campo3[1])
        e-mail[8] = acha("email8",tbcntgen.campo3[1])
        e-mail[9] = acha("email9",tbcntgen.campo3[1])
         .
    do i = 1 to 9:
        if e-mail[i] = ?
        then e-mail[i] = "".
    end.
    disp e-mail[1] format "x(40)" skip
         e-mail[2] format "x(40)" skip
         e-mail[3] format "x(40)" skip
         e-mail[4] format "x(40)" skip
         e-mail[5] format "x(40)" skip
         e-mail[6] format "x(40)" skip
         e-mail[7] format "x(40)" skip
         e-mail[8] format "x(40)" skip
         e-mail[9] format "x(40)"
         with frame f-mail centered 1 down side-label
         color message row 5 title "      E-MAIL    " .
  
    UPDATE e-mail[1]
         e-mail[2]
         e-mail[3]
         e-mail[4]
         e-mail[5]
         e-mail[6]
         e-mail[7]
         e-mail[8]
         e-mail[9]
         with frame f-mail  .
         
    tbcntgen.campo3[1] = "".
    do i = 1 to 9:
        if e-mail[i] <> ?
        then
        tbcntgen.campo3[1] = tbcntgen.campo3[1] +
            "email" + string(i,"9") + "=" + e-mail[i]
            + "|".   
    end.
    /*
    OUTPUT TO value(varq) .
    for each btbcntgen where
             btbcntgen.tipcon > 0 no-lock.
        export btbcntgen.
    end.
    output close.
    */             
    hide frame f-mail no-pause.                                             
    a-recid = recid(tbcntgen).
    next keys-loop.                                                     
                                                                                
end.
 
 
