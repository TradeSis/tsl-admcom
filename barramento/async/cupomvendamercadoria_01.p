/* helio 13022023 - Projeto Cupom b2b - Grava retorno do Desconto. */
/* helio 27042021 - projeto cadastramento cliente na integracao jsin para filial 200 */

DEFINE INPUT  PARAMETER lcJsonEntrada      AS LONGCHAR.
def    output param     verro as char no-undo.
verro = "".
def var vcupomb2b as int.
def var par-clicod like clien.clicod.
def var vecommerce as log.
def buffer ocmon for cmon.
def buffer opdvmov for pdvmov.
def buffer opdvdoc for pdvdoc.
def buffer oplani for plani.
def var vdevolucao as log.
def var vcontnum  as int.
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
{/admcom/barramento/async/cupomvendamercadoria_01.i}

/* LE ENTRADA */
lokJSON = hcupomvendamercadoriaEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").

/**def var vsaida as char.
find first ttcupomvendamercadoria no-error.  
      
message avail ttcupomvendamercadoria.      
if not avail ttcupomvendamercadoria then leave. 

vsaida = "./json/mercadoria/" + trim(ttcupomvendamercadoria.tipo) + "_" + trim(operacao)  
                           + trim(ttcupomvendamercadoria.codigoLoja)  + "_"
                           + trim(ttcupomvendamercadoria.dataTransacao) + "_"
                           + trim(ttcupomvendamercadoria.numeroComponente) + "_"
                           + trim(ttcupomvendamercadoria.nsuTransacao) + "_"
                           + "cupomvendamercadoria.json".
**hcupomvendamercadoriaEntrada:WRITE-JSON("FILE",vsaida, true).
**/

find first ttcupomvendamercadoria no-error.  
def var tiposervico as char.
if trim(operacao) = "DEVOLUCAO" 
then vctmcod = "108".
else if trim(operacao) = "DEVOLUCAO-VT"
     then vctmcod = "27".
     else vctmcod = "10".     

vdevolucao = no.

if vctmcod = "108" or
   vctmcod = "27"
then do:
    vdevolucao = yes.    
    vmovtdc = 12.
end.    

    /* 26/04/2021 - orc - cria cadastro cliente - para ecommerce */

    find first ttcliente where ttcliente.idpai = ttcupomvendamercadoria.id no-error.
    if avail ttcliente
    then do:
        if int(ttcupomvendamercadoria.codigoLoja) = 200 /** ecommerce */
        then do:
            release clien.
            if dec(ttcliente.codigoCliente) <> ? and 
               dec(ttcliente.codigoCliente) <> 0
            then do: 
                find clien where clien.clicod = int64(ttcliente.codigoCliente) no-lock no-error.
            end.     
            if not avail clien 
            then do: 
                find neuclien where neuclien.cpf = dec(ttcliente.cpf) no-lock no-error. 
                if avail neuclien 
                then do: 
                    find clien where clien.clicod = neuclien.clicod no-lock no-error. 
                    if avail clien 
                    then ttcliente.codigoCliente = string(clien.clicod). 
                end.
                else do:
                    find clien where clien.ciccgc = ttcliente.cpf no-lock no-error.
                    if avail clien 
                    then ttcliente.codigoCliente = string(clien.clicod).
                end.
            end.
            
            if not avail clien
            then do:
                run /admcom/progr/p-geraclicod.p (output par-clicod). 
                ttcliente.codigoCliente = string(par-clicod).
                do on error undo. 
                
                    create clien. 
                    assign 
                        clien.clicod = int(ttcliente.codigoCliente) .
                        clien.ciccgc = string(ttcliente.cpf).
                        clien.clinom = string(ttcliente.nome).
                        clien.tippes = ttcliente.tipoCliente = "F".
                        clien.etbcad = int(ttcupomvendamercadoria.codigoLoja). 

                    create neuclien. 
                    neuclien.cpfcnpj = dec(clien.ciccgc).
                    neuclien.tippes  = clien.tippes.
                    neuclien.etbcod  = clien.etbcad.
                    neuclien.dtcad   = today.
                    neuclien.nome_pessoa = clien.clinom.
                    neuclien.clicod = clien.clicod.
                        
                        
                    create cpclien. 
                    assign  
                    cpclien.clicod     = clien.clicod
                    cpclien.var-char11 = ""
                    cpclien.datexp     = today.
                    
                    for each ttendereco where ttendereco.idpai = ttcliente.id.
                        clien.endereco[1]   = caps(ttendereco.rua).
                        clien.numero[1]     = int(ttendereco.numero) no-error.
                        clien.compl[1]      = caps(ttendereco.complemento).
                        clien.bairro[1]     = caps(ttendereco.bairro).
                        clien.cidade[1]     = caps(ttendereco.cidade).
                        clien.ufecod[1]     = caps(ttendereco.uf).
                        clien.cep[1]        = (ttendereco.cep).
                    end.     
                    find first ttcontato no-error.
                    if avail ttcontato
                    then clien.zona = ttcontato.email. 
                    
                    find first tttelefones where tttelefones.tipo = "CELULAR" no-error. 
                    if avail tttelefones
                    then clien.fax = tttelefones.numero.
                    find first tttelefones where tttelefones.tipo <> "CELULAR" no-error. 
                    if avail tttelefones
                    then clien.fone = tttelefones.numero.
                end.
            end.      
        end.
    end.    


