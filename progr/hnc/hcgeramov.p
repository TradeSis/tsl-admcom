def input  parameter par-caixa as int.
def output param     par-recmov as recid.

def buffer bpdvmov for pdvmov.
def var vseq as int.                                                            

def var vrodou  as log.
def var vprocod like pdvmovim.procod.
def var vmovdes like pdvmovim.movdes. /* #1 */
def var vmovpc  like pdvmovim.movpc.  /* #1 */
def var vmovqtm like pdvmovim.movqtm. /* #1 */


def shared temp-table tt-p2k_cab_transacao no-undo       
        field CODIGO_LOJA             as char
        field DATA_TRANSACAO          as char
        field NUMERO_COMPONENTE       as char
        field NSU_TRANSACAO           as char
        field TIPO_VENDA              as char
        field NUMERO_CUPOM            as char
        field CODIGO_CLIENTE          as char
        field VALOR_TOTAL_VENDA       as char
        field VALOR_TROCO_VENDA       as char
        field HORA_TRANSACAO          as char
        field TIPO_TRANSACAO          as char
        field TIPO_DESCONTO_SUB_TOTAL as char
        field VALOR_DESCONTO_SUB_TOTAL as char
        field CODIGO_OPERADOR         as char
        field CHAVE_ACESSO_NFE        as char
        field NUMERO_NFE              as char
        field SERIE_NFE               as char
        field ORIG_CODIGO_LOJA as char
        field ORIG_DATA_TRANSACAO     as char
        field ORIG_NUMERO_COMPONENTE  as char
        field ORIG_NSU_TRANSACAO      as char
        field desc_observacao_pedido  as char
        field TIPO_PEDIDO             as char
        field NUMERO_PEDIDO           as char.

def shared temp-table tt-p2k_item_transacao no-undo
    field num_seq_produto        as char
    field codigo_produto         as char
    field codigo_vendedor as char
    field qtd_vendida            as char
    field valor_unitario_produto as char
    field valor_acrescimo_item   as char
    field valor_desconto         as char
    field valor_icms             as char
    field cod_tributacao         as char
    field codigo_imei            as char
    field data_prevista_entrega  as char
    field data_pedido_especial   as char
    field valor_desconto_campanha as char
    field tipo_desconto as char
    field status_item             as char init 'v'.

def shared temp-table tt-p2k_recb_transacao no-undo
    field num_seq_forma    as char
    field codigo_forma     as char
    field codigo_plano     as char
    field valor_pago_forma as char
    field valor_acrescimo  as char.


find first tt-p2k_cab_transacao.

    
    find cmon where
                cmon.etbcod = int(tt-p2k_cab_transacao.codigo_loja) and 
                cmon.cxacod = par-caixa
                no-lock no-error. 
    if not avail cmon 
    then do on error undo: 
        create cmon. 
        assign 
            cmon.cmtcod = "PDV" 
            cmon.etbcod = int(tt-p2k_cab_transacao.codigo_loja)
            cmon.cxacod = par-caixa
            cmon.cmocod = int(string(cmon.etbcod) + 
                              string(cmon.cxacod,"999")) 
            cmon.cxanom = "Lj " + string(cmon.etbcod) + " " + 
                          "Cx " + string(cmon.cxacod). 
    end.


        find last bpdvmov where
                bpdvmov.etbcod = cmon.etbcod and
                bpdvmov.cmocod = cmon.cmocod and
                bpdvmov.datamov = today
                no-lock no-error.
        vseq = if avail bpdvmov 
               then bpdvmov.sequencia + 1
               else 1.
                       
        create pdvmov.
        par-recmov = recid(pdvmov).
        pdvmov.cmocod   = cmon.cmocod.
        pdvmov.codigo_operador = "100".
        pdvmov.COO      = int(tt-p2k_cab_transacao.nsu_transacao).
        pdvmov.ctmcod   = tt-p2k_cab_transacao.tipo_transacao.
        pdvmov.DataMov  = today.
        pdvmov.DtIncl   = today.
        pdvmov.entsai   = yes.
        pdvmov.etbcod   = cmon.etbcod.
        pdvmov.HoraMov  = time.
        pdvmov.HrIncl   = time.
        pdvmov.Sequencia = vseq.
        pdvmov.statusoper = "FEC".
        pdvmov.ValorTot   = dec(valor_total_venda) / 100.
        pdvmov.ValorTroco = 0.
        
        create pdvdoc.
        pdvdoc.etbcod = pdvmov.etbcod.
        pdvdoc.cmocod = pdvmov.cmocod.
        pdvdoc.DataMov = pdvmov.datamov.
        pdvdoc.Sequencia = pdvmov.sequencia.
        pdvdoc.ctmcod = pdvmov.ctmcod.
        pdvdoc.COO = pdvmov.coo.
        pdvdoc.seqreg = 1.
        pdvdoc.placod = ?.
        pdvdoc.tipo_venda = 1.
        pdvdoc.Valor = pdvmov.valortot.
        
        pdvdoc.clifor = int(codigo_cliente).
        
        pdvdoc.numero_nfe = int(tt-p2k_cab_transacao.numero_nfe).
        pdvdoc.serie      = tt-p2k_cab_transacao.serie_nfe.
        pdvdoc.chave_nfe  = chave_acesso_nfe. 
        
        pdvdoc.orig_loja = int(orig_codigo_loja).   
        pdvdoc.orig_componente = int(orig_numero_componente).
        pdvdoc.orig_data = date(int(entry(2,orig_data_transacao,"/")),
                                int(entry(1,orig_data_transacao,"/")),
                                int(entry(3,orig_data_transacao,"/"))) no-error.
        pdvdoc.orig_nsu = int(orig_nsu_transacao).
        

        vseq = 0.
        for each tt-p2k_item_transacao.

            
            vseq    = vseq + 1.
            vprocod = int(codigo_produto).
            vmovqtm = dec(QTD_VENDIDA).
            vmovpc  = dec(valor_unitario_produto) / 100.
            vmovdes = dec(valor_desconto) / 100.
            
           find pdvmovim where pdvmovim.etbcod    = pdvdoc.etbcod and
                            pdvmovim.cmocod    = pdvdoc.cmocod and
                            pdvmovim.datamov   = pdvdoc.datamov and
                            pdvmovim.sequencia = pdvdoc.sequencia and
                            pdvmovim.ctmcod    = pdvdoc.ctmcod and
                            pdvmovim.coo       = pdvdoc.coo and
                            pdvmovim.seqreg    = pdvdoc.seqreg and
                            pdvmovim.movseq    = vseq
                      no-lock no-error.
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
                    pdvmovim.movseq    = vseq
                    pdvmovim.procod    = vprocod
                    pdvmovim.movqtm    = vmovqtm
                    pdvmovim.movpc     = vmovpc
                    pdvmovim.movdes    = vmovdes.

                pdvmovim.movalicms = dec(COD_TRIBUTACAO).
                pdvmovim.movicms   = dec(valor_icms) / 100.
                pdvmovim.movacfin  = dec(VALOR_ACRESCIMO_ITEM) / 100.
