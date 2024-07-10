def input parameter par-arq as char.

/*par-arq = "/admcom/nfe/linx/NF_SAIDA_22102013.csv.39121".*/

def stream log.

def buffer bplani for plani.
def temp-table tt 
  field  NOME_CLIFOR as char 
  field  NF_SAIDA as char 
  field  TIPO_ENTRADAS as char 
  field  FILIAL as char 
  field  CONDICAO_PGTO as char 
  field  RECEBIMENTO as char 
  field  EMISSAO as char 
  field  FRETE as char 
  field  SEGURO as char 
  field  DESCONTO as char 
  field  ENCARGO as char 
  field  NF_PROPRIA_EMITIDA as char 
  field  IPI_VALOR as char 
  field  ICMS_BASE as char 
  field  ICMS_VALOR as char 
  field  QTDE_TOTAL as char 
  field  VALOR_TOTAL as char 
  field  DEVOLUCAO as char 
  field  VALOR_ADICIONAL as char 
  field  SERIE_NF_SAIDA as char 
  field  EMPRESA as char 
  field  ICMS_ISENTO as char 
  field  ICMS_OUTROS as char 
  field  PORC_DESCONTO as char 
  field  PORC_ENCARGO as char 
  field  VALOR_IMPOSTO_AGREGAR as char 
  field  VALOR_SUB_ITENS as char 
  field  DESCONTO_BRUTO as char 
  field  NOTA_CANCELADA as char 
  field  DATA_CANCELAMENTO as char 
  field  CHAVE_NFE as char 
  field  PROTOCOLO_AUTORIZACAO_NFE as char 
  field  DATA_AUTORIZACAO_NFE as char 
  field  PROTOCOLO_CANCELAMENTO_NFE as char 
  field  STATUS_NFE as char 
  field  MOTIVO_CANCELAMENTO_NFE as char 
  field  ITEM_NFE as char 
  field  CLASSIF_FISCAL as char 
  field  CODIGO_FISCAL_OPERACAO as char 
  field  CODIGO_ITEM as char  format "x(30)"
  field  DESCONTO_ITEM as char 
  field  DESCRICAO_ITEM as char format "x(60)" label "Descr"
  field  ITEM_IMPRESSAO as char 
  field  PRECO_UNITARIO as char 
  field  QTDE_DEVOLVIDA as char 
  field  QTDE_ITEM as char 
  field  UNIDADE as char 
  field  VALOR_ITEM as char 
  field  REFERENCIA as char 
  field  ITEM_NFE1      as char 
  field  BASE_IMPOSTO   as char 
  field  TAXA_IMPOSTO   as char 
  field  VALOR_IMPOSTO  as char 
  field  IMPOSTO        as char
  
  
  .

def var    vBASE_IMPOSTO    as dec.
def var    vTAXA_IMPOSTO    as dec.    
def var    vVALOR_IMPOSTO   as dec.
  
def var vv as int. 

input from value(par-arq).
repeat.
    create tt.
    import delimiter ";" tt.
    vv = vv + 1.
    if vv = 1 then  next.

if PROTOCOLO_AUTORIZACAO_NFE = ""
then do.
    output stream log to value("/admcom/nfe/linx/logs/" +
                    string(today,"99999999") +
                     ".log") append .
    put stream log unformatted 
        "NEXT - PROTOCOLO_AUTORIZACAO_NFE " PROTOCOLO_AUTORIZACAO_NFE " "
        NOME_CLIFOR " "
        NF_SAIDA      " "
        TIPO_ENTRADAS    " "
        FILIAL            " "
        RECEBIMENTO        " "
        EMISSAO             " " 
        "STATUS_NFE = " STATUS_NFE 
        skip
        .
    output stream log close.
    next.
end.    


