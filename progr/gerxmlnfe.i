{/u/wse-com/ws-nfe/soap/bsws.i}

function geraXmlNfe returns log (input ipcabec as logical,
                                 input ipcampo as character,
                                 input ipvalor as character,
                                 input iprodape as logical):

    if ipcabec
    then
    put unformatted
        "<?xml version='1.0' encoding='UTF-8'?>"
        "<notamax_integracao>"
        "    <dados usuario_notamax ='publico'"
        "           senha_notamax='senha'"       skip.
         
    put unformatted
        "           " ipcampo "='" ipvalor "'" skip. 
         
    if iprodape
    then
    put unformatted
        "    />"
        "</notamax_integracao>" skip.

end function.