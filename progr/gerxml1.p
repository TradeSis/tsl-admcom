def stream str-xml.
def var vcha-caminho-arq as character no-undo.
def var vdata            as date      no-undo.


define temp-table tt-remetente
    field numero_contrato           as character
    field codigo_administrativo     as integer
    field nome_remetente            as character
    field logradouro_remetente      as character
    field numero_remetente          as integer
    field complemento_remetente     as character
    field bairro_remetente          as character
    field cep_remetente             as character
    field cidade_remetente          as character
    field uf_remetente              as character
    field telefone_remetente        as character
    field fax_remetente             as character
    field email_remetente           as character
    field forma_pagamento           as character.

define temp-table tt-objeto-postal
    field numero_etiqueta           as character
    field codigo_objeto_cliente     as character
    field codigo_servico_postagem   as character
    field cubagem                   as character
    field peso                      as character
    field rt1                       as character
    field rt2                       as character
    field servico_adicional         as character.

define temp-table tt-destinatario
    field pk_numero_etiqueta        as character
    field nome_destinatario         as character
    field telefone_destinatario     as character
    field celular_destinatario      as character
    field email_destinatario        as character
    field logradouro_destinatario   as character
    field complemento_destinatario  as character
    field numero_end_destinatario   as integer.


define temp-table tt-nacional
    field pk_numero_etiqueta    as character
    field bairro_destinatario   as character
    field cidade_destinatario   as character
    field uf_destinatario       as character
    field cep_destinatario      as character
    field codigo_usuario_postal as character
    field centro_custo_cliente  as character
    field numero_nota_fiscal    as character
    field serie_nota_fiscal     as character
    field valor_nota_fiscal     as character
    field natureza_nota_fiscal  as character
    field descricao_objeto      as character
    field valor_a_cobrar        as character.

define temp-table tt-dimensao
    field pk_numero_etiqueta   as character
    field dimensao_altura      as character
    field dimensao_largura     as character
    field dimensao_comprimento as character.

form " "                      skip
     vdata label "Data " format "99/99/9999"  skip
     " "
      with frame f-01 side-labels title "Insira a data para emissao do Arquivo" centered row 5.

update vdata with frame f-01.

assign vcha-caminho-arq = "/admcom/web/correios/list-"
                              + string(vdata,"99-99-9999")
                              + ".xml".

output stream str-xml to value(vcha-caminho-arq).
    
create tt-remetente.
assign tt-remetente.numero_contrato             = "9912231982"                  
       tt-remetente.codigo_administrativo       = 9033734                  
       tt-remetente.nome_remetente              = "Lojas Lebes"         
       tt-remetente.logradouro_remetente        = "Rod.118"             
       tt-remetente.numero_remetente            = 15155             
       tt-remetente.complemento_remetente       = ""                 
       tt-remetente.bairro_remetente            = "Bairro Ipiranga"  
       tt-remetente.cep_remetente               = "94010-590"        
       tt-remetente.cidade_remetente            = "Gravatai"         
       tt-remetente.uf_remetente                = "RS"               
       tt-remetente.telefone_remetente          = ""                 
       tt-remetente.fax_remetente               = ""                 
       tt-remetente.email_remetente             = ""                 
       tt-remetente.forma_pagamento             = "".