for each ttcupomvendamercadoria.

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

    vdatamov = aaaa-mm-dd_todate(ttcupomvendamercadoria.dataTransacao).
    vnsu     = int(ttcupomvendamercadoria.nsuTransacao).

    find cmon where
            cmon.etbcod = int(ttcupomvendamercadoria.codigoLoja) and
            cmon.cxacod = int(ttcupomvendamercadoria.numeroComponente)
            no-lock no-error.

    if not avail cmon 
    then do on error undo: 
        create cmon. 
        assign 
            cmon.cmtcod = "PDV" 
            cmon.etbcod = int(ttcupomvendamercadoria.codigoLoja)
            cmon.cxacod = int(ttcupomvendamercadoria.numeroComponente)
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
        pdvmov.coo    = if int(numeroCupom) = 0 or int(numeroCupom) = ?
                        then int(ttcupomvendamercadoria.numero)
                        else int(numeroCupom)
        no-error.
    if not avail pdvmov
    then do:            
        create pdvmov.
        pdvmov.etbcod = cmon.etbcod.
        pdvmov.cmocod = cmon.cmocod.
        pdvmov.datamov = vdatamov.
        pdvmov.sequencia = vnsu.
        pdvmov.ctmcod = vctmcod.
        pdvmov.coo    = if int(numeroCupom) = 0 or int(numeroCupom) = ? 
                        then int(ttcupomvendamercadoria.numero) 
                        else int(numeroCupom).
    end.        
    else do:
        find first pdvdoc of pdvmov no-lock no-error.
        if avail pdvdoc
        then do: 
            message pdvmov.etbcod cmon.cxacod pdvmov.datamov "NSU" pdvmov.sequencia "NumeroCupom" pdvmov.coo pdvmov.ctmcod.
            verro = "JA INCLUIDO".
            return.
        end.
    end.    
    vecommerce = no.
    if pdvmov.etbcod = 200 or ttcupomVendaMercadoria.canalOrigem = "SITE"
    then do:
        vecommerce = yes.
    end.    
    message pdvmov.etbcod cmon.cxacod pdvmov.datamov "NSU" pdvmov.sequencia "numeroCupom" pdvmov.coo pdvmov.ctmcod ttcupomVendaMercadoria.canalOrigem.

    pdvmov.valortot   = if dec(valorTotalAPrazo) = 0
                        then dec(valorTotalLiquido)
                        else dec(valorTotalAPrazo).
    pdvmov.valortroco = dec(ttcupomvendamercadoria.valortroco).

    pdvmov.codigo_operador = /*ITEM?*/ ?.
        
    pdvmov.HoraMov    = hora_totime(horaTransacao).
    pdvmov.EntSai     = if vctmcod = "10"
                        then yes
                        else no.
    pdvmov.statusoper = tstatus.
/*    pdvmov.tipo_pedido = int(ora-coluna("tipo_pedido")).  */

    if tstatus <> "200"
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
    pdvdoc.tipo_venda   = if vctmcod = "10"
                          then 9
                          else if vctmcod = "108"
                               then 5
                               else 6. /* Padrao venda int(ora-coluna("tipo_venda")). */
                               
    pdvdoc.numero_pedido = int(ttcupomVendaMercadoria.numeroPedido). 
    vnumeroPedido        = ttcupomVendaMercadoria.numeroPedido. 

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
    
     
    find first ttcliente where ttcliente.idpai = ttcupomvendamercadoria.id no-error.
    if avail ttcliente
    then do:
        /*
        field tipoCliente as char 
        field codigoCliente as char 
        field cpfCnpj as char 
        field nome as char 
        */
        pdvdoc.clifor         = dec(ttcliente.codigoCliente) no-error.
    
    end.        
    /* Lebes pega consumidor final */
    if pdvdoc.clifor = ? or pdvdoc.clifor = 0
    then pdvdoc.clifor = 1.

    /*
    pdvdoc.tipo_desc_sub   = ora-coluna("tipo_desconto_sub_total").
    pdvdoc.valor_desc_sub  = dec(ora-coluna("valor_desconto_sub_total")).
    */
    
    assign
        pdvdoc.numero_nfe = int(ttcupomVendaMercadoria.numero)
        pdvdoc.serie_nfe  = ttcupomVendaMercadoria.serie.
        pdvdoc.chave_nfe  = chaveNfce.
