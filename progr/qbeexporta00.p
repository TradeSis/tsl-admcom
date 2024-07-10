/* Ajuste 28/10/2021  88743 Helio */ 
{admcab.i}

def var vlista as char EXTENT 4 format "x(20)".

assign vlista[1] = "CREDIARIO"
       vlista[2] = "CRÉDITO PESSOAL"
       vlista[3] = "GERAL"
       vlista[4] = "GARANTIA / RFQ".

display vlista no-label with frame f-lista centered no-label 1 col.
choose field vlista with frame f-lista.
hide frame f-lista.

if frame-index = 1
then run qbeexporta.p.
else if frame-index = 2
then run qbeexporta-cp.p.
else if frame-index = 3
then run qbeexporta-elcp.p.
else if frame-index = 4
then run ffcexporta-gar.p.

hide message no-pause.

