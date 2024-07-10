/* 09022023 helio ID 155965 */
def input  param pcontnum  like contrato.contnum. 
def input  param vcobout  like cobra.cobcod.
def input  param poperacao as char.
def input  param pstatus   as char.
def output param psicred as recid.

find contrato where contrato.contnum = pcontnum no-lock.

find cobra where cobra.cobcod = vcobout no-lock.

if cobra.sicred
then DO on error undo:
    
    poperacao = if contrato.tpcontrato = "N" or contrato.modcod = "CPN"
                                then "NOVACAO"
                                else "CONTRATO".
   
   
    pstatus = "VALIDAR".
    
  find first sicred_contrato where sicred_contrato.operacao = poperacao and
                                   sicred_contrato.contnum  = contrato.contnum and
                                   sicred_contrato.dtinc    = today and
                                   sicred_contrato.sstatus  = pstatus
                                     no-lock no-error.
    if avail sicred_contrato
    then next.

  create sicred_contrato.
  psicred = recid(sicred_contrato).  
  ASSIGN
    sicred_contrato.operacao  = poperacao
    sicred_contrato.dtinc     = today
    sicred_contrato.hrinc     = 1 /*time */
    sicred_contrato.contnum   = contrato.contnum
    sicred_contrato.sstatus   = pstatus
    sicred_contrato.cobcod    = cobra.cobcod
    sicred_contrato.lotnum    = ?.
        assign
        sicred_contrato.cmocod    = ?
        sicred_contrato.ctmcod    = "ENV"
        sicred_contrato.DataMov   = today
        sicred_contrato.etbcod    = contrato.etbcod
        sicred_contrato.Sequencia = ?
        sicred_contrato.seqforma  = ?.
END.

