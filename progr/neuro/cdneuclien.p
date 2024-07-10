/*
Motor de Credito
*/
{admcab.i}

def var mopcao as char extent 5 format "x(55)" init
    [ "Neurotech - Acessos","Logs de Acoes WS","Comportamento",
    " Historico de Alteracao de Status Cadastral",
    " Historico de Consulta Listas Restritivas"].

repeat with frame f-neuclien side-labels centered
    1 down no-box.
    prompt-for neuclien.cpfcnpj colon 15.
    form clien.clinom no-label .

    
    if input neuclien.cpfcnpj > 0
    then do.
        find neuclien where neuclien.cpfcnpj = input neuclien.cpfcnpj
                      no-lock no-error.
    end.
    else do.
        prompt-for neuclien.clicod label "Codigo Cliente" colon 15.
        if input neuclien.clicod > 0
        then find neuclien where neuclien.clicod = input neuclien.clicod
                           no-lock no-error.
    end.
    if not avail neuclien
    then do:
        message "NEUCLIEN nao encontrado".
        next.
    end.

    repeat.
        find clien where clien.clicod = neuclien.clicod no-lock no-error.
        find clienstatus of clien no-lock no-error.
                 
        disp 
            NeuClien.CpfCnpj
            NeuClien.Clicod
            clien.clinom when avail clien
            NeuClien.VlrLimite  colon 42
            NeuClien.VctoLimite colon 65
            skip(1)
            clien.idstatuscad colon 15
            clienstatus.statuscadnom when avail clienstatus no-label
            clienstatus.BloqueioAlteracaoCadastral
            clienstatus.bloqueiovenda
            with frame f-neuclien.

        disp mopcao with frame f-opcao centered no-label 1 col row 8.
        choose field mopcao with frame f-opcao.

        hide frame f-opcao no-pause.
        /*
        if frame-index = 1 or frame-index = 2
        then hide frame f-neuclien no-pause.
        */     
        if frame-index = 1
        then run neuro/cdneuproposta.p (recid(neuclien)).
        else if frame-index = 2
        then run neuro/cdneuclienlog.p (recid(neuclien)).
        else if frame-index = 3
        then run neuro/mostra_comportamento.p (recid(neuclien)).
        else if frame-index = 4
        then run cli/statuscadhist.p (clien.clicod).
        else if frame-index = 5
             then run cli/listasrest.p (neuclien.cpf).        
    end.
end.
hide frame f-neuclien no-pause.

