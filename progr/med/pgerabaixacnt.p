
def input param precmedadesao as recid.
def var prec as recid.
def var vseqreg as int.
def var vjuro as dec.
    find medadesao where recid(medadesao) = precmedadesao no-lock no-error. 
    if not avail medadesao then return.
    
        find first pdvtmov where pdvtmov.ctmcod = "BD2" no-lock.

        find cmon where cmon.etbcod = 999 and cmon.cxacod = 99 no-lock.
                    
        run fin/cmdincdt.p (recid(cmon), 
                                recid(pdvtmov),  
                                if medadesao.dtcanc = ? then today else medadesao.dtcanc,
                                output prec).

        find pdvmov where recid(pdvmov) = prec no-lock.

                            
do on error undo:                           
    find medadesao where recid(medadesao) = precmedadesao exclusive no-wait no-error. 
    if avail medadesao
    then do:
        find contrato of medadesao no-lock no-error.
        find clien of contrato no-lock.
        
        vseqreg = 0.
        for each titulo where titulo.empcod = 19 and titulo.titnat = no and
                    titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
                    titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum) 
                no-lock.       
            if titulo.titsit = "LIB" then. else next.
            
            /* helio 14042023 Qualitor ID 21258 - Cancelamento de contratos Chama Doutor.*/
            /*   nao cancela mais vencidos */
            if titulo.titdtven < medadesao.dtcanc
            then next.  
             
            /**/ 
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
            pdvdoc.hispaddesc        = "BAIXA POR CANCELAMENTO DA ADESAO".

            pdvdoc.valor             = titulo.titvlcob.
            pdvdoc.titvlcob          = titulo.titvlcob.
            
            pdvdoc.valor_encargo    = 0.
            pdvdoc.desconto = 0.
                            
            if titulo.titsit = "LIB" 
            then run /admcom/progr/fin/baixatitulo.p (recid(pdvdoc),
                                                      recid(titulo)).

            else pdvdoc.pstatus = YES.     
        end.
    end.
    
end.