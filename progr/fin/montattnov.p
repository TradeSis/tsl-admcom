def input param ppdvmov as recid.
def input param ptela   as log.
 
def shared temp-table ttnovacao no-undo
    field tipo      as char
    field contnum   like contrato.contnum format ">>>>>>>>>>9"
    field valor     like contrato.vltotal
    field saldoabe  like titulo.titvlcob  
    index idx is unique primary tipo desc contnum asc.

for each ttnovacao.
    delete ttnovacao.
end.
    
find pdvmov where recid(pdvmov) = ppdvmov no-lock.

    for each pdvdoc of pdvmov no-lock.
        if int(pdvdoc.contnum) = 0 or
           pdvdoc.contnum = ?
        then next.   
        find first ttnovacao where ttnovacao.tipo = "ORIGINAL" and
                                   ttnovacao.contnum = int(pdvdoc.contnum)
                    no-error.
        if not avail ttnovacao
        then do:
            create ttnovacao.
            ttnovacao.tipo      = "ORIGINAL".
            ttnovacao.contnum   = int(pdvdoc.contnum).
        end.
        ttnovacao.valor = ttnovacao.valor + pdvdoc.valor.
        find titulo where titulo.contnum = int(pdvdoc.contnum) and
                          titulo.titpar  = pdvdoc.titpar
                          no-lock no-error.
        if not avail titulo
        then do: 
            find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock.
            find first titulo where 
                    titulo.empcod     = 19 and 
                    titulo.titnat     = no and 
                    titulo.modcod     = contrato.modcod and 
                    titulo.etbcod     = contrato.etbcod and 
                    titulo.clifor     = contrato.clicod and 
                    titulo.titnum     = pdvdoc.contnum and 
                    titulo.titpar     = pdvdoc.titpar
                    no-lock no-error.
            if not avail titulo
            then next. 
        end.    
        ttnovacao.saldoabe = ttnovacao.saldoabe + if titulo.titsit = "LIB" then titulo.titvlcob else 0.                  
        
        
    end.
    for each pdvforma of pdvmov where pdvforma.pdvtfcod = "93" no-lock.
        find contrato where contrato.contnum = int(pdvforma.contnum) no-lock no-error.
        if avail contrato
        then do:
            find first ttnovacao where ttnovacao.tipo = "NOVO" and
                                       ttnovacao.contnum = contrato.contnum
                        no-error.
            if not avail ttnovacao
            then do:
                create ttnovacao.
                ttnovacao.tipo      = "NOVO".
                ttnovacao.contnum   = contrato.contnum.
            end.
            ttnovacao.valor = ttnovacao.valor + contrato.vltotal.
            if contrato.dtinicial >= 07/01/2020
            then for each titulo where titulo.contnum = contrato.contnum no-lock.
                ttnovacao.saldoabe = ttnovacao.saldoabe + if titulo.titsit = "LIB" then titulo.titvlcob else 0.                  
            end.
            else for each titulo where 
                    titulo.empcod     = 19 and 
                    titulo.titnat     = no and 
                    titulo.modcod     = contrato.modcod and 
                    titulo.etbcod     = contrato.etbcod and 
                    titulo.clifor     = contrato.clicod and 
                    titulo.titnum     = string(contrato.contnum) 
                    no-lock.
                ttnovacao.saldoabe = ttnovacao.saldoabe + if titulo.titsit = "LIB" then titulo.titvlcob else 0.                  
            end.                                

        end.
    end.



if ptela 
then do:
    for each ttnovacao.
        disp ttnovacao.
    end.    
end.    
    