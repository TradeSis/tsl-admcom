def new global shared var scontador as int.

def input parameter par-rec as recid.
def input parameter par-operacao as char.
def input parameter vdtref  as date.
def input parameter par-valor as dec.
def input parameter par-oricobcod as int.
def input parameter par-cobcod as int.

{/admcom/progr/acha.i}

def var vtpcontrato as char.

/**def var vdtvenc     as date.**/
def var vdtant as date.
def buffer bctbposcart  for ctbposcart.

vdtref = date(month(vdtref),01,year(vdtref)).


def var vrec1 as recid.
def var vrec  as recid.
        
    find titulo where recid(titulo) = par-rec no-lock. 
        if   acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and 
            acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM" and 
                titulo.tpcontrato <> "L" 
        then vtpcontrato = "F". 
        else vtpcontrato = titulo.tpcontrato.
    
    /**if titulo.contnum = ? 
    **then do on error undo.
    **    find current titulo exclusive no-wait no-error.
    **    if avail titulo
    **    then do:
    **        titulo.contnum = int(titulo.titnum).
    **        find current titulo no-lock.
    **    end.    
    **    else do:
    **        find titulo where recid(titulo) = par-rec no-lock.
    **    end.
    **end.    **/
    
    if par-oricobcod <> par-cobcod
    then par-operacao = "TROCA".
        
    vrec1 = ?.    
    
    if par-oricobcod <> par-cobcod or
       par-operacao = "PAGAMENTO" or
       par-operacao = "SAIDA"  or
       par-operacao = "TROCA"
    then do on error undo:
        
            find last ctbposhiscart
                    where ctbposhiscart.contnum  = int(titulo.titnum) and
                          ctbposhiscart.titpar   = titulo.titpar and
                          ctbposhiscart.trecid   = recid(titulo) and
                          ctbposhiscart.dtref    <= vdtref and
                          (ctbposhiscart.dtrefSAIDA = ? or ctbposhiscart.dtrefSAIDA > vdtref)
                exclusive-lock no-error.
            
            if not avail ctbposhiscart
            then do:                      
                repeat.        
                    scontador = scontador + 1.
                    find first ctbposhiscart where ctbposhiscart.contnum  = int(titulo.titnum) and
                                                ctbposhiscart.titpar   = titulo.titpar and
                                                 ctbposhiscart.trecid   = recid(titulo) and
                                                  ctbposhiscart.dtinc    = today and
                                                  ctbposhiscart.hrinc    = scontador
                        no-lock no-error.
                    if avail ctbposhiscart then do:
                         pause 1 message "existe 1".
                         next.
                    end.   
                    leave.
                end.
                                                                       
                create ctbposhiscart.
                ASSIGN
                ctbposhiscart.trecid   = recid(titulo)  
                ctbposhiscart.dtinc    = today
                ctbposhiscart.hrinc    = scontador
                ctbposhiscart.cobcod   = par-oricobcod
                ctbposhiscart.modcod   = titulo.modcod
                ctbposhiscart.tpcontrato = vtpcontrato
                ctbposhiscart.etbcod   = titulo.etbcod
                ctbposhiscart.contnum  = int(titulo.titnum)
                ctbposhiscart.titpar   = titulo.titpar.
                ctbposhiscart.dtref    = vdtref.
                ctbposhiscart.operacaoENTRADA = par-operacao.
                /*
                if par-operacao = "troca"
                then pause 1 no-message.
                */
            end.
                ctbposhiscart.operacaoSAIDA = par-operacao.
                ctbposhiscart.dtrefSAIDA = vdtref.
                ctbposhiscart.ValorSAIDA      = ctbposhiscart.ValorSAIDA + par-valor.
                if par-operacao = "TROCA" and vdtref < date(month(today),01,year(today))
                then do:
                    find first ctbposcart where
                            ctbposcart.dtref  = vdtref
                            no-lock no-error.
                            
                    if avail ctbposcart
                    then do:        
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
                        ctbposcart.saida = ctbposcart.saida + ctbposhiscart.valorsaida.
                        ctbposcart.saldo   = ctbposcart.saldo   - ctbposhiscart.valorsaida.
                    end.
                end.    
                
        vrec1 = recid(ctbposhiscart).
    end. 
    do on error undo:
        if par-operacao = "EMISSAO" or
           par-operacao = "ENTRADA" or
           par-operacao = "troca"
        then do:
                repeat.
                    scontador = scontador + 1.
                    release ctbposhiscart.
                    find first ctbposhiscart where ctbposhiscart.contnum  = int(titulo.titnum) and
                                                ctbposhiscart.titpar   = titulo.titpar and
                                                 ctbposhiscart.trecid   = recid(titulo) and
                                                  ctbposhiscart.dtinc    = today and
                                                  ctbposhiscart.hrinc    = scontador
                        no-lock no-error.
                    if avail ctbposhiscart then do:
                        /**message ctbposhiscart.contnum ctbposhiscart.titpar ctbposhiscart.dtref ctbposhiscart.dtinc ctbposhiscart.hrinc.**/
                        pause 1 message "processando trocas, aguarde...".
                        next.
                    end.     
                    leave.
                end.
                create ctbposhiscart.

                ASSIGN
                ctbposhiscart.trecid   = recid(titulo)
                ctbposhiscart.dtinc    = today
                ctbposhiscart.hrinc    =  time
                ctbposhiscart.cobcod   = par-cobcod
                ctbposhiscart.modcod   = titulo.modcod
                ctbposhiscart.tpcontrato = vtpcontrato
                ctbposhiscart.etbcod   = titulo.etbcod
                ctbposhiscart.contnum  = int(titulo.titnum)
                ctbposhiscart.titpar   = titulo.titpar.
                ctbposhiscart.dtref    = vdtref.
                ctbposhiscart.dtrefSAIDA    = ?.
                ctbposhiscart.qtdtitulos = ctbposhiscart.qtdtitulos + 1. 
                ctbposhiscart.Valor      = ctbposhiscart.Valor + par-valor.
                ctbposhiscart.operacaoENTRADA = par-operacao.

            if par-operacao = "troca"
            then if titulo.cobcod <> par-cobcod
                 then do:
                    find current     titulo exclusive.
                    titulo.cobcod = par-cobcod.
                end.
                
           if par-operacao = "TROCA" and vdtref < date(month(today),01,year(today))
           then do: 
           
            find first ctbposcart where
                            ctbposcart.dtref  = vdtref
                            no-lock no-error.
                            
            if avail ctbposcart
            then do:        
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
                ctbposcart.entrada = ctbposcart.entrada + ctbposhiscart.valor.
                ctbposcart.saldo   = ctbposcart.saldo   + ctbposhiscart.valor.
            end.
            end.        
        end.
        
        vrec = recid(ctbposhiscart).
    end.
        
    find current ctbposhiscart no-lock.
    
                                            
