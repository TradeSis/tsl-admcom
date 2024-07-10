def input  param ppdvdoc as recid.
def input  param pcontnum  like contrato.contnum. 
def input  param ptitpar   like titulo.titpar.
def output param psicred as recid.

def var pnovacao-sicred as log. /* helio 09052022 ID 117402 - Exportação de pagamentos - admcom */
def buffer xcontrato for contrato.
def buffer xtitulo for titulo.
def buffer xcobra for cobra.

def var voperacao as char.

find pdvdoc where recid(pdvdoc) = ppdvdoc no-lock no-error.
if avail pdvdoc
then do:
    find pdvmov   of pdvdoc no-lock.
    find pdvtmov of pdvdoc no-lock.
    find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock no-error.
    if not avail contrato
    then next.
    find titulo   where titulo.contnum   = contrato.contnum    and
                        titulo.titpar    = pdvdoc.titpar
               no-lock no-error.
    
    ptitpar = pdvdoc.titpar.
    
end.    
else do:
    find contrato where contrato.contnum = pcontnum no-lock no-error.
    if not avail contrato 
    then next.
    
    find titulo where titulo.contnum = contrato.contnum and
                      titulo.titpar  = ptitpar 
                      no-lock no-error.
end.


                if not avail titulo
                then do:
                    find first titulo where
                    titulo.empcod     = 19 and
                    titulo.titnat     = no and
                    titulo.modcod     = contrato.modcod and
                    titulo.etbcod     = contrato.etbcod and
                    titulo.clifor     = contrato.clicod and
                    titulo.titnum     = string(contrato.contnum) and 
                    titulo.titpar     = ptitpar and
                    titulo.titdtemi   = contrato.dtinicial
                    no-lock no-error.
                    if avail titulo
                    then do on error undo:
                        /*
                        find current titulo exclusive.
                        titulo.contnum  = contrato.contnum. 
                        find current titulo no-lock.
                        */
                    end.    
                end.
    
    if not avail titulo then next.

pnovacao-sicred = no.
if pdvtmov.novacao
then do:
    find first pdvmoeda of pdvmov where pdvmoeda.titpar > 0 no-lock no-error.
    if avail pdvmoeda
    then do:
        find xcontrato where xcontrato.contnum = int(pdvmoeda.titnum) no-lock no-error.
        if avail xcontrato
        then do:
                 find first xtitulo where
                    xtitulo.empcod     = 19 and
                    xtitulo.titnat     = no and
                    xtitulo.modcod     = xcontrato.modcod and
                    xtitulo.etbcod     = xcontrato.etbcod and
                    xtitulo.clifor     = xcontrato.clicod and
                    xtitulo.titnum     = string(xcontrato.contnum) and 
                    xtitulo.titpar     = pdvmoeda.titpar and
                    xtitulo.titdtemi   = xcontrato.dtinicial
                    no-lock no-error.
                    if avail xtitulo
                    then do:
                        find xcobra of xtitulo no-lock.
                        if xcobra.sicred
                        then pnovacao-sicred = yes.
                    end.

        end.
    end.
end.    
find cobra where cobra.cobcod = titulo.cobcod no-lock.

if cobra.sicred
then DO on error undo:

    if avail pdvdoc and pdvdoc.datamov = ? then return.
    voperacao = if not avail pdvdoc
                then "PAGAMENTO"
                else if pdvdoc.titvlcob < 0 
                     then "ESTORNO" 
                     else if pdvtmov.novacao /*19022021*/ and cobra.cobcod <> 14 /*fidc vai para pagamento */
                             and pnovacao-sicred
                          then "NOVACAO"  
                          else if pdvtmov.devolucao   
                               then "CANCELAMENTO"  
                               else if pdvtmov.ctmcod = "DRL" /* Helio 13112023 - Desenrola - Arquivo Separado */
                                    then "DESENROLA"
                                    else "PAGAMENTO".

    find first sicred_pagam where 
            sicred_pagam.contnum = contrato.contnum and
            sicred_pagam.titpar  = titulo.titpar    and
            sicred_pagam.operacao = voperacao  and                                         
        sicred_pagam.dtinc     = today and
        sicred_pagam.hrinc     = time
        no-lock no-error.
    if avail sicred_pagam then pause 1.
        
    create sicred_pagam.
    psicred = recid(sicred_pagam).  
    if avail pdvtmov
    then do:
        if pdvtmov.ctmcod = "ECP" or pdvtmov.ctmcod = "EDP"
        then do:
            if pdvdoc.datamov = titulo.titdtpag
            then voperacao = "CANCELAMENTO".
            else voperacao = "PAGAMENTO".
        end.
        
        sicred_pagam.operacao  = voperacao.
    end.
    else do:
        sicred_pagam.operacao = "PAGAMENTO".
    end.                                     
    assign
    sicred_pagam.dtinc     = today
    sicred_pagam.hrinc     = time
    sicred_pagam.contnum   = contrato.contnum
    sicred_pagam.titpar   = titulo.titpar
    sicred_pagam.sstatus   = "ENVIAR"
    sicred_pagam.cobcod    = cobra.cobcod
    sicred_pagam.lotnum    = ?.
    if avail pdvdoc
    then do:
        assign
        sicred_pagam.cmocod    = pdvmov.cmocod
        sicred_pagam.ctmcod    = pdvmov.ctmcod
        sicred_pagam.DataMov   = pdvmov.DataMov
        sicred_pagam.etbcod    = pdvmov.etbcod
        sicred_pagam.Sequencia = pdvmov.Sequencia
        sicred_pagam.seqreg    = pdvdoc.seqreg.
    end.
    else do:
        assign
        sicred_pagam.cmocod    = ?
        sicred_pagam.ctmcod    = "SIT"
        sicred_pagam.DataMov   = titulo.titdtpag
        sicred_pagam.etbcod    = titulo.etbcobra
        sicred_pagam.Sequencia = ?
        sicred_pagam.seqreg  = ?.
    end.            
END.

