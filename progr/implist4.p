def var vdata              as date      no-undo.
def var vcha-caminho-arq   as character no-undo.
def var vint-cont          as integer no-undo.

form " "                      skip
     vdata label "Data " format "99/99/9999"  skip
     " "
        with frame f-01 side-labels title "Insira a data para emissao da Listagem" centered row 5.

update vdata with frame f-01.

define stream str-html.

define variable vdat-data-postagem as date no-undo.

define temp-table tt-remetente    
    field data-emissao        as date
    field pagina              as integer
    field unidade-postagem    as character
    field cep-unidade         as character
    field data-postagem       as date
    field cod-administrativo  as integer
    field contrato            as integer
    field numerolista         as integer
    field cliente             as character
    field totalizador         as character
    field cartao-postagem     as character
    field remetente           as character
    field endereco-rem        as character.

define temp-table tt-destinatario
    field destinatario        as character
    field cep-desti           as character
    field declara-valor       as character
    field val-declarado       as decimal
    field valor-cobrado-desti as decimal
    field inf-compl           as character
    field cod-postagem        as character
    field nf                  as character
    field volume              as character
    field servico             as character
    field peso-tarifado       as character
    field servico-adic        as character
    field valor-pagar         as character
    field contador            as integer.

create tt-remetente.
assign tt-remetente.data-emissao           = today                 .
    /* tt-remetente.pagina                 =  */
       tt-remetente.unidade-postagem       = "999999 - AC GRAVATAI" .
       tt-remetente.cep-unidade            = "99999-999"            .
       tt-remetente.data-postagem          = vdata                  .
       tt-remetente.cod-administrativo     = 9999999                .
       tt-remetente.contrato               = 9999999                .
       tt-remetente.numerolista            = 222                       .
       tt-remetente.cliente                = "Lojas Lebes"          .
       tt-remetente.totalizador            = "FY-9999999"           .
       tt-remetente.cartao-postagem        = "00060750081"          .
       tt-remetente.remetente              = "Lojas Lebes"          .
       tt-remetente.endereco-rem           = 

       "Rod.118 N 15.155 " +
       "Bairro Ipiranga "    +
       "Gravatai/"            +
       "RS"                 +
       "94010-590"          .

assign vint-cont = 0.

for each wbsdocbvol where wbsdocbvol.dtfec = vdata no-lock.
    find wbsdocbase of wbsdocbvol no-lock.
    find plani where plani.etbcod = wbsdocbvol.plani-etbcod 
                 and plani.placod = wbsdocbvol.plani-placod
                 no-lock.
    find first pedid where pedid.pednum = wbsdocbase.dcbnum
                       and pedid.etbcod = 200 
                       and pedid.pedtdc = 3 no-lock.
    if avail pedid 
    then find first pedecom where pedecom.pednum = pedid.pednum       
                              and pedecom.etbcod = pedid.etbcod       
                              and pedecom.pedtdc = pedid.pedtdc
                                  no-lock no-error.
    if not avail pedecom or pedecom.tipofrete <> "TRANSP"
    then next. 
                                  
    find clien where clien.clicod = plani.desti no-lock.    
    def var vqtdvol as int.

    create tt-destinatario.
    assign tt-destinatario.destinatario        = clien.clinom                .
           tt-destinatario.cep-desti           = pedecom.cep                 .
           tt-destinatario.declara-valor       = "SIM"                       .
           tt-destinatario.val-declarado       = 9999                        .
           tt-destinatario.valor-cobrado-desti = 9999                        .
           tt-destinatario.inf-compl           = "99999"                     .
           tt-destinatario.cod-postagem        = wbsdocbvol.cod-postagem     .
           tt-destinatario.nf                  = string(plani.numero)      .
           tt-destinatario.volume              = string(wbsdocbvol.dcbseq) +
                                           "/" + string(vqtdvol).            .
           tt-destinatario.servico             = "99999 SEDEX CONTRATO"   .
           tt-destinatario.peso-tarifado       = "9999"                    .
           tt-destinatario.servico-adic        = "999 RR"                    .
           tt-destinatario.valor-pagar         = "99999"                     .
                   
    assign vint-cont = vint-cont + 1.
    
    assign tt-destinatario.contador = vint-cont.
                                                 
