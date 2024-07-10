

message time.
def var vetbcod_aux as char.     
def var contacliente as int.

/* def var letra as char. */


def var calendariobase as date.

calendariobase = 01/01/2010.
def var qtdtitulostodos as int.
              
              /*
letra = "A".
                */
                
def var arquivodestino as char.

arquivodestino =  "/admcom/lebesintel/balanco/teste.txt".

output to value(arquivodestino).

contacliente = 0.


def var qtdnotasaprazo as int.
def var statuscliente as char.
def var qtdnotasavista as int.
def var comprouantigamente as int.
def var comprouanoanterior as int.
def var qtdtitulosmesanterior as int.

def var mesatualprazo as int.
def var mesatualvista as int.

for each clien where
clicod = 10407819 no-lock.
   
statuscliente = "NAO SE ENQUADRA".

            pause 0.
if clien.clinom = "" then next.

/* LOJA DO CLIENTE */

    vetbcod_aux = string(clien.clicod).                              
       
      if length(vetbcod_aux) = 10                                      
           then vetbcod_aux = substring(vetbcod_aux,2,3).                   
        else vetbcod_aux = substr(vetbcod_aux,length(vetbcod_aux) - 1,2).



comprouantigamente = 0.

                /*comprou a mais de um ano? */
        find first plani where             
                plani.pladat < today - 365 and    
                plani.movtdc = 5 and               
                plani.Desti = clien.clicod             
                    no-lock no-error.         
                         
                        if avail plani then do:
                        comprouantigamente = 1.                        
                         end.
                         else do:
                        comprouantigamente = 0. 
                        end.


                 /*comprou ano anterior ao mes */
                    comprouanoanterior = 0.
                  find first plani where                            
                   plani.pladat >= today - 365 and
                   plani.pladat <= date(month(today),1,year(today)) - 1 and        ~              plani.movtdc = 5 and                      
                   plani.Desti = clien.clicod                
                                   no-lock no-error.                     
                                                                                         
                            if avail plani then do:           
                             comprouanoanterior = 1.                                                        end.                             
                            else do:                         
                             comprouanoanterior = 0.           
                                end.                              
                                
                 qtdtitulosmesanterior = 0.
                      
                 /* titulos mes anterior */
            find first fin.titulo use-index iclicod where                                   fin.titulo.clifor = clien.clicod and                      
           fin.titulo.empcod = 19      
          and fin.titulo.titnat = no and fin.titulo.modcod = "CRE"                   and fin.titulo.titdtven >= date(month(today) - 1,1,year(today))
   and fin.titulo.titdtven <= date(month(today),1,year(today)) - 1
    no-lock no-error.

                        if avail titulo then do:                                                qtdtitulosmesanterior = 1.
                         end.
                         else do: 
                         qtdtitulosmesanterior = 0.                                                     end.                                                        





                 qtdtitulostodos = 0.                                     
                                                                                  
                    /* titulos todos */                                     
               find first fin.titulo use-index iclicod where                                    fin.titulo.clifor = clien.clicod and             
              fin.titulo.empcod = 19                                                         and fin.titulo.titnat = no and fin.titulo.modcod = "CRE"                                     no-lock no-error.                                                           
                                                                                   
                           if avail titulo then do:                                                  qtdtitulostodos = 1.                                                                end.                                                                              else do:                                                                          qtdtitulostodos = 0.                                                     end.                                                  















              mesatualprazo = 0.
           /* VENDA MES ATUAL A PRAZO */
       find first plani where                         
           plani.pladat >= date(month(today),1,year(today)) and                
           plani.pladat <= today and                      
           plani.movtdc = 5 and                           
           plani.crecod = 2 and                           
           plani.modcod = "CRE" and                       
           plani.Dest = clien.clicod                      
             no-lock no-error.                        
                                                     
                   if avail plani then do:                        
                     mesatualprazo = 1.
                     end.
                     else do:
                     mesatualprazo = 0.
                     end.

        
                        mesatualvista = 0.
                   /* VENDA MES A VISTA A PRAZO */                              
                              find first plani where                                         
             plani.pladat >= date(month(today),1,year(today)) and       
             plani.pladat <= today and                                  
             plani.movtdc = 5 and                                       
             plani.crecod = 1 and                                       
             plani.modcod = "VVI" and                                   
             plani.Dest = clien.clicod                                  
                    no-lock no-error.                                        
                                                                            
                                                                                               if avail plani then do:                            
                        mesatualvista = 1.                                                        end.                                             
                             else do:                                         
                     mesatualvista = 0.                               
                   end.                                             
            








                                                                               
        /*CLIENTES NOVOS PROSPECT */                                         
                                                                                  
                  if clien.dtcad >=  date(month(today),1,year(today)) and        
                clien.dtcad <=  date(month(today),1,year(today)) + 31 and       
                          (mesatualvista = 0 or mesatualprazo = 0) then do:                           
                statuscliente = "NOVOS PROSPECT".                      
