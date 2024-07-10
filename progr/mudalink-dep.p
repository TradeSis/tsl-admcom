{admcab.i}
def var vtipo as char format "X(20)" extent 2 
    initial["SEM LINK","COM LINK"].
    
display vtipo no-label with frame f1 side-label centered row 10.
choose field vtipo with frame f1.
if frame-index = 1
then do:
    os-command  cp /etc/printcap.semlink /etc/printcap.
    os-command  service lpd restart.
    
    display "VOCE INFORMOU QUE O DEPOSITO ESTA SEM LINK"
        with frame f2 color message centered.
    pause.
    
end.    
else do:
    
    os-command  cp /etc/printcap.comlink /etc/printcap.
    os-command  service lpd restart.
    
    display "VOCE INFORMOU QUE O DEPOSITO ESTA COM LINK"
            with frame f3 color message centered.
    pause.
    
end.
 
