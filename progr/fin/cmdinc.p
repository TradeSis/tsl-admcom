{cabec.i}


def input  parameter par-CMon-Recid         as   recid.
def input  parameter par-pdvtmov-recid       as   recid.
def output parameter Sai-pdvmov-Recid      as   recid.

def buffer bpdvmov     for pdvmov.

find CMon      where recid(CMon)      = par-CMon-Recid   no-lock.
find pdvtmov    where recid(pdvtmov)    = par-pdvtmov-Recid no-lock.

    form cmon.etbcod    label "Etb" format ">>9"
         CMon.cxacod    label "CAIXA"
         CMon.cxanom             no-label
         func.funape              no-label format "x(15)"
         CMon.cxadt         colon 65 format "99/99/9999" label "Data"
         with frame f-eCMon row 3 width 81 three-d
                         side-labels no-box.
if pdvtmov.ctmcod <> "EST" and pdvtmov.ctmcod <> "ENO" and pdvtmov.ctmcod <> "BOL" and
    pdvtmov.ctmcod <> "CSE" and pdvtmov.ctmcod <> "REP" and pdvtmov.ctmcod <> "CER" and 
    pdvtmov.ctmcod <> "GOL" and pdvtmov.ctmcod <> "ECP" and pdvtmov.ctmcod <> "EDP" 
then do:
    disp today @ cmon.cxadt  with frame f-ecmon.    
    prompt-for cmon.cxadt with frame f-ecmon.
end.
    
do transaction.

find last bpdvmov where 
            bpdvmov.etbcod = cmon.etbcod and
            bpdvmov.cmocod = cmon.cmocod and
            bpdvmov.datamov = if input frame f-ecmon cmon.cxadt = ?
                             then today
                             else input frame f-ecmon cmon.cxadt
                        no-lock no-error.

create pdvmov.
  ASSIGN
    pdvmov.etbcod          = cmon.etbcod.
    pdvmov.cmocod          = cmon.cmocod.
    pdvmov.DataMov         = if input frame f-ecmon cmon.cxadt = ?
                             then today
                             else input frame f-ecmon cmon.cxadt.
    pdvmov.Sequencia       = if avail bpdvmov
                             then bpdvmov.sequencia + 1
                             else 1.
    pdvmov.ctmcod          = pdvtmov.ctmcod.
    pdvmov.COO             = pdvmov.Sequencia.
    pdvmov.ValorTot        = 0.
    pdvmov.ValorTroco      = 0.
    pdvmov.codigo_operador = string(sfuncod).
    pdvmov.HoraMov         = time.
    pdvmov.statusoper      = "".
    pdvmov.entsai          = pdvtmov.operacao.
    pdvmov.DtIncl          = today.
    pdvmov.HrIncl          = time.

  
assign
    sai-pdvmov-recid = recid(pdvmov).
end.

