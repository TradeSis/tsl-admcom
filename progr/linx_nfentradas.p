def input parameter par-arq as char.

/*
par-arq = "/admcom/nfe/linx/NF_ENTRADA_14122013.csv".
*/


pause 0 before-hide.
def buffer bplani for plani.
def temp-table tt-plani like plani.

def temp-table tt 
  field  NOME_CLIFOR as char 
  field  NF_ENTRADA as char 
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
  field  TRANSF_FILIAL as char 
  field  DEVOLUCAO as char 
  field  NF_ENTRADA_PROPRIA as char 
  field  FRETE_A_PAGAR as char 
  field  NF_ENTRADA_CONHECIMENTO as char 
  field  DATA_DIGITACAO as char 
  field  VALOR_ADICIONAL as char 
  field  SERIE_NF_ENTRADA as char 
  field  EMPRESA as char 
  field  ICMS_ISENTO as char 
  field  ICMS_OUTROS as char 
  field  PORC_DESCONTO as char 
  field  PORC_ENCARGO as char 
  field  VALOR_IMPOSTO_AGREGAR as char 
  field  VALOR_SUB_ITENS as char 
  field  ITEM_DIGITADO as char 
  field  DESCONTO_BRUTO as char 
  field  ESPECIE_SERIE as char 
  field  NOTA_CANCELADA as char 
  field  DATA_CANCELAMENTO as char 
  field  COD_CLIFOR_SACADO as char 
  field  CHAVE_NFE as char 
  field  PROTOCOLO_AUTORIZACAO_NFE as char 
  field  DATA_AUTORIZACAO_NFE as char 
  field  PROTOCOLO_CANCELAMENTO_NFE as char 
  field  STATUS_NFE as char 
  field  MOTIVO_CANCELAMENTO_NFE as char 
  field  ITEM_NFE as char 
  field  CLASSIF_FISCAL as char 
  field  CODIGO_FISCAL_OPERACAO as char 
  field  CODIGO_ITEM as char 
  field  DESCONTO_ITEM as char 
  field  DESCRICAO_ITEM as char 
  field  ITEM_IMPRESSAO as char 
  field  PRECO_UNITARIO as char 
  field  QTDE_DEVOLVIDA as char 
  field  QTDE_ITEM as char 
  field  UNIDADE as char 
  field  VALOR_ITEM as char 
  field  REFERENCIA as char 
  field  VALOR_ENCARGOS as char 
  field  VALOR_DESCONTOS as char 
  field  PORC_ITEM_RATEIO_FRETE as char 
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

if date(recebimento) < 09/01/2012
then next.

BASE_IMPOSTO  = replace(BASE_IMPOSTO , "," , "." ).
TAXA_IMPOSTO  = replace(TAXA_IMPOSTO , "," , "." ).
VALOR_IMPOSTO = replace(VALOR_IMPOSTO , "," , "." ).
tt.frete      = replace(tt.frete , "," , "." ).

    disp    
        filial                         /* etbcod*/ format "x(30)"
        nome_clifor                    /* nome clifor  */ format "x(30)"
        serie_nf                       /* serie nf */
        NF_ENTRADA
        recebimento                    /* dtinclu  */
        emissao                        /* pladat*/
        qtde_total                     /* qtd total movins*/
            dec(qtde_total) / 1000
                    
        valor_total                    /* platot   */
            dec(valor_total) / 100000
        data_digitacao                 /* dtinclu  */
        
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
        
