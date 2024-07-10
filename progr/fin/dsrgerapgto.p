
def input param precdesenr53 as recid.
def input param ptitvlcob    as dec.
def input param pjuros       as dec.
def input param pdata        as date.
def output param precok as recid.
precok = ?.

def var prec as recid.
def buffer bcontrato for contrato.

def var vseqreg as int.
def var vjuro as dec.
    find desenr53 where recid(desenr53) = precdesenr53 no-lock no-error. 
    if not avail desenr53 then return.
    
        find first pdvtmov where pdvtmov.ctmcod = "DRL" no-lock.

        find cmon where cmon.etbcod = 999 and cmon.cxacod = 99 no-lock.
                    
        run fin/cmdincdt.p (recid(cmon), 
                                recid(pdvtmov),  
                                /* Helio 14112023 - Data da baixa de contratos Desenrola -  Ser HOJE() */
                                pdata, /**if desenr53.dataMovimento = ? then today else desenr53.dataMovimento,**/
                                output prec).

        find pdvmov where recid(pdvmov) = prec no-lock.

                            
do on error undo:                           
    find desenr53 where recid(desenr53) = precdesenr53 exclusive no-wait no-error. 
    if avail desenr53
    then do:
        find bcontrato where bcontrato.contnum = desenr53.contnum no-lock.            
        find clien of bcontrato no-lock.
        
        vseqreg = 0.
        /* Helio 14112023 Baixa de contrato Desenrola - Baixa total **/
        /* Alterado para ler todos os titulso em aberto do cliente **/
        for each titulo use-index iclicod where titulo.empcod = 19 and titulo.titnat = no and                               
                                titulo.clifor = bcontrato.clicod and 
                                titulo.titsit = "LIB" 
                no-lock.
            find contrato where contrato.contnum = int(titulo.titnum) no-lock.
       /*                                             
       * for each desenr51tit where desenr51tit.clicod = bcontrato.clicod no-lock.
       *     find contrato where contrato.contnum = desenr51tit.contnum no-lock.
       *     find titulo where titulo.empcod = 19 and titulo.titnat = no and 
       *         titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
       *         titulo.clifor = contrato.clicod and
       *         titulo.titnum = string(contrato.contnum) and titulo.titpar = desenr51tit.titpar
       *         no-lock.
       *     if titulo.titsit = "LIB" then. else next.
       */     
            
            
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
            pdvdoc.Desconto_Tarifa   = 0.
            
            pdvdoc.Valor_Encargo     = (titulo.titvlcob / ptitvlcob) * pjuros.  /* quando pdvdoc.valor_encargo eh negativo, é desconto */
            
            pdvdoc.hispaddesc        = "BAIXA DESENROLA id=" + desenr53.idAgrupamentoB3.
            
            pdvdoc.valor             = titulo.titvlcob + pdvdoc.Valor_Encargo.
            pdvdoc.titvlcob          = titulo.titvlcob. /* desenr51tit */
            
            pdvdoc.desconto = 0.        /* campo pdvdoc.desaconto eh dispénsa de juros */
                            
            if titulo.titsit = "LIB" 
            then run /admcom/progr/fin/baixatitulo.p (recid(pdvdoc),
                                                      recid(titulo)).

            else pdvdoc.pstatus = YES.     
            precok = prec.
        end.
    end.
    
end.