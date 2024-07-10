function GeraXml returns log
    (input a-acao  as char, 
     input b-acao  as char,
     input p-tag   as char,
     input p-valor as char,
     input p-cdata as char):

    p-valor = trim(p-valor).    

    if p-cdata = "S"
    then assign p-valor = "<![CDATA[" + p-valor + "]]>".

    if a-acao = "XML" and b-acao = ""
    then put unformatted 
            "<?xml version='1.0' encoding='iso-8859-1' ?>" skip.

    else if a-acao <> "" or
            b-acao <> ""
    then do:
        if a-acao <> ""
        then
            if a-acao = "T1" or
               a-acao = "T2" or
               a-acao = "T3" or
               a-acao = "T4" or
               a-acao = "T5" or
               a-acao = "T6" or
               a-acao = "T7"
            then put unformatted "<" p-tag ">".
        
        if p-valor <> ""
        then put unformatted p-valor.

        if a-acao <> "" and b-acao <> ""
        then put unformatted "</" p-tag ">".

        else if b-acao <> ""
        then
            if b-acao = "T1" or
               b-acao = "T2" or
               b-acao = "T3" or
               b-acao = "T4" or
               b-acao = "T5" or
               b-acao = "T6" or
               b-acao = "T7"
            then put unformatted "</" p-tag ">".

        put skip.
    end.

end function.

