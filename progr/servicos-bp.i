    for each tt-servicos. delete tt-servicos. end.
    message {&palavra}. pause.
    for each servicos where servicos.descricao matches {&palavra}.
            create tt-servicos.
            buffer-copy servicos to tt-servicos.
    end. 