vBASE_IMPOSTO = dec(BASE_IMPOSTO).
vTAXA_IMPOSTO = dec(TAXA_IMPOSTO)  .
vVALOR_IMPOSTO = dec(VALOR_IMPOSTO).
disp
BASE_IMPOSTO TAXA_IMPOSTO VALOR_IMPOSTO IMPOSTO      
        
    vBASE_IMPOSTO 
    vTAXA_IMPOSTO
    vVALOR_IMPOSTO
        
        with 4 column 1 down.


    find opcom where opcom.opccod = CODIGO_FISCAL_OPERACAO NO-LOCK no-error.

    if not avail opcom
    then find opcom where 
            opcom.opccod = string(int(CODIGO_FISCAL_OPERACAO) - 1000)
                                    NO-LOCK no-error.
    if not avail opcom
    then find opcom where 
                opcom.opccod = string(int(CODIGO_FISCAL_OPERACAO) + 1000)
                                    NO-LOCK no-error.    

    disp avail opcom.    

    if not avail opcom
    then next.

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
    then do.
        pause 222.
        next.
    end.
    if depara_estab.etbcod = ?
    then do.
        pause 333.
        next.
    end.    
    find plani where plani.etbcod = 22                      and
                     plani.movtdc = opcom.movtdc            and
                     plani.emite  = depara_clifor.codigo    and
                     plani.serie  = tt.serie_nf             and
                     plani.numero = int(tt.NF_ENTRADA)
                     no-lock no-error.
    if not avail plani
    then do.
        def var vplacod like plani.placod.
        do on error undo.
            find last bplani where bplani.etbcod = 22      and 
                                   bplani.placod <= 500000 and  
                                   bplani.placod <> ? no-lock no-error.
            if not avail bplani 
            then vplacod = 1. 
            else vplacod = bplani.placod + 1.
        end.     
        create plani.
        assign
            plani.PlaCod    = vplacod
            plani.etbcod = 22
            plani.movtdc = opcom.movtdc       
            plani.emite  = depara_clifor.codigo
            plani.serie  = tt.serie_nf         
            plani.numero = int(tt.NF_ENTRADA)  . 
    
        create tt-plani.
        buffer-copy plani to tt-plani.
        
    end.
    do on error undo.
        find current plani.
        ASSIGN 
             plani.datexp    = today
             plani.PlaDat    = date(emissao) 
             plani.ICMS      = dec(tt.ICMS_BASE)  
             plani.platot = dec(tt.valor_total) / 100000.
             message dec(tt.valor_total) / 100000 plani.platot
                    plani.pladat.
         assign
             plani.BSubst    = dec(ICMS_BASE)
             /*
             plani.ICMSSubst = tt.ICMSSubst */
             plani.BIPI      = dec(IPI_VALOR)
/*             plani.AlIPI     = tt.AlIPI */
             plani.IPI       = dec(tt.IPI)
             plani.Seguro    = dec(tt.Seguro)
             plani.Frete     = dec(tt.Frete)
             plani.modcod   = "DUP"
             plani.horincl  = time
             plani.hiccod   = plani.opccod.
        
        ASSIGN                      /*
            plani.DesAcess  = tt.DesAcess
            plani.DescProd  = tt.DescProd 
            plani.AcFProd   = tt.AcFProd 
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
        assign               
               plani.Desti     = 22
               /* plani.IndEmi    = tt.IndEmi       */
               /* plani.NotPed    = tt.NotPed   */
               plani.OpCCod    = int(opcom.OpCCod)
               plani.UFDes     = tt.chave_nfe /*"RS"*/
               plani.ProTot    = dec(tt.valor_total) / 100000 - plani.frete
               plani.datexp    = plani.dtinclu.

        disp plani.etbcod
            plani.emite
            plani.desti
            plani.serie
            plani.numero
            plani.pladat
            plani.dtinclu.  
    END.
    /*
    QTDE_ITEM = replace(QTDE_ITEM,",",".").*/

    def var vprocod as int.
    def var x as char.
    x = "".
    def var v as int.
    do v = 1 to 40.
        if substr(CODIGO_ITEM,v,1) = "." 
        then next.
        x = x + substr(CODIGO_ITEM,v,1).
    end.
    def var vmovseq like movim.movseq.
    vprocod = int(x). 
    vmovseq = int(ITEM_NFE1). 
    vprocod = int(string(vmovseq ) + string(vprocod,"99999999")).
    /* nova logica para produto */
    vprocod = 0.
    x = "".             do v = 1 to 40.
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
    vprocod = dec(string(vmovseq) + string(vprocod)).
    find produ where produ.procod = vprocod no-lock no-error. 
    if avail produ
    then
        vprocod = dec(string(vmovseq * 10) + string(vprocod)).
    /*                          */
    
    
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
        ASSIGN prodnewfree.procod    = vprocod                       .
               prodnewfree.pronom    = DESCRICAO_ITEM                .
               prodnewfree.pronomc   = DESCRICAO_ITEM                .
               prodnewfree.codfis    = dec(vCLASSIF_FISCAL) no-error.
               prodnewfree.itecod    = vprocod.                     .
               
        ASSIGN 
               prodnewfree.proindice = ?.
    end.                     
    /*
    PRECO_UNITARIO = replace(PRECO_UNITARIO , "," , "." ).
    */
    VALOR_ITEM = replace(VALOR_ITEM , "," , "." ).
    tt.PORC_ITEM_RATEIO_FRETE = replace(tt.PORC_ITEM_RATEIO_FRETE,",","." ).
    ASSIGN movim.movtdc  = plani.movtdc 
           movim.movseq  = int(ITEM_NFE1)
           movim.movqtm  = dec(QTDE_ITEM) / 1000
           movim.movpc   = dec(PRECO_UNITARIO) / 100000 no-error.
           movim.movpc   = dec(VALOR_ITEM) / movim.movqtm no-error.
           movim.movdev  = 0.
           /*movim.movdev  = plani.frete * dec(tt.PORC_ITEM_RATEIO_FRETE) 
           / 100*/.
           