BASE_IMPOSTO  = replace(BASE_IMPOSTO , "," , "." ).
TAXA_IMPOSTO  = replace(TAXA_IMPOSTO , "," , "." ).
VALOR_IMPOSTO = replace(VALOR_IMPOSTO , "," , "." ).
    disp    
        filial                         /* etbcod*/ format "x(30)"
        nome_clifor                    /* nome clifor  */
                                                    format "x(30)"
        serie_nf                       /* serie nf */
        NF_SAIDA
        recebimento                    /* dtinclu  */
        emissao                        /* pladat*/
        qtde_total                     /* qtd total movins*/
            dec(qtde_total) / 1000
                    
        valor_total                    /* platot   */
            dec(valor_total) / 1000
        
        chave_nfe                      /* chave NFE    */
        
        PROTOCOLO_AUTORIZACAO_NFE      /* protocolo NFE */
        
        CODIGO_FISCAL_OPERACAO         /* opfcod   */
        
        CODIGO_ITEM                    /* procod   */
        
        DESCRICAO_ITEM                 /* pronom   */

        PRECO_UNITARIO                 /* movpc    */
            dec(PRECO_UNITARIO) / 100000  
        QTDE_ITEM                      /* movqtm   */
            dec(QTDE_ITEM) / 1000
        VALOR_ITEM                     /* movpc * movqtm */
            dec(VALOR_ITEM) / 100
        REFERENCIA                     /* referencia   */ format "x(30)"
        with 4 column 1 down.
    pause 0.    
vBASE_IMPOSTO = dec(BASE_IMPOSTO).
vTAXA_IMPOSTO = dec(TAXA_IMPOSTO)  .
vVALOR_IMPOSTO = dec(VALOR_IMPOSTO).
disp
BASE_IMPOSTO TAXA_IMPOSTO VALOR_IMPOSTO IMPOSTO      
        
    vBASE_IMPOSTO 
    vTAXA_IMPOSTO
    vVALOR_IMPOSTO
        
        with 4 column 1 down.

pause 0.    
    
    find opcom where opcom.opccod = CODIGO_FISCAL_OPERACAO no-error.

    if not avail opcom
    then
        find opcom where 
            opcom.opccod = string(int(CODIGO_FISCAL_OPERACAO) - 1000)
                                    no-error.
    if not avail opcom
    then
        find opcom where 
                opcom.opccod = string(int(CODIGO_FISCAL_OPERACAO) + 1000)
                                    no-error.    

    disp avail opcom.    pause 0.
    

    if STATUS_NFE = "49"
    then do.
        run cancela.  next.
    end.   

    if not avail opcom
    then   do.
        output stream log to value("/admcom/nfe/linx/logs/" +
                        string(today,"99999999") +
                         ".log") append .
        put stream log unformatted 
            "NEXT - not avail opcom "  " "
            "CODIGO_FISCAL_OPERACAO= " CODIGO_FISCAL_OPERACAO " "
            NOME_CLIFOR " "
            NF_SAIDA      " "
            TIPO_ENTRADAS    " "
            FILIAL            " "
            RECEBIMENTO        " "
            EMISSAO             " " 
            "STATUS_NFE = " STATUS_NFE
            skip
            .
        output stream log close.
        next.
    end.
    find first depara_estab where depara_estab.filial = tt.filial
                                        no-error.
    if not avail depara_estab
    then do.
        create depara_estab.
        assign depara_estab.filial = tt.filial.
    end.
    find first depara_clifor where depara_clifor.nome_clifor = tt.nome_clifor
                                        no-error.
    if not avail depara_clifor
    then do.
        create depara_clifor.
        assign depara_clifor.nome_clifor = tt.nome_clifor.
    end.
    if depara_clifor.codigo = ?
    then   do.
        output stream log to value("/admcom/nfe/linx/logs/" +
                        string(today,"99999999") +
                         ".log") append .
        put  stream log unformatted 
            "NEXT - depara_clifor.codigo = ?  "  " "
            tt.NOME_CLIFOR " "
            tt.NF_SAIDA      " "
            tt.TIPO_ENTRADAS    " "
            tt.FILIAL            " "
            tt.RECEBIMENTO        " "
            tt.EMISSAO             " " 
            skip
            .
        output stream log close.        
        next.
    end.
    if depara_estab.etbcod = ?
    then do.
        output stream log to value("/admcom/nfe/linx/logs/" +
                        string(today,"99999999") +
                         ".log") append .
        put stream log unformatted 
            "NEXT - depara_estab.etbcod = ?  "  " "
            tt.NOME_CLIFOR " "
            tt.NF_SAIDA      " "
            tt.TIPO_ENTRADAS    " "
            tt.FILIAL            " "
            tt.RECEBIMENTO        " "
            tt.EMISSAO             " " 
            skip
            .
        output stream log close.        
        next.
    end.
