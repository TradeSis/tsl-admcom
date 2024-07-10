{admcab.i.ssh}

def var v-ok            as log.
def var vok             as log.


repeat:

    def var v-linha as char extent 15 format "x(30)".
    
    v-linha[1] = "INCLUSÃO DE PEDIDO MANUAL".
    v-linha[2] = "CONSULTA DE PEDIDO MANUAL".
    v-linha[3] = "CONSULTA PE DIDOS AUTOMATICOS".
    v-linha[4] = "CONSULTA DE PEDIDOS ESPECIAIS".
    
    disp v-linha with frame f-linha 1 down centered no-label 1 column
            row 5 title "  V E N D A  ".
    choose field v-linha with frame f-linha.
    
    hide frame f-linha no-pause.
    
    if frame-index = 1
    then do:
        run fipedido.p.
    end.
    else if frame-index = 2
    then do:
    end.
    else if frame-index = 3
    then do:
    end.
    else if frame-index = 4
    then do:
    end.
end.
