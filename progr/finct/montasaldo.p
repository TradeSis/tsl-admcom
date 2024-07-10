/*06032021 helio*/
def input param vdtreffim as date.
def var vdtref as date.
def var vdtant as date.
def buffer bctbposcart for ctbposcart.

vdtref = date(month(vdtreffim),01,year(vdtreffim)).
message vdtref. pause 1.
for each ctbposcart where ctbposcart.dtref = vdtref.
    delete ctbposcart.
end.
        vdtant = date(month(vdtref),01,year(vdtref)) - 1.
        vdtant = date(month(vdtant),01,year(vdtant)).
def var vsaldo as dec.
        hide message no-pause.
        message "carteira, gerando saldos deste mes... Aguarde....." vdtant "ref" vdtref.
        pause 2.    
        vsaldo = 0.
        for each bctbposcart where 
          bctbposcart.dtref = vdtant
          no-lock.

           find first ctbposcart where 
                ctbposcart.dtref  = vdtref and
                /*ctbposcart.dtvenc = bctbposcart.dtvenc and**/
                ctbposcart.etbcod = bctbposcart.etbcod and
                ctbposcart.modcod = bctbposcart.modcod and
                ctbposcart.tpcontrato = bctbposcart.tpcontrato and
                ctbposcart.cobcod = bctbposcart.cobcod
             no-error.
            if not avail ctbposcart
            then do:
                create ctbposcart.
                ctbposcart.dtref  = vdtref.
                /**ctbposcart.dtvenc = bctbposcart.dtvenc.**/
                ctbposcart.etbcod = bctbposcart.etbcod .
                ctbposcart.modcod = bctbposcart.modcod .
                ctbposcart.tpcontrato = bctbposcart.tpcontrato.
                ctbposcart.cobcod = bctbposcart.cobcod.
            end. 
            ctbposcart.saldoanterior = bctbposcart.saldo. 
            ctbposcart.saldo         = bctbposcart.saldo.
            vsaldo = vsaldo + bctbposcart.saldo.
    end.

for each ctbposhiscart where ctbposhiscart.dtref = vdtref and ctbposhiscart.dtrefsaida = ? no-lock.
           find first ctbposcart where 
                ctbposcart.dtref  = vdtref and
                ctbposcart.etbcod = ctbposhiscart.etbcod and
                ctbposcart.modcod = ctbposhiscart.modcod and
                ctbposcart.tpcontrato = ctbposhiscart.tpcontrato and
                ctbposcart.cobcod = ctbposhiscart.cobcod
             no-error.
            if not avail ctbposcart
            then do:
                create ctbposcart.
                ctbposcart.dtref  = vdtref.
                ctbposcart.etbcod = ctbposhiscart.etbcod .
                ctbposcart.modcod = ctbposhiscart.modcod .
                ctbposcart.tpcontrato = ctbposhiscart.tpcontrato.
                ctbposcart.cobcod = ctbposhiscart.cobcod.
            end. 
            if ctbposhiscart.operacaoENTRADA = "TROCA"
            then ctbposcart.entrada = ctbposcart.entrada + ctbposhiscart.valor.
            else ctbposcart.emissao = ctbposcart.emissao + ctbposhiscart.valor.
            
            ctbposcart.saldo   = ctbposcart.saldo   + ctbposhiscart.valor.
            vsaldo = vsaldo + ctbposhiscart.valor.
            
end.