def var c-placod as char format "x(20)".
def var vplacod like plani.placod.

def var vmovqtm like movim.movqtm.
def var vmovpc  like movim.movpc.

c-placod = "55" + string(int(tt.NF_SAIDA),"9999999").
vplacod = int(c-placod).
message c-placod vplacod. pause 0.

                  pause 0.
                  
    find plani where plani.etbcod = 22 and
                     plani.placod = vplacod
                     no-lock no-error.
    if not avail plani
    then do.
        create plani.
        assign
            plani.PlaCod    = vplacod
            plani.etbcod = depara_estab.etbcod
            plani.movtdc = opcom.movtdc       
            plani.emite  = 22
            plani.serie  = "1"
            plani.numero = int(tt.NF_SAIDA)  . 
    end.

    find a01_infnfe where a01_infnfe.etbcod = plani.etbcod and  
                          a01_infnfe.placod = plani.placod
                          no-lock
                          no-error.
    if not avail a01_infnfe
    then do.
        /*
        create a01_infnfe.
        ASSIGN a01_infnfe.versao      = plani.versao 
               a01_infnfe.Id          = plani.Id  
               a01_infnfe.pk_nitem    = plani.pk_nitem  
               a01_infnfe.etbcod      = plani.etbcod  
               a01_infnfe.placod      = plani.placod  
               a01_infnfe.emite       = plani.emite  
               a01_infnfe.serie       = plani.serie  
               a01_infnfe.numero      = plani.numero  
               a01_infnfe.chave       = plani.chave  
               a01_infnfe.sitnfe      = plani.sitnfe  
               a01_infnfe.situacao    = plani.situacao  
               a01_infnfe.solicitacao = plani.solicitacao  
               a01_infnfe.Aguardando  = plani.Aguardando  
               a01_infnfe.TEmite      = plani.TEmite  
               a01_infnfe.TDesti      = plani.TDesti. 
        */
    end.
    
    do on error undo.
        find current plani.
        ASSIGN 
             plani.datexp    = today
             plani.emite  = 22
             plani.serie  = "1"
             plani.PlaDat    = date(emissao) 
             plani.dtinclu   = plani.pladat
             plani.ICMS      = dec(tt.ICMS_BASE)  
             plani.platot = dec(tt.valor_total) / 100.
             message dec(tt.valor_total) / 100000 plani.platot
                    plani.pladat.  pause 0.
             assign
             plani.BSubst    = dec(ICMS_BASE)     .
             /*
             plani.ICMSSubst = tt.ICMSSubst */
             plani.BIPI      = dec(IPI_VALOR)      .
/*             plani.AlIPI     = tt.AlIPI */
             plani.IPI       = dec(tt.IPI)               .
             plani.Seguro    = dec(tt.Seguro)             .
             plani.Frete     = dec(tt.Frete)
             .

        ASSIGN                      /*
            plani.DesAcess  = tt.DesAcess
            plani.DescProd  = tt.DescProd 
            plani.AcFProd   = tt.AcFProd 
            plani.ModCod    = tt.ModCod 
            plani.AlICMS    = tt.AlICMS 
            plani.Outras    = tt.Outras 
            plani.AlISS     = tt.AlISS 
            plani.BICMS     = tt.BICMS 
            plani.UFEmi     = tt.UFEmi 
            plani.BISS      = tt.BISS 
            plani.CusMed    = tt.CusMed 
            plani.UserCod   = tt.UserCod     
            plani.DtInclu   = date(recebimento)
                                      */   /*
            plani.HorIncl   = tt.HorIncl     */
            plani.NotSit    = no
