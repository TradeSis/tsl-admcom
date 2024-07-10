    /* filtro-estab.i
    */    
    for each wfestab.
        delete wfestab.
    end.
    cestab = "".

/***
    if westab.etbcat = "LOJA"
    then do.
        vestab = no.
        create wfEstab.
        wfestab.etbcod = setbcod.
    end.
    else do.
***/    
    update vestab
           with frame fopcoes.
    if vestab
    then cestab = "Geral".
    else
      repeat with frame festab title "Selecao de Estabelecimentos"
                        centered retain 1 row 14 overlay.
        pause 0. 
        create wfEstab.
        update wfestab.etbcod
    help "Selecione o Estabelecimento ou tecle <F4> para Sair da Selecao".

        if wfestab.etbcod = 0
        then leave.
        find first bwfestab where bwfestab.etbcod = wfestab.etbcod and
                             recid(bwfestab) <> recid(wfestab) no-error.
        if avail bwfestab
        then do :
           delete wfestab. 
           undo.
        end.
        find first estab where estab.etbcod = wfestab.etbcod no-lock no-error.
        if not avail estab
        then do:
            message "Estabelecimento Invalido"
                    view-as alert-box.
            delete wfestab.
            undo.
        end.
        disp estab.etbnom.
      end.
    hide frame festab no-pause.

/***
    end. /* LOJA */
***/

    if not vEstab
    then for each wfestab by wfestab.etbcod.
        find estab where estab.etbcod = wfestab.etbcod no-lock no-error.
        if not avail estab
        then next.
        cestab = trim(cestab + " " + string(estab.etbcod)).
    end.
    display vestab cestab with frame fopcoes.
