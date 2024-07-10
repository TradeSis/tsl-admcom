{admcab.i}
def var vtip as char format "x(10)" extent 2 initial ["Estacao","Fornec."].
repeat:
    disp vtip with frame f1 no-label centered row 10.
    choose field vtip with frame f1.
    if frame-index = 1
    then run prom07.p.
    else run prom08.p.
end.
