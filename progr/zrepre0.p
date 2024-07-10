{admcab.i}

def var vzoom    as char extent 2 format "x(12)"
        initial [" Nome "," Empresa  "].
        
display vzoom        
    with frame fzoom no-labels row 4 column 53 overlay color yellow/black.
choose field vzoom with frame fzoom.
hide frame fzoom no-pause.
    
if frame-index = 1
then run zrepre.p. 
else run zrepre1.p.
  