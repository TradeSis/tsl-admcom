{cabec.i}
def var vvctolimite like neuclien.vctolimite.

repeat with frame f-neuclien side-label 2 col centered
    1 down row 3.
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
    then do:
        message "NEUCLIEN nao encontrado".
        next.
    end.
    find clien where clien.clicod = neuclien.clicod no-lock no-error.
         
    disp 
        NeuClien.CpfCnpj
        NeuClien.Clicod
        clien.clinom when avail clien
        NeuClien.VlrLimite
        NeuClien.VctoLimite
        with frame f-neuclien.

    do transaction:
    find current neuclien exclusive.
    vvctolimite = neuclien.vctolimite.
    update neuclien.vctolimite
        with frame f-neuclien.
    if neuclien.vctolimite <> vvctolimite
    then do:    
        run neuro/gravaneuclilog.p 
            (neuclien.cpfcnpj,
             "ALTVCTO",
             0,
             setbcod,
             0,
             "",
             "VCTO ALTMAN POR " + string(sfuncod) + " De " +
                (if vvctolimite = ?
                 then "-"
                 else string(vvctolimite,"99/99/9999")) +
             " P/ "   +
                (if neuclien.vctolimite = ?
                then "-"
                else string(neuclien.vctolimite,"99/99/9999")) 
                ).
    end.
    
    run neuro/cdneuclienlog.p (recid(neuclien)).
    end. /* do transaction */
    find current neuclien no-lock.    
    find clien where clien.clicod = neuclien.clicod no-lock no-error.
         
    disp 
        NeuClien.CpfCnpj
        NeuClien.Clicod
        clien.clinom when avail clien
        NeuClien.VlrLimite
        NeuClien.VctoLimite
        with frame f-neuclien.
        
end.
hide frame f-neuclien no-pause.
