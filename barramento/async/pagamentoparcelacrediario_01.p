/* #10082022 helio - problema das baixas parciais continuava - formula estava ainda errada */
/* helio 28022022 - iepro - ajuste relatorio divergencia de juros */

DEFINE INPUT  PARAMETER lcJsonEntrada      AS LONGCHAR.
def    output param     verro as char no-undo.
verro = "".
def var vecommerce as log init no.
def var tiposervico as char.
DEFINE var lcJsonsaida      AS LONGCHAR.
def var vtpseguro as int.

def var vctmcod  like pdvmov.ctmcod.
def var vmodcod     like contrato.modcod.
def var vdatamov as date. /* 01.12.2017 */
def var vnsu     as int.
def var vseqreg as int.

def var vmovseq as int.

def var vcodigo_forma  as char. 
def var vtitpar as int.

def var vultima as dec.
def var vtotal as dec.
def var vtotalsemjuros as dec.
def var vtitvlcobsemjuros as dec.
def var vtitvlcob as dec.
def var vi as int.
def var vmes as int.
def var vano as int.
def var vdia as int.
def var vvenc as date.
def var vseqforma as int.
def var vseqfp as int.

def var vvalor_vista as dec.
def var vvalor_contrato as dec.

{/admcom/barramento/functions.i}
{/admcom/barramento/async/pagamentoparcelacrediario_01.i}

/* LE ENTRADA */
lokJSON = hpagamentoParcelaCrediarioEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").


/**def var vsaida as char.
**find first ttpagamentoParcelaCrediario.
vsaida = "./json/pagamento/"  
                           + trim(ttpagamentoparcelacrediario.codigoLoja)  + "_"
                           + trim(ttpagamentoparcelacrediario.dataTransacao) + "_"
                           + trim(ttpagamentoparcelacrediario.numeroComponente) + "_"
                           + trim(ttpagamentoparcelacrediario.nsuTransacao) + "_"
                           + "pagamento.json".
*hpagamentoparcelacrediarioEntrada:WRITE-JSON("FILE",vsaida, true).
**/


/*


*/

for each ttpagamentoParcelaCrediario.
    
    for each ttparcelaspagas where ttparcelaspagas.idpai = ttpagamentoparcelacrediario.id.
                /*
                     field cpfCnpjCliente as char
        field codigoCliente as char
        field numeroContrato as char
        field modalidadeContrato as char
        field carteiraContrato as char
        field seqParcela as char
        field dataVencimentoParcela as char
        field dataPagamentoParcela as char
        field valorParcela as char
        field valorEncargoAtraso as char
        field valorDispensaJuros as char
        field valorPago as char
            */
        if ttparcelaspagas.modalidadeContrato = "CHQ" /* cheque */
        then do: 
            find first cheque use-index clien 
                    where cheque.clicod = int(ttparcelaspagas.codigoCliente) and
                          cheque.chenum = int(ttparcelaspagas.numeroContrato)
                          no-lock no-error.
            if not avail cheque                          
            then do:
                verro = "CHEQUE " + ttparcelaspagas.numeroContrato + " Nao existe no cadastro de cheque".
                leave.
            end.                                            
                                
        end.
        else do:
            find contrato where contrato.contnum = int(ttparcelaspagas.numeroContrato) no-lock no-error.
            if not avail contrato
            then do:
                verro = "Contrato " + ttparcelaspagas.numeroContrato + " Nao existe no TS Crediario".
                leave.
            end.
            else do:
                find titulo where titulo.empcod = 19 and
                                  titulo.titnat = no and  
                                  titulo.modcod = contrato.modcod and
                                  titulo.etbcod = contrato.etbcod and
                                  titulo.clifor = contrato.clicod and
                                  titulo.titnum = string(contrato.contnum) and
                                  titulo.titpar = 
                                    int(ttparcelaspagas.seqParcela) and
                                  titulo.titdtemi = contrato.dtinicial
                                  no-lock no-error.
                if not avail titulo
                then find first titulo where titulo.empcod = 19 and
                                  titulo.titnat = no and  
                                  titulo.modcod = contrato.modcod and
                                  titulo.etbcod = contrato.etbcod and
                                  titulo.clifor = contrato.clicod and
                                  titulo.titnum = string(contrato.contnum) and
                                  titulo.titpar = 
                                    int(ttparcelaspagas.seqParcela) 
                                  no-lock no-error.

                if not avail titulo
                then do:
                    verro = "Parcela " + string(contrato.contnum) + "/" + ttparcelaspagas.seqParcela + " Nao existe no TS Crediario".
                    leave.
                end.
            end.
        end.
    end.
