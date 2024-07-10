    if {3} = ""
    then {3} = "Estabelecimento".
    find {1} where {1}.etbcod = {2} no-lock no-error.
    if not avail {1}
    then do:
        bell.
        message color red/with
            {3} "nao existe ou nao cadastrado."
            view-as alert-box title " Mensagem ".
        undo, retry.
    end.    
            
    if {1}.etbcgc = "" or {1}.etbinsc = ""
    then do:
        bell.
        if {1}.etbcgc = ""
        then message color red/with
            {3} "sem CNPJ"
            view-as alert-box title " Mensagem ".
        if {1}.etbcgc = ""
        then message color red/with
            {3} "sem Inscricao Estadual"
            view-as alert-box title " Mensagem ".
        undo, retry.
    end.
