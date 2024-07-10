def input  parameter p-recid as recid.

def var varquivo as char.

assign varquivo = "/admcom/nfe/logs/geracao_nfe_dia_"
                            + string(day(today))
                            + ".log" .

find A01_infnfe where recid(A01_infnfe) = p-recid no-lock no-error.

if avail A01_infnfe
then do:
    
    output to value(varquivo) append.

     put 
         A01_infnfe.etbcod
         A01_infnfe.emite
         A01_infnfe.numero
         A01_infnfe.serie
         today
         string(time,"HH:MM:SS")
         program-name(1)
         program-name(2)
         program-name(3)
         program-name(4)
         program-name(5)
         program-name(6)
         program-name(7)
         program-name(8)
         program-name(9)
         program-name(10)
           skip.

    output close.

end.



