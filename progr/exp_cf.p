{admcab.i}

def var vcod as char format "x(18)".


message "Gerar arquivo de classificacao fiscal" update sresp.
if not sresp
then return.



output to l:\audit\cf.txt.

for each clafis no-lock by clafis.codfis.

    put unformatted
        clafis.codfis        format "x(10)"      
        "01/01/1900"
        clafis.desfis        format "x(255)" skip.
             
             
end.
output close.
message "Arquivo l:\audit\cf.txt  Gerado".
pause.
              
              
