def var vdata as date.

assign vdata = today.

def buffer bprodu for produ.

/*****************************************************************
******  Bloqueia compra para Produto Descontinuado        ****
******************************************************************/
for each produ where produ.descontinuado = yes and opentobuy = yes.

pause 0.

produ.opentobuy = no.
produ.datexp = today.

end.

/************************************************************************
*******  Descontinua produtos com Data de Fim de Vida Nula  *****
************************************************************************/  


/*for each produ where produ.datfimvida = ? and descontinuado = yes.    
                                                                     
pause 0.                                                                                                                                            
produ.datfimvida = today.                                             
produ.datexp = today.                                                 

end.
*/

/************************************************************************
*******  Descontinua produtos com Data de Fim de Vida ultrapassada  *****
************************************************************************/
for each produ where produ.datfimvida < vdata no-lock.

    if produ.descontinuado = yes
        or produ.datfimvida = ?
    then next.
    
    run p-descontinua-produto (input produ.procod).

end.


/************************************************************************
***********  Descontinua produtos Que começam com Asterisco (*)  ********
************************************************************************/

/*for each produ where produ.pronom begins ("*") and produ.catcod = 31 no-lock.

    if produ.descontinuado = yes
    then next.
    
    run p-descontinua-produto (input produ.procod).

end.
*/

/************************************************************************
*************  Descontinua produtos com sustenido no nome ***************
************************************************************************/
/*for each produ where produ.pronom matches ("*#*") and produ.catcod = 31 no-lock.

    if produ.descontinuado = yes
    then next.
    
    run p-descontinua-produto (input produ.procod).

end.*/

/************************************************************************
************  Descontinua produtos que o nome contenha BRICK  ***********
*************************************************************************/
/*for each produ where produ.pronom matches ("*BRICK*") and produ.catcod = 31 no-lock.

    if produ.descontinuado = yes
    then next.
    
    run p-descontinua-produto (input produ.procod).

end.
*/

/******Cria data de descontinuado para produtos descontinuados********/
for each produ where descontinuado = yes  no-lock.        
                                                                      
find first produaux where produ.procod = produaux.procod and nome_campo = "Data_descontinuado"  no-lock no-error.                  
                                                                            
      if not avail produaux then do:
         create produaux.                                                                   assign                                                                          produaux.procod = produ.procod                                                  nome_campo = string("Data_descontinuado")
             valor_campo = string(today) .                                     
       
       end.       

end.

procedure p-descontinua-produto:

    def input parameter p-procod as integer.

    find first bprodu where bprodu.procod = p-procod exclusive-lock no-error.

    if avail bprodu
    then do:
    
        assign bprodu.descontinuado = yes.
      
       /* 
        find first produaux where nome_campo = "Data_descontinuado" 
                       and produaux.procod = bprodu.procod no-lock no-error.
       
                       if avail produaux then
                               nome_campo = string("Data_descontinuado")  
                               valor_campo = string(today)
                                             else      
        create produaux.
        assign 
               produaux.procod = bprodu.procod
               nome_campo = string("Data_descontinuado")
               valor_campo = string(today) .
       */


    find first produaux where nome_campo = "Data_descontinuado"               
               and produaux.procod = bprodu.procod no-error.                       
                                                                        
                      if avail produaux then do:                              
                        nome_campo = string("Data_descontinuado").           
                        valor_campo = string(today).                          
                                 end.                                    
                                 else do:                                    
                           create produaux.                                                                   assign                                                                          produaux.procod = bprodu.procod                                                  nome_campo = string("Data_descontinuado")      
                             valor_campo = string(today) .                  
                                    end.                                                     



    end.



end procedure.

                                 
