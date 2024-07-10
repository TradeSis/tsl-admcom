{admcab.i}
def var prec as recid. 
def var vseqreg as int.

def input param par-pdvmov as recid.

def buffer opdvmov for pdvmov.
def buffer opdvdoc for pdvdoc.

def shared temp-table ttpdvmov no-undo
    field rec    as recid
    field tipo      as char
    field contnum   like contrato.contnum format ">>>>>>>>>>9"
    field valor     like contrato.vltotal
    field primeiro  as log
    field saldoabe  like titulo.titvlcob  
        index idx is unique primary rec asc tipo desc contnum asc.



find first pdvtmov where pdvtmov.ctmcod = "ENO" no-lock.
 
find cmon where cmon.etbcod = setbcod and cmon.cxacod = 99 no-lock.
 
run fin/cmdinc.p (recid(cmon), recid(pdvtmov), output prec).

find pdvmov where recid(pdvmov) = prec no-lock.

vseqreg = 0.

for each ttpdvmov where ttpdvmov.rec = par-pdvmov and ttpdvmov.tipo = "ORIGINAL" no-lock.

    find opdvmov where recid(opdvmov) = par-pdvmov no-lock.
    
    for each opdvdoc of opdvmov 
            where opdvdoc.contnum = string(ttpdvmov.contnum)
            no-lock.

        find contrato where contrato.contnum = int(opdvdoc.contnum) no-lock.

        find titulo where titulo.contnum = int(opdvdoc.contnum) and titulo.titpar = opdvdoc.titpar no-lock no-error.
        if avail titulo
        then do: 
            do on error undo:  
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
                    pdvdoc.ContNum           = string(titulo.ContNum)
                    pdvdoc.titpar            = titulo.titpar.
                    pdvdoc.titdtven          = titulo.titdtven.
                
                  ASSIGN
                    pdvdoc.placod            = 0
                    pdvdoc.pago_parcial      = opdvdoc.pago_parcial
                    pdvdoc.modcod            = titulo.modcod
                    pdvdoc.Desconto_Tarifa   = opdvdoc.Desconto_Tarifa * -1
                    pdvdoc.Valor_Encargo     = opdvdoc.Valor_Encargo   * -1
                    pdvdoc.hispaddesc        = "ESTORNO".

                    pdvdoc.Valor             = opdvdoc.valor * -1.
                    pdvdoc.titvlcob          = opdvdoc.titvlcob * -1.
                
                    pdvdoc.pstatus  = yes.
                    pdvdoc.orig_loja         = opdvdoc.etbcod.
                    pdvdoc.orig_data         = opdvdoc.datamov.
                    pdvdoc.orig_nsu          = opdvdoc.sequencia.
                    pdvdoc.orig_componente   = opdvdoc.cmocod.
                    pdvdoc.orig_vencod       = opdvdoc.seqreg.
                                               
                run fin/baixatitulo.p (recid(pdvdoc),
                                       recid(titulo)).
                                       
            end.
        
        end.
    end.
end.
for each ttpdvmov where ttpdvmov.rec = par-pdvmov and ttpdvmov.tipo = "NOVO" no-lock.

    find opdvmov where recid(opdvmov) = par-pdvmov no-lock.
    
    find contrato where contrato.contnum = ttpdvmov.contnum no-lock.
    
    for each titulo where titulo.contnum = contrato.contnum no-lock.
        if titulo.titpar = 0
        then next.
        if titulo.titsit <> "LIB"
        then next.  
        
            do on error undo:  
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
                    pdvdoc.ContNum           = string(titulo.ContNum)
                    pdvdoc.titpar            = titulo.titpar.
                    pdvdoc.titdtven          = titulo.titdtven.
                
                  ASSIGN
                    pdvdoc.placod            = 0
                    pdvdoc.pago_parcial      = "N"
                    pdvdoc.modcod            = titulo.modcod
                    pdvdoc.Desconto_Tarifa   = 0
                    pdvdoc.Valor_Encargo     = 0
                    pdvdoc.hispaddesc        = "ESTORNO NOVACAO".

                    pdvdoc.Valor             = titulo.titvlcob.
                    pdvdoc.titvlcob          = titulo.titvlcob.
                
                    pdvdoc.pstatus  = yes.
                    pdvdoc.orig_loja         = opdvmov.etbcod.
                    pdvdoc.orig_data         = opdvmov.datamov.
                    pdvdoc.orig_nsu          = opdvmov.sequencia.
                    pdvdoc.orig_componente   = opdvmov.cmocod.
                                               
                run fin/baixatitulo.p (recid(pdvdoc),
                                       recid(titulo)).
                                       
            end.
    
    end.

end.
                                                
