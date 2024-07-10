
output to l:\work\cheque.log append.
    put "Inicio do processo dia " today format "99/99/9999"
        " Hora: " string(time,"HH:MM:SS") skip. 
output close.



for each cheque where cheque.chesit = "PAG" no-lock.

    
    find titcli where titcli.clicod = cheque.clicod and
                      titcli.etbcod = 999 no-error.
    if avail titcli
    then do transaction:
        delete titcli.
    end.
    
end.    


for each cheque where cheque.chesit = "LIB" no-lock.

    
    find titcli where titcli.clicod = cheque.clicod and
                      titcli.etbcod = 999 no-error.
    if not avail titcli
    then do transaction:
    
        create titcli.
        assign titcli.etbcod = 999
               titcli.clicod = cheque.clicod 
               titcli.dtexp  = today
               titcli.flag   = yes.
    end.
    
end.    


output to l:\work\cheque.log append.
    put "Fim do processo dia " today format "99/99/9999" 
        " Hora: " string(time,"HH:MM:SS") skip. 
output close.



