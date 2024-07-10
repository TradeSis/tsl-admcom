{admcab.i} 


message "Confirma a atualizacao dos precos de tabela?" update sresp.
if sresp
then do:
    hide message no-pause. 
    
    message "Atualizando...". 
    
    for each plaviv: 
        find first estoq where 
                    estoq.procod = plaviv.procod and
                    estoq.etbcod = 900 no-lock no-error.
        if avail estoq 
        then do transaction: 
            if plaviv.tipviv = 3 
            then plaviv.prepro = estoq.estvenda.  
            
            plaviv.pretab = estoq.estvenda.
        end.
    end. 
    message "Precos atualizados...". pause 2 no-message.
    hide message no-pause.
end.