/*        pdvdoc.observacao_pedido = ora-coluna("desc_observacao_pedido"). */

        /* devolucao/outras operacoes com origem */

    if vdevolucao
    then do: 
            
        find first ttcupomOrigemVenda.
        
        find ocmon         where ocmon.etbcod    = int(ttcupomOrigemVenda.codigoLoja) and
                                 ocmon.cxacod    = int(ttcupomOrigemVenda.numeroComponente)
                                 no-lock.
        
        find first opdvmov where opdvmov.etbcod  = ocmon.etbcod and
                                 opdvmov.cmocod  = ocmon.cmocod and
                                 opdvmov.datamov = aaaa-mm-dd_todate(ttcupomOrigemVenda.dataTransacao) and
                                 opdvmov.sequencia = int(ttcupomOrigemVenda.nsuTransacao) 
                    no-lock no-error.
        find first opdvdoc of opdvmov where opdvdoc.seqreg = 1 no-lock no-error.
        if avail opdvdoc
        then do: 
            
            find first oplani where oplani.etbcod = opdvdoc.etbcod and
                                    oplani.placod = opdvdoc.placod 
                                    no-lock no-error.

            pdvdoc.orig_loja        = opdvmov.etbcod.
            pdvdoc.orig_data        = opdvmov.datamov.
            pdvdoc.orig_nsu         = opdvmov.sequencia.
            pdvdoc.orig_componente  = ocmon.cxacod.
            if avail oplani
            then do:            
                pdvdoc.orig_vencod      = oplani.vencod.
                pdvdoc.orig_placod      = oplani.placod.
            end.    
        end.
        
    end.
              
    for each ttitens where ttitens.idpai = ttcupomVendaMercadoria.id.

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
        if not vdevolucao
        then
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
                        cupomb2b.numeroComponente   = int(ttcupomvendamercadoria.numeroComponente).
                        cupomb2b.nsuTransacao       = string(pdvmov.sequencia).
                        cupomb2b.clicod             = if cupomb2b.clicod = ? or cupomb2b.clicod = 0
                                                      then pdvdoc.clifor
                                                      else cupomb2b.clicod.
                        message "                     Atualizado Cliente: " cupomb2b.clicod 
                            cupomb2b.etbcod cupomb2b.dataTransacao cupomb2b.numeroComponente cupomb2b.nsuTransacao.
                    end.
                end.
                 
            end.
        end.
        /*  helio 13022023 */
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

        
        if false
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
            plani.platot   = if dec(valorMercadoriasServicos) = 0 then dec(valorTotalLiquido) else dec(valorMercadoriasServicos) /* helio 12042021 , era soh valorMercadoriasServicos **/                                
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

            if vdevolucao and avail oplani
            then do:   
                plani.modcod   = "DEV".
                plani.opccod   = 1202.
                plani.notfat   = pdvmov.etbcod.
                plani.hiccod   = 1202.
                
                create ctdevven.
                ctdevven.movtdc     = plani.movtdc.
                ctdevven.Etbcod     = plani.Etbcod.
                ctdevven.placod     = plani.placod.
                ctdevven.emite      = plani.emite .
                ctdevven.serie      = plani.serie .
                ctdevven.numero     = plani.numero.
                ctdevven.pladat     = plani.pladat.
                ctdevven.movtdc-ori = oplani.movtdc.
                ctdevven.etbcod-ori = oplani.etbcod.
                ctdevven.placod-ori = oplani.placod.
                ctdevven.emite-ori  = oplani.emite .
                ctdevven.serie-ori  = oplani.serie .
                ctdevven.numero-ori = oplani.numero.
                ctdevven.pladat-ori = oplani.pladat.
                ctdevven.dtexp      = today.

            end.
            
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

        if not vdevolucao
        then
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
    
        if not vdevolucao or (vdevolucao and vctmcod = "27") /* troca */
        then do:
              {/admcom/barramento/async/recebimentos.i ttcupomvendamercadoria.id}
        end.     
        else do:
                  vcontnum = ?.
                for each ttrecebimentos where ttrecebimentos.idpai = ttcupomvendamercadoria.id.
                    for each ttcontrato where ttcontrato.id = ttrecebimentos.id: 
                        vcontnum      = int(ttcontrato.numeroContrato).
                        leave.
                    end.
                end.
                run acertos (recid(ctdevven),vcontnum).
        end.   
    