end.                                                                         
                                                                             
assign vcha-caminho-arq = "/admcom/web/correios/transportadora/list-"
                                        + string(vdata,"99-99-9999")
                                        + ".html".

output stream str-html to value(vcha-caminho-arq).

/*
output stream str-html to value("/admcom/custom/laureano/listagem.html").
*/

find first tt-remetente no-lock no-error.

put stream str-html unformatted
    "<html>" skip
    "<head>" skip
    "    <style> " skip
    "      .destinatario~{" skip
    "        font-size:10px; " skip
    "        font-family:Times;}" skip
    "                           " skip
    "      .remetente~{" skip
    "        font-size:12px;" skip
    "        font-family:Times;}" skip              
    "                           " skip
    "                           " skip
    "    </style>" skip
    "            " skip
    "            " skip
    "</head>" skip
    "<body>" skip
    "<table border='0' style='border-collapse: collapse' bordercolor='#000000' width='715'>" skip
    "<tr>" skip
    "    <td width='17%' nowrap>&nbsp;</td>" skip
    "    <td width='59%' align='Left' nowrap><font size='3'><b>Listagem de remessa via Transportadora</b></font></td>" skip
    "    <td width='24%' nowrap>&nbsp;</td>" skip
    "</tr>" skip
    "<tr>" skip
    "    <td nowrap>&nbsp;</td>" skip
    "    <td align='Center' nowrap><font size='4'><b>Lista de Postagem</b></font></td>" skip
    "    <td nowrap><font size='2'><b>Data de Emissão</b> " tt-remetente.data-emissao " </font></td>" skip
    "</tr>" skip
    "<tr>" skip
    "    <td nowrap>&nbsp;</td>" skip
    "    <td nowrap>&nbsp;</td>" skip
/*  "    <td nowrap><font size='2'><b>Página:</b>" tt-remetente.pagina " </font>~ </td>" skip */
    "</tr>" skip
    "</table>" skip
    "<table border='1' style='border-collapse: collapse' bordercolor='#000000' width='715'>" skip
    "<tr>" skip
    "    <td colspan='2'>" skip
    "        <table border='0' style='border-collapse: collapse' bordercolor='#000000' width='712'>" skip
    "            <tr>" skip
    "                <td nowrap height='24' colspan='3' class='remetente'><b>Unidade de postagem: </b>" skip
    "                " tt-remetente.unidade-postagem " </td>" skip
    "                <td nowrap height='24' colspan='3' class='remetente'>" skip
    "                    <p align='right'><b>CEP:</b> " tt-remetente.cep-unidade "</td>" skip
    "            </tr>" skip
    "            <tr>" skip
    "                <td width='15%' nowrap class='remetente'><b>Data da postagem:</b></td>" skip
    "                <td width='13%'  nowrap class='remetente'>" tt-remetente.data-postagem "</td>" skip
    "                <td width='24%' nowrap align='right' class='remetente'><b>Código Administrativo</b>:</td>" skip
    "                <td width='17%' nowrap class='remetente'>" tt-remetente.cod-administrativo "</td>" skip
    "                <td width='17%' nowrap class='remetente'>" skip
    "                <p align='right'><b>Contrato:</b></td>" skip
    "                <td width='14' nowrap class='remetente'>" tt-remetente.contrato "</td>" skip
    "            </tr>" skip
    "            <tr>" skip
    "                <td nowrap class='remetente'><b>Número da lista:</b></td>" skip
    "                <td nowrap class='remetente'> " tt-remetente.numerolista " </td>" skip
    "                <td nowrap align='right' class='remetente'><b>Cliente:</b></td>" skip
    "                <td nowrap colspan='3' class='remetente'>" skip
    "                <p align='left'>" tt-remetente.cliente "</td>" skip
    "            </tr>" skip
    "        </table>" skip
    "    </td>" skip
    "</tr>" skip.
    