for each wbsdocbvol where wbsdocbvol.dtfec = vdata no-lock.
    find wbsdocbase of wbsdocbvol no-lock.
    find plani where plani.etbcod = wbsdocbvol.plani-etbcod
                 and plani.placod = wbsdocbvol.plani-placod
                 no-lock.
                 
    release pedid.
    release pedecom.     
    release clien.        
    find first pedid where pedid.pednum = wbsdocbase.dcbnum
                       and pedid.etbcod = 200
                       and pedid.pedtdc = 3 no-lock no-error.
    if avail pedid
    then find first pedecom where pedecom.pednum = pedid.pednum
                              and pedecom.etbcod = pedid.etbcod
                              and pedecom.pedtdc = pedid.pedtdc
                                  no-lock no-error.
    find clien where clien.clicod = plani.desti no-lock no-error.

    if not avail pedid or not avail pedecom or not avail clien
    then next.
    
    create tt-objeto-postal.
    assign tt-objeto-postal.numero_etiqueta         = wbsdocbvol.cod-postagem
           tt-objeto-postal.codigo_objeto_cliente   = ""
           tt-objeto-postal.codigo_servico_postagem = "40436"
           tt-objeto-postal.cubagem                 = ""
           tt-objeto-postal.peso                    = ""
           tt-objeto-postal.rt1                     = ""
           tt-objeto-postal.rt2                     = ""
           tt-objeto-postal.servico_adicional       = "25".
    
    create tt-destinatario.                         
    assign tt-destinatario.pk_numero_etiqueta       = wbsdocbvol.cod-postagem
           tt-destinatario.nome_destinatario        = clien.clinom
           tt-destinatario.telefone_destinatario    = ""
           tt-destinatario.celular_destinatario     = ""
           tt-destinatario.email_destinatario       = ""
           tt-destinatario.logradouro_destinatario  = pedecom.endereco
           tt-destinatario.complemento_destinatario = pedecom.complemento
           tt-destinatario.numero_end_destinatario  = pedecom.numero.
    
    create tt-nacional.
    assign tt-nacional.pk_numero_etiqueta     = wbsdocbvol.cod-postagem
           tt-nacional.bairro_destinatario    = pedecom.bairro
           tt-nacional.cidade_destinatario    = pedecom.cidade
           tt-nacional.uf_destinatario        = pedecom.uf
           tt-nacional.cep_destinatario       = pedecom.cep
           tt-nacional.codigo_usuario_postal  = ""
           tt-nacional.centro_custo_cliente   = ""
           tt-nacional.numero_nota_fiscal     = ""
           tt-nacional.serie_nota_fiscal      = ""
           tt-nacional.valor_nota_fiscal      = "" 
           tt-nacional.natureza_nota_fiscal   = ""
           tt-nacional.descricao_objeto       = ""
           tt-nacional.valor_a_cobrar         = "".
    
    create tt-dimensao.
    assign tt-dimensao.pk_numero_etiqueta   = wbsdocbvol.cod-postagem
           tt-dimensao.dimensao_altura      = "0,0"
           tt-dimensao.dimensao_largura     = "0,0"
           tt-dimensao.dimensao_comprimento = "0,0".
    
end.

find first tt-remetente no-lock no-error.

if not avail tt-remetente then return.

put stream str-xml unformatted
    "<?xml version='1.0' encoding='iso-8859-1'?> " skip
    "<correioslog> " skip
    "    <tipo_arquivo>Postagem</tipo_arquivo> " skip
    "    <versao_arquivo>2.3</versao_arquivo> " skip
    "    <remetente> " skip
    "        <numero_contrato>" tt-remetente.numero_contrato "</numero_contrato> " skip
    "        <codigo_administrativo>" tt-remetente.codigo_administrativo "</codigo_administrativo> " skip
    "        <nome_remetente><![CDATA[" tt-remetente.nome_remetente "]]></nome_remetente> " skip
    "        <logradouro_remetente><![CDATA[" tt-remetente.logradouro_remetente "]]></logradouro_remetente> " skip
    "        <numero_remetente><![CDATA[" tt-remetente.numero_remetente "]]></numero_remetente> " skip
    "        <complemento_remetente><![CDATA[" tt-remetente.complemento_remetente "]]></complemento_remetente> " skip
    "        <bairro_remetente><![CDATA[" tt-remetente.bairro_remetente "]]></bairro_remetente> " skip
    "        <cep_remetente><![CDATA[" tt-remetente.cep_remetente "]]></cep_remetente> " skip
    "        <cidade_remetente><![CDATA[" tt-remetente.cidade_remetente "]]></cidade_remetente> " skip
    "        <uf_remetente>" tt-remetente.uf_remetente "</uf_remetente> " skip
    "        <telefone_remetente>" tt-remetente.telefone_remetente "</telefone_remetente> " skip
    "        <fax_remetente>" tt-remetente.fax_remetente "</fax_remetente> " skip
    "        <email_remetente><![CDATA[" tt-remetente.email_remetente "]]></email_remetente> " skip
    "        <forma_pagamento>" tt-remetente.forma_pagamento "</forma_pagamento> " skip
    "    </remetente> " skip.
    
for each tt-objeto-postal no-lock,

    first tt-destinatario
    where tt-destinatario.pk_numero_etiqueta = tt-objeto-postal.numero_etiqueta
                                                             no-lock,
    first tt-nacional
    where tt-nacional.pk_numero_etiqueta = tt-destinatario.pk_numero_etiqueta
                                                             no-lock,
    first tt-dimensao
    where tt-dimensao.pk_numero_etiqueta = tt-nacional.pk_numero_etiqueta
                                                             no-lock:

