/* 26112021 helio venda carteira */
{admbatch.i}
def input param pstatus   as char.
def input param poperacao as char.



def new shared temp-table ttsicred no-undo
    field marca     as log format "*/ "
    field cobcod    like titulo.cobcod     
    field dtenvio   like lotefin.datexp
    field lotnum    like lotefin.lotnum
    
    field datamov   like pdvforma.datamov
    field ctmcod    like pdvforma.ctmcod        
    field modcod    like poscart.modcod
    field tpcontrato    like poscart.tpcontrato
    field qtd       as int 

    field titvlcob       like pdvdoc.titvlcob
    field valor_encargo  like pdvdoc.valor_encargo
    field desconto       like pdvdoc.desconto
    field valor          like pdvdoc.valor


    index idx is unique primary 
        cobcod asc
        dtenvio  asc
        datamov asc 
        ctmcod asc
        modcod asc
        tpcontrato asc  
        lotnum          .

for each cobra where cobra.sicred = yes and cobra.cobcod = 10 /* so financeira */ no-lock.
    run montatt (cobra.cobcod).

    find first ttsicred where ttsicred.marca = yes and ttsicred.cobcod = cobra.cobcod no-error.
    if not avail ttsicred
    then do:
        message "Nenhum registro encontrato para " pstatus poperacao cobra.cobcod cobra.cobnom.
        next.
    end.     
    message cobra.cobcod cobra.cobnom poperacao pstatus.
    
                    if cobra.cobcod = 10
                    then do:
                        if poperacao = "CANCELAMENTO"
                        then run fin/opesiccanenvia.p (poperacao, pstatus).
                        else if poperacao = "ESTORNO"
                             then run fin/opesicestenvia.p (poperacao, pstatus).
                             else do:
                                run fin/opesicpagenvia.p (poperacao, pstatus).
                            end.     
                    end.
                    /**helio 21122021 retirado do projeto
                    *if cobra.cobcod = 14
                    *then do:
                    *    if poperacao = "PAGAMENTO"
                    *    then do:
                    *        run fin/opefidcpagenvia.p (poperacao,pstatus).
                    *    end.   
                    *end.
                    *if cobra.cobcod = 16
                    *then do:
                    *    if poperacao = "PAGAMENTO"
                    *    then do:
                    *        run finct/opefidcpagenvia16.p (poperacao,pstatus).
                    *    end.
                    *end.        
                    */
end.


procedure montatt.
def input param pcobcod as int.
hide message no-pause.
message color normal "fazendo calculos... aguarde...".


for each ttsicred.
    delete ttsicred.
end.

    if pstatus = "ENVIAR"
    then 
        for each sicred_pagam where
            sicred_pagam.operacao = poperacao and
            sicred_pagam.cobcod   = pcobcod   and
            sicred_pagam.sstatus  = pstatus 
             no-lock.
             
             
            run gravatt.      
    end.
    

hide message no-pause.
           
end procedure.


procedure gravatt.
    find lotefin where 
            lotefin.lotnum = sicred_pagam.lotnum no-lock no-error.
    find contrato where contrato.contnum = sicred_pagam.contnum no-lock.

        find titulo where titulo.contnum = contrato.contnum and
                      titulo.titpar  = sicred_pagam.titpar
                      no-lock no-error.
                if not avail titulo
                then do:
                    find first titulo where
                    titulo.empcod     = 19 and
                    titulo.titnat     = no and
                    titulo.modcod     = contrato.modcod and
                    titulo.etbcod     = contrato.etbcod and
                    titulo.clifor     = contrato.clicod and
                    titulo.titnum     = string(contrato.contnum) and 
                    titulo.titpar     = sicred_pagam.titpar and
                    titulo.titdtemi   = contrato.dtinicial
                    no-lock no-error.
                    if not avail titulo then next.
                end.
 
        find first pdvmov where 
                pdvmov.etbcod = sicred_pagam.etbcod and
                pdvmov.cmocod = sicred_pagam.cmocod and
                pdvmov.datamov = sicred_pagam.datamov and
                pdvmov.sequencia = sicred_pagam.sequencia and pdvmov.ctmcod = sicred_pagam.ctmcod
                no-lock .
            find pdvdoc of pdvmov where
                pdvdoc.seqreg = sicred_pagam.seqreg
                no-lock.
     
    find first ttsicred where
        ttsicred.cobcod  = sicred_pagam.cobcod and            
        ttsicred.datamov = sicred_pagam.datamov and
        ttsicred.dtenvio = (if avail lotefin
                           then lotefin.datexp
                           else ?) and
        ttsicred.lotnum  = (if avail lotefin
                           then lotefin.lotnum
                           else ?) and
        ttsicred.ctmcod  = sicred_pagam.ctmcod  and
        ttsicred.modcod  = titulo.modcod         and
        ttsicred.tpcontrato = titulo.tpcontrato
        no-error.
    if not avail ttsicred
    then do:
        create ttsicred.
        ttsicred.marca   = yes. /* automatico */
        ttsicred.cobcod  = sicred_pagam.cobcod.
        ttsicred.datamov = sicred_pagam.datamov.
        ttsicred.dtenvio = (if avail lotefin
                           then lotefin.datexp
                           else ?).
        ttsicred.lotnum = (if avail lotefin
                           then lotefin.lotnum
                           else ?).
        ttsicred.ctmcod  = sicred_pagam.ctmcod.
        ttsicred.modcod  = titulo.modcod.
        ttsicred.tpcontrato = titulo.tpcontrato.
    end.
    ttsicred.qtd = ttsicred.qtd + 1.
    
    ttsicred.titvlcob = ttsicred.titvlcob + pdvdoc.titvlcob.
    ttsicred.valor_encargo = ttsicred.valor_encargo + pdvdoc.valor_encargo.
    ttsicred.desconto = ttsicred.desconto + pdvdoc.desconto.
    ttsicred.valor = ttsicred.valor + pdvdoc.valor.
 

end procedure.






