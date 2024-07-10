{admcab.i}
def var prec as recid. 
def input param par-pdvdoc as recid.

def buffer opdvdoc for pdvdoc.

find opdvdoc where recid(opdvdoc) = par-pdvdoc no-lock.
find titulo where titulo.contnum = int(opdvdoc.contnum) and titulo.titpar = opdvdoc.titpar no-lock no-error.
if not avail titulo
then do:
    find contrato where contrato.contnum = int(opdvdoc.contnum) no-lock.
    
                find first titulo where
                        titulo.empcod = 19 and
                        titulo.titnat = no and
                        titulo.etbcod = contrato.etbcod and
                        titulo.clifor = contrato.clicod and
                        titulo.modcod = contrato.modcod and
                        titulo.titnum = string(contrato.contnum) and
                        titulo.titpar = opdvdoc.titpar and
                        titulo.titdtemi = contrato.dtinicial
                        no-lock no-error.
                        
            if not avail titulo
            then do:
                message "Problema para encontrar titulo " opdvdoc.contnum "/" opdvdoc.titpar.
                undo.
            end.
end.            

find first pdvtmov where pdvtmov.ctmcod = "EST" no-lock.
 
find cmon where cmon.etbcod = setbcod and cmon.cxacod = 99 no-lock.
 
run fin/cmdinc.p (recid(cmon), recid(pdvtmov), output prec).


find pdvmov where recid(pdvmov) = prec no-lock.


do on error undo:
    create pdvdoc.
  ASSIGN
    pdvdoc.etbcod            = pdvmov.etbcod
    pdvdoc.cmocod            = pdvmov.cmocod
    pdvdoc.DataMov           = pdvmov.DataMov
    pdvdoc.Sequencia         = pdvmov.Sequencia
    pdvdoc.ctmcod            = pdvmov.ctmcod
    pdvdoc.COO               = pdvmov.COO
    pdvdoc.seqreg            = opdvdoc.seqreg
    pdvdoc.tipo_venda        = opdvdoc.tipo_venda
    pdvdoc.CliFor            = opdvdoc.CliFor
    pdvdoc.ContNum           = opdvdoc.ContNum
    pdvdoc.titpar            = opdvdoc.titpar
    pdvdoc.titdtven          = opdvdoc.titdtven.

  ASSIGN
    pdvdoc.placod            = 0
    pdvdoc.pago_parcial      = opdvdoc.pago_parcial
    pdvdoc.modcod            = opdvdoc.modcod
    pdvdoc.Desconto_Tarifa   = opdvdoc.Desconto_Tarifa * -1
    pdvdoc.Valor_Encargo     = opdvdoc.Valor_Encargo   * -1
    pdvdoc.hispaddesc        = "ESTORNO".

    pdvdoc.Valor             = opdvdoc.valor * -1.
    pdvdoc.titvlcob          = opdvdoc.titvlcob * -1.
    pdvdoc.titvlrcustas       = opdvdoc.titvlrcustas * -1. /* IEPRO */
    pdvdoc.pstatus  = yes.
    pdvdoc.orig_loja         = opdvdoc.etbcod.
    pdvdoc.orig_data         = opdvdoc.datamov.
    pdvdoc.orig_nsu          = opdvdoc.sequencia.
    pdvdoc.orig_componente   = opdvdoc.cmocod.
    pdvdoc.orig_vencod       = opdvdoc.seqreg.
                                               
    run fin/baixatitulo.p (recid(pdvdoc),
                           recid(titulo)).


end.
