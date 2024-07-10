{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 13 no-lock no-error.
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
varquivo = "/admcom/work/arquivodg013.txt".
output to value(varquivo). 
put unformatted
"ALTERACAO CARTAO PRESENTE    <BR>"
"------------------------------ <BR>"
. 
output close. 

if venvmail = yes
then do:
    run /admcom/progr/envia_dg.p("13",varquivo).
end.