/*            plani.NotFat    = tt.NotFat */
/*            plani.HiCCod    = tt.HiCCod */
/*            plani.NotObs[1] = tt.NotObs[1] 
            plani.NotObs[2] = tt.NotObs[2] 
            plani.NotObs[3] = tt.NotObs[3] */ .
                                    
/*               plani.RespFre   = tt.RespFre*/
/*               plani.NotTran   = tt.NotTran */
/*               plani.Isenta    = tt.Isenta */
/*               plani.ISS       = tt.ISS */
/*               plani.NotPis    = tt.NotPis */
/*               plani.NotAss    = tt.NotAss */
/*               plani.NotCoFinS = tt.NotCoFinS */
/*               plani.TMovDev   = tt.TMovDev */
               
               plani.Desti     = depara_clifor.codigo .
               
                        /*
               plani.IndEmi    = tt.IndEmi       */
               
                            /*
               plani.NotPed    = tt.NotPed   */
               
               plani.OpCCod    = int(opcom.OpCCod)          .
               plani.UFDes     = tt.chave_nfe /*"RS"*/                  .
               plani.ProTot    = dec(tt.valor_total) / 100.
               plani.datexp    = plani.pladat.
        disp plani.etbcod
            plani.emite
            plani.desti
            plani.serie
            plani.numero
            plani.pladat
            plani.dtinclu.    pause 0.
    find depara_estab where depara_estab.filial = depara_clifor.nome_clifor
                    no-error.
    if avail depara_estab
    then plani.desti = depara_estab.etbcod.
    END.
    /*
    QTDE_ITEM = replace(QTDE_ITEM,",",".").*/

    def var vprocod as int.
    vprocod = 0.
    def var x as char.
    x = "".
    def var v as int.
    do v = 1 to 40.
        if substr(CODIGO_ITEM,v,1) = "." 
        then next.
        x = x + substr(CODIGO_ITEM,v,1).
    end.
    vprocod = int(x) no-error. 
    
    def var vos as char.
    vos = "". 
    def var vlength as int.
    if vprocod = 0 
    then do. 
        if descricao_item matches "*O.S.:*" 
        then do. 
            do v = 1 to 90. 
                if substr(descricao_item,v,5) = "O.S.:" 
                then do. 
                    vos = trim(substr(descricao_item,v + 5,35)). 
                    vlength = length(trim(substr(descricao_item,v + 5,35))).
                    vprocod = int(substr(codigo_item,vlength + 1)).
                    /***
                    message vos "#" vlength "#"
                            int(substr(codigo_item,vlength + 1))
                            "##"
                            codigo_item
                            "###" vprocod
                            .****/
                    leave. 
                end.  
            end. 
        end. 
    end. 
             
            
    
    find movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.procod = vprocod
                     no-error.
    if not avail movim
    then do.
        create movim.
        assign movim.etbcod = plani.etbcod
               movim.placod = plani.placod
               movim.procod = vprocod. 
    end.
    def var vmaterial as log.
    vmaterial = yes.
    if vmaterial
    then do.
        find first movimaux where movimaux.etbcod      = movim.etbcod AND
                                  movimaux.placod      = movim.placod AND
                                  movimaux.procod      = movim.procod AND
                                  movimaux.nome_campo  = "MATERIAL"
                                  no-error.
        if not avail movimaux
        then  create movimaux.
        do.
            ASSIGN movimaux.movtdc      = movim.movtdc 
                   movimaux.etbcod      = movim.etbcod 
                   movimaux.placod      = movim.placod 
                   movimaux.procod      = movim.procod 
                   movimaux.nome_campo  = "MATERIAL"
                   movimaux.valor_campo = replace(PRECO_UNITARIO , "," , "." )
                   movimaux.tipo_campo  = "LINX"
                   movimaux.datexp      = today
                   movimaux.exportar    = no.
        end.
        find prodnewfree where prodnewfree.procod = vprocod no-error.
        def var vCLASSIF_FISCAL as char.
        vCLASSIF_FISCAL = replace(CLASSIF_FISCAL,".","").
        if not avail prodnewfree
        then create prodnewfree.
        ASSIGN prodnewfree.procod    = vprocod              .
               prodnewfree.corcod    = ?                    .
