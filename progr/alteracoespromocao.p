def var vtoday as date.
def var varquivo as char.

vtoday = today - 2.
varquivo = "/admcom/tmp/alteracoespromocoes/produtosalterados_" + string(vtoday,"99999999") + "_" + string(today,"99999999") + "_" 
        + replace(string(time,"HH:MM:SS"),":","") + ".csv".

message "Gerando arquivo " varquivo.
output to value(varquivo).
put unformatted skip 
"Fil;Produto;Nome;DtAltPromoc;PromInicio;PromFinal;PromValor;Categoria;"
skip.
for each estoq where estoq.dtaltprom >= vtoday and estoq.dtaltprom <= today 
        no-lock 
        by estoq.etbcod by estoq.procod.
    find produ of estoq no-lock no-error.
    if not avail produ then next.
    put unformatted 
            estoq.etbcod ";" 
            estoq.procod  ";"
            produ.pronom ";"
            estoq.dtaltprom format "99/99/9999" ";"
            estoq.estbaldat format "99/99/9999" ";" 
            estoq.estprodat format "99/99/9999" ";"
            trim(string(estoq.estproper,">>>>>>9.99")) ";"
            produ.catcod ";"
            skip.
end.
output close.
            
