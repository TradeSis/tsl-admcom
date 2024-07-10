def output parameter varquivo as char.
{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 1007 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para INFORMATIVO nao cadastrado ou desativado".
    pause 0.
    return.
end.
def var venvmail as log.
varquivo = "/admcom/work/informativo1007.txt".
output to value(varquivo). 
put unformatted
"<HTML>"  SKIP.
/*
"PEDIDOS DE COMPRA EM ATRASO CONFECCAO <BR><BR>"
. */
PUT unformatted
    "<TABLE border=~"2~" frame=~"hsides~" rules=~"groups~"" skip
    "          summary=~"DREBES & CIA LTDA~">" skip
    "<CAPTION><b>PEDIDOS DE COMPRA EM ATRASO CONFECCAO</CAPTION>" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"left~">" skip
    "<COLGROUP align=~"left~">" skip
    "<COLGROUP align=~"left~">"  skip
    "<THEAD valign=~"top~">" skip
    "<TR>" skip
    "<TH><b>Pedido</TH>" skip
    "<TH><b>Data</TH>" skip
    "<TH><b>For.Cod.</TH>" skip
    "<TH><b>Razao Social</TH>" skip
    "<TH><b>Previsao</TH>" skip
    "<TH><b>Fil></TH>" skip
    "</TR> </THEAD>" skip
    "<TBODY>" skip
    .
 
venvmail = no.
def buffer npedid for pedid.
def var vqtd as int.
for each pedid where pedid.pedtdc = 1 and 
    pedid.sitped = "A" and pedid.peddat >= 01/01/08 and
    pedid.peddti >= 01/01/2009 no-lock:
    find first npedid where 
                npedid.etbcod = 999 and
               (npedid.pedtdc = 4 or
                npedid.pedtdc = 6) and
                /*npedid.pedsit = yes and*/
                npedid.comcod = pedid.pednum
                no-lock no-error.
    if avail npedid
    then next.
    
    if pedid.peddtf <= today 
    then do:
        find first liped where liped.etbcod = pedid.etbcod and
                               liped.pedtdc = pedid.pedtdc and
                               liped.pednum = pedid.pednum
                               no-lock no-error.
        if not avail liped
        then next.
        find produ where produ.procod = liped.procod no-lock no-error.
        if not avail produ then next.
        if produ.catcod < 41
        then next.
        
        find first forne where 
        forne.forcod = pedid.clfcod no-lock NO-ERROR.
        if not avail forne
        then next.
    
        put unformatted
        "<TR><TD>" pedid.pednum "</TD>" 
        "<TD>" pedid.peddat     "</TD>"
        "<TD>" forne.forcod     "</TD>"
        "<TD>" forne.fornom format "x(30)" "</TD>"
        "<TD>" pedid.peddti format "99/99/9999" " a " 
               pedid.peddtf format "99/99/9999"
        "</TD>" 
        "<TD>" pedid.etbcod format ">>9" "</TD>"
        "</TR>"
        skip.
        venvmail = yes.
        vqtd = vqtd + 1.
        /*
        if vqtd = 10
        then leave.
        */
    end.
end.
put "</TBODY> </TABLE> </HTML>" skip.
output close.

if venvmail = yes
then do:
    run /admcom/progr/envia_info.p("1007",varquivo).
end.

