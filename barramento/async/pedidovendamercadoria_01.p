/* helio 13022023 - Projeto Cupom b2b - Grava retorno do Desconto. */

DEFINE INPUT  PARAMETER lcJsonEntrada      AS LONGCHAR.
def    output param     verro as char no-undo.
verro = "".
def var vcupomb2b as int.

def var vecommerce as log init no.
def var tiposervico as char.
def var vtpseguro  as int.

def var vctmcod  like pdvmov.ctmcod.
def var vmodcod  like contrato.modcod initial "".

def var vdatamov as date. /* 01.12.2017 */
def var vnsu     as int.

def var vseq    as int.
def var vprocod like pdvmovim.procod.
def var vmovdes like pdvmovim.movdes. /* #1 */
def var vmovpc  like pdvmovim.movpc.  /* #1 */
def var vmovqtm like pdvmovim.movqtm. /* #1 */
def var vcodigo_forma  as char. 
def var vtitpar as int.
def var vi as int.
def var vmes as int.
def var vano as int.
def var vdia as int.
def var vvenc as date.
def var vseqforma as int.
def var vseqfp as int.
def var vtitvlcob as dec.
def var vultima as dec.
def var vtotal as dec.
def var vtotalsemjuros as dec.
def var vtitvlcobsemjuros as dec.
def var par-ser as char.

def var par-num  as int.
def var vplacod  like plani.placod.
def var vmovtdc  as int init 5. 
def var vvencod  as int.
def var vmovseq  as int.
def var vvalor_vista as dec.
def var vvalor_contrato as dec.

def temp-table tt-movim no-undo like pdvmovim
    field movdes-combo as dec
    field desc-cam      like movim.desc-cam
    field desc-crm      like movim.desc-crm
    field nrobonus-crm like movim.nrobonus-crm /**/
    field desc-man      like movim.desc-man
    field desc-total      like movim.desc-total.

{/admcom/barramento/functions.i}
{/admcom/barramento/async/pedidovendamercadoria_01.i}

/* LE ENTRADA */
lokJSON = hpedidovendamercadoriaEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").

/**def var vsaida as char.
find first ttpedidovendamercadoria.        
vsaida = "./json/pedidovenda/" + trim(ttpedidovendamercadoria.tipo) + "_" 
                           + trim(ttpedidovendamercadoria.codigoLoja)  + "_"
                           + trim(ttpedidovendamercadoria.dataTransacao) + "_"
                           + trim(ttpedidovendamercadoria.numeroComponente) + "_"
                           + trim(ttpedidovendamercadoria.nsuTransacao) + "_"
                           + "pedidovendamercadoria.json".
**hpedidovendamercadoriaEntrada:WRITE-JSON("FILE",vsaida, true).
**/


for each ttpedidovendamercadoria.

    /*
    field chavePedidoExterno as char 
    field chaveNotaExterno as char 
    field dataEmissao as char 
    field ecf as char 
    field statusNFce as char 
    field mensagemCorpoNotaFiscal as char 
    field mensagemDadosAdicionais as char 
    field valorTotalBruto as char          /
    field valorTotalLiquido as char 
    field descontos as char 
    field valorMercadorias as char 
    field valorServicos as char 
    field valorMercadoriasServicos as char 
    field valorEncargos as char 
    field optouNFPaulista as char 
    */

    vctmcod  = "10".
    vdatamov = aaaa-mm-dd_todate(ttpedidovendamercadoria.dataTransacao).
    vnsu     = int(ttpedidovendamercadoria.nsuTransacao).

    find cmon where
            cmon.etbcod = int(ttpedidovendamercadoria.codigoLoja) and
            cmon.cxacod = int(ttpedidovendamercadoria.numeroComponente)
            no-lock no-error.

    if not avail cmon 
    then do on error undo: 
        create cmon. 
        assign 
            cmon.cmtcod = "PDV" 
            cmon.etbcod = int(ttpedidovendamercadoria.codigoLoja)
            cmon.cxacod = int(ttpedidovendamercadoria.numeroComponente)
            cmon.cmocod = int(string(cmon.etbcod) + string(cmon.cxacod,"999")) 
            cmon.cxanom = "Lj " + string(cmon.etbcod) + " " + 
                          "Cx " + string(cmon.cxacod). 
    end.
                                          
                                          
    find first pdvmov where
        pdvmov.etbcod = cmon.etbcod and
        pdvmov.cmocod = cmon.cmocod and
        pdvmov.datamov = vdatamov and
        pdvmov.sequencia = vnsu and
        pdvmov.ctmcod = vctmcod and
        pdvmov.coo    = int(ttpedidovendamercadoria.numero)
        no-error.
    if not avail pdvmov
    then do:            
        create pdvmov.
        pdvmov.etbcod = cmon.etbcod.
        pdvmov.cmocod = cmon.cmocod.
        pdvmov.datamov = vdatamov.
        pdvmov.sequencia = vnsu.
        pdvmov.ctmcod = vctmcod.
        pdvmov.coo    = int(ttpedidovendamercadoria.numero).
    end.        
    else do:
        verro = "JA INCLUIDO".
        return.
    end.    
    

    pdvmov.valortot   = if dec(valorTotalAPrazo) = 0
                        then dec(valorTotalLiquido)
                        else dec(valorTotalAPrazo).
    pdvmov.valortroco = dec(ttpedidovendamercadoria.valortroco).

    pdvmov.codigo_operador = /*ITEM?*/ ?.
        
    pdvmov.HoraMov    = hora_totime(horaTransacao).
    pdvmov.EntSai     = yes.
    pdvmov.statusoper = ttpedidovendamercadoria.tstatus.
