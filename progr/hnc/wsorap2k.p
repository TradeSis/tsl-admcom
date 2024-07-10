{admcab.i}
 
DEFINE input param vcMetodo   AS CHARACTER     NO-UNDO.
def output param pretorno as char.

def var vretorno as char.

DEFINE var vcENTRADA      AS CHARACTER     NO-UNDO.
def var vcProdutos as char.
DEFINE VARIABLE vhSocket   AS HANDLE           NO-UNDO.
def var vlinha as char.
def var vsaida as char.

def var vx as int.
def var vcsite as char.
def var vmetodo as char.
def var vLOG as char.
def var vxml    as char.

    def var vlf as char.
    vlf = '~r~n'.
    vlf = chr(10).
    vlf = " ".

def shared temp-table tt-xmlretorno
    field child-num  as int
    field root       as char format "x(15)"
    field tag        as char format "x(20)"
    field valor      as char format "x(20)"
    /*index x is unique primary child-num asc root asc tag asc valor asc*/.



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

def shared temp-table tt-p2k_receb_cred_seg no-undo
        field num_seq_forma as char
        field numero_contrato as char
        field valor_seguro as char
        field num_apolice as char
        field num_sorteio as char
        field tipo_seguro as char /* codigo do produto */
        field num_seq_seguro as char.


if vcMetodo = "insertTransacao"
then do:

    find first tt-p2k_cab_transacao no-error.
    if not avail tt-p2k_cab_transacao then return.
    find first tt-p2k_receb_cred_seg no-error.
    find first tt-p2k_recb_transacao no-error.
    

    vcEntrada = 
    '\{ \"transacao\" : \{ ' + vlf +
        '   \"status\":\"ENVIADO\",' + vlf +
        '   \"codigo_loja\":\"' + CODIGO_LOJA + '\",'        + vlf +
        '   \"data_transacao\":\"' + data_transacao          + '\",' + vlf +
        '   \"numero_componente\":\"' + numero_componente       + '\",' + vlf +
        '   \"nsu_transacao\":\"' + nsu_transacao           + '\",' + vlf +
        '   \"cab_transacao\" : \{ ' + vlf +
            '       \"tipo_venda\":\"' + tipo_venda           + '\",' + vlf +
            '       \"numero_cupom\":\"' + numero_cupom           + '\",' + vlf +
            '       \"codigo_cliente\":\"' + codigo_cliente          + '\",' + vlf +
            '       \"valor_total_venda\":\"' + valor_total_venda       + '\",' + vlf +
            '       \"valor_troco_venda\":\"' + valor_troco_venda       + '\",' + vlf +
            '       \"hora_transacao\":\"' + hora_transacao       + '\",' + vlf +
            '       \"tipo_transacao\":\"' + tipo_transacao        + '\",' + vlf +
            '       \"tipo_desconto_sub_total\":\"' + tipo_desconto_sub_total  + '\",' + vlf +
            '       \"valor_desconto_sub_total\":\"' + valor_desconto_sub_total  + '\",' + vlf +
            '       \"codigo_operador\":\"' + codigo_operador       + '\",' + vlf +
            '       \"chave_acesso_nfe\":\"' + chave_acesso_nfe       + '\",' + vlf +
            '       \"numero_nfe\":\"' + numero_nfe       + '\",' + vlf +
            '       \"serie_nfe\":\"' + serie_nfe       + '\",' + vlf +
            '       \"orig_codigo_loja\":\"' + orig_codigo_loja  + '\",' + vlf +
            '       \"orig_data_transacao\":\"' + orig_data_transacao      + '\",' + vlf +
            '       \"orig_numero_componente\":\"' + orig_numero_componente  + '\",' + vlf +
            '       \"orig_nsu_transacao\":\"' + orig_nsu_transacao     + '\",' + vlf +
            '       \"desc_observacao_pedido\":\"' + desc_observacao_pedido   + '\",' + vlf +
            '       \"tipo_pedido\":\"' + tipo_pedido    + '\",' + vlf +
            '       \"numero_pedido\":\"' + tipo_pedido       + '\"' + vlf +
            '   \}, ' + vlf +
        '   \"fim_transacao\":\{ ' + vlf +
            '       \"numero_cupom\":\"' + numero_cupom + '\",' + vlf +
            '       \"status_registro\":\"NP\" ' + vlf +
            '   \}, ' + vlf.
        
        /** produtos **/
        vcEntrada = vcEntrada +
        '   \"itens_transacao\":[ ' +
                '   \{ ' + vlf.
        vcProdutos = "".
        for each tt-p2k_item_transacao:
            vcprodutos = vcprodutos + 
                    (if vcprodutos <> "" 
                     then ('    \},' + vlf + '      \{' + vlf)
                     else '')
                     +
                                '       \"num_seq_produto\":\"' + num_seq_produto + '\",' + vlf + 
                                '       \"codigo_produto\":\"' + codigo_produto + '\",' + vlf + 
                                '       \"codigo_vendedor\":\"' + codigo_vendedor + '\",' + vlf + 
                                '       \"qtd_vendida\":\"' + qtd_vendida + '\",' + vlf + 
                                '       \"valor_unitario_produto\":\"' + valor_unitario_produto + '\",' + vlf + 
                                '       \"valor_acrescimo_item\":\"' + valor_acrescimo_item + '\",' + vlf + 
                                '       \"valor_desconto\":\"' + valor_desconto + '\",' + vlf + 
                                '       \"valor_icms\":\"' + valor_icms + '\",' + vlf + 
                                '       \"cod_tributacao\":\"' + cod_tributacao + '\",' + vlf +  
                                '       \"codigo_imei\":\"' + codigo_imei  + '\",' + vlf +  
                                '       \"data_prevista_entrega\":\"' + data_prevista_entrega  + '\",' + vlf + 
                                '       \"data_pedido_especial\":\"' + data_pedido_especial  + '\",' + vlf + 
                                '       \"valor_desconto_campanha\":\"' + valor_desconto_campanha  + '\",' + vlf + 
                                '       \"tipo_desconto\":\"' + tipo_desconto  + '\",' + vlf + 
                                '       \"status_item\":\"V\" ' + vlf.
        end.

        vcEntrada = vcEntrada +                 
                vcprodutos + '      \}' + vlf +
                "   ]," + vlf.
        
        if avail tt-p2k_receb_cred_seg
        then do:
            vcEntrada = vcEntrada +
            '   \"receb_cred_seg\": ' +
                    '   \{ ' + vlf  +
                    '       \"num_seq_forma\":\"' + tt-p2k_receb_cred_seg.num_seq_forma + '\",' + vlf + 
                    '       \"numero_contrato\":\"' + numero_contrato + '\",' + vlf + 
                    '       \"valor_seguro\":\"' + valor_seguro + '\",' + vlf + 
                    '       \"num_apolice\":\"' + num_apolice + '\",' + vlf + 
                    '       \"num_sorteio\":\"' + num_sorteio + '\",' + vlf + 
                    '       \"tipo_seguro\":\"' + tipo_seguro + '\",' + vlf + 
                    '       \"num_seq_seguro\":\"' + num_seq_seguro + '\"' + vlf + 
                '    \},' + vlf.
        end.
        vcEntrada = vcEntrada +
        '   \"recb_transacao\": ' +
                '   \{ ' + vlf +
                '       \"num_seq_forma\":\"' + tt-p2k_recb_transacao.num_seq_forma + '\",' + vlf + 
                '       \"codigo_forma\":\"' + codigo_forma + '\",' + vlf + 
                '       \"codigo_plano\":\"' + codigo_plano + '\",' + vlf + 
                '       \"valor_pago_forma\":\"' + valor_pago_forma + '\",' + vlf + 
                '       \"valor_acrescimo\":\"' + valor_acrescimo + '\"' + vlf +
            '    \}' + vlf.
                 
      vcEntrada = vcEntrada +           
       '    \}' + vlf +
     '\}' .

   
