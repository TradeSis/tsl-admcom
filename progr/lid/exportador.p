{admcab.i}

def var copcoes as char format "x(60)" extent 6 init 
    [/*1*/ " Exporta Contratos ",
     /*2*/ " Exporta Parcelas   ",   
     /*3*/ " Exporta Movimentos ",
     /*4*/ " Exporta Clientes/Limites ",
     /*5*/ " Marcação CLIENTES  Exportacao por JSON (cron)",
     /*6*/ " Marcação CONTRATOS Exportacao por JSON (cron)"].

def var iopcoes as int.

repeat.

    disp
        copcoes
        with frame fop
        row 3 centered title " EXPORTA LAYOUT LIDIA " no-labels
        width 70.
    choose field copcoes
        with frame fop.        
    iopcoes = frame-index.

    if iopcoes = 1
    then run lid/expcsv_contratos.p.
    if iopcoes = 2
    then run lid/expcsv_parcelas.p.
    if iopcoes = 3
    then run lid/expcsv_movimento.p.
    if iopcoes = 4
    then run lid/expcsv_limites.p.
    if iopcoes = 5
    then run lid/marca_synapse_cliente.p .
    if iopcoes = 6
    then run lid/marca_synapse_contrato.p .
    
    

end.