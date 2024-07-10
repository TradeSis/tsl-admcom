def input param pstatus     like sicred_pagam.sstatus.

{admbatch.i}
{acha.i}

pause 0 before-hide.

        for each sicred_pagam where
            sicred_pagam.sstatus  = "ERRO" and sicred_pagam.datamov  >= today - 90: 
            sicred_pagam.sstatus  = pstatus.
            sicred_pagam.descerro = "". 
            
        end.

        find first sicred_param where (sicred_param.dtfim = ? or sicred_param.dtfim > today) and 
                                      sicred_param.dtini <= today
                                      no-lock no-error.
        if not avail sicred_param                                      
        then do:
            for each sicred_contrato where
                sicred_contrato.sstatus  = pstatus:

                sicred_contrato.descerro = "Sem tabela de Parametros vigente".
                hide message no-pause.
                message today sicred_contrato.descerro. 
                sicred_contrato.sstatus  = "ERRO".
            end.    
        end.


        for each sicred_pagam where
            sicred_pagam.sstatus  = pstatus and
            sicred_pagam.datamov  >= today - 90:

            find contrato where contrato.contnum = sicred_pagam.contnum no-lock no-error. 
            if not avail contrato 
            then do:
                sicred_pagam.descerro = "Contrato " + string(sicred_pagam.contnum) + " nao encontrado".
                hide message no-pause.
                message  today sicred_pagam.sstatus sicred_pagam.operacao sicred_pag.contnum sicred_pagam.descerro. 
                sicred_pagam.sstatus  = "ERRO".
                next.
            end.
  
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
                end.
            if not avail titulo
            then do:
                sicred_pagam.descerro = "Titulo " +  string(contrato.contnum) + "/" + string(sicred_pagam.titpar) + " nao encontrado".
                hide message no-pause.
                message  today sicred_pagam.sstatus sicred_pagam.operacao sicred_pag.contnum sicred_pagam.descerro. 
                
                sicred_pagam.sstatus  = "ERRO".
                next.
            end.

            
            find cobra of titulo no-lock.
            if not cobra.sicred
            then do:
                sicred_pagam.descerro = "Titulo " +  string(contrato.contnum) + "/" + string(sicred_pagam.titpar) + " nao esta na carteira sicred".
                hide message no-pause.
                message  today sicred_pagam.sstatus sicred_pagam.operacao sicred_pag.contnum sicred_pagam.descerro. 
                
                sicred_pagam.sstatus  = "CANCELA".
                next.
            end.
               
               
        end.






