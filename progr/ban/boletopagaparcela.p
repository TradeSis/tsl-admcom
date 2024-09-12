def input parameter par-pdvmov      as recid.
def input parameter par-boletagbol  as recid.
def input parameter par-titdtpag    as date.
def input parameter par-titvlpag    as dec.
def input parameter par-titjuro     as dec.  
def output param    par-ok as log.
def var vqtdparcelas as int.
def var vtitvlpag as dec decimals 2.
def var vseqreg as int.

par-ok = no.
find boletagbol where recid(boletagbol) = par-boletagbol no-lock no-error.
if not avail boletagbol then return.

find pdvmov where recid(pdvmov) = par-pdvmov no-lock.
vqtdparcelas = 0.
for each boletagparcela of boletagbol no-lock.
    vqtdparcelas = vqtdparcelas + 1.
end.
vtitvlpag = dec(par-titvlpag / vqtdparcelas).

for each boletagparcela of boletagbol no-lock.
    find contrato where contrato.contnum = boletagparcela.contnum
         no-lock no-error.    
    if avail contrato
    then do:  
        find first  titulo where   
                titulo.empcod = 19 and 
                titulo.titnat = no and 
                titulo.modcod = contrato.modcod and 
                titulo.etbcod = contrato.etbcod and 
                titulo.clifor = contrato.clicod and 
                titulo.titnum = string(contrato.contnum) and 
                titulo.titpar = boletagparcela.titpar
                exclusive no-error.
        if avail titulo
        then do:
            if titulo.titsit = "LIB" or titulo.titsit = "PAG"
            then do:
               par-ok = yes.
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
                pdvdoc.hispaddesc        = "BAIXA DE BOLETO " + string(boletagbol.bancod,"999") + "/" + string(boletagbol.nossonumero). 
                
                pdvdoc.valor = if vtitvlpag < titulo.titvlcob
                               then titulo.titvlcob
                               else vtitvlpag.
                pdvdoc.titvlcob          = titulo.titvlcob.
                pdvdoc.valor_encargo    = pdvdoc.valor - titulo.titvlcob.
                if pdvdoc.valor_encargo < 0
                then do:
                    pdvdoc.desconto = pdvdoc.valor_encargo * -1.
                    pdvdoc.valor_encargo = 0.
                end.
        
                if titulo.titsit = "LIB" /* #H1 */
                then run /admcom/progr/fin/baixatitulo.p (recid(pdvdoc),
                                                          recid(titulo)).

                else pdvdoc.pstatus = YES.     
                    
            end.
        end.      
    end.

end.


do on error undo:
    find current boletagbol exclusive no-wait no-error.
    if avail boletagbol
    then do:
        boletagbol.dtpagamento = par-titdtpag.
        boletagbol.situacao    = "P". /* PAGO */
    end.
end.
