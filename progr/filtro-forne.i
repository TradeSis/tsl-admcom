/*
    filtro-forne.i
*/    
    for each wfforne.
        delete wfforne.
    end.
    cforne = "".

    update vforne
           with frame fopcoes.
    if vforne
    then cforne = "Geral".
    else
      repeat with frame fforne title "Selecao de Fornecedores"
                        centered retain 1 row 14 overlay.
        pause 0. 
        create wfforne.
        update wfforne.forcod
    help "Selecione o Fornecedor ou tecle <F4> para Sair da Selecao".

        if wfforne.forcod = 0
        then leave.
        find first bwfforne where bwfforne.forcod = wfforne.forcod and
                             recid(bwfforne) <> recid(wfforne) no-error.
        if avail bwfforne
        then do :
           delete wfforne. 
           undo.
        end.
        find first forne where forne.forcod = wfforne.forcod no-lock no-error.
        if not avail forne
        then do:
            message "Fornecedor Invalido"
                    view-as alert-box.
            delete wfforne.
            undo.
        end.
        disp forne.fornom.
      end.
    hide frame fforne no-pause.

    if not vforne
    then for each wfforne by wfforne.forcod.
        find forne where forne.forcod = wfforne.forcod no-lock no-error.
        if not avail forne
        then next.
        cforne = trim(cforne + " " + string(forne.forcod)).
    end.
    display vforne cforne with frame fopcoes.
