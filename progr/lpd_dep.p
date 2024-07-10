{admcab.i}
def var vtipo as char format "X(30)" extent 2 
    initial["IMPRESSAO EM MODO DISCADO","IMPRESSAO EM MODO NORMAL"].
    
display vtipo no-label with frame f1 side-label centered row 10.
choose field vtipo with frame f1.
if frame-index = 1
then do:
    os-command silent  cp /etc/printcap.semlink /etc/printcap.
    os-command silent sudo /sbin/service lpd restart.
    
    display "O SISTEMA ESTA FUNCIONANDO EM MODO DISCADO"
        with frame f2 color message centered.
    pause.
    
end.    
else do:
    
    os-command silent cp /etc/printcap.comlink /etc/printcap.
    os-command silent sudo /sbin/service lpd restart.
    
    display "O SISTEMA ESTA FUNCIONANDO EM MODO NORMAL"
            with frame f3 color message centered.
    pause.
    
end.
 
