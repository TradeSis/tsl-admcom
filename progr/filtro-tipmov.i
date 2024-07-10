    
    /*
      tipmov
    */  
    for each wftipmov.
       delete wftipmov.
    end. 
    ctipmov = "".
    update vtipmov
           with frame fopcoes.
    if vtipmov
    then 
        ctipmov = "Geral".
    else
      repeat with frame ftipmov title "Selecao de Tipo de Movimentacao "
                        centered retain 1 row 14 overlay.
        create wftipmov.
        update wftipmov.movtdc
            help "Selecione o Tipo de Movimentacao ou tecle <F4> para Sair".

        if wftipmov.movtdc = 0
        then leave.
        find first bwftipmov where bwftipmov.movtdc = wftipmov.movtdc and
                             recid(bwftipmov) <> recid(wftipmov) no-error.
        if avail bwftipmov
        then do :
           delete wftipmov. 
           undo.
        end.
        find tipmov where tipmov.movtdc = wftipmov.movtdc no-lock no-error.
        if not avail tipmov
        then do:
            message "Tipo de Movimentacao invalido".
            delete wftipmov.
            undo.
        end.
        disp tipmov.movtnom format "x(35)".
      end.
    hide frame ftipmov no-pause.

    if not vtipmov
    then
        for each wftipmov where wftipmov.movtdc > 0 by wftipmov.movtdc.
            find tipmov where tipmov.movtdc = wftipmov.movtdc no-lock no-error.
            if avail tipmov
            then ctipmov = trim(ctipmov + " " + string(tipmov.movtdc)).
        end.
    display ctipmov with frame fopcoes.
