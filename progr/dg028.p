{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 28 no-lock no-error.
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
varquivo = "/admcom/work/arquivodg028.txt".
output to value(varquivo). 
put unformatted
"PEDIDOS ESPECIAIS EM ATRASO PELO FORNECEDOR <BR><BR>"
. 
PUT unformatted
    "<TABLE border=~"2~" frame=~"hsides~" rules=~"groups~"" skip
    "          summary=~"DREBES & CIA LTDA~">" skip
    "<CAPTION><b>" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"right~">" skip
    "<COLGROUP align=~"left~">" skip
    "<COLGROUP align=~"left~">" skip
    "<COLGROUP align=~"left~">"  skip
    "<THEAD valign=~"top~">" skip
    "<TR>" skip
    "<TH><b>Ped.Loj.<BR>" skip
    "<TH><b>Ped.Fab.<BR>" skip
    "<TH><b>For.Cod.<BR>" skip
    "<TH><b>Razao Social<BR>" skip
    "<TH><b>Previsao<BR>" skip
    "<TBODY>" skip
    .
 
venvmail = no.
def buffer npedid for pedid.
for each pedid where pedtdc = 6 and 
    sitped = "P" and comcod <> 0 no-lock,
    first npedid where npedid.pedtdc = 1 and
                      npedid.etbcod = 999 and
                      npedid.pednum = pedid.comcod
                      no-lock by npedid.peddti.
    if not avail npedid
    then next. 
    if npedid.sitped = "F"
    then.
    else next. 
    if npedid.peddtf >= today  and
        npedid.peddtf - today <= 3
    then do:

    find first forne where forne.forcod = npedid.clfcod no-lock NO-ERROR.
    if not avail forne
    then next.
    
    put unformatted
        "<TR><TD>" pedid.pednum  
        "<TD>" npedid.pednum
        "<TD>" forne.forcod
        "<TD>" forne.fornom format "x(30)"
        "<TD>" npedid.peddti format "99/99/9999" " a " 
               npedid.peddtf format "99/99/9999"
        "</TR>"
        skip.
    venvmail = yes.
    end.
end.
put "</TABLE>" skip.
output close.

if venvmail = yes
then do:
    run /admcom/progr/envia_info.p("28",varquivo).
end.
