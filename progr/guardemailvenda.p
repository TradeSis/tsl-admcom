{/admcom/progr/admcab-batch.i new}

setbcod = 999.
sfuncod = 101.

def var varquivo as char.
def var varqsai as char.
def var vassunto as char.
def var vmail as char.

varquivo = "/admcom/logs/mail.sh-gurademailvenda-" + string(day(today),"99") +
            string(month(today),"99") + string(year(today),"9999") + "." +
            string(time).


/****  EMAIL-VENDA ***
output to value(varquivo) append.
put "Inicio processamento info1008.p " 
        today " "
        string(time,"hh:mm:ss") skip.
vassunto = "".
varqsai = "". 

run /admcom/progr/info1008.p (output varqsai).
    
put "Final  processamento info1008.p "  
        today " "
        string(time,"hh:mm:ss") skip.
output close.

*** FIM EMAIL-VENDA ***/


