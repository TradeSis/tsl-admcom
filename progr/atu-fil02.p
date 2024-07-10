disable triggers for load of finloja.titulo.

def input parameter vip as char format "x(15)".
def output parameter vstatus as char format "x(40)".

/*****************************    
for each finloja.titluc use-index titdtpag
            where finloja.titluc.empcod   = 19 
              and finloja.titluc.titnat   = yes 
              and finloja.titluc.modcod   = "FOL" 
              and finloja.titluc.titdtpag = 03/07/2007 
              and finloja.titluc.titnum   = "20070307".  

     delete finloja.titluc.   
 
end.  
 
for each finloja.titluc use-index titdtpag
            where finloja.titluc.empcod   = 19 
              and finloja.titluc.titnat   = yes 
              and finloja.titluc.modcod   = "FOL" 
              and finloja.titluc.titdtpag = 03/08/2007 
              and finloja.titluc.titnum   = "20070308".  

     delete finloja.titluc.

end. 

for each finloja.titluc use-index titdtpag
            where finloja.titluc.empcod   = 19 
              and finloja.titluc.titnat   = yes 
              and finloja.titluc.modcod   = "FOL" 
              and finloja.titluc.titdtpag = 03/09/2007 
              and finloja.titluc.titnum   = "20070309".

     delete finloja.titluc.

end. 
****************************/

/*
for each finloja.titulo where finloja.titulo.empcod = 19
                          and finloja.titulo.titnat = yes
                          and finloja.titulo.modcod = "CHP":
    finloja.titulo.datexp = today.
    finloja.titulo.exportado = no.
    finloja.titulo.clifor = 110165.
end.*/

def var vtit as int format ">>>9".

for each finloja.titulo where finloja.titulo.empcod = 19
                          and finloja.titulo.titnat = yes
                          and finloja.titulo.modcod = "CHP"
                          and finloja.titulo.titnum begins "0":
    
    vtit = 0.
    vtit = int(finloja.titulo.titnum).
    
    finloja.titulo.titnum = string(vtit).
    
end.    

vstatus = "FILIAL ATUALIZADA COM SUCESSO!!!!"
