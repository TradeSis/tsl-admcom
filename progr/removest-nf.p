def input parameter p-movtdc like plani.movtdc.
def input parameter p-etbcod like plani.etbcod.
def input parameter p-emite like plani.emite.
def input parameter p-serie like plani.serie.
def input parameter p-numero like plani.numero.

def new global shared var sparam      as char.

sparam = "NOTAFISCAL=SIM" +
         "|MOVTDC=" + STRING(p-movtdc) +
         "|ETBCOD=" + string(p-etbcod) +
         "|EMITE=" + string(p-emite) +
         "|SERIE=" + string(p-serie) +
         "|NUMERO=" + string(p-numero) + 
         "|ATUALIZAR=SIM" +
         "|".

def var varqlog as char.
varqlog = "/admcom/logs/removest-nf.log".
output to value(varqlog) append.
put string(today,"99/99/9999") "-" string(time,"hh:mm:ss") skip
    sparam format "x(70)" skip
    "Executa removest20141.p" skip.
output close.
    
run removest20142.p.

sparam = "".

return.