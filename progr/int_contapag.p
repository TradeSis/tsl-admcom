def var varq as char.
def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var vetb as char.
def var sparam as char.
def var vpasta as char.
def var vdata as char.
def var varquivo as char.
def var vesc as char extent 3 format "x(25)".
def var vsc as char format "x(3)".
def var vtitvlpag like titulo.titvlpag.
def var vestab as char.
def var vi as int.
def var vsep as char init "|" format "x".
def var vcod-serv as char.

vesc[1] = "CONTAS A PAGAR".
vesc[2] = "IMPOSTOS RET.".
vesc[3] = "PROCESSOS ASSOCIADOS".

def var vindex as int.

sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").

if opsys = "unix" and sparam = "AniTA"
then
repeat:
    
    vindex = vindex + 1.
    disp vesc no-label with frame f-esc 1 down centered width 80.
    choose field vesc with frame f-esc.
                   
    vindex = frame-index.
                       
    case vindex:
        when 1 then vsc = "TQ_MCONTASPAGARRECEBER".
        when 2 then vsc = "TQ_MCONTASPRRETIDOS".
        when 3 then vsc = "TQ_MCONTASPRPROCADMJUD".
        otherwise leave.
    end case.
                
     varquivo = "/admcom/decision/serv_" + vsc
                + string(day(today),"99")
                + string(month(today),"99")
                + string(year(today),"9999")
                + "_"
                + string(time)
                + ".txt".
    
    output to value(varquivo).        
        case vindex:
            when 1 then run put-01.
            when 2 then run put-02.
            when 3 then run put-03.
            otherwise leave.
        end case.                                             
    output close.

end.
else do:

    /*********
    input from /file_server/param_dcpg.
    import varq.
    output close.
    assign
            vetbcod = int(substring(varq,1,3))
            vestab  = string(vetbcod)
            vdti    = date(int(substring(varq,6,2)),
                           int(substring(varq,4,2)),
                           int(substring(varq,8,4)))
            vdtf    = date(int(substring(varq,14,2)),
                           int(substring(varq,12,2)),
                           int(substring(varq,16,4))).
    *******/
 
    do vi = 1 to 3:
        vindex = vi.
                       
        case vindex:
            when 1 then vsc = "TQ_MCONTASPAGARRECEBER".
            when 2 then vsc = "TQ_MCONTASPRRETIDOS".
            when 3 then vsc = "TQ_MCONTASPRPROCADMJUD".
            otherwise leave.
        end case.
             
        varquivo = "/file_server/serv_" + vsc + "_" + ".txt".
        
        /********        
        if vetbcod = 0
        then varquivo = "/file_server/serv_" + vsc + "_" + 
                    trim(string(vetb,"x(3)")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt".
        else varquivo = "/file_server/serv_" + vsc + "_" +
                    trim(string(vetbcod,"999")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt".
        ***/
        
        output to value(varquivo).        
        case vindex:
            when 1 then run put-01.
            when 2 then run put-02.
            when 3 then run put-03.
            otherwise leave.
        end case.                                             
        output close.
    end.
end.
         
procedure put-01:
    for each servi_titulo no-lock:
        put unformatted
            '001'                             vsep /*CodCiaNat*/               
            servi_titulo.codestabelecimento   vsep /*CodEstabelecimentoNat*/   
            servi_titulo.codGrupoContabil     vsep /*CodGrupoContabilNat*/     
            '001'                             vsep /*CodPlanoContaNat*/        
            servi_titulo.codParceiro          vsep /*CodParceiroNat*/          
            string(servi_titulo.dataOperacao,"99/99/9999") vsep /*DataOperacao*/ 
            servi_titulo.descricao            vsep /*Descricao*/               
            servi_titulo.ValorOperacao        vsep /*ValorOperacao*/           
            servi_titulo.TipoOperacao         vsep /*TipoOperacao*/            
            servi_titulo.TipoDocumento        vsep /*TipoDocumento*/           
            servi_titulo.NumeroDocumento      vsep /*NumeroDocumento*/         
            servi_titulo.ValorOriginalTitulo  vsep /*ValorOriginalTitulo*/     
            string(servi_titulo.DataEmissaoDocumento,"99/99/9999") vsep                     /*DataEmissaoDocumento*/    
            string(servi_titulo.DataVencimento, "99/99/9999")      
            vsep /*DataVencimento*/          
            servi_titulo.NumeroArquivamento   vsep /*NumeroArquivamento*/      
            servi_titulo.Tipo                 vsep /*Tipo*/
            servi_titulo.CodigoObra           vsep /*CodigoObraNat*/
            servi_titulo.EfeitoMovimento      vsep /*EfeitoMovimento*/
            servi_titulo.NumeroParcela        vsep /*NumeroParcela*/
        skip.
    end.
