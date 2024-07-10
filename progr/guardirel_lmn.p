{/admcom/progr/admcab-batch.i new}
setbcod = 999.
sfuncod = 101.

def var varquivo as char.
def var varqsai as char.
def var vassunto as char.
def var vmail as char.

varquivo = "/admcom/logs/mail.sh-guradirel-" + string(day(today),"99") +
            string(month(today),"99") + string(year(today),"9999") + "." +
            string(time).

output to value(varquivo) append.
put "Inicio processamento plani-4-cron.p " 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "PLANILHA DE FECHAMENTO GERAL".
varqsai = "". 
run /admcom/progr/plani-4-cron.p (output varqsai).
    
put "Final  processamento plani-4-cron.p "  
        today " "
        string(time,"hh:mm:ss") skip.
output close.
    
if search(varqsai) <> ?
then do:
    run envia_info_anexo_lmn.p(input "1001", input varquivo,
                           input varqsai, input vassunto).
end.
                        
    
return.