put clien.clicod ";" clien.clinom ";" statuscliente format "x(30)" ";" skip.   
                        next.                                                  
                                         end.   



                      /* CLIENTES PROSPECT */                                                                                                                                       
           if(                                                                                (comprouantigamente = 0)                                                      and(comprouanoanterior = 0)                                                        and(qtdtitulostodos = 0)                                                     and (mesatualvista = 0 or mesatualprazo = 0)                                    ) then do:                                                                  statuscliente = "PROSPECT".                  
put clien.clicod ";" clien.clinom ";" statuscliente format "x(30)" ";" skip. 
          next.                                                              
                                    end.                                               
                                                                                    
                                                            



      /* CLIENTES NOVOS COMPRA A PRAZO */


            if clien.dtcad >=  date(month(today),1,year(today)) and
               clien.dtcad <=  date(month(today),1,year(today)) + 31 and
               mesatualprazo = 1 then do:
               statuscliente = "NOVO COMPRA A PRAZO".                  
                              put clien.clicod ";" clien.clinom ";" statuscliente format "x(30)" ";" skip. 
          next.                                                              
                          end.


    /*CLIENTES NOVOS COMPRA A VISTA */
    
                if clien.dtcad >=  date(month(today),1,year(today)) and                        clien.dtcad <=  date(month(today),1,year(today)) + 31 and    
                          mesatualvista = 1 then do:                                               statuscliente = "NOVO COMPRA A VISTA".                       
put clien.clicod ";" clien.clinom ";" statuscliente format "x(30)" ";" skip.                            next.                                                                    end.                                              
    