/*                pdvmovim.codigo_imei = codigo_imei.*/
                pdvmovim.vencod    = int(codigo_vendedor).
           
                /*
                pdvmovim.MovDesCampanha =
                                 dec(valor_desconto_campanha).
                */
                /*
                pdvmovim.dt_prevista_entrega = (data_prevista_entrega).
                pdvmovim.dt_pedido_especial  = (data_pedido_especial).
                */
                /*
                pdvmovim.tipo_desconto = int(tt-p2k_item_transacao.TIPO_DESCONTO).
                */
            end.
                    
                    
        end.                    


        find first tt-p2k_recb_transacao.

        find first pdvforma where      
                 pdvforma.etbcod     = pdvmov.etbcod and
                 pdvforma.cmocod     = pdvmov.cmocod and
                 pdvforma.DataMov    = pdvmov.DataMov and
                 pdvforma.Sequencia  = pdvmov.Sequencia and
                 pdvforma.ctmcod     = pdvmov.ctmcod and
                 pdvforma.COO        = pdvmov.COO and
                 pdvforma.seqforma   = 1
                no-error.
        if not avail pdvforma 
        then do: 
            create pdvforma.
            assign
                pdvforma.etbcod     = pdvmov.etbcod
                pdvforma.DataMov    = pdvmov.DataMov
                pdvforma.cmocod     = pdvmov.cmocod
                pdvforma.COO        = pdvmov.COO
                pdvforma.Sequencia  = pdvmov.Sequencia
                pdvforma.ctmcod     = pdvmov.ctmcod 
                pdvforma.seqforma   = 1.
        end.                     
        
        pdvforma.pdvtfcod     = tt-p2k_recb_transacao.codigo_forma.
        pdvforma.fincod       = int(codigo_plano).  
        pdvforma.valor_forma  = dec(tt-p2k_recb_transacao.valor_pago_forma) / 100.
        pdvforma.valor_ACF    = dec(tt-p2k_recb_transacao.valor_acrescimo) / 100.
        pdvforma.valor        = pdvforma.valor_forma + pdvforma.valor_acf.

        if pdvmov.ctmcod = "10" and
           (pdvforma.fincod = 2 or pdvforma.fincod = 157)
        then pdvforma.fincod = 0. /* Venda a Vista */

        /**
        if pdvmov.ctmcod = "27" /* troca */ and
           pdvforma.pdvtfcod = "102" and
           vnu_vale > 0
        then pdvforma.contnum = string(vnu_vale, "99999999").
        **/
        
        find first pdvdoc of pdvmov exclusive.
        assign
            pdvdoc.fincod = pdvforma.fincod
            pdvdoc.crecod = 1. /* sempre eh 1, exceto se importa crediario */
     
