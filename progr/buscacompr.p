{admcab.i}
/*Busca Comprador*/
/*Pedidos especiais classes*/

def input parameter vclase as int.
def input parameter vfabri as int.
def output parameter vresult as int.

def temp-table tt-result
    field clacod like clase.clacod
    field fabcod like fabri.fabcod
    field comcod like compr.comcod
    field clacod1 like clase.clacod.

        
        
def temp-table tt-arquivo
    field clacod like clase.clacod
    field fabcod like fabri.fabcod
    field comcod like compr.comcod.


def temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    field clacod1 like clase.clacod
    index iclase is primary unique clacod.
 


def var vlinha as char.
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.


input from value("/admcom/import/classes/pedidosespeciais_classes.csv").
    repeat on error undo, next.
        import unformatted vlinha.

        if substring(vlinha,1,6) = "CLASSE"
        then next.

        create tt-arquivo.
        assign tt-arquivo.clacod = int(entry(1,vlinha,";"))
               tt-arquivo.fabcod = int(entry(3,vlinha,";"))
               tt-arquivo.comcod = int(entry(5,vlinha,";")) .
    end.     
input close.


for each tt-arquivo.
    if tt-arquivo.clacod = 0 then next.
    run cria-tt-clase.
end.

procedure cria-tt-clase.

 for each clase where clase.clasup = tt-arquivo.clacod no-lock:
   find first bclase where bclase.clasup = clase.clacod no-lock no-error.
   if not avail bclase
   then do: 
     find tt-clase where tt-clase.clacod = clase.clacod no-error. 
     if not avail tt-clase 
     then do: 
       create tt-clase. 
       assign tt-clase.clacod = clase.clacod 
              tt-clase.clanom = clase.clanom
              tt-clase.clacod1 = tt-arquivo.clacod.
     end.
   end.
   else do: 
     for each bclase where bclase.clasup = clase.clacod no-lock: 
         find first cclase where cclase.clasup = bclase.clacod no-lock no-error.
         if not avail cclase
         then do: 
           find tt-clase where tt-clase.clacod = bclase.clacod no-error. 
           if not avail tt-clase 
           then do: 
             create tt-clase. 
             assign tt-clase.clacod = bclase.clacod 
                    tt-clase.clanom = bclase.clanom
                    tt-clase.clacod1 = tt-arquivo.clacod.
.
           end.
         end.
         else do: 
           for each cclase where cclase.clasup = bclase.clacod no-lock: 
             find first dclase where dclase.clasup = cclase.clacod 
                                                     no-lock no-error. 
             if not avail dclase 
             then do: 
               find tt-clase where tt-clase.clacod = cclase.clacod no-error. 
               if not avail tt-clase 
               then do: 
                 create tt-clase. 
                 assign tt-clase.clacod = cclase.clacod 
                        tt-clase.clanom = cclase.clanom
                        tt-clase.clacod1 = tt-arquivo.clacod.
               end.                          
             end.
             else do: 
               for each dclase where dclase.clasup = cclase.clacod no-lock: 
                 find first eclase where eclase.clasup = dclase.clacod 
                                                         no-lock no-error. 
                 if not avail eclase 
                 then do: 
                   find tt-clase where tt-clase.clacod = dclase.clacod no-error.
                   if not avail tt-clase 
                   then do: 
                     create tt-clase. 
                     assign tt-clase.clacod = dclase.clacod 
                            tt-clase.clanom = dclase.clanom
                            tt-clase.clacod1 = tt-arquivo.clacod.
 
                   end.       
                 end. 
                 else do:  
                   for each eclase where eclase.clasup = dclase.clacod no-lock:
                     find first fclase where fclase.clasup = eclase.clacod 
                                                             no-lock no-error.
                     if not avail fclase 
                     then do: 
                       find tt-clase where tt-clase.clacod = eclase.clacod
                                                             no-error.
                       if not avail tt-clase 
                       then do: 
                         create tt-clase. 
                         assign tt-clase.clacod = eclase.clacod 
                                tt-clase.clanom = eclase.clanom
                                tt-clase.clacod1 = tt-arquivo.clacod.
 
                       end.
                     end.
                     else do:
                       for each fclase where fclase.clasup = eclase.clacod
                                    no-lock:
                         find first gclase where gclase.clasup = fclase.clacod 
                                                             no-lock no-error.
                         if not avail gclase 
                         then do: 
                           find tt-clase where tt-clase.clacod = fclase.clacod
                                                                 no-error.
                           if not avail tt-clase 
                           then do: 
                             create tt-clase. 
                             assign tt-clase.clacod = fclase.clacod 
                                    tt-clase.clanom = fclase.clanom
                                    tt-clase.clacod1 = tt-arquivo.clacod.

                           end.
                         end.
                         else do:
                             find tt-clase where 
                                tt-clase.clacod = gclase.clacod no-error.
                             if not avail tt-clase
                             then do:
                                 create tt-clase. 
                                 assign tt-clase.clacod = gclase.clacod 
                                        tt-clase.clanom = gclase.clanom
                                        tt-clase.clacod1 = tt-arquivo.clacod.
                                        
                             end.  
                         end.
                       end.
                     end.
                   end.
                 end.
               end.
             end.
           end.                                  
         end.
     end.
   end.
 end.
end procedure.    

 
for each tt-arquivo.

    for each tt-clase where tt-clase.clacod1 = tt-arquivo.clacod no-lock.

        create tt-result.
        assign tt-result.clacod = tt-clase.clacod
               tt-result.fabcod = tt-arquivo.fabcod
               tt-result.comcod = tt-arquivo.comcod
               tt-result.clacod1 = tt-arquivo.clacod.
    end.

end.


/***
for each tt-result.
    disp tt-result.
end.
***/

find first tt-result where  tt-result.clacod1 = vclase and
                            tt-result.fabcod  = vfabri no-lock no-error.

if avail tt-result
then vresult = tt-result.comcod.
else do:
    find first tt-result where  tt-result.clacod = vclase and
                                tt-result.fabcod = vfabri no-lock no-error.
                                    
    if avail tt-result
    then vresult = tt-result.comcod.
    else vresult = 0.
                            
end.                            

