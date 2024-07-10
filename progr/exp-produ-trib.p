{admcab.i new}

output to /admcom/relat/exp-produ-trib.txt.

for each produ where produ.proseq = 0 no-lock,
    first clafis of produ no-lock:
    disp produ.procod          column-label "Produto"     format ">>>>>>>>9"
         produ.pronom          column-label "Descricao"   format "x(45)"
         clafis.codfis         column-label "NCM"
         produ.proipiper       column-label "Tributacao"
         clafis.mva_estado1    column-label "MVA!Interno"
         clafis.mva_oestado1   column-label "MVA!Interestado"
         clafis.perred         column-label "Reducao!de Base"
         with frame f-dis down width 120
         .
         
end.    
output close.

