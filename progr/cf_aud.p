{admcab.i}



message "Gerar arquivo de classificacao fiscal" update sresp.
if not sresp
then return.



output to l:\audit\cf.txt.

for each clafis no-lock by clafis.codfis.
   
    if clafis.codfis = 0
    then next.

    put unformatted
        string(clafis.codfis) format "x(10)"      
        "01/01/1900"
        clafis.desfis         format "x(90)" skip.
             
             
end.
output close.
message "Arquivo l:\audit\cf.txt  Gerado".
pause.
              
              
