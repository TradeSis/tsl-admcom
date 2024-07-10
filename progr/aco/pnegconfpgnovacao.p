
def output param precOK as recid.
def input param pformaPagamento as char.
def input param pidAcordo    as int.

precOK = ?.
def var vseq as int.
def var vvltotal    as dec.
def var vvlf_principal as dec.
def var vvlf_acrescimo as dec.
def var vvlentra as dec.
def var vqtdParcelas as int.
def var vmodcod as char.
def var vtitvlaco   as dec.

def var vcontnum as int.
def var prec as recid.
def var precentrada as recid.
def var vseqreg as int.
def var vjuro as dec.
def buffer epdvmov for pdvmov.
     
find first pdvtmov where pdvtmov.ctmcod = "NAO" no-lock.

find cmon where cmon.etbcod = 999 and cmon.cxacod = 99 no-lock.
                    
run fin/cmdincdt.p (recid(cmon), 
                    recid(pdvtmov),  
                    today,
                    output prec).

find pdvmov where recid(pdvmov) = prec no-lock.  

find first pdvtmov where pdvtmov.ctmcod = "AOB" no-lock.  

run fin/cmdincdt.p (recid(cmon), recid(pdvtmov),  
                    today, 
                    output precentrada).

find epdvmov where recid(epdvmov) = precentrada no-lock.

