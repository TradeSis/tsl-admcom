def new global shared var vmudasequenciais as char.

do on error undo.

    find CSLog_sequencias where 
        CSLog_sequencias.cyber_sigla = {1}
      exclusive no-error. 
    
    if vmudasequenciais = "NAO"
    then .
    else do:
      CSLog_sequencias.Cyber_sequencia = CSLog_sequencias.Cyber_sequencia + 1.
      CSLog_sequencias.Cyber_DtProces = today.
    end.
    
    {2} = CSLog_sequencias.cyber_sequencia.

end.