/*prodnewfree.protam    = ?*/                               .
               prodnewfree.pronom    = DESCRICAO_ITEM       .
               prodnewfree.pronomc   = DESCRICAO_ITEM       . 
               prodnewfree.codfis    = dec(vCLASSIF_FISCAL) no-error       .                
               prodnewfree.itecod    = vprocod.
               
        ASSIGN 
               prodnewfree.proindice = ?.
    end.                     
    vmovqtm = 0.
    vmovpc = 0.
    
    /*
    PRECO_UNITARIO = replace(PRECO_UNITARIO , "," , "." ).
    */

    VALOR_ITEM = replace(VALOR_ITEM , "," , "." ).
    vmovqtm = movim.movqtm + (dec(QTDE_ITEM) / 1000).
    if movim.movpc > 0
    then vmovpc  = (movim.movpc * movim.movqtm) + dec(VALOR_ITEM).
    else vmovpc  = dec(VALOR_ITEM) .
    
    ASSIGN movim.movtdc    = plani.movtdc 
           movim.movseq    = int(ITEM_NFE1)
           /*movim.movqtm    = vmovqtm
           movim.movpc     = vmovpc / vmovqtm no-error 
           */
           movim.movqtm    = (dec(QTDE_ITEM) / 1000)
           movim.movpc     = (dec(PRECO_UNITARIO) / 100000) 
           no-error.
           /*
           movim.movpc     = dec(VALOR_ITEM) / movim.movqtm no-error.
           */
    /*assign
        movim.movqtm = vmovqtm
        movim.movpc     = vmovpc / vmovqtm
        .*/    
    if IMPOSTO = "ICM"
    then assign
            movim.movbicms  = /*movim.movbicms +*/ vBASE_IMPOSTO
            movim.MovICMS   = /*movim.movbicms +*/ vVALOR_IMPOSTO
            movim.MovAlICMS = vTAXA_IMPOSTO.

    if IMPOSTO = "IPI"
    then assign
            movim.MovAlIPI = vTAXA_IMPOSTO.

    assign
/*           movim.MovDev    = plani.MovDev */
/*           movim.MovAcFin  = plani.MovAcFin */
/*           movim.movipi    = plani.movipi */
/*           movim.MovPro    = plani.MovPro */
/*           movim.MovICMS   = plani.MovICMS */
/*           movim.MovAlICMS = plani.MovAlICMS */
/*           movim.MovPDesc  = plani.MovPDesc   */
/*           movim.MovCtM    = plani.MovCtM  */
/*           movim.MovAlIPI  = plani.MovAlIPI */
           movim.movdat    = plani.pladat 
/*           movim.MovHr     = plani.MovHr */
/*           movim.MovDes    = plani.MovDes */
/*           movim.MovSubst  = plani.MovSubst*/ .
/*    ASSIGN movim.OCNum[1]  = plani.OCNum[1] 
           movim.OCNum[2]  = plani.OCNum[2] 
           movim.OCNum[3]  = plani.OCNum[3] 
           movim.OCNum[4]  = plani.OCNum[4] 
           movim.OCNum[5]  = plani.OCNum[5] 
           movim.OCNum[6]  = plani.OCNum[6] 
           movim.OCNum[7]  = plani.OCNum[7] 
           movim.OCNum[8]  = plani.OCNum[8] 
           movim.OCNum[9]  = plani.OCNum[9]   */
    assign           
           movim.datexp    = plani.datexp 
           movim.Emite     = plani.Emite 
           movim.Desti     = plani.Desti 
           movim.datexp     = movim.movdat.

    find first movimaux where movimaux.etbcod      = movim.etbcod AND 
                              movimaux.placod      = movim.placod AND
                              movimaux.procod      = movim.procod AND
                              movimaux.nome_campo  = "BICMS"
                                  no-error.
    if not avail movimaux 
    then  create movimaux. 
    do. 
        ASSIGN movimaux.movtdc      = movim.movtdc  
               movimaux.etbcod      = movim.etbcod  
               movimaux.placod      = movim.placod  
               movimaux.procod      = movim.procod  
               movimaux.nome_campo  = "BICMS"       
               movimaux.valor_campo = string(vBASE_IMPOSTO) 
               movimaux.tipo_campo  = "LINX"        
               movimaux.datexp      = today         
               movimaux.exportar    = no.
    end.

    
    run estoque (input recid(movim)).    
    run icms.
    
