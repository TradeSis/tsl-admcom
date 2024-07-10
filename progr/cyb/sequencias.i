def new global shared var vmudasequenciais as char.

do on error undo.

    find cyber_sequencias where 
        cyber_sequencias.cyber_sigla = {1}
      exclusive no-error. 
    
    if vmudasequenciais = "NAO"
    then .
    else do:
      cyber_sequencias.Cyber_sequencia = cyber_sequencias.Cyber_sequencia + 1.
      cyber_sequencias.Cyber_DtProces = today.
    end.
    
    {2} = cyber_sequencias.cyber_sequencia.

end.
