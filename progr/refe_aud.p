
def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var vdata as date.
def var vetb as char.
def var varq as char.

def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
 
if opsys = "unix" and sparam <> "AniTA"
then do:
        
        input from /admcom/audit/param_ref.
        repeat:
            import varq.
            vetbcod = int(substring(varq,1,3)).
            vdti    = date(int(substring(varq,6,2)),
                           int(substring(varq,4,2)),
                           int(substring(varq,8,4))).
            vdtf    = date(int(substring(varq,14,2)),
                           int(substring(varq,12,2)),
                           int(substring(varq,16,4))).
                       
        end.
        input close.
    
        if vetbcod = 999
        then return.
    
end.
else do:
    
        update vetbcod with frame f1.
        if vetbcod = 0
        then display "GERAL" @ estab.etbnom with frame f1.
        else do:
            find estab where estab.etbcod = vetbcod no-lock.
            display estab.etbnom no-label with frame f1.
        end.
    
        update vdti label "Data Inicial" colon 16
               vdtf label "Data Final" with frame f1 side-label width 80.
end.
    
    
    if vetbcod = 0
    then vetb = "".
    else vetb = string(vetbcod,"999").
    if opsys = "unix"
    then varq = "/admcom/audit/refer_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
    else varq = "l:\audit\refer_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") + 
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".

output to value(varq).

        
for each estab where
         (if vetbcod > 0 then estab.etbcod = vetbcod
                         else true) no-lock:
    /*
    disp "PROCESSANDO... AGUARDE! " estab.etbcod 
                        with frame f-dd 1 down centered row 10
                        no-label.
    */                    
    for each docrefer where
         docrefer.etbcod = estab.etbcod and
         docrefer.datadr >= vdti and
         docrefer.datadr <= vdtf
         no-lock: 
        
        put docrefer.etbcod format ">>9" /* Filial */
            docrefer.tiporefer format ">>>>9" /* Tipo de referencia:
                                          11: PROCESSO REFERENCIADO
                                          12: DOCUMENTO DE ARRECADACAO
                                          13: DOCUMENTO FISCAL REFERENCIADO
                                          14: CUPOM FISCAL REFERENCIADO */
            docrefer.tipmov format "x" /* E: ENTRADA    S: SAIDA */
            docrefer.numori format ">>>>>>>>>>>9" /* NUMERO DO DOCUMENTO */
            docrefer.serieori format "x(5)"  /* SERIE DO DOCUMENTO */
            string(docrefer.codedori)
             format "x(18)" /* CODIGO EMITENTE/DESTINO */
            docrefer.dtemiori format "99999999" /* DATA EMISSÃO DO DOCUMENTO */
            docrefer.modeloori format "x(2)" /* MODELO DO DOCUMENTO */
            docrefer.serecf format "x(20)" /* NUMERO DE SERIE DA ECF */
            docrefer.numecf format ">>9" /* NUMERO DO CAIXA ATRIBUIDO AO ECF */
            docrefer.coo    format ">>>>>>>>>>>9" /* COO DO CUPOM FISCAL */
            docrefer.dtemicupom format "99999999"
                            /* DATA DE EMISSÃO DO CUPOM FISCAL */
            docrefer.modeloda format "x" 
                            /* MODELO DO DOCUMENTO DE ARRECADAÇÃO */
            docrefer.ufbenef format "x(2)"
                            /* UF BENEFICIARIA DO RECOLHIMENTO */
            docrefer.numeroda format "x(20)"
                            /* NUMERO DO DOCUMENTO DE ARRECADAÇÃO */
            docrefer.autenticacao format "x(30)" /* AUTENTICAÇÃO BANCARIA */
            docrefer.valorda format ">>>>>>>>>>>>>>>9"
                            /* VALOR DO DOCUMENTO DE ARRECADAÇÃO */
            docrefer.dtvencimento format "99999999"
                            /* DATA VENCIMENTO DO DOCUMENTO */
            docrefer.dtpagamento format "99999999"
                            /* DATA DE PAGAMENTO */
            docrefer.tipmovref format "x" /* TITPO DE MOVIMENTO REFERENCIADO 
                                          E: ENTRADA     S: SAIDA */ 
            docrefer.tipoemi format "x" /* TIPO DE EMISSÃO
                                          P: PROPRIA     T: TERCEIRO */
            string(docrefer.codrefer) format "x(18)"
                                /* EMITENTE/DESTINO REFERENCIADO */
            docrefer.modelorefer format "x(2)" /* MODELO REFERENCIADO */
            docrefer.serierefer format "x(5)" /* SERIE REFERENCIADO */
            docrefer.numerodr format ">>>>>>>>>>>9"
                                /* NUMERO DOCUMENTO REFERENCIADO */
            docrefer.datadr format "99999999"
                                /* DATA DOCUMENTO REFERENCIADO */
            docrefer.origem format "x" /* INDICAÇÃO DE ORIGEM DO PROCESSO
                                          0: SEFAZ 1: JUSTIÇA FEDERAL
                                          2: JUSTIÇA ESTADUAL
                                          3: SECEX/RFB   9: OUTROS */
            docrefer.idproc format "x(254)" /* IDENTIFICAÇÃO DO PROCESSO */
            docrefer.transporte format "x" /* TIPO DE TRANSPORTE COLETA */
            docrefer.cnpj format "x(18)" /* CNPJ/CPF LOCAL DE COLETA */
            docrefer.iecoleta format "x(20)" /* IE LOCAL DE COLETA */
            docrefer.codmun format "x(7)" /* CODIGO MUNICIPIO LOCAL COLETA */
            docrefer.cnpjent format "x(18)" /* CNPJ/CPF LOCAL DE ENTREGA */
            docrefer.ieentrega format "x(20)" /* IE LOCAL DE ENTREGA */
            docrefer.codmunent format "x(7)" /* CODIGO MUNICIPIO ENTREGA */
            docrefer.codobs format "x(6)" /* CODIGO DE OBSERVAÇÃO */
            skip .
    end.
end.
    
output close.    
