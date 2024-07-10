def temp-table tipo-alcis
    field tp        as char format "x(4)"
    field tm        as char format "x(30)"
    field acao      as char
    field consulta  as char
    field acaodescr as char.

create tipo-alcis.
assign tipo-alcis.tm       = "Confirmacao do Recebimento"
       tipo-alcis.tp       = "CREC"
       tipo-alcis.acao     = "alcis/crec.p"
       tipo-alcis.consulta = "alcis/consulta-crec.p".

create tipo-alcis.
assign tipo-alcis.tm       = "Confirmacao da Ordem de Venda"
       tipo-alcis.tp       = "CONF"
       tipo-alcis.acao     = "alcis/acao-confh.p"
       tipo-alcis.consulta = "alcis/consulta-conf.p".

create tipo-alcis.
assign tipo-alcis.tm       = "Bloqueio/Desbloqueio Estoque"
       tipo-alcis.tp       = "BDES"
       tipo-alcis.acao     = "alcis/bdes_bloq.p"
       tipo-alcis.consulta = "alcis/consulta-bdes.p".

create tipo-alcis.
assign tipo-alcis.tm       = "Batimento de Estoque"
       tipo-alcis.tp       = "ESTQ"
       tipo-alcis.acao     = "alcis/inve.p"
       tipo-alcis.consulta = "alcis/consulta-inve.p".

create tipo-alcis.
assign tipo-alcis.tm       = "FECHAMENTO DE GAIOLA"
       tipo-alcis.tp       = "FCGL"
       tipo-alcis.acao     = "alcis/fcgl_acao.p"
       tipo-alcis.consulta = "alcis/fcgl_consulta.p".       
       
def var alcis-diretorio as char.
alcis-diretorio = "/usr/ITF/dat/out".
