{admcab.i}

def input param pctmcod         as char.
def input param preccontrsite   as recid.
def input param pvalor          as dec.

def var prec as recid.
find first pdvtmov where pdvtmov.ctmcod = pctmcod no-lock.
 
find cmon where cmon.etbcod = setbcod and cmon.cxacod = 99 no-lock.
 
run fin/cmdinc.p (recid(cmon), recid(pdvtmov), output prec).

find pdvmov where recid(pdvmov) = prec no-lock.

find contrsite where recid(contrsite) = preccontrsite no-lock.
find contrato  where contrato.contnum = contrsite.contnum no-lock.

def var vseqreg as int.

def shared temp-table ttparcela
    field titpar    like titulo.titpar
    field titvltot  like titulo.titvltot
    field titvlpag  like titulo.titvlpag
    field titvlcob  like titulo.titvlcob
    field titvlprod as dec
    field titvlfrete as dec
    field titvlacres as dec
    field titvlbaixa as dec
    field titvlcredito as dec
    field novosaldo  as dec.
def shared temp-table ttcancela no-undo
    field prec as recid
    field operacao as char    
    field qtddevol as int
    field valordevol as dec.
def buffer bttcancela for ttcancela.    
    
def shared temp-table ttdevolve no-undo
    field prec as recid
    field qtddevol as int.


def buffer bcontrsitbai for contrsitbai. 
def var vsequencia as int.
vseqreg = 0.
for each ttparcela no-lock
    by ttparcela.titpar.
    
    find titulo where titulo.contnum = contrato.contnum and
                      titulo.titpar  = ttparcela.titpar.
    
        find last bcontrsitbai where 
                bcontrsitbai.codigoPedido = contrsite.codigoPedido and
                bcontrsitbai.contnum      = contrato.contnum  and
                bcontrsitbai.titpar       = titulo.titpar and
                bcontrsitbai.titdtpag     = pdvmov.DataMov
                no-error.
        vsequencia = if avail bcontrsitbai then bcontrsitbai.sequencia + 1 else 1.
                                                            
        create contrsitbai.
        contrsitbai.codigoPedido = contrsite.codigoPedido.
        contrsitbai.contnum      = contrato.contnum.
        contrsitbai.titpar       = titulo.titpar.
        contrsitbai.titdtpag     = pdvmov.DataMov.
        
        contrsitbai.Sequencia    = vsequencia.
        
        assign
        contrsitbai.titvlcredito = ttparcela.titvlcredito
        contrsitbai.titvlbaixa   = ttparcela.titvlbaixa
        contrsitbai.titvlprod    = ttparcela.titvlprod
        contrsitbai.titvlfrete   = ttparcela.titvlfrete
        contrsitbai.titvlacres   = ttparcela.titvlacres.

    if contrsitbai.titvlbaixa <= 0
    then next.
    
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
    pdvdoc.ContNum           = string(contrato.contnum)
    pdvdoc.titpar            = titulo.titpar
    pdvdoc.titdtven          = titulo.titdtven.

  ASSIGN
    pdvdoc.pago_parcial      = if titulo.titvlcob = contrsitbai.titvlbaixa then "N" else "S"
    pdvdoc.modcod            = titulo.modcod
    pdvdoc.Desconto_Tarifa   = 0
    pdvdoc.Valor_Encargo     = 0
    pdvdoc.hispaddesc        = "DEVOLUCAO PEDIDO ECOMMERCE " + string(contrsite.codigopedido).
    

    pdvdoc.Valor             = contrsitbai.titvlbaixa.
    pdvdoc.titvlcob          = contrsitbai.titvlbaixa.

    
    run fin/baixatitulo.p (recid(pdvdoc),
                           recid(titulo)).


end.


    for each ttdevolve.
        find contrsitmov where recid(contrsitmov) = ttdevolve.prec.
        contrsitmov.qtddevol = ttdevolve.qtddevol.
        delete ttdevolve.
    end.
    for each ttcancela. 
        find contrsitem where recid(contrsitem) = ttcancela.prec.
        contrsitem.qtddevol  = ttcancela.qtddevol. 
        delete ttcancela.
    end.



do on error undo.
    find current contrsite exclusive.
    contrsite.saldocredito = 0.
    for each contrsitbai of contrsite no-lock.
        contrsite.saldocredito = contrsite.saldocredito + contrsitbai.titvlcredito.
    end.
end.    
    
