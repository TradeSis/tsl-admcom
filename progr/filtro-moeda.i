    
    /*
      moeda
    */  
    for each wfmoeda.
       delete wfmoeda.
    end. 
    cmoeda = "".
    update vmoeda
           with frame fopcoes.
    if vmoeda
    then 
        cmoeda = "Geral".
    else
      repeat with frame fmoeda title "Selecao de Moedas "
                        centered retain 1 row 14 overlay.
        create wfmoeda.
        update wfmoeda.moecod
            help "Selecione a Moeda tecle <F4> para Sair".

        if wfmoeda.moecod = ""
        then leave.
        find first bwfmoeda where bwfmoeda.moecod = wfmoeda.moecod and
                             recid(bwfmoeda) <> recid(wfmoeda) no-error.
        if avail bwfmoeda
        then do :
           delete wfmoeda. 
           undo.
        end.
        find moeda where moeda.moecod = wfmoeda.moecod no-lock no-error.
        if not avail moeda
        then do:
            message "Moeda invalida".
            delete wfmoeda.
            undo.
        end.
        disp moeda.moenom format "x(35)".
      end.
    hide frame fmoeda no-pause.

    if not vmoeda
    then
        for each wfmoeda where wfmoeda.moecod <> "" by wfmoeda.moecod.
            find moeda where moeda.moecod = wfmoeda.moecod no-lock no-error.
            if avail moeda
            then cmoeda = trim(cmoeda + " " + string(moeda.moecod)).
        end.
    display cmoeda with frame fopcoes.