put stream str-xml unformatted   
    "    <objeto_postal>" skip
    "        <numero_etiqueta>" tt-objeto-postal.numero_etiqueta "</numero_etiqueta> " skip
    "        <codigo_objeto_cliente>" tt-objeto-postal.codigo_objeto_cliente "</codigo_objeto_cliente> " skip
    "        <codigo_servico_postagem>" tt-objeto-postal.codigo_servico_postagem "</codigo_servico_postagem> " skip
    "        <cubagem>" tt-objeto-postal.cubagem "</cubagem> " skip
    "        <peso>" tt-objeto-postal.peso "</peso> " skip
    "        <rt1>" tt-objeto-postal.rt1 "</rt1> " skip
    "        <rt2>" tt-objeto-postal.rt2 "</rt2> " skip
    "        <destinatario>" skip                                                 
    "            <nome_destinatario><![CDATA[" tt-destinatario.nome_destinatario "]]></nome_destinatario> " skip
    "            <telefone_destinatario>" tt-destinatario.telefone_destinatario "</telefone_destinatario> " skip
    "            <celular_destinatario>" tt-destinatario.celular_destinatario "</celular_destinatario> " skip
    "            <email_destinatario>" tt-destinatario.email_destinatario "</email_destinatario> " skip
    "            <logradouro_destinatario><![CDATA[" tt-destinatario.logradouro_destinatario "]]></logradouro_destinatario> " skip
    "            <complemento_destinatario><![CDATA[" tt-destinatario.complemento_destinatario "]]></complemento_destinatario> " skip
    "            <numero_end_destinatario>" tt-destinatario.numero_end_destinatario "</numero_end_destinatario> " skip
    "        </destinatario> " skip
    "        <nacional> " skip
    "            <bairro_destinatario><![CDATA[" tt-nacional.bairro_destinatario "]]></bairro_destinatario> " skip
    "            <cidade_destinatario><![CDATA[" tt-nacional.cidade_destinatario "]]></cidade_destinatario> " skip
    "            <uf_destinatario>" tt-nacional.uf_destinatario "</uf_destinatario> " skip
    "            <cep_destinatario>" tt-nacional.cep_destinatario "</cep_destinatario> " skip
    "            <codigo_usuario_postal>" tt-nacional.codigo_usuario_postal "</codigo_usuario_postal> " skip
    "            <centro_custo_cliente>" tt-nacional.centro_custo_cliente "</centro_custo_cliente> " skip
    "            <numero_nota_fiscal>" tt-nacional.numero_nota_fiscal "</numero_nota_fiscal> " skip
    "            <serie_nota_fiscal>" tt-nacional.serie_nota_fiscal "</serie_nota_fiscal> " skip
    "            <valor_nota_fiscal>" tt-nacional.valor_nota_fiscal "</valor_nota_fiscal> " skip
    "            <natureza_nota_fiscal>" tt-nacional.natureza_nota_fiscal "</natureza_nota_fiscal> " skip
    "            <descricao_objeto>" tt-nacional.descricao_objeto "</descricao_objeto> " skip
    "            <valor_a_cobrar>" tt-nacional.valor_a_cobrar "</valor_a_cobrar> " skip
    "        </nacional> " skip
    "        <servico_adicional>"
    "            <codigo_servico_adicional>" tt-objeto-postal.servico_adicional
    "</codigo_servico_adicional>" skip 
    "        </servico_adicional> " skip
    "        <dimensao_objeto>" skip
    "            <dimensao_altura>" tt-dimensao.dimensao_altura "</dimensao_altura>" skip
    "            <dimensao_largura>" tt-dimensao.dimensao_largura "</dimensao_largura>" skip
    "            <dimensao_comprimento>" tt-dimensao.dimensao_comprimento "</dimensao_comprimento>" skip
    "        </dimensao_objeto>" skip
    " </objeto_postal>" skip.
    
    
end.

put stream str-xml unformatted
    "</correioslog>" skip.

if can-find(first tt-destinatario)
then do:
    message "Arquivo gerado com sucesso em: " vcha-caminho-arq.
    pause.
end.
    


