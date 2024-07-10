{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 29 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.
def var varquivo as char.
def var venvmail as log.
varquivo = "/admcom/relat/arquivodg029M.txt".
output to value(varquivo). 
put unformatted
"PRODUTOS COM ALTERACAO DE PRECO NAS ULTIMAS 24 HORAS<BR>" SKIP
"DAS 12:00HS DO DIA " TODAY - 1 " ATE AS 12:00HS DO DIA " TODAY "<BR>" SKIP
"SETOR: 31 MOVEIS <BR>" SKIP
. 
PUT unformatted
    "<TABLE border=~"2~" frame=~"hsides~" rules=~"groups~"" skip
    "          summary=~"DREBES & CIA LTDA~">" skip
    "<CAPTION><b>" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"left~">" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"left~">" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"right~">"  skip
    "<THEAD valign=~"top~">" skip
    "<TR>" skip
    "<TH><b>Codigo<BR>" skip
    "<TH><b>Descricao<BR>" skip
    "<TH><b>Data<BR>" skip
    "<TH><b>Hora<BR>" skip
    "<TH><b>Preco<BR>" skip
    "<TBODY>" skip
    .
 
venvmail = no.

def var vhora as int.
vhora = 3600 * 12 .
for each hispre where
         hispre.dtalt >= today - 1 no-lock:
    if (hispre.dtalt = today - 1 and
       hispre.hora-inc < vhora) or
       (hispre.dtalt = today  and
       hispre.hora-inc > vhora)
    then next.    
    if hispre.estvenda-ant = hispre.estvenda-nov and
       hispre.estpromo-ant = hispre.estpromo-nov 
    then next.
    find produ where produ.procod = hispre.procod and
                   produ.catcod = 31
        no-lock no-error.
    if not avail produ then next.
    put unformatted
        "<TR><TD>" produ.procod format ">>>>>>>9" 
        "<TD>" produ.pronom 
        "<TD>" hispre.dtalt
        "<TD>" string(hispre.hora-inc,"hh:mm:ss")
        "<TD>" hispre.estvenda-nov format ">>,>>9.99"
        "</TR>"
        skip.
    venvmail = yes.
end.
put "</TABLE>" skip.
output close.
 
if venvmail = yes
then do:
    run /admcom/progr/envia_info.p("29",varquivo).
end.

pause 5 no-message.

varquivo = "/admcom/relat/arquivodg029C.txt".
output to value(varquivo). 
put unformatted
"PRODUTOS COM ALTERACAO DE PRECO NAS ULTIMAS 24 HORAS<BR>" SKIP
"DAS 12:00HS DO DIA " TODAY - 1 " ATE AS 12:00HS DO DIA " TODAY "<BR>" SKIP
"SETOR: 41 CONFECCOES <BR>" SKIP
. 
PUT unformatted
    "<TABLE border=~"2~" frame=~"hsides~" rules=~"groups~"" skip
    "          summary=~"DREBES & CIA LTDA~">" skip
    "<CAPTION><b>" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"left~">" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"left~">" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"right~">"  skip
    "<THEAD valign=~"top~">" skip
    "<TR>" skip
    "<TH><b>Codigo<BR>" skip
    "<TH><b>Descricao<BR>" skip
    "<TH><b>Data<BR>" skip
    "<TH><b>Hora<BR>" skip
    "<TH><b>Preco<BR>" skip
    "<TBODY>" skip
    .
 
venvmail = no.

for each hispre where
         hispre.dtalt >= today - 1 no-lock:
    if (hispre.dtalt = today - 1 and
       hispre.hora-inc < vhora) or
       (hispre.dtalt = today  and
       hispre.hora-inc > vhora)
    then next.    
    if hispre.estvenda-ant = hispre.estvenda-nov and
       hispre.estpromo-ant = hispre.estpromo-nov 
    then next.
    find produ where produ.procod = hispre.procod and
                    produ.catcod = 41
        no-lock no-error.
    if not avail produ then next.
    put unformatted
        "<TR><TD>" produ.procod format ">>>>>>>9" 
        "<TD>" produ.pronom 
        "<TD>" hispre.dtalt
        "<TD>" string(hispre.hora-inc,"hh:mm:ss")
        "<TD>" hispre.estvenda-nov format ">>,>>9.99"
        "</TR>"
        skip.
    venvmail = yes.
end.
put "</TABLE>" skip.
output close.
 
if venvmail = yes
then do:
    run /admcom/progr/envia_info.p("29",varquivo).
end.

