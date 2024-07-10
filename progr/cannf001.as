if keyfunction(lastkey) = "return"
then do:
    bell.
    sresp = no.
    message color red/with
        "Confirma cancelamento da NF " tt-plani.numero " ?"
        update sresp.
    if not sresp
    then next keys-loop.
    else. 
    find plani where plani.movtdc = tt-plani.movtdc and
                     plani.etbcod = tt-plani.etbcod and
                     plani.emite  = tt-plani.emite  and
                     plani.serie  = tt-plani.serie  and
                     plani.numero = tt-plani.numero
                     no-lock no-error.
    if not avail plani 
    then next keys-loop.
    else.
    if plani.modcod = "CAN"
    then do:
        bell.
        message color red/with
            "Nota Fiscal ja cancelada."
            view-as alert-box.
        next keys-loop.    
    end.
    bell.
    sresp = yes.
    message color red/with
        "Confirma retornar estoque"
        update sresp.
    if sresp
    then do:    
    for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod
                             no-lock:
            do on error undo:
                run atuest-tst.p (input recid(movim),
                          input "E",
                          input 0).
            end.
    end.
    end.
    bell.
    sresp = yes.
    message color red/with
        "Confirma cancelar titulos"
        update sresp.
    if sresp
    then do on error undo:     
    for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = estab.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero).
        titulo.titsit = "CAN".
    end.
    end.             

    do on error undo:
        find plani where plani.movtdc = tt-plani.movtdc and
                     plani.etbcod = tt-plani.etbcod and
                     plani.emite  = tt-plani.emite  and
                     plani.serie  = tt-plani.serie  and
                     plani.numero = tt-plani.numero
                      no-error.
       plani.modcod = "CAN".
    end.
    
    if opsys = "UNIX"
    then varq = "../progr/NFcaN.Ctb" .
    else varq = "..\progr\NFcaN.Ctb" .
    output to value(varq) append.
    export plani.
    output close.
    tt-plani.modcod = "CAN".
    disp tt-plani.modcod with frame f-linha.
    
    find planiaux where planiaux.etbcod = plani.etbcod and
                         planiaux.emite  = plani.emite and
                         planiaux.serie = plani.serie and
                         planiaux.numero = plani.numero and
                         planiaux.nome_campo = "SITUACAO" AND
                         planiaux.valor_campo = "CANCELADA"
                         NO-LOCK no-error.
    if not avail planiaux
    THEN DO:
                create planiaux.
                assign
                    planiaux.etbcod = plani.etbcod 
                    planiaux.placod = plani.placod
                    planiaux.emite  = plani.emite 
                    planiaux.serie = plani.serie 
                    planiaux.numero = plani.numero 
                    planiaux.nome_campo = "SITUACAO" 
                    planiaux.valor_campo = "CANCELADA"
                    .
                                             
    END.

    bell.
    message color red/with 
        "Nota Fiscal " plani.numero "cancelada"
        view-as alert-box.
end.