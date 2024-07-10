{admcab.i}


def var vetbcod like ger.estab.etbcod.
def var vdti    like com.plani.pladat initial today.
def var vdtf    like com.plani.pladat initial today.
def var vstatus as char format "x(40)".
def var vip   as char format "x(15)".
def buffer xestab for ger.estab.

repeat:
    message "Todas as Filiais?" update sresp. 
    if sresp
    then do:
        input from l:\work\listaloja.txt.
        repeat:
        
            import vip.
        
            if connected ("gerloja")
            then disconnect gerloja.    
                  
            pause 0.
            message "Conectando..." vip.
  
            connect ger -H value(vip) -S sdrebger -N tcp -ld gerloja no-error.
    
            display vip label "FILIAL"
                     with frame f-2 15 down width 60 row 5 centered.
      
            if not connected ("gerloja")
            then do:
                vstatus = "FALHA NA CONEXAO COM A FILIAL".
                display vstatus  label "STATUS"
                    with frame f-2.
                undo, retry.    
            end.

            run atumenu.p (input vip, output vstatus).
                       
            display vstatus  label "STATUS"
                    with frame f-2.
                
        end.
    end.


    else do:
        repeat:

            if connected ("gerloja")
            then disconnect gerloja.
    
            
            update vip    label "IP - Filial" at 2 skip
            with frame f-1 side-label width 80.
            
    
            message "Conectando..." vip.
            connect ger -H value(vip) -S sdrebger -N tcp -ld gerloja no-error.
    
            display vip label "FILIAL"
                     with frame f-3 1 down width 60 row 10 centered.
      
            if not connected ("gerloja")
            then do:
                vstatus = "FALHA NA CONEXAO COM A FILIAL".
                display vstatus  label "STATUS"
                    with frame f-3.
                undo, retry.    
            end.
        
            run atumenu.p (input vip, output vstatus).
                       
        end.
    
    end.
    
end.