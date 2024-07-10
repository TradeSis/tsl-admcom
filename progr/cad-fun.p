{admcab.i}
repeat:
    create totcli.
    update empcod label "Func." format ">>>>>>>9"
            with frame f1 side-label no-validate width 80.
    find clien where clien.clicod = totcli.empcod no-lock no-error.
    if not avail clien
    then do:
        message "Cliente nao Cadastrado".
        undo, retry.
    end.
    disp clien.clinom no-label with frame f1.
    pause.
 end.
