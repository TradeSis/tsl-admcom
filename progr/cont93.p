{admcab.i}
def var vtipo as char format "X(30)" extent 2 
    initial["IMPRESSAO MODO CONTIGENCIA","IMPRESSAO MODO LINK"].
    
display vtipo no-label with frame f1 side-label centered row 10.
choose field vtipo with frame f1.
if frame-index = 1
then do:
    os-command   sudo /home/drebes/scripts/contdep.sh dep93 cont.

 
    display "O SISTEMA ESTA FUNCIONANDO EM MODO CONTIGENCIA"
        with frame f2 color message centered.
    pause.
    
end.    
else do:
    
    os-command   sudo /home/drebes/scripts/contdep.sh dep93 link.
    
    display "O SISTEMA ESTA FUNCIONANDO EM MODO LINK"
            with frame f3 color message centered.
    pause.
    
end.
 
