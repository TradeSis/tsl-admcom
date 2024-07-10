{admcab-batch.i new}

message today "VAI RODAR O GERA DESPESA" today - 1.
 
for each estab 
    where estab.usap2k
    no-lock.
    message today string(time,"hh:mm:ss") " pesquisando vendas filial " estab.etbcod.
    for each cmon of estab no-lock.
        for each pdvdoc where
                pdvdoc.etbcod = estab.etbcod and
                pdvdoc.cmocod = cmon.cmocod and
                pdvdoc.datamov = today - 1
            no-lock. 
            
            find first plani where plani.etbcod = pdvdoc.etbcod  
                        and plani.placod = pdvdoc.placod
                       no-lock no-error.     
                    if avail plani
                    then do:
                         def var htime as int.
                         htime = time.
                        message today string(time,"hh:mm:ss") " gera-despesa" plani.numero.
                         run /admcom/progr/gera-despesa.p (recid(plani))
                             no-error.
                         message today string(time,"hh:mm:ss") " gera-despesa rodou em " string(time - htime,"HH:MM:SS").
                     end.
        end.
    end.
end.                 