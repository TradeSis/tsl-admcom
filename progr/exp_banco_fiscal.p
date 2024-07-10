def var total as dec.

message "Gerando arquivo...".

output to /admcom/relat/exp_banco_fiscal.csv.

for each plani where pladat >= 01/01/2013 and pladat <= 01/01/2014 and movtdc = 4 no-lock.

find first movim where movim.movtdc = plani.movtdc and
                       movim.etbcod = plani.etbcod and
                       movim.movdat = plani.pladat and
                       movim.placod = plani.placod no-lock.

find produ where produ.procod = movim.procod no-lock no-error.
if not avail produ then next.

find first estoq where estoq.procod = produ.procod no-lock.

total = movim.movqtm * estoq.estven.

find clafis where clafis.codfis = produ.codfis no-lock no-error.
if not avail clafis then next.

find a01_infnfe where a01_infnfe.numero = plani.numero and
                      a01_infnfe.emite = plani.etbcod no-lock no-error.
if not avail a01_infnfe then next.

find n01_icms where n01_icms.chave = a01_infnfe.chave no-lock no-error.        if not avail n01_icms then next.                        

find q01_pis where q01_pis.chave = a01_infnfe.chave no-lock no-error.
if not avail q01_pis then next.
                                       
find s01_cofins where s01_cofins.chave = a01_infnfe.chave no-lock no-error.
if not avail s01_cofins then next.
                                       
find o01_ipi where o01_ipi.chave = a01_infnfe.chave no-lock no-error.
if not avail o01_ipi then next.                                       

disp plani.numero plani.opccod format ">>>9" plani.pladat produ.pronom 
format "x(25)" produ.codfis format ">>>>>>>>>9" estoq.estven movim.movqtm total
format ">>,>>>,>>9.99" n01_icms.vbc n01_icms.picms n01_icms.vicms n01_icms.predbcst n01_icms.vbcst clafis.mva_estado1 clafis.mva_oestado1 q01_pis.vpis s01_cofins.vcofins o01_ipi.vipi o01_ipi.pipi with width 600.

end.

output close.

message "ARQUIVO 'exp_banco_fiscal.csv' GERADO EM L:/relat" view-as alert-box.