for each ctbposhiscart where ctbposhiscart.dtref = vdtref and ctbposhiscart.dtrefsaida = vdtref no-lock.
           find first ctbposcart where 
                ctbposcart.dtref  = vdtref and
                ctbposcart.etbcod = ctbposhiscart.etbcod and
                ctbposcart.modcod = ctbposhiscart.modcod and
                ctbposcart.tpcontrato = ctbposhiscart.tpcontrato and
                ctbposcart.cobcod = ctbposhiscart.cobcod
             no-error.
            if not avail ctbposcart
            then do:
                create ctbposcart.
                ctbposcart.dtref  = vdtref.
                ctbposcart.etbcod = ctbposhiscart.etbcod .
                ctbposcart.modcod = ctbposhiscart.modcod .
                ctbposcart.tpcontrato = ctbposhiscart.tpcontrato.
                ctbposcart.cobcod = ctbposhiscart.cobcod.
            end. 
            if ctbposhiscart.operacaoENTRADA = "TROCA"
            then ctbposcart.entrada = ctbposcart.entrada + ctbposhiscart.valor.
            else ctbposcart.emissao = ctbposcart.emissao + ctbposhiscart.valor.
            ctbposcart.saldo   = ctbposcart.saldo   + ctbposhiscart.valor.
            vsaldo = vsaldo + ctbposhiscart.valor.

            if ctbposhiscart.operacaoSAIDA = "TROCA"
            then ctbposcart.saida     = ctbposcart.saida     + ctbposhiscart.valor.
            else ctbposcart.pagamento = ctbposcart.pagamento + ctbposhiscart.valor.

            ctbposcart.saldo   = ctbposcart.saldo   - ctbposhiscart.valor.
            vsaldo = vsaldo - ctbposhiscart.valor.

             
end.

    
for each ctbposhiscart where ctbposhiscart.dtrefsaida > vdtref and ctbposhiscart.dtrefsaida <> ? and ctbposhiscart.dtref = vdtref no-lock.
           find first ctbposcart where 
                ctbposcart.dtref  = vdtref and
                ctbposcart.etbcod = ctbposhiscart.etbcod and
                ctbposcart.modcod = ctbposhiscart.modcod and
                ctbposcart.tpcontrato = ctbposhiscart.tpcontrato and
                ctbposcart.cobcod = ctbposhiscart.cobcod
             no-error.
            if not avail ctbposcart
            then do:
                create ctbposcart.
                ctbposcart.dtref  = vdtref.
                ctbposcart.etbcod = ctbposhiscart.etbcod .
                ctbposcart.modcod = ctbposhiscart.modcod .
                ctbposcart.tpcontrato = ctbposhiscart.tpcontrato.
                ctbposcart.cobcod = ctbposhiscart.cobcod.
            end. 
            if ctbposhiscart.operacaoENTRADA = "TROCA"
            then ctbposcart.entrada = ctbposcart.entrada + ctbposhiscart.valor.
            else ctbposcart.emissao = ctbposcart.emissao + ctbposhiscart.valor.
            ctbposcart.saldo   = ctbposcart.saldo   + ctbposhiscart.valor.
            vsaldo = vsaldo + ctbposhiscart.valor.


end.
    
for each ctbposhiscart where ctbposhiscart.dtrefsaida = vdtref and ctbposhiscart.dtref < vdtref no-lock.
           find first ctbposcart where 
                ctbposcart.dtref  = vdtref and
                ctbposcart.etbcod = ctbposhiscart.etbcod and
                ctbposcart.modcod = ctbposhiscart.modcod and
                ctbposcart.tpcontrato = ctbposhiscart.tpcontrato and
                ctbposcart.cobcod = ctbposhiscart.cobcod
             no-error.
            if not avail ctbposcart
            then do:
                create ctbposcart.
                ctbposcart.dtref  = vdtref.
                ctbposcart.etbcod = ctbposhiscart.etbcod .
                ctbposcart.modcod = ctbposhiscart.modcod .
                ctbposcart.tpcontrato = ctbposhiscart.tpcontrato.
                ctbposcart.cobcod = ctbposhiscart.cobcod.
            end. 
            if ctbposhiscart.operacaoSAIDA = "TROCA"
            then ctbposcart.saida = ctbposcart.saida + ctbposhiscart.valorsaida.
            else ctbposcart.pagamento = ctbposcart.pagamento + ctbposhiscart.valorsaida.
            ctbposcart.saldo   = ctbposcart.saldo  - ctbposhiscart.valor.
            vsaldo = vsaldo - ctbposhiscart.valor.
end.
message vsaldo.
pause 1.


for each ctbposcart where ctbposcart.dtref = vdtref and saldo = 0 and emissao = 0 and pagamento = 0 and entradas = 0 and saidas = 0  .
    delete ctbposcart.
end    