end.
input close.                 


procedure estoque.
        def input parameter par-mov as recid.
        find movim where recid(movim) = par-mov no-lock.
        def buffer xestoq for estoq.
        find first xestoq where xestoq.procod = movim.procod no-lock no-error.
        if  avail xestoq
        then do.
            find first movimaux where movimaux.etbcod      = plani.etbcod and
                                      movimaux.placod      = plani.placod and
                                      movimaux.procod      = movim.procod and
                                      movimaux.nome_campo  = "ATUEST"     and
                                      movimaux.valor_campo = "SIM"
                                      no-lock no-error.
            if not avail movimaux 
            then do. 
                disp pladat numero serie movim.procod.
                                        pause 0.
                run /admcom/progr/atuest.p (input recid(movim), 
                              input "I",    
                              input 0). 
                do on error undo. 
                    create movimaux. 
                    assign movimaux.etbcod      = plani.etbcod 
                           movimaux.placod      = plani.placod 
                           movimaux.procod      = movim.procod 
                           movimaux.nome_campo  = "ATUEST"     
                           movimaux.valor_campo = "SIM" 
                           movimaux.movtdc      = plani.movtdc 
                           movimaux.tipo_campo  = "LINX" 
                           movimaux.datexp      = today 
                           movimaux.exportar    = no. 
                    
                    if plani.movtdc = 6 
                    then for each estoq where estoq.procod = movim.procod.
                            estoq.estcusto = movim.movpc.
                         end.
                end. 
            end. 
        end.
end procedure.            

                 
procedure icms.
do on error undo.
    def buffer bplani for plani.
    find bplani where bplani.etbcod = movim.etbcod and 
                      bplani.placod = movim.placod  .
    bplani.bicms = 0.
    bplani.icms  = 0. 
    def buffer bmovim for movim. 
    for each bmovim where bmovim.etbcod = bplani.etbcod and 
                          bmovim.placod = bplani.placod
                          no-lock.
        bplani.icms = bplani.icms + bmovim.movicms.
    end. 
end.
end procedure.
                          


procedure cancela.
    do on error undo.
        def var c-placod as char format "x(20)".
        def var vplacod like plani.placod.

        c-placod = "55" + string(int(tt.NF_SAIDA),"9999999").
        vplacod = int(c-placod).
        find plani where plani.etbcod = 22 and
                         plani.placod = vplacod
                         no-error.
        if avail plani and plani.modcod <> "CAN"
        then do.
            message "cancelando"
                        chave
                        . pause 1.
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod:
                run /admcom/progr/atuest.p (input recid(movim),
                              input "E",
                              input 0).
            end.
            plani.modcod = "CAN".
            find planiaux where planiaux.etbcod = plani.etbcod and
                                 planiaux.emite  = plani.emite and
                                 planiaux.serie = plani.serie and
                                 planiaux.numero = plani.numero and
                                 planiaux.nome_campo = "SITUACAO" AND
                                 planiaux.valor_campo = "CANCELADA"
                                 NO-LOCK no-error.
            if not avail planiaux
            THEN DO:
                create planiaux.
                assign
                    planiaux.etbcod = plani.etbcod 
                    planiaux.placod = plani.placod
                    planiaux.emite  = plani.emite 
                    planiaux.serie = plani.serie 
                    planiaux.numero = plani.numero 
                    planiaux.nome_campo = "SITUACAO" 
                    planiaux.valor_campo = "CANCELADA"
                    .
            END.
        end.
    end.
end procedure.
