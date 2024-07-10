def var psicred as recid.

for each contrato where contrato.dtinicial >= today - 30 no-lock.
    if contrato.banco = 10 or contrato.banco = 13
    then do:
        find first sicred_contrato where sicred_contrato.contnum = contrato.contnum no-lock no-error.
        if not avail sicred_contrato
        then do:
            if contrato.etbcod = 200
            then do: 
                run /admcom/progr/fin/sicrecontr_create.p (?,
                                                           contrato.contnum,
                                                           output psicred).
            end.    
        end.        
    end.
end.            
