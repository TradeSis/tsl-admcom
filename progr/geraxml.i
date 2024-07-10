function GeraXml returns log
    (input a-acao  as char, 
     input b-acao  as char,
     input p-tag   as char,
     input p-valor as char):
    p-valor = trim(p-valor).    

    if a-acao = "XML" and b-acao = ""
    then do:
        put unformatted 
            "<?xml version='1.0' encoding='UTF-8' ?>" skip.
    end.
    else if a-acao <> "" or  b-acao <> ""
    then do:
        if a-acao <> ""
        then do: 
            if a-acao = "T1"
            then put unformatted "<" p-tag ">" .
            if a-acao = "T2"
            then put unformatted "<" p-tag ">" .
            if a-acao = "T3"
            then put unformatted "<" p-tag ">" .
            if a-acao = "T4"
            then put unformatted "<" p-tag ">" .
            if a-acao = "T5"
            then put unformatted "<" p-tag ">" .
            if a-acao = "T6"
            then put unformatted "<" p-tag ">" .
            if a-acao = "T7"
            then put unformatted "<" p-tag ">" .
        end.
        
        if p-valor <> ""
        then put unformatted p-valor.

        if a-acao <> "" and b-acao <> ""
        then do:
            put unformatted "</" p-tag ">" .
        end.
        else if b-acao <> ""
        then do:
            if b-acao = "T1"
            then put unformatted "</" p-tag ">" .
            if b-acao = "T2"
            then put unformatted "</" p-tag ">" .
            if b-acao = "T3"
            then put unformatted "</" p-tag ">" .
            if b-acao = "T4"
            then put unformatted "</" p-tag ">" .
            if b-acao = "T5"
            then put unformatted "</" p-tag ">" .
            if b-acao = "T6"
            then put unformatted "</" p-tag ">" .
            if b-acao = "T7"
            then put unformatted "</" p-tag ">" .
         end.
         put skip.
    end.

end function.

