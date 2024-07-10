
def output param precOK as recid.
def input param pformaPagamento as char.
def input param pidAcordo    as int.

precOK = ?.

def var prec as recid.
def var vseqreg as int.
def var vjuro as dec.
    
find first pdvtmov where pdvtmov.ctmcod = "AOB" no-lock.

find cmon where cmon.etbcod = 999 and cmon.cxacod = 99 no-lock.
                    
run fin/cmdincdt.p (recid(cmon), 
                    recid(pdvtmov),  
                    today,
                    output prec).

find pdvmov where recid(pdvmov) = prec no-lock.

find aoacordo where aoacordo.idacordo = pidAcordo exclusive.
                            
do on error undo:                           
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
            pdvdoc.hispaddesc        = "PAGAMENTO NEGOCIACAO - ACORDO ONLINE ID: " + string(pidacordo) + " - " + pformaPagamento.

            pdvdoc.titvlrcustas      = 0.
            
            pdvdoc.valor             = AoAcOrigem.vltot.
            pdvdoc.titvlcob          = AoAcOrigem.vlcob.
            
                /* helio 11012022 - IEPRO */
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
    find first aoacparcela of aoacordo where aoacparcela.parcela = 0.
    aoacparcela.dtbaixa = today.
    
    if vseqreg > 0
    then precOK = prec.
    
end.