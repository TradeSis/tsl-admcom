/* {admcab.i} */
{admcab.palm}

def var vescolha as char format "x(28)" extent 2
               initial ["  1. PERFORMANCE DE VENDAS  ",
                        "  2. SAIR                   "].

form
    skip(1)
    vescolha[1] skip
    vescolha[2]
    skip(1)
    with frame f-escolha  row 5 title " MENU " overlay.

repeat:
    clear frame f-escolha no-pause.
    hide  frame f-escolha no-pause.

    disp vescolha no-label with frame f-escolha overlay.
    choose field vescolha auto-return with frame f-escolha .
    
    if frame-value = "  1. PERFORMANCE DE VENDAS  "
    then do:

        run conv-palm2.p.

    end.
    
    if frame-value = "  2. SAIR                   "
    then quit.
end.

quit.