for each tt-destinatario no-lock:

    put stream str-html unformatted
        "<tr>" skip
        "    <td width='50%'>" skip
        "        <table border='0' style='border-collapse: collapse' bordercolor='#000000' width='100%'>" skip
        "            <tr>" skip
        "                <td class='destinatario' width='1%'></td>" skip
        "                <td class='destinatario' width='32%'><b>Destinatário:</b></td>" skip
        "                <td class='destinatario' width='24%'><p align='right'><b>Cep destino:</b></td>" skip
        "                <td class='destinatario' width='43%'>" tt-destinatario.cep-desti "</td>" skip
        "            </tr>" skip
        "            <tr height='20' valign='top'>" skip
        "                <td class='destinatario' width='1%'></td>" skip
        "                <td class='destinatario' colspan='3'>" tt-destinatario.destinatario "</td>" skip
        "            </tr>" skip
        "            <tr>" skip
        "                <td class='destinatario' width='1%'></td>" skip
        "                <td class='destinatario'><b>Deseja declarar valor?</b></td>" skip
        "                <td class='destinatario'><b>Valor declarado:</b></td>" skip
        "                <td class='destinatario'><b>Valor a Cobrar do destinatário:</b></td>" skip
        "            </tr>" skip
        "            <tr height='20' valign='top'>" skip
        "                <td class='destinatario' width='1%'></td>" skip
        "                <td class='destinatario'>NAO</td>" skip
        "                <td class='destinatario'></td>" skip            
        "                <td class='destinatario'></td>" skip
        "            </tr>" skip
        "            <tr>" skip
        "                <td class='destinatario' width='1%'></td>" skip
        "                <td class='destinatario' colspan='3'><b>Inf.compl.:</b> " tt-destinatario.inf-compl "</td>" skip
        "            </tr>" skip
        "        </table>" skip
        "    </td>" skip
        "    <td width='50%'>" skip
        "        <table border='0' style='border-collapse: collapse' bordercolor='#000000' width='100%'>" skip
        "            <tr height='16' valign='center'>" skip
        "                <td class='destinatario' width='1%'></td>" skip
        "                <td class='destinatario' width='40%'><b>Nº Objeto: </b>" tt-destinatario.cod-postagem "</td>" skip
        "                <td class='destinatario' width='29%' align='center'><b>Nº da N.F.:</b> " tt-destinatario.nf "</td>" skip
        "                <td class='destinatario' width='29%' align='center'>
        <b>Volume:</b> " tt-destinatario.volume "</td>" skip
        "            </tr>" skip
        "            <tr height='16' valign='center'>" skip
        "                <td class='destinatario' width='1%'></td>" skip
        "                <td class='destinatario' colspan='3'><b>Serviço </b>" tt-destinatario.servico  skip
        "                CONTRATO</td>" skip
        "            </tr>" skip
        "            <tr height='16' valign='center'>" skip
        "                <td class='destinatario' width='1%'></td>" skip
        "                <td class='destinatario'><b>Peso tarifado(g): </b></td>" skip
        "                <td class='destinatario' colspan='2'><b>Serviços adicionais: </b>" tt-destinatario.servico-adic skip
        "                </td>" skip
        "            </tr>" skip
        "            <tr  height='20' valign='top'>" skip
        "                <td class='destinatario' width='1%'></td>" skip
        "                <td class='destinatario'>" tt-destinatario.peso-tarifado " </td>" skip
        "                <td class='destinatario'>&nbsp;</td>" skip
        "                <td class='destinatario'>&nbsp;</td>" skip            
        "            </tr>" skip
        "            <tr height='16' valign='center'>" skip
        "                <td class='destinatario' width='1%'></td>" skip
        "                <td class='destinatario' colspan='3'><b>Valor a pagar: " tt-destinatario.valor-pagar "</b></td>" skip
        "            </tr>" skip
        "        </table>" skip
        "    </td>" skip
        "</tr>" skip.
    
        
    
    if (vint-cont >= 8 and vint-cont < 17 and tt-destinatario.contador = 7)
                 or
       (vint-cont >= 17 and ((tt-destinatario.contador - 7) mod 9) = 0)
    then do:

        put stream str-html unformatted
            "</table>"
            "<p style='page-break-before: always'></p>"
            "<table border='1' style='border-collapse: collapse'                              bordercolor='#000000' width='715'>" skip.
    
    end.
    
