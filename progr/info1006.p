
def output parameter varquivo as char.
{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 1006 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para INFORMATIVO nao cadastrado ou desativado".
    pause 0.
    return.
end.
def var venvmail as log.
varquivo = "/admcom/work/informativo1006.txt".
/*
output to value(varquivo). 
put unformatted
"<HTML>" skip.
*/
/*
"PEDIDOS DE COMPRA EM ATRASO MOVEIS <BR><BR>"
.  */
/****
PUT unformatted
    "<TABLE border=~"2~" frame=~"hsides~" rules=~"groups~"" skip
    "          summary=~"DREBES & CIA LTDA~">" skip
    "<CAPTION><b>PEDIDOS DE COMPRA EM ATRASO MOVEIS</CAPTION>" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"left~">" skip
    "<COLGROUP align=~"left~">" skip
    "<COLGROUP align=~"right~">"  skip
    "<COLGROUP align=~"right~">"  skip
    "<COLGROUP align=~"left~">"  skip
    "<THEAD valign=~"top~">" skip
    "<TR>" skip
    "<TH><b>Pedido</TH>" skip
    "<TH><b>Data</TH>" skip
    "<TH><b>For.Cod.</TH>" skip
    "<TH><b>Razao Social</TH>" skip
    "<TH><b>Previsao</TH>" skip
    "<TH><b>Qtd.Solicitada</TH>" skip
    "<TH><b>Saldo</TH>" skip
    "<TH><b>Fil</TH>" skip
    "<TH><b>Comp</TH>" skip
    "</TR> </THEAD>" skip 
    "<TBODY>" skip
    .
***/ 
venvmail = yes.
def buffer npedid for pedid.

def temp-table tt-pedid
    field pednum like pedid.pednum
    field peddat like pedid.peddat
    field forcod like pedid.clfcod
    field fornom like forne.fornom
    field peddti like pedid.peddti
    field peddtf like pedid.peddtf
    field qtdped as dec
    field qtdpen as dec
    field etbcod like pedid.etbcod
    field compra as char
    field situacao as char
    index i1 situacao .
    
def var vped as int.
def var vpen as int.
def var vcomp as character.

for each pedid where pedid.pedtdc = 1 and 
         pedid.etbcod = 999 and 
         pedid.sitped = "A" and pedid.peddat >= 01/01/08
         :

    if pedid.peddti <= 01/01/2009 then next.
    if pedid.peddtf >= today + 15 then next.
      
    find first npedid where 
                npedid.etbcod = 999 and
               (npedid.pedtdc = 4 or
                npedid.pedtdc = 6) and
                /*npedid.pedsit = yes and*/
                npedid.comcod = pedid.pednum
                no-lock no-error.
    if avail npedid
    then next.

    if today - pedid.peddtf > 32
    then do transaction:
        pedid.sitped = "F".
    end.
    
    if pedid.sitped = "F"
    then next.
    
    assign vcomp = "".
    
    release compr.
    find first compr where compr.comcod = pedid.comcod no-lock no-error.
    
    if avail compr
    then vcomp = caps(string(compr.comnom,"x(01)")).

    vped = 0.
    vpen = 0.
    for each liped of pedid no-lock .
        find produ where produ.procod = liped.procod no-lock no-error.
        if not avail produ then next.
        if produ.catcod >= 41
        then next.
        vped = vped + liped.lipqtd.
        vpen = vpen + (liped.lipqtd - liped.lipent).    
    end. 
    if vped = 0 then next.
    
    /*
        find produ where produ.procod = liped.procod no-lock no-error.
        if not avail produ then next.
        if produ.catcod >= 41
        then next.
    */    
        find first forne where 
        forne.forcod = pedid.clfcod no-lock NO-ERROR.
        if not avail forne
        then next.
        
        /**
        put unformatted
        "<TR><TD>" pedid.pednum "</TD>"  
        "<TD>" pedid.peddat     "</TD>"
        "<TD>" forne.forcod     "</TD>"
        "<TD>" forne.fornom format "x(30)" "</TD>"
        "<TD>" pedid.peddti format "99/99/9999" " a " 
               pedid.peddtf format "99/99/9999"
        "</TD>"
        "<TD>" vped "</TD>"
        "<TD>" vpen "</TD>"
        "<TD>" pedid.etbcod format ">>9" "</TD>"
        "<TD>" vcomp "</TD>"
        "</TR>"
        skip.
        **/
        
        venvmail = yes.
    create tt-pedid.
    assign
        tt-pedid.pednum = pedid.pednum
        tt-pedid.peddat = pedid.peddat
        tt-pedid.forcod = pedid.clfcod
        tt-pedid.fornom = forne.fornom
        tt-pedid.peddti = pedid.peddti
        tt-pedid.peddtf = pedid.peddtf
        tt-pedid.qtdped = vped
        tt-pedid.qtdpen = vpen
        tt-pedid.etbcod = pedid.etbcod
        tt-pedid.compra = vcomp
        .
    if tt-pedid.peddtf >= today
    then tt-pedid.situacao = "Vencido".
    else tt-pedid.situacao = "Vencer". 
         
end.
/*
put "</TBODY> </TABLE>" skip.
output close.
*/

output to value(varquivo). 
put unformatted
"<HTML>" skip.

PUT unformatted
    "<TABLE border=~"2~" frame=~"hsides~" rules=~"groups~"" skip
    "          summary=~"DREBES & CIA LTDA~">" skip
    "<CAPTION><b>PEDIDOS DE COMPRA EM ATRASO MOVEIS - VENCIDOS</CAPTION>" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"left~">" skip
    "<COLGROUP align=~"left~">" skip
    "<COLGROUP align=~"right~">"  skip
    "<COLGROUP align=~"right~">"  skip
    "<COLGROUP align=~"left~">"  skip
    "<THEAD valign=~"top~">" skip
    "<TR>" skip
    "<TH><b>Pedido</TH>" skip
    "<TH><b>Data</TH>" skip
    "<TH><b>For.Cod.</TH>" skip
    "<TH><b>Razao Social</TH>" skip
    "<TH><b>Previsao</TH>" skip
    "<TH><b>Qtd.Solicitada</TH>" skip
    "<TH><b>Saldo</TH>" skip
    "<TH><b>Fil</TH>" skip
    "<TH><b>Comp</TH>" skip
    "</TR> </THEAD>" skip 
    "<TBODY>" skip
    .

for each tt-pedid where tt-pedid.situacao = "Vencido":
    put unformatted
        "<TR><TD>" tt-pedid.pednum "</TD>"  
        "<TD>" tt-pedid.peddat     "</TD>"
        "<TD>" tt-pedid.forcod     "</TD>"
        "<TD>" tt-pedid.fornom format "x(30)" "</TD>"
        "<TD>" tt-pedid.peddti format "99/99/9999" " a " 
               tt-pedid.peddtf format "99/99/9999"
        "</TD>"
        "<TD>" tt-pedid.qtdped "</TD>"
        "<TD>" tt-pedid.qtdpen "</TD>"
        "<TD>" tt-pedid.etbcod format ">>9" "</TD>"
        "<TD>" tt-pedid.compra "</TD>"
        "</TR>"
        skip.

end.
put "</TBODY> </TABLE>" skip(2).

PUT unformatted
    "<TABLE border=~"2~" frame=~"hsides~" rules=~"groups~"" skip
    "          summary=~"DREBES & CIA LTDA~">" skip
    "<CAPTION><b>PEDIDOS DE COMPRA EM ATRASO MOVEIS - A VENCER</CAPTION>" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"left~">" skip
    "<COLGROUP align=~"left~">" skip
    "<COLGROUP align=~"right~">"  skip
    "<COLGROUP align=~"right~">"  skip
    "<COLGROUP align=~"left~">"  skip
    "<THEAD valign=~"top~">" skip
    "<TR>" skip
    "<TH><b>Pedido</TH>" skip
    "<TH><b>Data</TH>" skip
    "<TH><b>For.Cod.</TH>" skip
    "<TH><b>Razao Social</TH>" skip
    "<TH><b>Previsao</TH>" skip
    "<TH><b>Qtd.Solicitada</TH>" skip
    "<TH><b>Saldo</TH>" skip
    "<TH><b>Fil</TH>" skip
    "<TH><b>Comp</TH>" skip
    "</TR> </THEAD>" skip 
    "<TBODY>" skip
    .

for each tt-pedid where tt-pedid.situacao = "Vencer":
    put unformatted
        "<TR><TD>" tt-pedid.pednum "</TD>"  
        "<TD>" tt-pedid.peddat     "</TD>"
        "<TD>" tt-pedid.forcod     "</TD>"
        "<TD>" tt-pedid.fornom format "x(30)" "</TD>"
        "<TD>" tt-pedid.peddti format "99/99/9999" " a " 
               tt-pedid.peddtf format "99/99/9999"
        "</TD>"
        "<TD>" tt-pedid.qtdped "</TD>"
        "<TD>" tt-pedid.qtdpen "</TD>"
        "<TD>" tt-pedid.etbcod format ">>9" "</TD>"
        "<TD>" tt-pedid.compra "</TD>"
        "</TR>"
        skip.

end.
put "</TBODY> </TABLE>" skip(2).



output close.


if venvmail = yes
then do:
    run /admcom/progr/envia_info.p("1006",varquivo).
end.

