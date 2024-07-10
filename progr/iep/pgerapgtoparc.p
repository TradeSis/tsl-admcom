
def input param prectitprotesto as recid.
def var prec as recid.
def var vseqreg as int.
def var vjuro as dec.
    find titprotesto where recid(titprotesto) = prectitprotesto no-lock no-error. 
    if not avail titprotesto then return.
    
        find first pdvtmov where pdvtmov.ctmcod = "IEP" no-lock.

        find cmon where cmon.etbcod = 999 and cmon.cxacod = 99 no-lock.
                    
        run fin/cmdincdt.p (recid(cmon), 
                                recid(pdvtmov),  
                                if titprotesto.dtbaixa = ? then today else titprotesto.dtbaixa,
                                output prec).

        find pdvmov where recid(pdvmov) = prec no-lock.

                            
do on error undo:                           
    find titprotesto where recid(titprotesto) = prectitprotesto exclusive no-wait no-error. 
    if avail titprotesto
    then do:
        find contrato of titprotesto no-lock no-error.
        find clien of contrato no-lock.
        
        vseqreg = 0.
        for each titprotparc of titprotesto no-lock.
            find titulo where titulo.empcod = 19 and titulo.titnat = no and
                    titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
                    titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum) and
                    titulo.titpar = titprotparc.titpar
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
            pdvdoc.hispaddesc        = "BAIXA EM CARTORIO IEPRO ".

            pdvdoc.titvlrcustas      = if titprotesto.pagacustas
                                       then titprotparc.titvlrcustas
                                       else 0.
            
            pdvdoc.valor             = titprotparc.titvlcob + pdvdoc.titvlrcustas +  titprotparc.titvljur. 
            pdvdoc.titvlcob          = titprotparc.titvlcob.
            
                /* helio 11012022 - IEPRO */
                vjuro = 0.
                run juro_titulo.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad,
                               titulo.titdtven,
                               titprotparc.titvlcob,
                               output vjuro).
            pdvdoc.valor_encargo    = vjuro.
            /* DISPENSA DE JUROS AGORA FICA EM pdvdoc.desconto */
            
            pdvdoc.desconto = vjuro - titprotparc.titvljur.
            if pdvdoc.desconto < 0 
            then pdvdoc.desconto = 0.
                            
            if titulo.titsit = "LIB" 
            then run /admcom/progr/fin/baixatitulo.p (recid(pdvdoc),
                                                      recid(titulo)).

            else pdvdoc.pstatus = YES.     
        end.
    end.
    
end.