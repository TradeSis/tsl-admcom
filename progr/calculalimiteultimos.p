

FUNCTION limite-cred-scor return decimal
     ( input rec-clien as recid )   .
         def var vcalclim as dec.
             def var vpardias as dec.
                 run callim-cred-scor-batch.p(input rec-clien,
                                            output vcalclim).
                                              return vcalclim.
                                                end function.     

def var providev as dec.
def var limite-cred-scor as dec.
def var contacliente as int.
def var limitecalculado as dec.

def var basedecalculo as dec.
def var vendasaudavel as dec.
def var diaspagamento as int.
def var percsaudavel as dec.
/* def var letra as char. */

def input parameter letra as char.

def var calendariobase as date.
def var parcelasspc as int.

calendariobase = 01/01/2010.
              
              /*
letra = "A".
                */
                
def var arquivodestino as char.



contacliente = 0.

for each clien where
clicod = int(letra) no-lock.
   
            pause 0.

if clien.clinom = "" then next.

parcelasspc = 0.

limitecalculado = 0.
providev = 0.

basedecalculo = 0.
vendasaudavel = 0.
percsaudavel = 0.

contacliente = contacliente + 1.

limite-cred-scor = limite-cred-scor(recid(clien)).

for each fin.titulo use-index iclicod where        
          fin.titulo.clifor = clien.clicod and
          fin.titulo.titsit = "LIB" and fin.titulo.empcod = 19
      and fin.titulo.titnat = no and fin.titulo.modcod = "CRE"
      and fin.titulo.titdtpag = ?
      and fin.titulo.titdtven >= calendariobase
      
                            no-lock.  
                     
                     if fin.titulo.titvlcob <= 0 then next.                               
                     if fin.titulo.titvlcob = ? then next.                                       
      if today - fin.titulo.titdtven > 30 then do:
                                    parcelasspc = parcelasspc + 1.
                             end.
                                                    
                       providev = providev + fin.titulo.titvlcob.

pause 0.

                    end.
  

for each dragao.titulo use-index iclicod where                       
          dragao.titulo.clifor = clien.clicod and                    
                    dragao.titulo.titsit = "LIB" and dragao.titulo.empcod = 19    
        and dragao.titulo.titnat = no and dragao.titulo.modcod = "CRE"    
              and dragao.titulo.titdtpag = ?
              and dragao.titulo.titdtven >= calendariobase
              and dragao.titulo.titpar >= 30
               
                                          no-lock. 
         
                                                                       pause 0.
                                 if dragao.titulo.titvlcob <= 0 then next.                                              
                             if dragao.titulo.titvlcob = ? then next.                                                  
                 if today - dragao.titulo.titdtven > 30 then do:                                             parcelasspc = parcelasspc + 1.  
                          end.                                   
                                                                      
                                                                       
                                                                       
                       providev = providev + dragao.titulo.titvlcob. 
                      
                                                                             
                                
                             end.                                     
                             

    for each fin.titulo use-index iclicod where                         
                      fin.titulo.clifor = clien.clicod and                      
                      fin.titulo.titsit = "PAG" and
                      fin.titulo.empcod = 19 and     
                      fin.titulo.titnat = no and
                      fin.titulo.modcod = "CRE" and
                      fin.titulo.titdtpag <> ? and
                      fin.titulo.titdtven >= calendariobase
                                                                                                                     no-lock.              
                                              pause 0.         
                  if fin.titulo.titvlcob <= 0 then next.   
              if fin.titulo.titvlcob = ? then next.
              
              basedecalculo = basedecalculo + fin.titulo.titvlcob.
              diaspagamento = titdtpag - titdtven.
                 
if diaspagamento <= 15 then do:
     vendasaudavel = vendasaudavel + fin.titulo.titvlcob.
                    end.
                    
                          end.                                            
                             
                             
                             
                             
                         
                             
                                                                          
                    limitecalculado = limite-cred-scor - providev.
                  
                    if limitecalculado < 0 then limitecalculado = 0.                          
                    if limitecalculado = ? then limitecalculado =  0.
                    
             percsaudavel = vendasaudavel / basedecalculo.
             percsaudavel = percsaudavel * 100.
                                              
            if percsaudavel = ? then percsaudavel = 0.
            if percsaudavel < 0 then percsaudavel = 0.                                     pause 0.
                                                               
put clien.clicod ";" clinom ";" limite-cred-scor format ">>>>>>>>>.99" ";" providev format ">>>>>>>>>>.99" ";" limitecalculado format ">>>>>>>>>>.99" ";" YEAR(today) format "9999" "-" MONTH(today) format "99" "-" DAY(today) format "99" ";" basedecalculo format ">>>>>>>>>>.99" ";" vendasaudavel format ">>>>>>>>>>.99" ";" percsaudavel ";" parcelasspc ";" time ";" skip.
pause 0.

                    end.
                    
                                                         




