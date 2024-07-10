{admcab.i}

def input parameter p-recid-titulo as recid.
def output parameter p-recid-pdvdoc as recid.
p-recid-pdvdoc = ?.

find titulo where recid(titulo) = p-recid-titulo no-lock.
find contrato where contrato.contnum = int(titulo.titnum) no-lock.

def buffer bpdvmov for pdvmov.

if titulo.etbcobra <> ? and titulo.etbcobra > 0 and
   titulo.titdtpag <> ? and
   titulo.titdtpag > 07/01/20
then do:
    
    find first pdvtmov where pdvtmov.ctmcod = "REC" no-lock.
    find cmon where cmon.etbcod = setbcod and cmon.cxacod = 99 no-lock.
    find last bpdvmov where
              bpdvmov.etbcod = cmon.etbcod and
              bpdvmov.cmocod = cmon.cmocod and
              bpdvmov.datamov = titulo.titdtpag
              no-lock no-error.

    do on error undo:
        create pdvmov.
        ASSIGN
            pdvmov.etbcod          = cmon.etbcod
            pdvmov.cmocod          = cmon.cmocod
            pdvmov.DataMov         = titulo.titdtpag
            pdvmov.Sequencia       = if avail bpdvmov
                                     then bpdvmov.sequencia + 1 else 1
            pdvmov.ctmcod          = pdvtmov.ctmcod
            pdvmov.COO             = pdvmov.Sequencia
            pdvmov.ValorTot        = 0
            pdvmov.ValorTroco      = 0
            pdvmov.HoraMov         = time
            pdvmov.statusoper      = ""
            pdvmov.entsai          = pdvtmov.operacao
            pdvmov.DtIncl          = today
            pdvmov.HrIncl          = time.
    end.
    find current pdvmov no-lock.
        
    do on error undo:
        create pdvdoc.
        ASSIGN
            pdvdoc.etbcod            = pdvmov.etbcod
            pdvdoc.cmocod            = pdvmov.cmocod
            pdvdoc.DataMov           = pdvmov.DataMov
            pdvdoc.Sequencia         = pdvmov.Sequencia
            pdvdoc.ctmcod            = pdvmov.ctmcod
            pdvdoc.COO               = pdvmov.COO
            pdvdoc.seqreg            = 1
            pdvdoc.tipo_venda        = 0
            pdvdoc.CliFor            = titulo.CliFor
            pdvdoc.ContNum           = titulo.titnum
            pdvdoc.titpar            = titulo.titpar
            pdvdoc.titdtven          = titulo.titdtven.
                        
         ASSIGN
            pdvdoc.placod            = 0
            pdvdoc.pago_parcial      = ""
            pdvdoc.modcod            = titulo.modcod
            pdvdoc.Desconto_Tarifa   = 0
            pdvdoc.Valor_Encargo     = 0
            pdvdoc.hispaddesc        = "ESTORNO"
            pdvdoc.Valor             = titulo.titvlpag
            pdvdoc.titvlcob          = titulo.titvlcob
            pdvdoc.pstatus  = yes.
                        
    end.
    find current pdvdoc no-error.
    p-recid-pdvdoc = recid(pdvdoc).
end.
                                    
