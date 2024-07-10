{admcab.i}

def var vsano as char extent 4 FORMAT "x(18)"
    init["  CLIENTES 2022","","",""]   .
    
vsano[1] = "  CLIENTES 2022" .

disp vsano with frame f-es 1 down no-label centered.
choose field vsano with frame f-es.
    
if frame-index = 1
then run ctb/bg-salcart-v0122.p.

