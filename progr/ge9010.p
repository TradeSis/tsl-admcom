def input parameter par-arquivo as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.
def var vdg as char.

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.tipcon = 9010 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 10.
    return.
end.

def var vlimite as dec.
def var assunto as char.
def var vldesc  as dec.
def var venvmail as log init no.
def var tvlcob as dec.
def var tvlpag as dec.
def var tdesno as dec.
def var tdesan as dec.
def buffer bplani for plani.

vdg = "9010".

def var quantidadeajuste as int.
def var valordeajuste as dec.
def var depto as int init 0.
def var dt as date.


for each estab no-lock.

quantidadeajuste = 0.
valordeajuste = 0.

for each plani where 
         plani.movtdc = 7 and
         plani.etbcod = estab.etbcod and 
         plani.pladat >= par-dtini - 1 and
         plani.pladat <= par-dtfim - 1
         no-lock.
         
         if not avail plani then next.

    for each movim where
             movim.etbcod = plani.etbcod and
             movim.placod = plani.placod and
             movim.movtdc = plani.movtdc
             no-lock.
        if movim.movqtm >= 1
        then do:
            
        quantidadeajuste = quantidadeajuste + movim.movqtm.
        valordeajuste = valordeajuste + (movim.movpc * movim.movqtm).
       end. 
    
    /* DEPTO */
    find produ where produ.procod = movim.procod no-lock no-error.
    if avail produ then depto = produ.catcod.      
    
    end.

    /* DATA */
    dt = plani.pladat.

    end.

  if quantidadeajuste = 0 then next.             
     
               output to value(par-arquivo) append.          
                                  
                       PUT unformatted                               
                        par-dtini ";"                          
                        vdg ";"                                   
                        estab.etbcod  "|"                         
                        quantidadeajuste  "| Acrescimo |" valordeajuste  "|" depto "|" dt         
                                                    
                                skip.                                     
                                                       
                 output close.
     
     
     end.

     
     
     
     
     
    for each estab no-lock.                            
                                      
   quantidadeajuste = 0.                              
   valordeajuste = 0.                                                                           
      for each plani where                               
         plani.movtdc = 8 and                      
         plani.etbcod = estab.etbcod and           
         plani.pladat >= par-dtini - 1 and             
         plani.pladat <= par-dtfim - 1                
        no-lock.                                  
                                               

          for each movim where                           
             movim.etbcod = plani.etbcod and       
             movim.placod = plani.placod and       
             movim.movtdc = plani.movtdc           
             no-lock.                              
                  if movim.movqtm >= 1                        
                        then do:          
                          
             quantidadeajuste = quantidadeajuste + movim.movqtm.    
             valordeajuste = valordeajuste + (movim.movpc * movim.movqtm).    
                 
                 end. 

                 /* DEPTO */
    find produ where produ.procod = movim.procod no-lock no-error.
    if avail produ then depto = produ.catcod.                                                   
                                                                     
                 end.

                 /* DATA */
    dt = plani.pladat.

                 end.                                                      
                   
         if quantidadeajuste = 0 then next.                                                                                           
           
                                                          
                                   output to value(par-arquivo) append.  
                                         
                                                                                    PUT unformatted                         
            par-dtini ";"                       
            vdg ";"                                
            estab.etbcod  "|"                      
            quantidadeajuste  "| Decrescimo |" valordeajuste "|" depto "|" dt                
                                                               
                                                                                               skip.                          
         output close.
            
            end.
