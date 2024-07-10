{admcab.i new}

def var vcont as integer.


assign vcont = 0.


for each clien no-lock:

   
   sresp = yes.
   run cpf.p(input clien.ciccgc, output sresp).
           
   if clien.ciccgc = ?
       or sresp = false
       or length(clien.ciccgc) <> 11
   then next.

   if clien.clicod <= 3
   then next.

            
    

    assign vcont = vcont + 1.

    if vcont mod 10000 = 0 then do:
     
     display vcont string(time,"HH:MM:SS").    

        pause 0.

    end.

end.



display vcont.