/*           if dec(tt.PORC_ITEM_RATEIO_FRETE) > 100
           then do. message tt.PORC_ITEM_RATEIO_FRETE.
           pause. end.*/

if IMPOSTO = "ICMS"
then
    assign
        movim.movbicms  = vBASE_IMPOSTO
        movim.MovICMS   = vVALOR_IMPOSTO
        movim.MovAlICMS = vTAXA_IMPOSTO.

if IMPOSTO = "IPI"
then assign
        movim.MovAlIPI = vTAXA_IMPOSTO.

if IMPOSTO = "PIS"
then assign
        movim.movbpiscof = vBASE_IMPOSTO
        movim.movpis     = vVALOR_IMPOSTO
        movim.movalpis   = vTAXA_IMPOSTO.

if IMPOSTO = "COFINS"
then assign
        movim.movbpiscof  = vBASE_IMPOSTO
        movim.movcofins   = vVALOR_IMPOSTO
        movim.movalcofins = vTAXA_IMPOSTO.

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
           movim.Desti     = plani.Desti .

    run icms.

end.
input close.                 

find first tt-plani no-error.
if avail tt-plani
then run difereate1.                 

procedure icms.

do on error undo.
    def buffer bplani for plani.
    def buffer bmovim for movim. 

    find bplani where bplani.etbcod = movim.etbcod and 
                      bplani.placod = movim.placod.
    assign
        bplani.bicms  = 0
        bplani.icms   = 0
        bplani.notpis = 0
        bplani.notcofins = 0. 
    for each bmovim where bmovim.etbcod = bplani.etbcod and 
                          bmovim.placod = bplani.placod
                    no-lock.
        assign
            bplani.icms   = bplani.icms  + bmovim.movicms
            bplani.bicms  = bplani.bicms + bmovim.movbicms
            bplani.notpis = bplani.notpis + bmovim.movpis
            bplani.notcofins = bplani.notcofins + movim.movcofins.
    end. 
end.
end procedure.

procedure difereate1.
    def var vtotal as dec.
    def var vdifer as dec.
    for each tt-plani where tt-plani.numero > 0 no-lock,
        first plani where plani.etbcod = tt-plani.etbcod   and
                          plani.movtdc = tt-plani.movtdc   and
                          plani.emite  = tt-plani.emite    and
                          plani.serie  = tt-plani.serie    and
                          plani.numero = tt-plani.numero
                          no-lock:
        vtotal = 0.
        for each movim where
             movim.etbcod = plani.etbcod and
             movim.placod = plani.placod and
             movim.movtdc = plani.movtdc
             no-lock:
            vtotal = vtotal + (movim.movpc * movim.movqtm).
        end.
        vdifer = plani.platot - vtotal.
        if vdifer > 0 and vdifer  < 1
        then do:
            vtotal = 0. 
            for each movim where
                movim.etbcod = plani.etbcod and
                movim.placod = plani.placod and
                movim.movtdc = plani.movtdc
                no-lock:
                vtotal = vtotal + (movim.movpc * movim.movqtm).
                if 0.0001 * movim.movqtm <= vdifer
                then do:
                    vtotal = vtotal + (0.0001 * movim.movqtm).
                    vdifer = vdifer - (0.0001 * movim.movqtm).
                end.   
            end.
        end.
    end.
end procedure. 
