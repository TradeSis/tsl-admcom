
DEF TEMP-TABLE ttmarca NO-UNDO
    FIELD rec_id AS RECID.

def var vi as int.
def var varqcsv as char format "x(65)".
DEF VAR vacordoquebrado AS LOG.
DEF VAR vsituacaoparcela AS INT.
varqcsv = "/admcom/tmp/serasa/" + 
             "CO_" + string(today,"99999999") + "_001" + ".csv".

def var vsituacao as char extent 2 initial ["A","E"].
            
output to value(varqcsv).
put unformatted  "CNPJ_CREDOR;" 
                 "NUMERO_ACORDO;"
                 "NUMERO_PARCELA;"
                 "DOCUMENTO;"
                 "DATA_PAGAMENTO;"
                 "SITUACAO_PARCELA;"
                 skip.


do vi = 1 to 2.
for each aoacordo where aoacordo.tipo = "SERASA" AND aoacordo.situacao = vsituacao[vi] no-lock.
    
    vacordoquebrado = false.

    for each aoacparcela of aoacordo.
  
        if aoacparcela.DtEnvio <> ? then next.
        
        if aoacparcela.DtVencimento < today and aoacparcela.dtbaixa = ?
        then vacordoquebrado = true.
        
        if aoacparcela.dtBaixa <> ? 
        then vsituacaoparcela = 1.
        else do:
            if aoacparcela.DtVencimento < today
            then vsituacaoparcela = 2.
            else vsituacaoparcela = 0.
        end.
        
        if vsituacaoparcela = 0    /* só envia quebrado e pago, que ainda nao foi enviado */
        then next.
        
        FIND clien where clien.clicod = aoacordo.clifor NO-LOCK.
        
        aoacparcela.enviar = yes.
        aoacparcela.DtEnvio = today.
                   
        put unformatted
            "96662168000131" ";"
            aoacordo.IDAcordo ";"
            aoacparcela.Parcela ";"
            clien.ciccgc ";"
            aoacparcela.dtBaixa ";" 
            vsituacaoparcela ";"
            skip.

    end.

    if vacordoquebrado = true
    then do:
        create ttmarca.
        ttmarca.rec_id = recid(aoacordo).
    end.

end.
end.
output close.

    
                 
FOR EACH ttmarca NO-LOCK:
    find aoacordo where recid(aoacordo) = ttmarca.rec_id.
     aoacordo.Situacao = "Q".    
end. 
    














