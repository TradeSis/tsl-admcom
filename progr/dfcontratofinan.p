{admcab.i}

def var vcontnum like contrato.contnum.

repeat:
    vcontnum = 0.
    update vcontnum label "Contrato" format ">>>>>>>>>9"
        with frame f1 width 80 1 down side-label.

    find contrato where contrato.contnum = vcontnum no-lock no-error.
    if not avail contrato
    then do:
        bell.
        message color red/with
        "Nenhum registro encontrato para contrato informado."
        view-as alert-box.
        undo.
    end.
    disp contrato except contnum  with 1 column
    title " Contrato ".
    pause 0.
    for each titulo where titulo.clifor = contrato.clicod and
                          titulo.titnum = string(contrato.contnum)
                          no-lock:
        disp titulo.titpar titulo.titdtven titulo.titvlcob
            with frame f2 column 40 down
            title " Parcelas ".
    end.
    if contrato.banco = 10 
    then do:
        bell.
        message color red/with
        "Contrato da Financeira."
         view-as alert-box.
    end. 
    else do:
        sresp = no.
        message "Deseja transferir contrato para Financeira?" update sresp.
        if sresp
        then do on error undo:
            find current contrato exclusive no-wait.
            if avail contrato
            then contrato.banco = 10.
            else do:
                bell.
                message color red/with
                "Contrato em uso por outro local." skip
                "Impossivel alterar."
                view-as alert-box.
            end.
        end.
    end.
end.