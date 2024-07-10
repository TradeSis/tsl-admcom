{admcab.i}
                                
def var vresp as logical format "SIM/NAO" initial "NAO".
def var vip   as char format "x(15)".
def var vaplicod as char format "x(15)".
def var vmenuprinc as char format "x(15)".
def var vsubmenu as char format "x(30)".
def var vmentit as char format "x(40)".
def var vmenpro as char format "x(10)".
def var vstatus as char format "x(40)".


repeat:
    update vmenuprinc  label "Menu Principal" at 2 skip
    with title "MENUS DE REFERENCIA" frame f-1 side-label 
                                                width 60.
    /* if vmenuprinc = ""
    then do:    
        message "INSIRA UM VALOR PARA ESTE CAMPO".
        undo.
    end. */
                    
            
    /* update vsubmenu label "Sub Menu" at 2 skip
    with frame f-1.
    /* if vsubmenu = ""
    then do:    
        message "INSIRA UM VALOR PARA ESTE CAMPO".
        undo.
    end. */
     */                 
    update vmenpro  label "Nome do Programa (sem o '.p')" at 2 skip
    with frame f-2 side-label row 8 width 80.
              
    update vresp label "Todas as Filiais" at 2 skip
    with frame f-6 side-label row 12 width 60. 
            
    if vresp
    then do:
        input from l:\work\listaloja.txt.
        repeat:
        
            import vip.
        
            if connected ("gerloja")
                    then disconnect gerloja.    
                  
            pause 0.
            message "Conectando..." vip.
  
            connect ger -H value(vip) -S sdrebger -N tcp -ld gerloja                                                                     no-error.
    
            display vip label "FILIAL"
            with frame f-3 15 down width 60 row 5 centered color white/red.
                    
            if not connected ("gerloja")
            then do:
                vstatus = "FALHA NA CONEXAO COM A FILIAL".
                display vstatus  label "STATUS"
                with frame f-3.
                undo, retry.    
            end.

            run exclumen2.p (input vmenuprinc, vsubmenu, vmentit,                                             vmenpro, output vstatus).
                       
            display vstatus  label "STATUS" with frame f-3.
       end.
   end.

   else do:
            
        if connected ("gerloja")
        then disconnect gerloja.
                    
        update vip  label "Hostname/IP Filial" at 2 skip
        with frame f-5 side-label row 15 width 60.     
                
        message "Conectando..." vip.
        connect ger -H value(vip) -S sdrebger -N tcp -ld gerloja                                                                 no-error.
    
        display vip label "FILIAL"
        with frame f-4 1 down width 60 row 18 centered color white/red.
         
        if not connected ("gerloja")
        then do:
            vstatus = "FALHA NA CONEXAO COM A FILIAL".
            display vstatus  label "STATUS"
            with frame f-4.
            undo, retry.       
         end.                                                        
         run exclumen2.p (input vmenuprinc, vsubmenu, vmentit, vmenpro,                                   output vstatus).    
                
         display vstatus  label "STATUS" with frame f-4.
         clear frame f-4.
            
     end.                 
      
end. 