end.
    

    
put stream str-html unformatted    
    "</table>" skip
    "         " skip
    "<table border='0' style='border-collapse: collapse' bordercolor='#000000' width='715'>" skip
    "<tr>" skip
    "    <td>&nbsp;</td>" skip
    "</tr>" skip
    "<tr>" skip
    "    <td>&nbsp;</td>" skip
    "</tr>" skip
    "</table>" skip
    "        " skip
    "<table border='1' style='border-collapse: collapse' bordercolor='#000000' width='715'>" skip
    "<tr>" skip
    "    <td>" skip
    "        <table border='0' style='border-collapse: collapse' bordercolor='#000000' width='100%'>" skip
    "            <tr>" skip
    "                <td width='30%' class='remetente'><b>Totalizador:</b></td>" skip
    "                <td width='30%' class='remetente'>" tt-remetente.totalizador skip
    "                <td width='40%' class='remetente' align='right'><b>Carimbo e assinatura  Matrícula dos Correios&nbsp;&nbsp;&nbsp;&nbsp;</b></td>" skip
    "            </tr>" skip
    "            <tr height='20'>" skip
    "                <td class='remetente' colspan='3'><b>APRESENTAR ESTA LISTA EM " skip
    "                CASO DE PEDIDO DE INFORMAÇÕ‡ES</b></td>" skip
    "            </tr>" skip
    "            <tr height='20'>" skip
    "                <td class='remetente'><b>Cartão de Postagem</b> " tt-remetente.cartao-postagem " </td>" skip
    "                <td class='remetente'><b>Remetente</b> " tt-remetente.remetente  "</td>" skip
    "                <td class='remetente'>&nbsp;</td>" skip
    "            </tr>" skip
    "            <tr height='20'>" skip
    "                <td class='remetente' colspan='2'><b>Endereço</b> " tt-remetente.endereco-rem  "</td>" skip
    "                <td class='remetente'>&nbsp;</td>" skip
    "            </tr>" skip
    "            <tr height='20'>" skip
    "                <td class='remetente' colspan='3'><b>Estou ciente do dispositivo na cláusula terceira do contrato de prestação de serviços.</b></td>" skip
    "            </tr>" skip
    "            <tr height='30'>" skip
    "                <td class='remetente' valign='bottom' colspan='3'><b>_______________________________________________________________________</b></td>" skip
    "            </tr>" skip
    "            <tr height='20'>" skip
    "                <td class='remetente' colspan='2' align='center'><b>ASSINATURA DO REMETENTE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></td>" skip
    "                <td class='remetente'>&nbsp;</td>" skip
    "            </tr>" skip
    "            <tr height='25'>" skip
    "                <td class='remetente' colspan='3' valign='bottom'><b>Obs.: 1ª via balancete, 2ª via cliente, 3ª via arquivo na unidade.</b></td>" skip
    "            </tr>" skip
    "        </table>" skip
    "    </td>" skip
    "</tr>" skip
    "     " skip
    "     " skip
    "</table>" skip
    "        " skip
    "        " skip
    "        " skip
    "</body>" skip
    "<html>" skip.    

    output stream str-html close.
     
    unix silent value("chmod 777 " + vcha-caminho-arq).

if can-find(first tt-destinatario)
then do:

    message "Arquivo gerado com sucesso em: " vcha-caminho-arq.
    pause.

end.
