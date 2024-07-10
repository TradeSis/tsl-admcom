
{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 11 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.

def var varquivo as char.
def var vdados as log.
vdados = no.
varquivo = "/admcom/work/arquivodg011.txt".
output to value(varquivo).

for each estoq where estoq.datexp >= today - 2 and
                     estoq.etbcod = 900 no-lock:
    find produ where produ.procod = estoq.procod no-lock no-error.
    if not avail produ
    then next.
    for each lgaltcus where lgaltcus.procod = produ.procod
                and lgaltcus.datalt >= today - 2
                :
        if lgaltcus.aux-i = 1
        then next.
        put unformatted
        "ALTERACAO PRECO DE CUSTO  <BR>"
        "----------------------------------- <BR>"
        "Codigo     : " produ.procod format ">>>>>>>9"        " <BR>"
        "Descricao  : " produ.pronom format "x(40)"           " <BR>"
        "Data       : " lgaltcus.datalt format "99/99/9999"   " <BR>"
        "Val.Aterior: " lgaltcus.cusant format ">>>>>9.99"          " <BR>"
        "Val.Atual  : " lgaltcus.cusalt format ">>>>>9.99"          " <BR>"
        "-----------------------------------"                         " <BR>"
        . 

        lgaltcus.aux-i = 1.
        vdados = yes.
    end. 
end.  
output close.   

if vdados
then do:
    run /admcom/progr/envia_dg.p("11",varquivo).
end.


