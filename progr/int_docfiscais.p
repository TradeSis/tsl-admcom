def var varq as char.
def var sparam as char.
def var varquivo as char.
def var vesc as char extent 5 format "x(14)".
def var vsc as char format "x(3)".
def var vsep as char init "|" format "x".

def var vetb as char.
def var vi as int.
def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.

assign vesc[1] = "NOTAS FISCAIS "
       vesc[2] = "ITENS DAS NF. "
       vesc[3] = "IMPOSTOS RET. "
       vesc[4] = "  PROCESSOS   "
       vesc[5] = "CONTAS A PAGAR".
       
def var vindex as int.

sparam = SESSION:PARAMETER.

if num-entries(sparam,";") > 1 then 
    sparam = entry(2,sparam,";").
    
def var vestab as char label "Cod. Estab.".
def var dinici as date label "Dt. Inicial" format "99/99/9999".
def var dfinal as date label "Dt. Final"   format "99/99/9999".

if opsys = "unix" and sparam = "AniTA"
then
repeat:
    vindex = vindex + 1.
    disp vesc no-label with frame f-esc 1 down centered width 80.
    choose field vesc with frame f-esc.
    
    vindex = frame-index.
        
    case vindex:
        when 1 then vsc = "TQ_MDOCUMENTOFISCAL".
        when 2 then vsc = "TQ_MDOCUMENTOFISCALITEM".
        when 3 then vsc = "TQ_MDOCFISCALITEMRETIDOS".
        when 4 then vsc = "TQ_MDOCFISCALPROCADMJUD".
        when 5 then vsc = "TQ_MDOCFISCALCONTASPR".
        otherwise leave.
    end case.

    do with frame f-servi-titulo with width 80 side-label on error undo .
        update vetbcod 
            help "Informe 0 para todos".
        if vetbcod > 0
        then do:
            find estab where estab.etbcod = vetbcod no-lock.
            disp estab.etbnom no-label.
        end.
        vetb = string(vetbcod,"999").
        vestab = string(vetbcod).
        update dinici at 1
            validate(dinici <> ?, "Data Inicial invalida.")
            help "Informe a Data Inicial".
       
        update dfinal 
            validate(dinici <= dfinal, "Data Final invalida.")
            help "Informe a Data Final".
            
        vdti = dinici.
        vdtf = dfinal.
    end.

       
    if vetbcod = 0
    then varquivo = "/admcom/decision/serv_" + vsc + "_" + 
                    trim(string(vetb,"x(3)")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt".
    else varquivo = "/admcom/decision/serv_" + vsc + "_" +
                    trim(string(vetbcod,"999")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt".
    
    output to value(varquivo).
        case vindex:
            when 1 then run pi-exp-tq-mdocumentofiscal.
            when 2 then run pi-exp-tq-mdocumentofiscalitem.
            when 3 then run pi-exp-tq-mdocfiscalitemretidos.
            when 4 then run pi-exp-tq-mdocfiscalprocadmjud.
            when 5 then run pi-exp-tq-mdocfiscalcontaspr.
            otherwise leave.
        end case.
    output close.
end.
else do:

    input from /file_server/param_dcfs.
    import varq.
    output close.
    assign
            vetbcod = int(substring(varq,1,3))
            vestab  = string(vetbcod)
            vetb = string(vetbcod,"999")
            vdti    = date(int(substring(varq,6,2)),
                           int(substring(varq,4,2)),
                           int(substring(varq,8,4)))
            vdtf    = date(int(substring(varq,14,2)),
                           int(substring(varq,12,2)),
                           int(substring(varq,16,4))).
    if vestab = "0" 
    then assign vestab = "" vetb = "".

    dinici = vdti.
    dfinal = vdtf.
    do vi = 1 to 5:
        vindex = vi.
        
        case vindex:
            when 1 then vsc = "TQ_MDOCUMENTOFISCAL".
            when 2 then vsc = "TQ_MDOCUMENTOFISCALITEM".
            when 3 then vsc = "TQ_MDOCFISCALITEMRETIDOS".
            when 4 then vsc = "TQ_MDOCFISCALPROCADMJUD".
            when 5 then vsc = "TQ_MDOCFISCALCONTASPR".
            otherwise leave.
        end case.

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

        /****************
        if vetbcod = 0
        then varquivo = "/admcom/decision/serv_" + vsc + "_" + 
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
        **********/
        
        output to value(varquivo).

        case vindex:
            when 1 then run pi-exp-tq-mdocumentofiscal.
            when 2 then run pi-exp-tq-mdocumentofiscalitem.
            when 3 then run pi-exp-tq-mdocfiscalitemretidos.
            when 4 then run pi-exp-tq-mdocfiscalprocadmjud.
            when 5 then run pi-exp-tq-mdocfiscalcontaspr.
            otherwise leave.
        end case.
        
        output close.
    end.
end.         

def var vcod-serv as char.

procedure pi-exp-tq-mdocumentofiscal:

    for each NF_Serv_Capa where 
            (if vetbcod <> 0 then NF_Serv_Capa.cod_estab = vestab 
                          else true) and
             NF_Serv_Capa.Data_ES >= dinici  AND
             NF_Serv_Capa.Data_ES <= dfinal no-lock,
        first NF_Serv_Itens where 
             NF_Serv_Itens.cod_estab = NF_Serv_Capa.cod_estab and
             NF_Serv_Itens.tipo_operacao = NF_Serv_Capa.tipo_operacao and
             NF_Serv_Itens.cod_modelo = NF_Serv_Capa.cod_modelo and
             NF_Serv_Itens.num_docto = NF_Serv_Capa.num_docto and
             NF_Serv_Itens.num_serie = NF_Serv_Capa.num_serie and
             NF_Serv_Itens.cod_parceiro = NF_Serv_Capa.cod_parceiro and
             NF_Serv_Itens.data_emissao = NF_Serv_Capa.data_emissao and
             NF_Serv_Itens.Data_ES = NF_Serv_Capa.Data_ES
             no-lock .
        if not avail NF_Serv_Itens
        then next.
        put unformatted 
            string("001"                      , "x(100)")               vsep
            string(NF_Serv_Capa.Cod_Estab     , "x(15)")                vsep
            string("0", "x(1)")                                         vsep
            string("SV", "x(2)")                                        vsep
            string(NF_Serv_Capa.Num_Docto     , "9999999999")           vsep
            string(NF_Serv_Capa.Num_Serie     , "x(4)")                 vsep
            string(NF_Serv_Capa.Cod_Parceiro  , "x(30)")                vsep
            string(NF_Serv_Capa.Data_Emissao,"99/99/9999")              vsep
            string(NF_Serv_Capa.Data_ES,"99/99/9999")                   vsep
            string("00", "x(2)")                                        vsep
            string("N")                                                 vsep
            string(NF_Serv_Capa.Val_Tot_Docto , "99999999999999999.99") vsep
            string(NF_Serv_Capa.Tipo_Pagamento, "9")                    vsep  
            string(NF_Serv_Capa.Val_Desconto  , "99999999999999999.99") vsep
            string(NF_Serv_Capa.Modelo_NF     , "x(15)")                vsep 
            string(NF_Serv_Capa.Val_Servico   , "99999999999999999.99") vsep
            string(NF_Serv_Capa.Data_Exec,"99/99/9999")                 vsep
            /*string(NF_Serv_Capa.Codigo_Obra   , "x(255)")    */    
            string(NF_Serv_Capa.Ind_Usso_RPS_Retencao,"x")              vsep
            string(NF_Serv_Capa.Numero_RPS,"x(30)")
            skip.
    end.
end procedure.

procedure pi-exp-tq-mdocumentofiscalitem:

    for each NF_Serv_Capa where 
            (if vetbcod <> 0 then NF_Serv_Capa.cod_estab = vestab 
                          else true) and
             NF_Serv_Capa.Data_ES >= dinici  AND
             NF_Serv_Capa.Data_ES <= dfinal no-lock,
        each NF_Serv_Itens where 
             NF_Serv_Itens.cod_estab = NF_Serv_Capa.cod_estab and
             NF_Serv_Itens.tipo_operacao = NF_Serv_Capa.tipo_operacao and
             NF_Serv_Itens.cod_modelo = NF_Serv_Capa.cod_modelo and
             NF_Serv_Itens.num_docto = NF_Serv_Capa.num_docto and
             NF_Serv_Itens.num_serie = NF_Serv_Capa.num_serie and
             NF_Serv_Itens.cod_parceiro = NF_Serv_Capa.cod_parceiro and
             NF_Serv_Itens.data_emissao = NF_Serv_Capa.data_emissao and
             NF_Serv_Itens.Data_ES = NF_Serv_Capa.Data_ES
             no-lock:
             
        vcod-serv = "SERV" + string(int(NF_Serv_Itens.Cod_Item),"999999999").
        put unformatted                       
            string(NF_Serv_Itens.CFOP            , "9999999999")    vsep
            string("001"                         , "x(100)")        vsep  
            string(NF_Serv_Itens.Cod_Estab       , "x(15)")         vsep
            string("0","x(1)")                                      vsep
            string("SV", "x(2)")                                    vsep
            string(NF_Serv_Itens.Num_Docto       , "9999999999")    vsep
            string(NF_Serv_Itens.Num_Serie       , "x(4)")          vsep
            string(NF_Serv_Itens.Cod_Parceiro    , "x(30)")         vsep
            string(NF_Serv_Itens.Data_Emissao,"99/99/9999")         vsep
            string(NF_Serv_Itens.Data_ES,"99/99/9999")              vsep
            string(NF_Serv_Itens.Numero_item     , "9999999999")    vsep
            string(vcod-serv       , "x(60)")         vsep
            string(NF_Serv_Itens.Desc_Compl      , "x(255)")        vsep
            string("SV", "x(6)")                                    vsep
            string(NF_Serv_Itens.Qtde_Item, "99999999999999999.99999")   vsep
            string(NF_Serv_Itens.Valor_Item, "99999999999999999.999999") vsep
            string(NF_Serv_Itens.Valor_Desconto, "99999999999999999.99") vsep
            string("1")                                             vsep
            string(NF_Serv_Itens.Cod_Plano_Conta, "x(60)")          vsep
           string(NF_Serv_Itens.Valor_Contabil, "99999999999999999.999999") vsep
            string("001", "x(56)")                                  vsep
            string(NF_Serv_Itens.Cod_Obra, "x(255)")                vsep
            skip.            
    end.
end procedure.

procedure pi-exp-tq-mdocfiscalitemretidos:
    def var vrepasse as char format "x".
    for each NF_Serv_Capa where 
            (if vetbcod <> 0 then NF_Serv_Capa.cod_estab = vestab 
                          else true) and
             NF_Serv_Capa.Data_ES >= dinici  AND
             NF_Serv_Capa.Data_ES <= dfinal no-lock,
        each NF_Serv_Itens where 
             NF_Serv_Itens.cod_estab = NF_Serv_Capa.cod_estab and
             NF_Serv_Itens.tipo_operacao = NF_Serv_Capa.tipo_operacao and
             NF_Serv_Itens.cod_modelo = NF_Serv_Capa.cod_modelo and
             NF_Serv_Itens.num_docto = NF_Serv_Capa.num_docto and
             NF_Serv_Itens.num_serie = NF_Serv_Capa.num_serie and
             NF_Serv_Itens.cod_parceiro = NF_Serv_Capa.cod_parceiro and
             NF_Serv_Itens.data_emissao = NF_Serv_Capa.data_emissao and
             NF_Serv_Itens.Data_ES = NF_Serv_Capa.Data_ES
             no-lock,
        each NF_Serv_Imposto_Ret where
             NF_Serv_Imposto_Ret.cod_estab = NF_Serv_Itens.cod_estab and
             NF_Serv_Imposto_Ret.Tipo_Operacao = 
                                    NF_Serv_Itens.tipo_operacao and
             NF_Serv_Imposto_Ret.Cod_Modelo = NF_Serv_Itens.cod_modelo and
             NF_Serv_Imposto_Ret.Num_Docto = NF_Serv_Itens.num_docto and
             NF_Serv_Imposto_Ret.Num_Serie = NF_Serv_Itens.num_serie and
             NF_Serv_Imposto_Ret.Cod_Parceiro = NF_Serv_Itens.cod_parceiro and
             NF_Serv_Imposto_Ret.Data_Emissao = NF_Serv_Itens.data_emissao and
             NF_Serv_Imposto_Ret.Data_ES = NF_Serv_Itens.Data_ES and
             NF_Serv_Imposto_Ret.Num_Item = NF_Serv_Itens.Numero_Item
             no-lock:
        
        if NF_Serv_Imposto_Ret.Tipo_Repasse > 0
        then vrepasse = string(NF_Serv_Imposto_Ret.Tipo_Repasse  , "9").
        else vrepasse = "". 

        vcod-serv = "SERV" + 
                string(int(NF_Serv_Imposto_Ret.Cod_Item),"999999999").
        put unformatted
         string("001"                              ,"x(100)")               vsep
         string(NF_Serv_Imposto_Ret.Cod_Estab      , "x(15)")               vsep
         string("0", "x(1)")                                                vsep
         string("SV", "x(2)")                                               vsep
         string(NF_Serv_Imposto_Ret.Num_Docto     , "9999999999")           
         vsep 
         string(NF_Serv_Imposto_Ret.Num_Serie     ,"x(4)")                  
         vsep 
         string(NF_Serv_Imposto_Ret.Cod_Parceiro  ,"x(30)")                 
         vsep 
         string(NF_Serv_Imposto_Ret.Data_Emissao,"99/99/9999")              
         vsep
         string(NF_Serv_Imposto_Ret.Data_ES,"99/99/9999")                   vsep
         string(NF_Serv_Imposto_Ret.Num_Item      , "9999999999")           vsep
         string(NF_Serv_Imposto_Ret.Data_Pagto,"99/99/9999")                vsep
         string(NF_Serv_Imposto_Ret.Cod_Imposto_Ret, "x(50)")               
         vsep 
         string(NF_Serv_Imposto_Ret.Val_Base_Ret, "9999999999999999999.99") 
         vsep 
         string(NF_Serv_Imposto_Ret.Aliquota_Ret  , "99999.99")             vsep
         string(NF_Serv_Imposto_Ret.Valor_Ret   , "9999999999999999999.99") 
         vsep 
         string(NF_Serv_Imposto_Ret.Cod_Receita   ,"x(10)")                 
         vsep 
         string(vcod-serv      , "x(60)")                vsep
         vrepasse format "x"
         vsep
         string(NF_Serv_Imposto_Ret.Val_Alim , "999999999999999999.99")     vsep
         string(NF_Serv_Imposto_Ret.Val_Apos15 , "999999999999999999.99")   vsep
         string(NF_Serv_Imposto_Ret.Val_Apos20 , "999999999999999999.99")   vsep
         string(NF_Serv_Imposto_Ret.Val_Apos25 , "999999999999999999.99")   
         vsep
         /*
         string(NF_Serv_Imposto_Ret.Val_Cont_Gil, "999999999999999999.99")  vsep
         string(NF_Serv_Imposto_Ret.Val_Cont_Prev, "999999999999999999.99") vsep
      string(NF_Serv_Imposto_Ret.Val_Cont_Senar, "999999999999999999.99")   vsep
         */
      string(NF_Serv_Imposto_Ret.Val_Dep_Jud, "999999999999999999.99")      vsep
      string(NF_Serv_Imposto_Ret.Val_Dep_Jud_R, "999999999999999999.99")    vsep
      string(NF_Serv_Imposto_Ret.Val_Mat_Equip, "999999999999999999.99")    vsep
      /*
      string(NF_Serv_Imposto_Ret.Val_Nao_Ret_Ad, "999999999999999999.99")   vsep
      string(NF_Serv_Imposto_Ret.Val_Nao_Ret_PR, "999999999999999999.99")   vsep
      */
      string(NF_Serv_Imposto_Ret.Val_Nao_Out_Desp, "999999999999999999.99") 
      vsep 
     string(NF_Serv_Imposto_Ret.Val_Ret_Ad15, "999999999999999999.99")     vsep
     string(NF_Serv_Imposto_Ret.Val_Ret_Ad20, "999999999999999999.99")     vsep
     string(NF_Serv_Imposto_Ret.Val_Ret_Ad25, "999999999999999999.99")     vsep
     string(NF_Serv_Imposto_Ret.Val_Ret_Sub , "999999999999999999.99")     vsep
     string(NF_Serv_Imposto_Ret.Val_Transp  , "999999999999999999.99")     vsep
     string(NF_Serv_Imposto_Ret.Var_Cod_Receita, "x(4)")                   vsep
     string(NF_Serv_Imposto_Ret.Aliq_Contri_Adicional,"x(5)")   vsep
     string(NF_Serv_Imposto_Ret.Aliq_Contrib_Sistema_S,"x(5)")   vsep
     string(NF_Serv_Imposto_Ret.Condicao_Retencao,"x")           vsep
     string(NF_Serv_Imposto_Ret.Descricao_Observacao,"x(255)")   vsep
     string(NF_Serv_Imposto_Ret.Finalidade_Retencao,"x")         vsep
     string(NF_Serv_Imposto_Ret.Valor_Contrib_Adicional,"x(19)") vsep
     string(NF_Serv_Imposto_Ret.Valor_Contrib_Sistema_S,"x(19)") 
         skip.
    end.            
end procedure.

procedure pi-exp-tq-mdocfiscalprocadmjud:
    for each NF_Serv_Item_Proc where
            (if vetbcod <> 0 then NF_Serv_Item_Proc.cod_estab = vestab 
                             else true) and
             NF_Serv_Item_Proc.Data_ES >= dinici  AND
             NF_Serv_Item_Proc.Data_ES <= dfinal no-lock.

        vcod-serv = "SERV" +
                    string(int(NF_Serv_Item_Proc.Cod_Item),"999999999").
                        
        put unformatted
            string(NF_Serv_Item_Proc.Data_Pagto_Adv,"99/99/9999")    vsep
            string(NF_Serv_Item_Proc.Val_Serv_Adv, "999999999999999999.99") vsep
            string("001"                               ,"x(100)")           vsep
            string(NF_Serv_Item_Proc.cod_Estab         ,"x(15)")            vsep
            string(NF_Serv_Item_Proc.Cod_Modelo        ,"x(2)")             vsep
            string(vcod-serv          ,"x(60)")            vsep
            string(NF_Serv_Item_Proc.cod_Mun_IBGE      ,"9999999999")       vsep
            string(NF_Serv_Item_Proc.Cod_Parceiro_Adv  ,"x(30)")            vsep
            string(NF_Serv_Item_Proc.Cod_Parceiro      ,"x(30)")            vsep
            string(NF_Serv_Item_Proc.Cod_Suspensao     ,"x(14)")            vsep
            string(NF_Serv_Item_Proc.Data_Emissao,"99/99/9999")             vsep
            string(NF_Serv_Item_Proc.Data_ES,"99/99/9999")                  vsep
            string(NF_Serv_Item_Proc.Num_Docto         ,"9999999999")       vsep
            string(NF_Serv_Item_Proc.Num_Item          ,"9999999999")       vsep
            string(NF_Serv_Item_Proc.Num_Processo      ,"x(30)")            vsep
            string(NF_Serv_Item_Proc.Num_Serie         ,"x(4)")             vsep
            string(NF_Serv_Item_Proc.Tipo_Operacao     ,"x(1)")             vsep
            string(NF_Serv_Item_Proc.Tipo_Processo     ,"A/J")              vsep
            skip.
    end.            
end procedure.

                      
procedure pi-exp-tq-mdocfiscalcontaspr:
    for each NF_Serv_CPG no-lock.
        vcod-serv = "SERV" +
                    string(int(NF_Serv_CPG.Cod_Item),"999999999").
        put unformatted
            string("001"                               ,"x(100)")     vsep 
            string(NF_Serv_CPG.Cod_Estab               ,"x(15)")      vsep
            string(NF_Serv_CPG.Tipo_Conta_PR           ,"x(2)")       vsep
            string(NF_Serv_CPG.Tipo_Docto_PR           ,"x(3)")       vsep
            string("P")                                               vsep
            string(NF_Serv_CPG.Num_Docto_PR            ,"x(30)")      vsep
            string(NF_Serv_CPG.Data_Operacao_PR,"99/99/9999")         vsep
            string(NF_Serv_CPG.Num_Parcela_PR          ,"999")        vsep
            string(NF_Serv_CPG.Tipo_Operacao           ,"x(1)")       vsep
            string(NF_Serv_CPG.Cod_Modelo              ,"x(2)")       vsep
            string(NF_Serv_CPG.Num_Docto               ,"9999999999") vsep
            string(NF_Serv_CPG.Num_Serie               ,"x(4)")       vsep
            string(NF_Serv_CPG.Cod_Parceiro            ,"x(30)")      vsep
            string(NF_Serv_CPG.Data_Emissao,"99/99/9999")             vsep
            string(NF_Serv_CPG.Data_ES,"99/99/9999")                  vsep
            string(vcod-serv                ,"x(60)")      vsep
            skip.
    end.            
end procedure. 
         