end.


def buffer btt-xmlretorno for tt-xmlretorno.

def var vtime   as int.
def var vchost as char.
def var vcport as char.
def var p-valor as char.

def var varqbin as char.
def var vconteudo as char.

run le_tabini.p (setbcod, 0, "NFE - AMBIENTE", OUTPUT p-valor).

vchost = "10.2.0.119".
vcPort = "8080".

vcSite = if p-valor = "HOMOLOGACAO"
         then "WS_TrocaOracle_hml/index"
         else if p-valor = "PRODUCAO"
              then "WS_TrocaOracle/index"
              else "".

if vcMetodo = "" then do:
    pretorno = "Metodo obrigatorio".
    return.
end. 

vtime = time.

empty temp-table tt-xmlretorno.



vsaida  = "/ws/log/wsorap2k"  + string(today,"999999") + replace(string(vtime,"HH:MM:SS"),":","") + ".json". 


output to value(vsaida + ".a").
put unformatted vcEntrada skip.
output close.

output to value(vsaida + ".sh").
vlinha = 
    "curl -s \"http://" + vcHost + ":" + vcPort + "/" + vcSite + "/" + vcMetodo + "\" " +
    " -H \"Content-Type: application/json\" " +
    " -d '" + vcEntrada + "' ".
put unformatted  vlinha.
output close.


unix silent value("sh " + vsaida + ".sh " + ">" + vsaida).
unix silent value("echo \"\n\">>"+ vsaida).

input from value(vsaida).
import unformatted vretorno.
input close.


unix silent value("rm -f " + vsaida). 



vretorno = replace(replace(replace(vretorno,"\}",""),"\{",""),"\"","").

pretorno = "SEM RETORNO".
if num-entries(vretorno,":") >= 2
then  do vx = 1 to num-entries(vretorno).
    create tt-xmlretorno.
    tt-xmlretorno.tag   = entry(1,entry(vx,vretorno),":") no-error.
    tt-xmlretorno.valor = entry(2,entry(vx,vretorno),":") no-error.
    if tt-xmlretorno.tag = "STATUS"
    then pretorno = tt-xmlretorno.valor.
end.
else do:
    create tt-xmlretorno.
    tt-xmlretorno.tag   = "STATUS".
    tt-xmlretorno.valor = substring(vretorno,1,40).
    pretorno = tt-xmlretorno.valor.
end.

