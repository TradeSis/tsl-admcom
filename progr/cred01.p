{admcab.i}

def var i as int.
def var vtip as char format "x(10)" extent 2 initial ["Posicao I","Posicao II"].
repeat:

    disp vtip with frame f1 no-label centered row 10.
    choose field vtip with frame f1.
    hide frame f1 no-pause.
    
/***
    message "Conectando com a matriz (FIN) ......".
    connect fin -H erp.lebes.com.br -S sdrebfin -N tcp -ld finmatriz.
    hide message no-pause.
    
    message "Conectando com a matriz (D) ......".
    connect dragao -H erp.lebes.com.br -S sdragao -N tcp -ld d no-error.
    hide message no-pause.
***/
    run conecta_d.p.
    
    if frame-index = 1
    then run cred02.p.
    else run cred03.p.
    
    disconnect finmatriz.
    disconnect d.
    
    hide message no-pause.
end.
