{admcab.i}

def var vclicod like clien.clicod.

message program-name(1).

repeat:

    
    update vclicod with centered overlay.

    find clien where clien.clicod = vclicod no-lock no-error.
    if not avail clien
    then do:
        message "Cliente nao Cadastrado".
        undo.
    end.
    else disp clien.clinom.

end.