find aoacordo where aoacordo.idacordo = pidAcordo no-lock.
                            

    do for geranum on error undo on endkey undo: 
    /*** Numeracao para CONTRATOS criados na matriz ***/ 
        find geranum where geranum.etbcod = 999 exclusive no-error. 
        if not avail geranum 
        then do: 
            create geranum. 
            assign geranum.etbcod  = 999 
                geranum.clicod  = 300000000 
                geranum.contnum = 300000000. 
        end. 
        geranum.contnum = geranum.contnum + 1. 
        find current geranum no-lock. 
        vcontnum = geranum.contnum. 
    end.

    vvltotal        = 0.    
    vvlf_principal  = 0.
    vvlf_acrescimo  = 0.
    vvlentra        = 0.
    vqtdParcelas    = 0.
    vmodcod = "".
    vtitvlaco = 0.
        
    for each aoacorigem of aoacordo no-lock.
        find contrato of aoacorigem no-lock. 
        find titulo where titulo.empcod = 19 and titulo.titnat = no and
               titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
               titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum) and
               titulo.titpar = aoacorigem.titpar
                no-lock.       
        if titulo.titsit = "LIB" then. else next.
        if vmodcod = "" 
        then if titulo.modcod begins "CP"
             then vmodcod = "CPN".
             else vmodcod = "CRE".
        vvlf_principal = vvlf_principal + aoacorigem.vlcob.
    end.
    for each aoacparcela of aoacordo no-lock.
        if aoacparcela.parcela = 0
        then vvlentra = aoacparcela.VlCobrado.
        else vqtdParcelas = vqtdParcelas + 1.
        vtitvlaco = vtitvlaco + aoacparcela.VlCobrado.       
    end.
    vvlf_acrescimo = vtitvlaco - vvlf_principal - vvlentra.
    
    /* cria contrato novo */
    do on error undo:
        create contrato.
        ASSIGN
            contrato.contnum   = vcontnum
            contrato.clicod    = aoacordo.clifor
            contrato.dtinicial = pdvmov.datamov
            contrato.etbcod    = aoacordo.etbcod
            contrato.vltotal   = vvltotal
            contrato.vlentra   = vvlentra
            contrato.modcod    = vmodcod
            contrato.crecod    = 500
            contrato.banco = if vmodcod = "CPN"
                             then 13 else 10
            contrato.tpcontrato = "N".
            
            contrato.vlf_acrescimo = vvlf_acrescimo.
            contrato.vlf_principal = vvlf_principal.
            contrato.nro_parcelas  = vqtdParcelas. 
            contrato.vltotal       = vtitvlaco.
            
            find first pdvforma where      
                     pdvforma.etbcod     = pdvmov.etbcod and
                 pdvforma.cmocod     = pdvmov.cmocod and
                 pdvforma.DataMov    = pdvmov.DataMov and
                 pdvforma.Sequencia  = pdvmov.Sequencia and
                 pdvforma.ctmcod     = pdvmov.ctmcod and
                 pdvforma.COO        = pdvmov.COO and
                 pdvforma.seqforma   = 1
                no-error.
            if not avail pdvforma 
            then do: 
                create pdvforma.
                assign
                    pdvforma.etbcod     = pdvmov.etbcod
                    pdvforma.DataMov    = pdvmov.DataMov
                    pdvforma.cmocod     = pdvmov.cmocod
                    pdvforma.COO        = pdvmov.COO
                    pdvforma.Sequencia  = pdvmov.Sequencia
                    pdvforma.ctmcod     = pdvmov.ctmcod 
                    pdvforma.seqforma   = 1.
            end.                     

            find pdvtforma where pdvtforma.pdvtfcod = "93" no-lock no-error.
            pdvforma.crecod       = contrato.crecod.
            pdvforma.modcod       = contrato.modcod.
            pdvforma.pdvtfcod     = "93".
            pdvforma.fincod       = 1.
            pdvforma.valor_forma  = contrato.vlTotal.
            pdvforma.valor        = contrato.vlTotal.


            pdvforma.contnum      = string(contrato.contnum).
            pdvforma.clifor       = contrato.clicod.
            pdvforma.crecod       = 2.
            
            pdvforma.qtd_parcelas = contrato.nro_parcela.
            pdvforma.valor_ACF    = contrato.vlf_Acrescimo.
            pdvforma.valor        = contrato.vlTotal.

    end.                                                    
    
    /* cria parcelas */
    for each aoacparcela of aoacordo 
        by aoacparcela.parcela.
                
        create titulo.
        ASSIGN
            titulo.empcod     = 19
            titulo.modcod     = contrato.modcod
            titulo.tpcontrato = "N" 
            titulo.CliFor     = contrato.Clicod
            titulo.titnum     = string(contrato.contnum)
            titulo.titpar     = aoacparcela.parcela
            titulo.titnat     = no
            titulo.etbcod     = contrato.etbcod
            titulo.titdtemi   = pdvmov.datamov
            titulo.titdtven   = aoacparcela.dtVencimento
            titulo.titvlcob   = aoacparcela.vlCobrado.

                find first pdvmoeda where      
                     pdvmoeda.etbcod       = pdvmov.etbcod and
                     pdvmoeda.cmocod       = pdvmov.cmocod and
                     pdvmoeda.DataMov      = pdvmov.DataMov and
                     pdvmoeda.Sequencia    = pdvmov.Sequencia and
                     pdvmoeda.ctmcod       = pdvmov.ctmcod and
                     pdvmoeda.COO          = pdvmov.COO and
                     pdvmoeda.seqforma     = pdvforma.seqforma and
                     pdvmoeda.seqfp        = 1 and
                     pdvmoeda.titpar       = titulo.titpar
                    no-error.
                if not avail pdvmoeda
                then do: 
                    create pdvmoeda.
                    /*pdvmoeda.titcod   = next-value(titcod).*/
                    assign
                         pdvmoeda.etbcod       = pdvmov.etbcod
                         pdvmoeda.DataMov      = pdvmov.DataMov
                         pdvmoeda.cmocod       = pdvmov.cmocod
                         pdvmoeda.COO          = pdvmov.COO
                         pdvmoeda.Sequencia    = pdvmov.Sequencia
                         pdvmoeda.ctmcod       = pdvmov.ctmcod
                         pdvmoeda.seqforma     = pdvforma.seqforma
                         pdvmoeda.seqfp        = 1
                         pdvmoeda.titpar       = titulo.titpar.   
                end.                  
                assign
                    pdvmoeda.contrato_p2k = pdvforma.contnum.
                pdvmoeda.clifor = contrato.clicod.
                pdvmoeda.titnum = string(contrato.contnum).
                pdvmoeda.moecod = pdvforma.modcod.
                pdvmoeda.modcod = pdvforma.modcod.

                pdvmoeda.valor = titulo.titvlcob.
                pdvmoeda.titdtven = titulo.titdtven.
        
        assign
            aoacparcela.contnum    = contrato.contnum.

        if aoacparcela.parcela = 0
        then do:
            assign
                aoacparcela.dtbaixa  = today
                aoacparcela.situacao = "B". 
            vseq = vseq + 1.    
            create pdvdoc.
            ASSIGN
                pdvdoc.etbcod            = epdvmov.etbcod
                pdvdoc.cmocod            = epdvmov.cmocod
                pdvdoc.DataMov           = epdvmov.DataMov
                pdvdoc.Sequencia         = epdvmov.Sequencia
                pdvdoc.ctmcod            = epdvmov.ctmcod
                pdvdoc.COO               = epdvmov.COO
                pdvdoc.seqreg            = vseq
                pdvdoc.CliFor            = titulo.CliFor
                pdvdoc.ContNum           = string(titulo.titnum)
                pdvdoc.titpar            = titulo.titpar
                pdvdoc.titdtven          = titulo.titdtven.
            ASSIGN
                pdvdoc.pago_parcial      = "N"
                pdvdoc.modcod            = titulo.modcod
                pdvdoc.Desconto_Tarifa   = 0
                pdvdoc.Valor_Encargo     = 0
                pdvdoc.hispaddesc        = "BAIXA ENTRADA ACORDO " + string(aoacordo.idacordo).
                pdvdoc.valor             = titulo.titvlcob. /*par-titvlpag.*/
                pdvdoc.titvlcob          = titulo.titvlcob.
                pdvdoc.valor_encargo    = 0.
            if pdvdoc.valor_encargo < 0
            then do: 
                pdvdoc.desconto = pdvdoc.valor_encargo * -1. 
                pdvdoc.valor_encargo = 0.
            end.
            pdvdoc.pstatus = yes.
            run /admcom/progr/fin/baixatitulo.p (recid(pdvdoc), recid(titulo)).
            aoacparcela.dtbaixa = today.
            
        end.
        else do: 
            titulo.titsit     = "LIB".
            aoacparcela.Situacao = "E".
            titulo.cobcod = 1.
            titulo.vlf_acrescimo  = contrato.vlf_acrescimo / contrato.nro_parcela.
            titulo.vlf_principal  = contrato.vlf_principal / vqtdParcelas.
        end.            
    end.


    vseqreg = 0.
        
    for each aoacorigem of aoacordo.
        find contrato of aoacorigem no-lock.
        find clien of contrato no-lock.
        
            find titulo where titulo.empcod = 19 and titulo.titnat = no and
               titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
               titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum) and
               titulo.titpar = aoacorigem.titpar
                no-lock.       
        if titulo.titsit = "LIB" then. else next.
        vseqreg = vseqreg + 1.    
            create pdvdoc.
            ASSIGN
            pdvdoc.etbcod            = pdvmov.etbcod
            pdvdoc.cmocod            = pdvmov.cmocod
            pdvdoc.DataMov           = pdvmov.DataMov
            pdvdoc.Sequencia         = pdvmov.Sequencia
            pdvdoc.ctmcod            = pdvmov.ctmcod
            pdvdoc.COO               = pdvmov.COO
            pdvdoc.seqreg            = vseqreg
            pdvdoc.CliFor            = titulo.CliFor
            pdvdoc.ContNum           = string(titulo.titnum)
            pdvdoc.titpar            = titulo.titpar
            pdvdoc.titdtven          = titulo.titdtven.
          ASSIGN
            pdvdoc.pago_parcial      = "N"
            pdvdoc.modcod            = titulo.modcod
            pdvdoc.Desconto_Tarifa   = 0
            pdvdoc.Valor_Encargo     = 0
            pdvdoc.hispaddesc        = "NEGOCIACAO - ACORDO ONLINE ID: " + string(pidacordo) + " - " + pformaPagamento.

            pdvdoc.titvlrcustas      = 0.
            
            pdvdoc.valor             = AoAcOrigem.vltot.
            pdvdoc.titvlcob          = AoAcOrigem.vlcob.
            
                vjuro = 0.
                run juro_titulo.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad,
                               titulo.titdtven,
                               titulo.titvlcob,
                               output vjuro).
            pdvdoc.valor_encargo    = vjuro.
            /* DISPENSA DE JUROS AGORA FICA EM pdvdoc.desconto */
            
            pdvdoc.desconto = vjuro - AoAcOrigem.vljur.
            if pdvdoc.desconto < 0 
            then pdvdoc.desconto = 0.
                            
            if titulo.titsit = "LIB" 
            then run /admcom/progr/fin/baixatitulo.p (recid(pdvdoc),
                                                      recid(titulo)).

            else pdvdoc.pstatus = YES.     
    end.
    
    if vseqreg > 0
    then precOK = prec.
    
