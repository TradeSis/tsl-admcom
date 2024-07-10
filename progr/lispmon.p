{admcab.i}
def var vestvenda like estoq.estvenda.
def var varqsai as char.
varqsai = "../relat/prod_montagem" + string(time) + ".txt".

message "Confirma a geracao do arquivo?" update sresp.
if sresp = no
then leave.

if opsys = "UNIX" 
then  output to value(varqsai).
else  output to "l:\relat\listaprodutosdemontagem.txt".

for each produ where produ.protam = "SIM" no-lock.
find first estoq where estoq.procod = produ.procod no-lock no-error.
if not avail estoq then next.
vestvenda = estoq.estvenda.
put produ.procod format ">>>>>>>>9" ";" produ.pronom ";" produ.clacod ";"
vestvenda skip.
end.
output close.

if opsys = "UNIX" 
then message "Arquivo Gerado" varqsai view-as alert-box.
else 
message "Arquivo Gerado l:\relat\listaprodutosdemontagem.txt".
pause.
