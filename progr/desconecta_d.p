def var i as int.
repeat:
    message "Desconectando.....D .".
    if connected ("d")
    then disconnect "d".
    leave.
end.