end.    
if verro <> "" then return.
for each ttpagamentoParcelaCrediario.

        /*
        */
        
    vctmcod  = "P7".
                   
    vdatamov = aaaa-mm-dd_todate(ttpagamentoparcelacrediario.dataTransacao).
    vnsu     = int(ttpagamentoparcelacrediario.nsuTransacao).

    find cmon where
            cmon.etbcod = int(ttpagamentoparcelacrediario.codigoLoja) and
            cmon.cxacod = int(ttpagamentoparcelacrediario.numeroComponente)
            no-lock  no-error.
    if not avail cmon 
    then do on error undo: 
        create cmon. 
        assign 
            cmon.cmtcod = "PDV" 
            cmon.etbcod = int(ttpagamentoparcelacrediario.codigoLoja)
            cmon.cxacod = int(ttpagamentoparcelacrediario.numeroComponente)
            cmon.cmocod = int(string(cmon.etbcod) + string(cmon.cxacod,"999")) 
            cmon.cxanom = "Lj " + string(cmon.etbcod) + " " + 
                          "Cx " + string(cmon.cxacod). 
    end.

    do on error undo:
    find first pdvmov where
        pdvmov.etbcod = cmon.etbcod and
        pdvmov.cmocod = cmon.cmocod and
        pdvmov.datamov = vdatamov and
        pdvmov.sequencia = vnsu and
        pdvmov.ctmcod = vctmcod and
        pdvmov.coo    = int(vnsu)
        no-error.
    if not avail pdvmov
    then do:            
        create pdvmov.
        pdvmov.etbcod = cmon.etbcod.
        pdvmov.cmocod = cmon.cmocod.
        pdvmov.datamov = vdatamov.
        pdvmov.sequencia = vnsu.
        pdvmov.ctmcod = vctmcod.
        pdvmov.coo    = int(vnsu).
    end.        
    else do:
        verro = "JA INCLUIDO".
        return.
    end.    

    message pdvmov.etbcod cmon.cxacod pdvmov.datamov "NSU" pdvmov.sequencia "numeroCupom" pdvmov.coo pdvmov.ctmcod.

    pdvmov.valortot   = dec(valorTotalRecebido).
    pdvmov.valortroco = dec(valortroco).

    pdvmov.codigo_operador =  codigoOperador.
        
    pdvmov.HoraMov    = hora_totime(horaTransacao).
    pdvmov.EntSai     = yes.
    pdvmov.statusoper = "".
