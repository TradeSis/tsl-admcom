
{admcab.i}

def var vidstatuscad like clien.idstatuscad.
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
            clien.idstatuscad @ vidstatuscad colon 15
            clienstatus.statuscadnom when avail clienstatus no-label
            clienstatus.BloqueioAlteracaoCadastral
            clienstatus.bloqueiovenda
            with frame f-neuclien.
        vidstatuscad = clien.idstatuscad.       
        update vidstatuscad with frame f-neuclien.
        find clienstatus where clienstatus.idstatuscad = vidstatuscad 
            no-lock no-error.
        if not avail clienstatus
        then do:
            message "Status " vidstatuscad "nao cadastrado" .
            undo.
        end.        
        disp
        clienstatus.statuscadnom when avail clienstatus no-label
            clienstatus.BloqueioAlteracaoCadastral
            clienstatus.bloqueiovenda
            with frame f-neuclien.

        if clien.idstatuscad <> vidstatuscad
        then do:
            message "Confirma Alteração de Status Cadastral?" update sresp.
            if sresp
            then do:
                run cli/statuscadins.p (input clien.clicod,                                         "", vidstatuscad).
            end.
        end.        
        run cli/statuscadhist.p (clien.clicod).
        
    end.
end.
hide frame f-neuclien no-pause.

