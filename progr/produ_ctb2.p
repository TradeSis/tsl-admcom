/*by Leote*/

{admcab.i}

message "Gerando arquivo...".

output to /admcom/relat/produ_ctb.csv.
 
for each produ no-lock.                                                        
                                                                               
find clafis where clafis.codfis = produ.codfis no-lock no-error.

if not avail clafis then next.
                                                                               
disp produ.procod format ">>>>>>>>>>>>>>>>9" produ.pronom produ.codfis format ">>>>>>>>>>>>>>>>>9"
clafis.pericm clafis.pisent clafis.pissai clafis.cofinsent clafis.cofinssai    
clafis.perred clafis.persub clafis.sittri clafis.mva_estado1                   
clafis.mva_estado2 clafis.mva_estado3 clafis.mva_oestado1                      
clafis.mva_oestado2 clafis.mva_oesatdo3 with width 300.                         

end.

output close.

message "ARQUIVO 'produ_ctb.csv' GERADO EM L:/relat" view-as alert-box.
