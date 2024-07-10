{admcab.i} /* por Trojack */
                               
def var vprocod like produaux.procod. 
              
repeat:                                                                   
           update vprocod format ">>>>>>>>>9" label "Produto"    
           with frame f-pro width 80 side-labels.                
                                                                            
                                                                                find produaux where produaux.procod = vprocod and 
                    produaux.nome_campo = "Pack" no-error.                                                                 
  if not avail produaux                                     
   then do on error undo:
                                                     
           message "Produto nao possui pack, pressione Ok para cadastra-lo!" view-as alert-box.
            create produaux.
                   assign produaux.procod = vprocod.
                          disp produaux.procod.
                          assign produaux.nome_campo = "Pack".
                          update produaux.valor_campo.
                          release produaux no-error.
      end.
         else do:                                                 
         disp produaux.procod.
         update produaux.valor_campo label "Lote do Produto (Pack)". 
         end.
end.               