/*    pdvmov.tipo_pedido = int(ora-coluna("tipo_pedido")).  */

    end.
    
    vseqreg = 0.
    for each ttparcelaspagas where ttparcelaspagas.idpai = ttpagamentoparcelacrediario.id.
                /* 
        field carteiraContrato as char
         field dataPagamentoParcela as char
            */
    
        vseqreg = vseqreg + 1.
        
        find first pdvdoc of pdvmov where pdvdoc.seqreg = vseqreg no-error.
        if not avail pdvdoc
        then do:
            create pdvdoc.
            assign 
                pdvdoc.etbcod    = pdvmov.etbcod
                pdvdoc.DataMov   = pdvmov.DataMov
                pdvdoc.cmocod    = pdvmov.cmocod
                pdvdoc.COO       = pdvmov.COO
                pdvdoc.Sequencia = pdvmov.Sequencia
                pdvdoc.ctmcod    = pdvmov.ctmcod
                pdvdoc.seqreg    = vseqreg
                /*pdvdoc.titcod    = ?*/ .
        end.  
        
        pdvdoc.clifor = dec(codigoCliente) no-error.
        if pdvdoc.clifor = ? or
           pdvdoc.clifor = 0
        then pdvdoc.clifor = 1.

       pdvdoc.contnum  = trim(ttparcelaspagas.numeroContrato).
       pdvdoc.titpar   = int(seqParcela).
       pdvdoc.titdtven = aaaa-mm-dd_todate(dataVencimentoParcela).
       pdvdoc.modcod   = modalidadeContrato.

       if ttparcelaspagas.modalidadeContrato = "CHQ" /* cheque */
       then do on error undo: 
            find first cheque use-index clien 
                    where cheque.clicod = int(ttparcelaspagas.codigoCliente) and
                          cheque.chenum = int(ttparcelaspagas.numeroContrato)
                          exclusive no-wait no-error.
            if avail cheque                          
            then do:
                    pdvdoc.valor = dec(valorPago). 
                    cheque.chejur = pdvdoc.Valor_Encargo .
                    cheque.chepag = pdvdoc.datamov .
                    cheque.chesit = "PAG". 
            end.
            next.
            
       end.
       else do:
           find titulo where titulo.contnum = int(pdvdoc.contnum) and
                         titulo.titpar   = pdvdoc.titpar
                         no-lock no-error.
            if not avail titulo
            then do:                           
                find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock no-error.
                if avail contrato
                then do: 
                    find titulo where
                            titulo.empcod = 19 and
                            titulo.titnat = no and
                            titulo.modcod = contrato.modcod and
                            titulo.etbcod = contrato.etbcod and
                            titulo.clifor = contrato.clicod and
                            titulo.titnum = pdvdoc.contnum and
                            titulo.titpar = pdvdoc.titpar and
                            titulo.titdtemi = contrato.dtinicial
                        no-lock no-error.
                    if not avail titulo
                    then find titulo where
                            titulo.empcod = 19 and
                            titulo.titnat = no and
                            titulo.modcod = contrato.modcod and
                            titulo.etbcod = contrato.etbcod and
                            titulo.clifor = contrato.clicod and
                            titulo.titnum = pdvdoc.contnum and
                            titulo.titpar = pdvdoc.titpar 
                        no-lock no-error.
    
                    if not avail titulo
                    then do:
                        verro = 
                               " SEQ=" + string(vseqreg) +
                               " Titulo nao encontrado:" +
                               " Clien=" + string(pdvdoc.clifor) +
                               " Titulo=" + pdvdoc.contnum +
                               "     Vecto=" + string(pdvdoc.titdtven) +
                               " Valor=" + string(pdvdoc.titvlcob) +
                               " Modal=" + vmodcod.
                        next.       
                    end.
                    else do:
                        find current titulo exclusive.
                        titulo.contnum = int(pdvdoc.contnum).
                    end.
                end.         
            end.
       end.

       pdvdoc.pago_parcial =  string(true_tolog(pagtoParcial),"S/N").

       /* 
       * helio 02032022 iepro - retirado --- 
       *pdvdoc.desconto_tarifa = 0. 
       *pdvdoc.valor_encargo   = dec(valorEncargoAtraso) - dec(valorDispensaJuros). 
       *if pdvdoc.pago_parcial = "N" and avail titulo
       *then do:
       *     if pdvdoc.valor < titulo.titvlcob
       *     then do:
       *         pdvdoc.valor_encargo = 0.
       *         pdvdoc.desconto_tarifa = titulo.titvlcob - pdvdoc.valor. /* NAO EH PARCIAL, E PAGOU A MENOR, DA DESCONTO */
       *     end.
       *end.     
       *pdvdoc.titvlcob = pdvdoc.valor - pdvdoc.valor_encargo + pdvdoc.desconto_tarifa.
       *if pdvdoc.pago_parcial = "S"
       *then do:
       *     pdvdoc.valor_encargo = 0.
       *     pdvdoc.titvlcob      = pdvdoc.valor.    
       *     
       *     if pdvdoc.titvlcob > titulo.titvlcob
       *     then do:
       *         pdvdoc.valor_encargo = pdvdoc.titvlcob - titulo.titvlcob.
       *         pdvdoc.titvlcob = titulo.titvlcob.
       *     end.
       *end. 
       *else do:
       *     if pdvdoc.titvlcob > titulo.titvlcob
       *     then do:
       *         pdvdoc.valor_encargo = pdvdoc.valor_encargo + (pdvdoc.titvlcob - titulo.titvlcob).
       *         pdvdoc.titvlcob      = titulo.titvlcob.
       *     end.
       *
       *end.
       * helio 02032022 iepro - retirado */

       /* helio 02032022 iepro */
       /* ajuste posterior ao iepro 28062022
       pdvdoc.titvlcob      = dec(ttparcelasPagas.valorParcela).
       pdvdoc.valor_encargo = dec(ttparcelasPagas.valorEncargoAtraso).
       pdvdoc.desconto      = dec(ttparcelasPagas.valorDispensaJuros).
       pdvdoc.valor = dec(ttparcelasPagas.valorPago). /* TOTAL DA TRANSACAO */
       */
       /* helio 02032022 iepro */

       /* ajuste posterior ao iepro 28062022 */


       if pdvdoc.pago_parcial = "S"
       then do:
           pdvdoc.titvlcob      = dec(ttparcelasPagas.valorPago) - dec(ttparcelasPagas.valorEncargoAtraso) + dec(ttparcelasPagas.valorDispensaJuros). /* #10082022 */
           pdvdoc.valor_encargo = dec(ttparcelasPagas.valorEncargoAtraso).
           pdvdoc.desconto      = dec(ttparcelasPagas.valorDispensaJuros).
           pdvdoc.valor         = dec(ttparcelasPagas.valorPago). /* TOTAL DA TRANSACAO */
       end.
       else do:
           pdvdoc.titvlcob      = titulo.titvlcob.
           pdvdoc.valor_encargo = dec(ttparcelasPagas.valorEncargoAtraso).
           pdvdoc.desconto      = dec(ttparcelasPagas.valorDispensaJuros).
           pdvdoc.valor         = dec(ttparcelasPagas.valorPago). /* TOTAL DA TRANSACAO */
       end.
       
       message "        update pdvdoc"
       pdvdoc.contnum pdvdoc.titpar pdvdoc.pago_parcial titulo.titvlcob ttparcelasPagas.valorEncargoAtraso ttparcelasPagas.valorDispensaJuros ttparcelasPagas.valorPago
       " ficou " "pdvdoc.titvlcob" pdvdoc.titvlcob "pdvdoc.valor_encargo" pdvdoc.valor_encargo 
       "pdvdoc.desconto" pdvdoc.desconto "pdvdoc.valor" pdvdoc.valor.       
       
        
    end.

    /* RECEBIMENTOS */
    
    {/admcom/barramento/async/recebimentos.i ttpagamentoparcelacrediario.id}
    
    message "transaction?" transaction.
    def var vconta as int.
    for each pdvdoc of pdvmov no-lock.
        vconta  = vconta + 1.
    end.
    
    for each pdvdoc of pdvmov.
    

        message "BAIXANDO" vconta pdvdoc.contnum "/" pdvdoc.titpar. 
        vconta = vconta - 1. 

        find titulo where titulo.contnum = int(pdvdoc.contnum) and
                         titulo.titpar   = pdvdoc.titpar
                         exclusive no-wait no-error.
        if avail titulo
        then do:
            
            run /admcom/progr/fin/baixatitulo.p (recid(pdvdoc),
                                                 recid(titulo)).
            assign     
                titulo.moecod   = if pdvmov.ctmcod = "P7" 
                                  then "PDM"
                                  else "NOV"
                titulo.etbcobra = pdvdoc.etbcod 
                titulo.datexp   = today 
                titulo.cxmdata  = pdvdoc.datamov 
                titulo.cxmhora  = string(pdvmov.horamov) 
                titulo.cxacod   = cmon.cxacod.
                
                
        end.
    end.
    message "FINAL pagamento" transaction.
    
    
end.
message "final".
/**
lokJson = hpagamentoParcelaCrediarioEntrada:WRITE-JSON("LONGCHAR", lcJsonSaida, TRUE).
**/

  


