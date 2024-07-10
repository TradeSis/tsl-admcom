{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 10 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.
def var varquivo as char.

def var vlimite as dec.
def var assunto as char.
def var vldesc  as dec.
def var venvmail as log init no.
def var tvlcob as dec.
def var tvlpag as dec.
def var tdesno as dec.
def var tdesan as dec.
def buffer bplani for plani.

varquivo = "/admcom/work/arquivodg012.txt".
output to value(varquivo). 
put unformatted
"AJUSTE DE ESTOQUE MAIOR QUE 1    <BR>"
"------------------------------ <BR>"
. 
for each plani where 
         plani.movtdc = 7 and 
         plani.pladat = today - 1
         no-lock.
    if plani.pedcod = 1
    then next.
    for each movim where
             movim.etbcod = plani.etbcod and
             movim.placod = plani.placod and
             movim.movtdc = plani.movtdc
             no-lock.
    if movim.movqtm > 1
    then do:
        find produ where produ.procod = movim.procod no-lock.
        PUT unformatted
        "Filial : " movim.etbcod format ">>9"           " <BR>"
        "Data   : " plani.pladat format "99/99/9999"    " <BR>"
        "Numero : " plani.numero                        " <BR>"
        "Produto: " movim.procod                        " <BR>"
        "Descricao: "  produ.pronom                     " <BR>"
        "Quantidade: " movim.movqtm                     " <BR>"
        "-----------------------------------"           " <BR>"
        .
        venvmail = yes.
    end.
    end. 
    find bplani where bplani.etbcod = plani.etbcod and
                      bplani.placod = plani.placod and
                      bplani.serie  = plani.serie
                      no-error.
    if avail bplani and bplani.pedcod = 0
    then do transaction:
        bplani.pedcod = 1.                  
    end.
end.
 
for each plani where 
         plani.movtdc = 8 and 
         plani.pladat = today - 1
         no-lock.
    if plani.pedcod = 1 then next.
    for each movim where
             movim.etbcod = plani.etbcod and
             movim.placod = plani.placod and
             movim.movtdc = plani.movtdc
             no-lock.
    if movim.movqtm > 1
    then do:
        find produ where produ.procod = movim.procod no-lock.
        put unformatted
        "Filial : " movim.etbcod format ">>9"           " <BR>"
        "Data   : " plani.pladat format "99/99/9999"    " <BR>"
        "Numero : " plani.numero                        " <BR>"
        "Produto: " movim.procod                        " <BR>"
        "Descricao: "  produ.pronom                     " <BR>"
        "Quantidade: " movim.movqtm                     " <BR>"
        "-----------------------------------"           " <BR>"
        .
        venvmail = yes.
    end.
    end.
    find bplani where bplani.etbcod = plani.etbcod and
                      bplani.placod = plani.placod and
                      bplani.serie  = plani.serie
                      no-error.
    if avail bplani and bplani.pedcod = 0
    then do transaction:
        bplani.pedcod = 1.                  
    end.

end.
output close. 

if venvmail = yes
then do:
    run /admcom/progr/envia_dg.p("12",varquivo).
end.
