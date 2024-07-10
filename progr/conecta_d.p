def var i as int.
repeat:
    message "Conectando.....D .".
    connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld d no-error.
    if not connected ("d")
    then do:
        if i = 1 
        then leave.
        i = i + 1.
        next.
    end. 
    else leave.
end.
if not connected ("d")
then message "Nao Conectado.....D .".

