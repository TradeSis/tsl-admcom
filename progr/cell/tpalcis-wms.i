def temp-table tipo-alcis
    field tp        as char format "x(4)"
    field tm        as char format "x(30)"
    field acao      as char
    field consulta  as char
    field acaodescr as char.

def var v-filtro as char extent 5.

create tipo-alcis.
assign tipo-alcis.tm       = "Confirmacao do Recebimento"
       tipo-alcis.tp       = "CREC"
       tipo-alcis.acao     = "acao-confrec-wms.p"
       tipo-alcis.consulta = "consulta-confrec-wms.p"
       .

/**
create tipo-alcis.
assign tipo-alcis.tm       = "Confirmacao da Ordem de Venda"
       tipo-alcis.tp       = "CONF"
       tipo-alcis.acao     = "alcis/acao-confh.p"
       tipo-alcis.consulta = "alcis/consulta-conf.p".
**/

create tipo-alcis.
assign tipo-alcis.tm       = "Confirmacao de Pedido Finalizado"
       tipo-alcis.tp       = "CONF"
       tipo-alcis.acao     = "acao-confped-wms.p"
       tipo-alcis.consulta = "consulta-confped-wms.p".
       
create tipo-alcis.
assign tipo-alcis.tm       = "Confirmacao de Embarque"
       tipo-alcis.tp       = "EBLJ"
       tipo-alcis.acao     = "acao-eblj-wms.p"
       tipo-alcis.consulta = "consulta-eblj-wms.p".

create tipo-alcis.
assign tipo-alcis.tm       = "Bloqueio/Desbloqueio Estoque"
       tipo-alcis.tp       = "BDES"
       tipo-alcis.acao     = "acao-bdes-wms.p"
       tipo-alcis.consulta = "consulta-bdes-wms.p".

create tipo-alcis.
assign tipo-alcis.tm       = "Espelho de Estoque"
       tipo-alcis.tp       = "SINC"
       tipo-alcis.acao     = "acao-sinc-wms.p"
       tipo-alcis.consulta = "consulta-sinc-wms.p".

/****
create tipo-alcis.
assign tipo-alcis.tm       = "Batimento de Estoque"
       tipo-alcis.tp       = "ESTQ"
       tipo-alcis.acao     = "alcis/inve.p"
       tipo-alcis.consulta = "alcis/consulta-inve.p".
****/


/***
create tipo-alcis.
assign tipo-alcis.tm       = "FECHAMENTO DE GAIOLA"
       tipo-alcis.tp       = "FCGL"
       tipo-alcis.acao     = "alcis/fcgl_acao.p"
       tipo-alcis.consulta = "alcis/fcgl_consulta.p".       
***/
       
def var alcis-diretorio as char.
alcis-diretorio = "/usr/ITF_CELL/dat/out".
def var alcis-diretorio-bkp as char.
alcis-diretorio-bkp = "/usr/ITF_CELL/bkp/out".

