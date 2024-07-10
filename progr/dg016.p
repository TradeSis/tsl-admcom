{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 16 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.
def var varquivo as char.
def var venvmail as log init no.

varquivo = "/admcom/work/arquivodg016.txt".
output to value(varquivo). 
put unformatted
"NOTAS NAO CONF MAIS Q 3 DIAS  <BR>"
"------------------------------ <BR>"
. 
output close. 

if venvmail = yes
then do:
    run /admcom/progr/envia_dg.p("16",varquivo).
end.