/* CLIENTES ATIVOS COMPRA PRAZO */
qtdnotasaprazo = 0.

         find first plani where 
         plani.pladat >= today - 365 and
         plani.pladat <= today and
         plani.movtdc = 5 and
         plani.crecod = 2 and
         plani.modcod = "CRE" and
         plani.Dest = clien.clicod
               no-lock no-error.
         
         if avail plani then do:
                    statuscliente = "ATIVO COMPRA A PRAZO".
               put clien.clicod ";" clien.clinom ";" statuscliente format "x(30)" ";" skip.     next.
                  end.
         

 /* CLIENTES ATIVOS COMPRA A VISTA */                                             
     qtdnotasavista = 0.                                                            
                                                                                             find first plani where                                                          plani.pladat >= today - 365 and                                                  plani.pladat <= today and                                                       plani.movtdc = 5 and                                                             plani.crecod = 1 and                                                           plani.modcod = "VVI" and                                                        plani.Dest = clien.clicod                                                               no-lock no-error.                                               
                                                                                       
                if avail plani then do:                                               
                          statuscliente = "ATIVO COMPRA A VISTA".                put clien.clicod ";" clien.clinom ";" statuscliente format "x(30)" ";" skip. 
  next.                                                                        
                    end.                                                         
      










         /* INADIMPLENTE */
         
                find first fin.titulo use-index iclicod where                
                       fin.titulo.clifor = clien.clicod and                                fin.titulo.titsit = "LIB" and fin.titulo.empcod = 19         
                  and fin.titulo.titnat = no and fin.titulo.modcod = "CRE"     
                         and fin.titulo.titdtpag = ? 
                         and fin.titulo.titdtven <= today - 120
                      no-lock no-error.                


                       if avail fin.titulo then do:                                                statuscliente = "INADIMPLENTE".
  put clien.clicod ";" clien.clinom ";" statuscliente format "x(30)" ";" skip.
                          next.                                                                             end.




         /* INADIMPLENTE NO DRAGAO */                                                    
                                                                                        
                        find first dragao.titulo use-index iclicod where                           dragao.titulo.clifor = clien.clicod and                                  dragao.titulo.titsit = "LIB" and
                    dragao.titulo.empcod = 19          
   and dragao.titulo.titnat = no and dragao.titulo.modcod = "CRE"                   and dragao.titulo.titdtpag = ?                           
                     and dragao.titulo.titdtven <= today - 120                
                        no-lock no-error.                                        
                                                                                                                                                                                      if avail dragao.titulo then do:                                       statuscliente = "INADIMPLENTE".
 put clien.clicod ";" clien.clinom ";" statuscliente format "x(30)" ";" skip. 
                          next.                                                
                       end.                                               



       /* CLIENTES ATIVO CONTRATO */                                            
                                                                                
                                                                                                                                                               
          find first fin.titulo use-index iclicod where                         
          fin.titulo.clifor = clien.clicod and                                  
          fin.titulo.titsit = "LIB" and fin.titulo.empcod = 19                  
         and fin.titulo.titnat = no and fin.titulo.modcod = "CRE"               
       and fin.titulo.titdtpag = ? no-lock no-error.                                                                                                           
        if avail fin.titulo then do:                                                     statuscliente = "ATIVO CONTRATO".                                     
 put clien.clicod ";" clien.clinom ";" statuscliente format "x(30)" ";" skip.                         next.                                                    
                                                            end.                













/*
                                                                                                                                     else do:
                          statuscliente = "INATIVO".                   
  put clien.clicod ";" clien.clinom ";" statuscliente format "x(30)" ";" skip.
                        next.                                                 
                         end.
                         
*/



/* inativo v2 */



      if(
         (comprouanoanterior = 0)
     and(qtdtitulosmesanterior = 0)
     and (mesatualprazo = 0)   and (mesatualvista = 0)     
     ) then do:
 
    statuscliente = "INATIVO". 
  put clien.clicod ";" clien.clinom ";" statuscliente format "x(30)" ";" skip.
  next.                                         
                    end.
                
                





/* RECUPERADOS A PRAZO */



      if(
        (comprouantigamente = 1)
     and(comprouanoanterior = 0)
     and(qtdtitulosmesanterior = 0)
     and (mesatualprazo = 1)     
     ) then do:
 
    statuscliente = "RECUPERADO COMPRA A PRAZO". 
  put clien.clicod ";" clien.clinom ";" statuscliente format "x(30)" ";" skip.
  next.                                         
                    end.
                
                




/* RECUPERADOS A VISTA */



      if(
        (comprouantigamente = 1)
     and(comprouanoanterior = 0)
     and(qtdtitulosmesanterior = 0)
     and (mesatualvista = 1)     
     ) then do:
 
    statuscliente = "RECUPERADO COMPRA A VISTA". 
  put clien.clicod ";" clien.clinom ";" statuscliente format "x(30)" ";" skip.
  next.                                         
                    end.
                



                   
 /* NAO SE ENQUADROU EM NADA... */        
 put clien.clicod ";" clien.clinom ";" statuscliente format "x(30)" ";" skip.             


end.
                                 
                    
                  
                    
output close.
message time.                                                            
message contacliente.



