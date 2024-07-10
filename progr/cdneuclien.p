{cabec.i new}

def var mopcao as char extent 4 format "x(25)" init
    ["Historico Alteracoes",
     "Neurotech - Acessos",
     "Neurotech - Logs",
     "Altera Limite"].

repeat with frame f-neuclien side-label 2 col centered
    1 down.
    prompt-for neuclien.cpfcnpj.
    if input neuclien.cpfcnpj > 0
    then do.
        find neuclien where neuclien.cpfcnpj = input neuclien.cpfcnpj
                      no-lock no-error.
    end.
    else do.
        prompt-for neuclien.clicod.
        if input neuclien.clicod > 0
        then find neuclien where neuclien.clicod = input neuclien.clicod
                           no-lock no-error.
    end.
    if not avail neuclien
    then next.
    disp neuclien.

    disp mopcao with frame f-opcao centered no-label 1 col.
    choose field mopcao with frame f-opcao.
    if frame-index = 1 
    then run neuro/cdneuclienhist.p (neuclien.cpfcnpj).
    else if frame-index = 2
    then run neuro/cdneuproposta.p (recid(neuclien)).
    else if frame-index = 3
    then run neuro/cdneuclienlog.p (recid(neuclien)).
end.
hide frame f-neuclien no-pause.
