/*{cabec.i}*/


def input  parameter par-CMon-Recid         as   recid.
def input  parameter par-pdvtmov-recid       as   recid.
def input  param     par-datamov             as date.
def output parameter Sai-pdvmov-Recid      as   recid.

def buffer bpdvmov     for pdvmov.

find CMon      where recid(CMon)      = par-CMon-Recid   no-lock.
find pdvtmov    where recid(pdvtmov)    = par-pdvtmov-Recid no-lock.

do transaction.

find last bpdvmov where 
            bpdvmov.etbcod = cmon.etbcod and
            bpdvmov.cmocod = cmon.cmocod and
            bpdvmov.datamov = par-datamov 
                        no-lock no-error.

create pdvmov.
  ASSIGN
    pdvmov.etbcod          = cmon.etbcod.
    pdvmov.cmocod          = cmon.cmocod.
    pdvmov.DataMov         = par-datamov.
    pdvmov.Sequencia       = if avail bpdvmov
                             then bpdvmov.sequencia + 1
                             else 1.
    pdvmov.ctmcod          = pdvtmov.ctmcod.
    pdvmov.COO             = pdvmov.Sequencia.
    pdvmov.ValorTot        = 0.
    pdvmov.ValorTroco      = 0.
/*    pdvmov.codigo_operador = string(sfuncod).*/
    pdvmov.HoraMov         = time.
    pdvmov.statusoper      = "".
    pdvmov.entsai          = pdvtmov.operacao.
    pdvmov.DtIncl          = today.
    pdvmov.HrIncl          = time.

  
assign
    sai-pdvmov-recid = recid(pdvmov).
end.