end.    


  

procedure acertos.

def input param par-rec as recid.
def input param par-contnum as int.

 
def var vtpseguro as int.
def buffer ped-cmon   for cmon.
def buffer ped-pdvdoc for pdvdoc.

    find ctdevven where recid(ctdevven) = par-rec no-lock.
    
    find first plani where plani.etbcod = ctdevven.etbcod-ori
                       and plani.placod = ctdevven.placod-ori
                     no-lock no-error.

    message string(time,"hh:mm:ss")
        "avail plani origem " avail plani skip
        " ctdevven.etbcod-ori" ctdevven.etbcod-ori skip
        " ctdevven.placod-ori" ctdevven.placod-ori skip
        " ctdevven.serie-ori " ctdevven.serie-ori
        " par-contnum " par-contnum.

    if avail plani
    then  do on error undo: 
        find vndseguro where vndseguro.tpseguro = 1 /* #2 */
                         and vndseguro.etbcod   = plani.etbcod
                         and vndseguro.placod   = plani.placod
                     exclusive no-wait   no-error.
        if avail vndseguro
        then do on error undo:
            assign
                vndseguro.dtcanc  = today
                vndseguro.motcanc = 12.
        end.
    end.

    if par-contnum = ? and avail plani
    then do:
        if plani.crecod = 1
        then run acerta-titulo (plani.serie + string(plani.numero)).
        else do:
            find first contnf where contnf.etbcod = plani.etbcod
                              and contnf.placod = plani.placod
                            no-lock.
            find contrato of contnf no-lock.
            run acerta-titulo ( contrato.contnum ).
        end.
    end.
    else do: 
        run acerta-titulo ( par-contnum ).
    end.
end procedure.


procedure acerta-titulo.

    def input parameter par-contnum like titulo.contnum.

    def var vvlpago as dec. /* #1 */
    def var vvlaber as dec.
    def var vseqreg like pdvdoc.seqreg.
    def var vparam-dev as char.
    def buffer bpdvdoc for pdvdoc.

    vseqreg = 1.
    find contrato where contrato.contnum = par-contnum no-lock.
    
    for each titulo where titulo.contnum = contrato.contnum
                      no-lock.
        message string(time,"hh:mm:ss")
            " titulo" 
            " titnum" titulo.titnum
            " titpar" titulo.titpar
            " titsit" titulo.titsit.

        if titulo.titsit = "PAG" or
           titulo.titdtpag <> ?
        then vvlpago = vvlpago + titulo.titvlpag.
        else do.
            vvlaber = titulo.titvlcob.

            vseqreg = vseqreg + 1.
            /* copiado de ip2k/imp-info-pagamento.p */
            create bpdvdoc.
            assign 
                bpdvdoc.etbcod    = pdvmov.etbcod
                bpdvdoc.DataMov   = pdvmov.DataMov
                bpdvdoc.cmocod    = pdvmov.cmocod
                bpdvdoc.COO       = pdvmov.COO
                bpdvdoc.Sequencia = pdvmov.Sequencia
                bpdvdoc.ctmcod    = pdvmov.ctmcod
                bpdvdoc.seqreg    = vseqreg
                bpdvdoc.valor     = vvlaber
                bpdvdoc.clifor    = titulo.clifor
                bpdvdoc.contnum   = string(titulo.contnum)
                bpdvdoc.titdtven  = titulo.titdtven
                bpdvdoc.titpar    = titulo.titpar
                bpdvdoc.titvlcob  = titulo.titvlcob.

            message "DEVOLUCAO" bpdvdoc.contnum bpdvdoc.titpar string(time,"hh:mm:ss") "criou bpdvdoc" vvlaber.

            run /admcom/progr/fin/baixatitulo.p (recid(bpdvdoc),recid(titulo)) no-error.
            if error-status:error
            then do:
                MESSAGE ERROR-STATUS:ERROR RETURN-VALUE. 
                undo, return.
            end.    
            
            
            run p.

            message "DEVOLUCAO" bpdvdoc.contnum bpdvdoc.titpar string(time,"hh:mm:ss") "baixou".
            
        end.
    end.

end procedure.

procedure p.

            do on error undo:
                find current titulo
                    exclusive no-wait no-error.
                if avail titulo
                then do:    
                    titulo.moecod   = "DEV". /*#1 "PDM" */
                    titulo.datexp   = today.
                end.
            end.                    


end procedure.
