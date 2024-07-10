{admcab.i}
                                
def var vresp as logical format "SIM/NAO" initial "NAO".
def var vip   as char format "x(15)".
def var vstatus as char format "x(40)".
def var varq_log as char format "x(40)".
def var vdata as date format "99-99-9999".
def var vfuncod as integer format "999".
def var vsenha as char format "x(8)".
def var vetbcod as integer format "999".
def var vetbcod2 as char format "x(2)".
                                        

vdata = today.

repeat:
    update vfuncod label "Codigo Funcionario" at 2 skip
    with title "INFORME OS DADOS" frame f-1 side-label width 80.
                   
            
    update vsenha label "Nova Senha" at 2 skip
    with frame f-1.
                     
           
    update vresp label "Todas as Filiais" at 2 skip
    with frame f-6 side-label row 8 width 60. 
            
    if vresp
    then do:
        varq_log = "l:\logs\sfunc_" + string(vdata, "99-99-9999") + ".log".
        output to value(varq_log).
            put "FILIAL" space(5) "STATUS" skip.
        output close.
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
            vetbcod2 = substring(vip,7,8). 
            vetbcod = integer(vetbcod2).          
            run sfunc2.p (input vfuncod, vetbcod, vsenha, output vstatus).    
            
                       
            display vstatus  label "STATUS" with frame f-3.
            output to value(varq_log) append.
                put vip space(2) vstatus skip.
            output close.
       end.
       message "Deseja visualizar log?" update vresp.
       if vresp
       then do:
            os-command edit value(varq_log).
       end.
   end.

   else do:
            
        if connected ("gerloja")
        then disconnect gerloja.
             
        update vetbcod  label "Estabelecimento" at 2 skip
        with frame f-5 side-label row 10 width 60.     
            
        update vip  label "IP - Filial" at 2 skip
        with frame f-5 side-label row 11 width 60.     
        
            
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
         run sfunc2.p (input vfuncod, vetbcod, vsenha, output vstatus).    
                
         display vstatus  label "STATUS" with frame f-4.
         clear frame f-4.
            
     end.                 
      
end.                            