end procedure.

procedure put-02:
    for each serv_titulo_iret no-lock:
        vcod-serv = "SERV" +
                    string(int(serv_titulo_iret.CodItem),"999999999").
        put unformatted
            '001'                               vsep /*CodCiaNat*/
            serv_titulo_iret.codEstabelecimento vsep /*CodEstabelecimentoNat*/
            serv_titulo_iret.CodParceiro                vsep /*CodParceiroNat*/
            string(serv_titulo_iret.DataOperacaoContaPagRec,"99/99/9999")    
                vsep /*DataOperacao*/
            serv_titulo_iret.TipoOperacaoContaPagRec    vsep /*TipoOperacao*/
            serv_titulo_iret.TipoDocumentoContaPagRec   vsep /*TipoDocumento*/
            serv_titulo_iret.NumeroDocumentoContaPagRec vsep /*NumeroDocumento*/
            serv_titulo_iret.TipoContaPagRec            vsep /*Tipo*/          
            serv_titulo_iret.NumeroParcelaContaPagRec   vsep /*NumeroParcela*/
            vcod-serv format "x(20)"
            /*serv_titulo_iret.CodItem */                   vsep /*CodItemNat*/
            string(serv_titulo_iret.DataPagamento,"99/99/9999")              
                vsep /*DataPagamento*/
            serv_titulo_iret.CodImpostoRetido       vsep /*CodImpostoRetidoNat*/
            serv_titulo_iret.ValorBaseRetencao      vsep /*ValorBaseRetencao*/
            serv_titulo_iret.AliquotaRetencao       vsep /*AliquotaRetencao*/
            serv_titulo_iret.ValorRetido             vsep /*ValorRetido*/
            serv_titulo_iret.ValorDepositoJudicial vsep /*VlrDepositoJudicial*/
            serv_titulo_iret.CodFormaTributacaoExt vsep /*CodFormaTribuExtNat*/
            serv_titulo_iret.VarCodReceita         vsep /*CodigoReceitaNat*/
            serv_titulo_iret.CodTipoRendimentoExt  vsep /*CodTipoRendimento*/
            serv_titulo_iret.ValorDeducaoBC        vsep /*ValorDeducaoBC*/
            serv_titulo_iret.VarCodReceita         vsep /*VarCodReceitaNat*/
        skip.
    end.      
end procedure.
      

procedure put-03:
    for each serv_titulo_proc no-lock:
        vcod-serv = "SERV" +
                    string(int(serv_titulo_proc.CodItem),"999999999").
        put unformatted
            string(serv_titulo_proc.DataPagamentoAdvogado,"99/99/9999")  
                vsep /*DtPagAdvogado*/
            serv_titulo_proc.ValorServicoAdvocaticio vsep /*VlrSerAdvocaticio*/
            '001'                                    vsep /*CodCiaNat*/
            serv_titulo_proc.CodEstabelecimento  vsep /*CodEstabelecimentoNat*/
            vcod-serv format "x(20)"
            /*serv_titulo_proc.CodItem*/                 vsep /*CodItemNat*/
            serv_titulo_proc.CodMunicipioIBGE     vsep /*CodMunicipioIBGENat*/
            serv_titulo_proc.CodParceiroAdv          vsep /*CodParceiroAdvNat*/
            serv_titulo_proc.CodParceiro             vsep /*CodParceiroNat*/
            serv_titulo_proc.CodSuspensao            vsep /*CodSuspensaoNat*/
            string(serv_titulo_proc.DataOperacao,"99/99/9999")            
                vsep /*DataOperacaoNat*/
            serv_titulo_proc.NumeroDocumento         vsep /*NumeroDocumentoNat*/
            serv_titulo_proc.NumeroParcela           vsep /*NumeroParcelaNat*/
            serv_titulo_proc.NumeroProcesso          vsep /*NumeroProcessoNat*/
            serv_titulo_proc.TipoDocumento           vsep /*TipoDocumentoNat*/
            serv_titulo_proc.Tipo                    vsep /*TipoNat*/
            serv_titulo_proc.TipoOperacao            vsep /*TipoOperacaoNat*/
            serv_titulo_proc.TipoProcesso            vsep /*TipoProcessoNat*/
        skip.
    end.   
end procedure.
