TRIGGER PROCEDURE FOR Assign OF estoq.estvenda old oldestoq.
do on error undo.
    DtAltPreco = today.
    if oldestoq = 0
    then do:
        find hisprpro where hisprpro.etbcod     = estoq.etbcod and
                            hisprpro.procod     = estoq.procod and
                            hisprpro.data_inicio = today
                            no-error.
        if not avail hisprpro 
        then create hisprpro.
        ASSIGN 
            hisprpro.preco_tipo = "T"
            hisprpro.etbcod     = estoq.etbcod
            hisprpro.procod     = estoq.procod
            hisprpro.data_inicio = today
            hisprpro.data_fim    = ?
            hisprpro.preco_valor = estoq.estvenda
            hisprpro.OFFER_ID    = ?
            hisprpro.preco_plano  = 0
            hisprpro.preco_parcela = 0
            hisprpro.PRICE_KEY  = program-name(1)
            hisprpro.data_inclu = today
            hisprpro.hora_inclu = time .
    end.
    else do:
        find hisprpro where hisprpro.etbcod     = estoq.etbcod and
                            hisprpro.procod     = estoq.procod and
                            hisprpro.data_inicio = today
                            no-error.
        if not avail hisprpro 
        then create hisprpro.
        ASSIGN 
            hisprpro.preco_tipo = "R"
            hisprpro.etbcod     = estoq.etbcod
            hisprpro.procod     = estoq.procod
            hisprpro.data_inicio = today
            hisprpro.data_fim    = ?
            hisprpro.preco_valor = estoq.estvenda
            hisprpro.OFFER_ID    = ?
            hisprpro.preco_plano  = 0
            hisprpro.preco_parcela = 0
            hisprpro.PRICE_KEY  = program-name(1)
            hisprpro.data_inclu = today
            hisprpro.hora_inclu = time .
    end.
end.

    run triexporta.p
            ("estoq", 
             "TRIGGER_estvenda", 
             recid(estoq)).
                              
