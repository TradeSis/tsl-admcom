{admcab.i}

def var ip   as char format "x(15)".

repeat:
    
   update ip  label "IP - Filial"  
            with frame f1 side-label width 80 1 column
                    title "ATUALIZACAO DE CLIENTES".

   compile atu6.p save.

   run atu6.r (input ip).
   
end.


