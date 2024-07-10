{admcab.i}

def var vlista as char EXTENT 2 format "x(20)".

assign vlista[1] = "CREDIARIO"
       vlista[2] = "CRÉDITO PESSOAL".

hide message no-pause.

display vlista no-label with frame f-lista centered no-label.
    choose field vlista with frame f-lista.
    
hide frame f-lista.

if frame-index = 1
then do:
    run /admcom/progr/apseguro.p.
end.
else if frame-index = 2
then do:
    run /admcom/progr/apseguro_cp.p.
end.




