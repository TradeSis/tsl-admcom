{admcab.i}

def var vtip as char format "x(10)" extent 2 initial ["Posicao I","Posicao II"].
repeat:
    disp vtip with frame f1 no-label centered row 10.
    choose field vtip with frame f1.
    hide frame f1 no-pause.
    
    if frame-index = 1
    then run loj/cred02.p.
    else run loj/cred03.p.
    
    hide message no-pause.
end.
