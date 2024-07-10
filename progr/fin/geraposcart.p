

    def input parameter par-rec as recid.
    def input parameter par-operacao as char.
    def input parameter vdtref  as date.

{/admcom/progr/acha.i}
    def var vtpcontrato as char.
    def buffer bposcart  for poscart.
    vdtref = date(month(vdtref),01,year(vdtref)).
        
    find titulo where recid(titulo) = par-rec no-lock.
                       if titulo.titsit = "LIB" or
                          titulo.titsit = "PAG" 
                       then .
                       else next.   
                  if   acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                       acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                    then vtpcontrato = "F".
                    else vtpcontrato = titulo.tpcontrato.

   find first poscart where 
        poscart.dtref  = vdtref 
    no-error.
    if not avail poscart
    then do:
        for each bposcart where bposcart.dtref = date(month(vdtref - 1),01,year(vdtref - 1)) no-lock.
            disp bposcart.
            
           find first poscart where 
                poscart.dtref  = vdtref and
                poscart.dtvenc = bposcart.dtvenc and
                poscart.etbcod = bposcart.etbcod and
                poscart.modcod = bposcart.modcod and
                poscart.tpcontrato = bposcart.tpcontrato 
            no-error.
            if not avail poscart
            then do:
                create poscart.
                poscart.dtref  = vdtref.
                poscart.dtvenc = bposcart.dtvenc.
                poscart.etbcod = bposcart.etbcod .
                poscart.modcod = bposcart.modcod .
                poscart.tpcontrato = bposcart.tpcontrato.
                poscart.saldoanterior = bposcart.saldo.
                poscart.saldo         = bposcart.saldo.
                
                
            end.
        end.
       
    end.   

   find first poscart where 
        poscart.dtref  = vdtref and
        poscart.dtvenc = date(month(titulo.titdtven),01,year(titulo.titdtven)) and
        poscart.etbcod = titulo.etbcod and
        poscart.modcod = titulo.modcod and
        poscart.tpcontrato = vtpcontrato 
    no-error.
    if not avail poscart
    then do:
        create poscart.
        poscart.dtref  = vdtref.
        poscart.dtvenc = date(month(titulo.titdtven),01,year(titulo.titdtven)).
        poscart.etbcod = titulo.etbcod.
        poscart.modcod = titulo.modcod.
        poscart.tpcontrato = vtpcontrato.
        
    end.
    
    if par-operacao = "emissao"
    then  poscart.emissao       = poscart.emissao + titulo.titvlcob.
    if par-operacao = "pagamento"
    then poscart.pagamento      = poscart.pagamento + titulo.titvlcob.
    
    /*poscart.entradas      = 0.
    poscart.saidas        = poscart.saidas  + if titulo.titdtpag > vdtref or titulo.titdtpag = ?
                                              then 0
                                              else titulo.titvlcob.
    **/
                                                  
    poscart.saldo         = poscart.saldoanterior + poscart.emissao -  poscart.pagamento +
                                                  + poscart.entradas - poscart.saidas.
    

