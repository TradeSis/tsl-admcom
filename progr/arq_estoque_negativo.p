def var vespecial as log format "Sim/Nao".
def var varquivo as char.
varquivo = "/admcom/relat/estoque-negativo-" +
            string(today,"99999999") + "." + string(time)
            .
output to value(varquivo).
             
Put "Loja;Produto;Descricao;Quantidade;PE (sim/não);Moda/Moveis;Vex (sim/nao);
 Descontinuado (sim/nao)" skip.

for each estab no-lock,
    each estoq where estoq.etbcod = estab.etbcod and
                     estoq.estatual < 0 no-lock,
    first produ where produ.procod = estoq.procod 
            and (produ.catcod = 31 or
                 produ.catcod = 41)
                no-lock:
    
    vespecial = produ.proipival = 1  .
    find categoria where categoria.catcod = produ.catcod no-lock.

    put unformatted
         estoq.etbcod
         ";"
         estoq.procod format ">>>>>>>>9"
         ";"
         produ.pronom
         ";"
         estoq.estatual format "->>>,>>9.99"
         ";"
         vespecial
         ";"
         categoria.catnom
         ";"
         produ.ind_vex
         ";"
         produ.descontinuado
         skip
         .

end.
output close.
varquivo = replace(varquivo,"/","~\").   
varquivo = replace(varquivo,"~\admcom","l:").
 
message color red/with
        varquivo
        view-as alert-box title "Arquivo gerado".