/*    pdvmov.tipo_pedido = int(ora-coluna("tipo_pedido")).  */

    if ttpedidovendamercadoria.tstatus <> "100"
    then return.
    
    find first pdvdoc of pdvmov where pdvdoc.seqreg = 1 no-error.
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
            pdvdoc.seqreg    = 1
            /*pdvdoc.titcod    = ?*/ .
    end.    
    pdvdoc.valor        = pdvmov.valortot.
    pdvdoc.tipo_venda   = 9. /* Padrao venda int(ora-coluna("tipo_venda")). */
    pdvdoc.numero_pedido = int(ttpedidovendamercadoria.numero). 
    vnumeroPedido = ttpedidovendamercadoria.numero.

    if pdvdoc.tipo_venda = 7 /* 7.Cancelamento de cupom fiscal no recebimento*/
    then assign
            pdvmov.EntSai     = ?
            pdvmov.statusoper = "CAN".
    else if pdvdoc.tipo_venda = 4
    then assign
            pdvmov.EntSai     = ?
            pdvmov.statusoper = "ANU".   
    else if pdvdoc.tipo_venda = 5 or
            pdvdoc.tipo_venda = 13
    then assign     
            pdvmov.EntSai     = no
            pdvmov.statusoper = "DEV".   
    else if pdvdoc.tipo_venda = 6
    then assign
            pdvmov.EntSai     = no
            pdvmov.statusoper = "TRO".   
    
     
    find first ttcliente where ttcliente.idpai = ttpedidovendamercadoria.id no-error.
    if avail ttcliente
    then do:
        /*
        field tipoCliente as char 
        field codigoCliente as char 
        field cpfCnpj as char 
        field nome as char 
        */
        pdvdoc.clifor         = dec(ttcliente.codigoCliente) no-error.
        
        /*delete ttcliente.*/
        
    end.        
    /* Lebes pega consumidor final */
    if pdvdoc.clifor = ? or pdvdoc.clifor = 0
    then pdvdoc.clifor = 1.

    /*
    pdvdoc.tipo_desc_sub   = ora-coluna("tipo_desconto_sub_total").
    pdvdoc.valor_desc_sub  = dec(ora-coluna("valor_desconto_sub_total")).
    */
    
    for each ttitens where ttitens.idpai = ttpedidovendamercadoria.id.

        /*
        field unidadeVenda as char 
        field montagem as char 
        field valorUnitarioPadrao as char 
        field valorTotal as char 
        field mercadologico as char 
        field codigoOperador as char 
        field indComposto as char 
        field serial as char 
        field custoUnitario as char 
        field pedidoEspecial as char 
        field obsPedidoEspecial as char 
        field formaEntrega as char 
        field lojaEntrega as char 
        field embalagemPresente as char 
        field brinde as char 
        */
    
        vseq    = int(ttitens.sequencial).
        vprocod = int(codigoLegado).
        vmovqtm = dec(quantidade).
        vmovpc  = dec(valorUnitario) .
        vmovdes = dec(valorTotalDesconto).
        find pdvmovim where pdvmovim.etbcod    = pdvdoc.etbcod and
                            pdvmovim.cmocod    = pdvdoc.cmocod and
                            pdvmovim.datamov   = pdvdoc.datamov and
                            pdvmovim.sequencia = pdvdoc.sequencia and
                            pdvmovim.ctmcod    = pdvdoc.ctmcod and
                            pdvmovim.coo       = pdvdoc.coo and
                            pdvmovim.seqreg    = pdvdoc.seqreg and
                            pdvmovim.movseq    = vseq
                      exclusive no-error.
        if not avail pdvmovim
        then do.
            create pdvmovim.
            assign
                pdvmovim.etbcod    = pdvdoc.etbcod
                pdvmovim.cmocod    = pdvdoc.cmocod
                pdvmovim.datamov   = pdvdoc.datamov
                pdvmovim.sequencia = pdvdoc.sequencia
                pdvmovim.ctmcod    = pdvdoc.ctmcod
                pdvmovim.coo       = pdvdoc.coo
                pdvmovim.seqreg    = pdvdoc.seqreg
                pdvmovim.movseq    = vseq.
        end.                 
        assign
            pdvmovim.procod    = vprocod 
            pdvmovim.movqtm    = vmovqtm 
            pdvmovim.movpc     = vmovpc 
            pdvmovim.movdes    = vmovdes.

            /*
            pdvmovim.movalicms = dec(ora-coluna("COD_TRIBUTACAO")).
            pdvmovim.movicms   = dec(ora-coluna("valor_icms")).
            pdvmovim.movacfin  = dec(ora-coluna("VALOR_ACRESCIMO_ITEM")).
            */
            
            pdvmovim.codigo_imei    = ttitens.imei.

            pdvmovim.vencod         = int(codigoVendedor).

            pdvmovim.dt_prevista_entrega = aaaa-mm-dd_todate(entregaDataFutura).  /*orapegadata(ora-coluna("data_prevista_entrega")).*/
            pdvmovim.dt_pedido_especial  = aaaa-mm-dd_todate(dataPedidoEspecial).

            /*
            pdvmovim.MovDesCampanha = dec(ora-coluna("valor_desconto_campanha")).
            pdvmovim.tipo_desconto = int(ora-coluna("TIPO_DESCONTO")).
            */
            
            /*
            pdvmovim.al_Red_Bc_Efet = dec(ora-coluna("Perc_Red_Bc_Efet")).
            pdvmovim.bc_Icms_Efet = dec(ora-coluna("Val_Red_Bc_Efet")).
            pdvmovim.al_Icms_Efet = dec(ora-coluna("Aliq_Icms_Efet")).
            pdvmovim.vl_Icms_Efet = dec(ora-coluna("Val_Icms_Efet")).
            */

        for each ttcampanhas where ttcampanhas.idpai = ttitens.id.
            /*
            field codigoCampanha as char 
            field seqCampanha as char 
            field tipoCampanha as char 
            field descricao as char 
            */
            /*delete ttcampanhas.*/
        
        end.
        
        /** nao entra no admcom **/
        for each ttgarantias where ttgarantias.idPai = ttitens.id.
            /**
            field descricao as char 
            field prazoGarantiaFornecedor as char 
            **/

            
            find pdvitem-garantia where      
                 pdvitem-garantia.etbcod      = pdvmov.etbcod and
                 pdvitem-garantia.cmocod      = pdvmov.cmocod and
                 pdvitem-garantia.DataMov     = pdvmov.DataMov and
                 pdvitem-garantia.Sequencia   = pdvmov.Sequencia and
                 pdvitem-garantia.ctmcod      = pdvmov.ctmcod and
                 pdvitem-garantia.COO         = pdvmov.COO and
                 pdvitem-garantia.seqproduto  = vseq and 
                 pdvitem-garantia.seqgarantia = int(ttgarantias.seqGarantia)
                no-error.
            if not avail pdvitem-garantia 
            then do: 
                create pdvitem-garantia.
                assign
                    pdvitem-garantia.etbcod      = pdvmov.etbcod
                    pdvitem-garantia.cmocod      = pdvmov.cmocod
                    pdvitem-garantia.DataMov     = pdvmov.DataMov
                    pdvitem-garantia.Sequencia   = pdvmov.Sequencia
                    pdvitem-garantia.ctmcod      = pdvmov.ctmcod
                    pdvitem-garantia.COO         = pdvmov.COO
                    pdvitem-garantia.seqproduto  = vseq
                    pdvitem-garantia.seqgarantia = int(ttgarantias.seqGarantia).
            end.
            assign
                pdvitem-garantia.valorgarantia = dec(ttgarantias.valor).
                pdvitem-garantia.codgarantia   = int(ttgarantias.codigo).
                pdvitem-garantia.dtinigar      = aaaa-mm-dd_todate(ttgarantias.dataInicioGarantia).
                pdvitem-garantia.dtfimgar      = aaaa-mm-dd_todate(ttgarantias.dataFimGarantia).
                pdvitem-garantia.tipogarantia  = ttgarantias.tipo.
                pdvitem-garantia.vlrcusto      = dec(ttgarantias.custoGarantia).
                pdvitem-garantia.tempo         = int(ttgarantias.tempoGarantia).
                pdvitem-garantia.certificado   = ttgarantias.certificado.
                pdvitem-garantia.procod        = vprocod.
                    
        end. 
        /**/
        /* helio 13022023 - Projeto Cupom b2b - Pega retorno do Desconto. */
        for each ttdescontos where ttdescontos.idPai = ttitens.id.
            if ttdescontos.tipoDesconto = "CUPOM_ADMCOM_B2B"
            then do:    
                vcupomb2b = int(ttdescontos.codigoIdentificador) no-error.
                message "CUPOM B2B" ttdescontos.tipoDesconto vcupomb2b pdvmov.datamov.
                find cupomb2b where cupomb2b.idCupom = vcupomb2b exclusive no-wait no-error.
                if avail cupomb2b
                then do:
                    if cupomb2b.nsuTransacao = ? or cupomb2b.nsuTransacao = ""
                    then do:
                        cupomb2b.etbcod             = pdvmov.etbcod.
                        cupomb2b.dataTransacao      = pdvmov.datamov.
                        cupomb2b.numeroComponente   = int(ttpedidovendamercadoria.numeroComponente).
                        cupomb2b.nsuTransacao       = string(pdvmov.sequencia).
                        cupomb2b.clicod             = pdvdoc.clifor.
                        message "                     Atualizado Cliente: " cupomb2b.clicod 
                            cupomb2b.etbcod cupomb2b.dataTransacao cupomb2b.numeroComponente cupomb2b.nsuTransacao.
                    end.
                end.
                 
            end.
        end.
        
        /*delete ttitens.*/
        
    end.
    for each pdvmovim of pdvdoc no-lock.
            if pdvmovim.vencod <> ? and
               pdvmovim.vencod <> 0
            then vvencod = pdvmovim.vencod.

            find first tt-movim where tt-movim.procod = pdvmovim.procod
                                no-error.
            if not avail tt-movim
            then do.
                vmovseq = vmovseq + 1.
                create tt-movim.
                assign
                    tt-movim.procod = pdvmovim.procod
                    tt-movim.movseq = vmovseq
                    tt-movim.movpc  = if pdvmovim.movpc = ? then 0 else pdvmovim.movpc
                    tt-movim.movalicms = pdvmovim.movalicms
                    tt-movim.dt_prevista_entrega = pdvmovim.dt_prevista_entrega
                    tt-movim.dt_pedido_especial  = pdvmovim.dt_pedido_especial
                    tt-movim.tipo_desconto = pdvmovim.tipo_desconto
                    tt-movim.al_Red_Bc_Efet = pdvmovim.al_Red_Bc_Efet
                    tt-movim.al_Icms_Efet   = pdvmovim.al_Icms_Efet.
            end.
            assign
                tt-movim.movqtm   = tt-movim.movqtm + pdvmovim.movqtm
                tt-movim.movdes   = tt-movim.movdes + pdvmovim.movdes
                tt-movim.movacfin = tt-movim.movacfin + pdvmovim.movacfin
                tt-movim.movbicms = tt-movim.movbicms + pdvmovim.movbicms
                tt-movim.movicms  = tt-movim.movicms  + pdvmovim.movicms
                tt-movim.movdescampanha = tt-movim.movdescampanha +
                                    pdvmovim.movdescampanha
                tt-movim.bc_Icms_Efet = tt-movim.bc_Icms_Efet +
                                    pdvmovim.bc_Icms_Efet
                tt-movim.vl_Icms_Efet = tt-movim.vl_Icms_Efet +
                                    pdvmovim.vl_Icms_Efet.

    end.
        
    /* CRIA PLANI */

    find plani where plani.etbcod = pdvdoc.etbcod and
                     plani.placod = pdvdoc.placod 
               NO-LOCK no-error.
    if not avail plani or
       pdvdoc.placod = 0 or
       pdvdoc.placod = ?
    then do:
        run bas/grplanum.p (pdvmov.etbcod, "", output vplacod, output par-num).

        
        if true
        then /*** PEDIDO OUTRA LOJA ***/
            assign
                par-ser = "PEDO"
                par-num = pdvdoc.numero_pedido.
        else 
        if pdvdoc.numero_nfe = 0
        then               
            assign
                par-ser = string(cmon.cxacod)
                par-num = pdvmov.coo.
        else /*** NFCE ***/
            assign
                par-ser = pdvdoc.serie_nfe
                par-num = pdvdoc.numero_nfe.
    end.
    
    do on error undo.  
        create plani. 
        assign 
            plani.placod   = vplacod 
            plani.etbcod   = pdvdoc.etbcod 
            plani.numero   = par-num
            plani.cxacod   = cmon.cxacod 
            plani.emite    = pdvdoc.etbcod 
            plani.vlserv   = 0 /*vdevval */ 
            plani.serie    = par-ser 
            plani.movtdc   = vmovtdc  
            plani.desti    = int(pdvdoc.clifor)  
            plani.dtinclu  = plani.pladat 
            plani.pladat   = pdvmov.datamov 
            plani.horincl  = pdvmov.horamov  
            plani.notsit   = no 
            plani.datexp   = today 
                                                                  
            plani.vlserv   = dec(valorServicos)
            plani.protot   = dec(valorMercadorias) 
            plani.acfprod  = dec(valorEncargos)
            plani.descprod = dec(descontos)     /* Informativo */
            plani.platot   = dec(valorMercadoriasServicos)
            plani.biss     = dec(valorTotalAPrazo).
            plani.vencod  =  vvencod. 
            
            /* 
            plani.hiccod = vcfop. 
            */  

            if false /*vpedidoutloj*/
            then .
            else if pdvdoc.numero_nfe = 0 /* Cupom fiscal */
            then assign
                    plani.notped = "C|" + string(pdvmov.coo) + "|" + 
                              string(cmon.cxacod) + "|" 
                              /** + vnser**/
                    /*** plani.ufemi numero de serie ***/.
            else assign /* NFCE ***/
                    plani.notped = "C"
                    plani.ufdes  = pdvdoc.chave_nfe.

            assign
                pdvdoc.placod = plani.placod.

        pdvdoc.pstatus = yes. /* FECHADO */

    end.   
    for each tt-movim.  
        create movim.
        assign 
            movim.movtdc = plani.movtdc 
            movim.etbcod = plani.etbcod 
            movim.placod = plani.placod 
            movim.emite  = plani.emite 
            movim.desti  = plani.desti 
            movim.movdat = plani.pladat 
            movim.movhr  = plani.horincl 
            movim.movseq = tt-movim.movseq 
            movim.procod = tt-movim.procod 
            movim.movpc  = tt-movim.movpc 
            movim.movqtm = tt-movim.movqtm 
            movim.movdes = tt-movim.movdes 
            movim.movacfin  = tt-movim.movacfin 
            movim.movicms   = tt-movim.movicms 
            movim.movalicms = tt-movim.movalicms.   
            movim.desc-cam  = tt-movim.desc-cam.  
            movim.desc-crm  = tt-movim.desc-crm. 
            movim.nrobonus-crm = tt-movim.nrobonus-crm. 
            movim.desc-man  = tt-movim.desc-man. 
            movim.desc-tot  = tt-movim.desc-tot.  
    end.
      
    /** GARANTIAS **/

        for each pdvitem-garantia of pdvmov no-lock.
            
            if pdvitem-garantia.tipogarantia = "R" or
               pdvitem-garantia.tipogarantia = "Y"
            then vtpseguro = 5.
            else if pdvitem-garantia.tipogarantia = "F"
            then vtpseguro = 6.

            find first tt-movim where tt-movim.procod = pdvitem-garantia.procod no-lock.

            find vndseguro where
                              vndseguro.tpseguro = vtpseguro
                          and vndseguro.etbcod   = pdvitem-garantia.etbcod
                          and vndseguro.certifi  = pdvitem-garantia.certificado
                          no-lock no-error.
            if not avail vndseguro
            then do.
                /** deveria vir do barramento 
                plani.seguro = plani.seguro + pdvitem-garantia.valorgarantia.
                **/

                create vndseguro.
                assign
                    vndseguro.tpseguro = vtpseguro
                    vndseguro.certifi  = pdvitem-garantia.certificado
                    vndseguro.etbcod   = /**if ventreoutloj 
                                         then pdvdoc.orig_loja
                                         else*/ pdvitem-garantia.etbcod
                    vndseguro.placod   = /*if ventreoutloj 
                                         then pdvdoc.orig_placod
                                         else */ plani.placod
                    vndseguro.prseguro = pdvitem-garantia.valorgarantia
                    vndseguro.pladat   = plani.pladat
                    vndseguro.dtincl   = plani.pladat
                    vndseguro.movseq   = tt-movim.movseq
                    vndseguro.procod   = pdvitem-garantia.procod
                    vndseguro.clicod   = plani.desti
                 /* vndseguro.codsegur = 9839 /* Fixo */ */
                 /* vndseguro.contnum  = pdvcredseg.contnum */
                    vndseguro.dtivig   = pdvitem-garantia.dtinigar
                    vndseguro.dtfvig   = pdvitem-garantia.dtfimgar
                    vndseguro.vencod   = /*if ventreoutloj /* #6 */
                                         then pdvdoc.orig_vencod
                                         else*/ plani.vencod
                    vndseguro.datexp   = ? /* nao replicar */
                    vndseguro.tempo    = pdvitem-garantia.tempo
                    vndseguro.exportado = yes.            
            
            end.

            find first movim where movim.etbcod = plani.etbcod
                               and movim.placod = plani.placod
                               and movim.procod = pdvitem-garantia.codgarantia
                           no-error.
            if not avail movim 
            then do. 
                vmovseq = vmovseq + 1.  
                create movim. 
                assign
                        movim.etbcod = plani.etbcod
                        movim.placod = plani.placod
                        movim.procod = pdvitem-garantia.codgarantia
                        movim.movseq = vmovseq
                        movim.movtdc = plani.movtdc
                        movim.emite  = plani.emite
                        movim.desti  = plani.desti
                        movim.movdat = plani.pladat
                        movim.movhr  = plani.horincl
                        movim.movalicms = 98 /* #3 */
                        movim.vuncom = 0
                        movim.movctm = 0.
            end. 
            assign
                    movim.movqtm = movim.movqtm + 1
                    movim.vuncom = movim.vuncom + pdvitem-garantia.valorgarantia
                    movim.movctm = movim.movctm + pdvitem-garantia.vlrcusto.
            movim.movpc = movim.vuncom / movim.movqtm. /* vlr.medio */

            
            find first movimseg where movimseg.etbcod = movim.etbcod and
                movimseg.placod  = movim.placod and
                movimseg.seg-movseq = movim.movseq  and
                        movimseg.movseq  = tt-movim.movseq 
                no-lock no-error.
            if not avail movimseg then do:        
                create movimseg.
                assign 
                    movimseg.etbcod  = movim.etbcod 
                    movimseg.placod  = movim.placod 
                    movimseg.seg-movseq = movim.movseq 
                    movimseg.movseq  = tt-movim.movseq 
                    movimseg.movpc   = pdvitem-garantia.valorgarantia 
                    movimseg.movctm  = pdvitem-garantia.vlrcusto 
                    movimseg.certifi = pdvitem-garantia.certificado 
                    movimseg.movdat  = movim.movdat 
                    movimseg.tpseguro = vtpseguro 
                    movimseg.subtipo = pdvitem-garantia.tipogarantia 
                    movimseg.tempo   = pdvitem-garantia.tempo.
            end.            
        end.        
    
    /* RECEBIMENTOS */
    
    {/admcom/barramento/async/recebimentos.i ttpedidovendamercadoria.id}
         
    /* delete ttpedidovendamercadoria */
    
    
end.    



