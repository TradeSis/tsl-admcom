def var varquivo            as char. 
def var vlinha              as char.

def temp-table tt-func
    field etbcod    as int
    field funcod    as int
    index idx01 etbcod funcod.
    
update varquivo label "Arquivo" format "x(78)"
            with frame f-arquivo .

if search(varquivo) <> ?
then do:

input from value(varquivo).

repeat:

    import vlinha.

    if num-entries(vlinha,";") = 2
    then do:
    
        message "Importando... " vlinha.
        pause 0.

        create tt-func.
        assign tt-func.etbcod = int(entry(1,vlinha,";"))
               tt-func.funcod = int(entry(2,vlinha,";")).
    
    end.

end.

end.
else message "Arquivo não encontrado!" view-as alert-box.

for each tt-func no-lock.

    find first func where func.etbcod = tt-func.etbcod
                      and func.funcod = tt-func.funcod
                                    exclusive-lock no-error.

    display tt-func.funcod func.funnom format "x(25)" with frame f01.

    if avail func
    then do:
        if trim(func.usercod) = ""
        then do:
            assign func.usercod = string(func.funcod).
            display "Alterado" with frame f01.
        end.    
        
    end.

end.