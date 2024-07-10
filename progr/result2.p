{admcab.i }
{result.i new}


   def var varquivo as char.
   def var vdti as date.
   def var vmes as int format "99".
   def var vano as int format "9999".
   
   assign vmes = month(today)
          vano = year(today).            
   disp vmes Label "Mês"
        vano label "Ano"
        with frame f-x 1 col side-label.
          
   update vmes 
          vano 
         with frame f-x.
    
   assign vdti = date(vmes,1,vano).
              
   if opsys = "UNIX"  
   then varquivo = "../relat-auto/Encerra/resultado" + string(vano,"9999") + 
                      string(vmes,"99") + ".txt". 
   else varquivo = "l:\relat-auto\Encerra\resultado" + string(vano,"9999") + 
                      string(vmes,"99") + ".txt".

    
  
   create tt-result.
   
   if search(varquivo) <> ?
   then do:
        input from value(varquivo).
        import tt-result.
   end.
   input close.     

   tt-result.dtresult = vdti.

   update tt-result.rec-oper label "Rec.Operac." with frame f-x.
   disp tt-result.dtresul no-label.                
   output to value (varquivo).
   export tt-result.
   output close.
   
   message "Mes/Ano: " vmes "/" vano skip 
           "Valor Informado: " tt-result.rec-oper skip 
           view-as alert-box.
           
           
       
