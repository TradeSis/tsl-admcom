    /* filtro-func-funcod.i
    */    
    for each wffunc.
        delete wffunc.
    end.
    cfunc = "".

    update vfunc
           with frame fopcoes.
    if vfunc
    then cfunc = "Geral".
    else
      repeat with frame ffunc title "Selecao de Funcionarios"
                        centered retain 1 row 14 overlay.
        pause 0. 
        create wffunc.
        do on error undo.
            wffunc.etbcod = 0.
        end.
        update wffunc.funcod
    help "Selecione o Funcionario ou tecle <F4> para Sair da Selecao".

        if wffunc.funcod = 0
        then leave.
        find first bwffunc where 
                                 bwffunc.funcod = wffunc.funcod and
                             recid(bwffunc) <> recid(wffunc) no-error.
        if avail bwffunc
        then do :
           delete wffunc. 
           undo.
        end.
        find first func where 
                              func.funcod = wffunc.funcod no-lock no-error.
        if not avail func
        then do:
            message "Funcionario Invalido"
                        view-as alert-box.
            delete wffunc.
            undo.
        end.
        disp func.funnom.
      end.
    hide frame ffunc no-pause.


    if not vfunc
    then for each wffunc by wffunc.funcod.
        find first func where 
                        func.funcod = wffunc.funcod no-lock no-error.
        if not avail func
        then next.
        cfunc = trim(cfunc + " " + string(func.funcod)).
    end.
    display vfunc cfunc with frame fopcoes.
