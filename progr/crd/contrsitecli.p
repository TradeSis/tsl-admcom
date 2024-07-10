{admcab.i}
def var vclicod like clien.clicod init 0.
def var par-codigoPedido like contrsite.codigoPedido init "".

repeat:

    form vclicod label "Cli" 
        par-codigoPedido
            with frame fcli row 3 side-labels width 80 
        title " CREDIARIO DIGITAL "  1 down.
        
    update vclicod
        with frame fcli.
    if vclicod = 0    
    then do:
        update par-codigoPedido label "Pedido" with frame fcli.
    end.
    else do:    
        find clien where clien.clicod = vclicod no-lock.
    end.
    
    run crd/contrsite.p (vclicod, par-codigoPedido).
     

end.