{cabec.i}
def var vcpfcnpj like neuclien.cpfcnpj.

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
        NeuClien.VlrLimite
        NeuClien.VctoLimite
        with frame f-neuclien.

    do transaction:
    find current neuclien exclusive.
    vcpfcnpj = neuclien.cpfcnpj.
    update neuclien.cpfcnpj
        with frame f-neuclien.
   if neuclien.cpfcnpj <> vcpfcnpj
   then do:
   run neuro/gravaneuclilog.p
            (neuclien.cpfcnpj,
             "ALTCPF",
             0,
             setbcod,
             0,
             "",
             "CPF ALTMAN POR " + string(sfuncod) + " De " +
                (if vcpfcnpj = ?
                 then "-"
                 else string(vcpfcnpj,"99999999999999999")) +
             " P/ "   +
                (if neuclien.cpfcnpj = ?
                then "-"
                else string(neuclien.cpfcnpj,"99999999999999999"))
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
