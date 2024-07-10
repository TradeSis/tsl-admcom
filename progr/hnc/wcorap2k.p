
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
    field NUM_SEQ_PRODUTO        as char 
    field CODIGO_PRODUTO         as char 
    field CODIGO_VENDEDOR as char 
    field QTD_VENDIDA            as char 
    field VALOR_UNITARIO_PRODUTO as char 
    field VALOR_ACRESCIMO_ITEM   as char 
    field VALOR_DESCONTO         as char 
    field VALOR_ICMS             as char 
    field COD_TRIBUTACAO         as char 
    field CODIGO_IMEI            as char 
    field DATA_PREVISTA_ENTREGA  as char 
    field DATA_PEDIDO_ESPECIAL   as char 
    field VALOR_DESCONTO_CAMPANHA as char 
    field TIPO_DESCONTO as char 
    field status_item             as char init 'V'.

def new shared temp-table tt-p2k_recb_transacao no-undo       
    field NUM_SEQ_FORMA    as char 
    field CODIGO_FORMA     as char 
    field CODIGO_PLANO     as char 
    field VALOR_PAGO_FORMA as char 
    field VALOR_ACRESCIMO  as char.

def new shared temp-table tt-p2k_receb_cred_seg no-undo       
        field num_seq_forma as char 
        field numero_contrato as char 
        field valor_seguro as char 
        field num_apolice as char 
        field num_sorteio as char 
        field TIPO_SEGURO as char /* codigo do produto */ 
        field num_seq_seguro as char.


def new shared temp-table tt-xmlretorno
    field child-num  as int
    field root       as char format "x(15)"
    field tag        as char format "x(20)"
    field valor      as char format "x(20)"
    /*index x is unique primary child-num asc root asc tag asc valor asc*/.


create tt-p2k_cab_transacao.
codigo_loja = "189".
create tt-p2k_item_transacao.
create tt-p2k_item_transacao. 

create tt-p2k_receb_cred_seg.
create tt-p2k_recb_transacao.


run hnc/wsorap2k.p ("insertTransacao").


