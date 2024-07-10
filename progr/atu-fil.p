{admcab.i}

def var vsenha as char.
def var varquivo as char.
update vsenha blank label "Senha" format "x(15)"
       with frame fsenha centered side-labels.
if vsenha <> "atualizaf2007"
then leave.
hide frame fsenha no-pause.       
        
def var vetbcod like ger.estab.etbcod.
def var vstatus as char format "x(40)".
def var vip   as char format "x(15)".
def buffer xestab for ger.estab.

repeat:

    message "Todas as Filiais?" update sresp. 
    if sresp
    then do:
        if opsys = "UNIX"
        then varquivo = "/admcom/work/listaloja.txt".
        else varquivo = "l:\work\listaloja.txt".

    
        input from value(varquivo).
        repeat:
        
            import vip.
        
            if connected ("finloja")
            then disconnect finloja.
                  
            pause 0.
            message "Conectando banco fin na filial ..." vip.
  
            connect fin -H value(vip) -S sdrebfin -N tcp -ld finloja no-error.
    
            display vip label "FILIAL"
                     with frame f-2 15 down width 60 row 5 centered.
      
            if not connected ("finloja")
            then do:
                vstatus = "FALHA NA CONEXAO COM A FILIAL".
                display vstatus  label "STATUS"
                    with frame f-2.
                undo, retry.    
            end.

            run atu-fil02.p (input vip, output vstatus).
                       
            display vstatus  label "STATUS"
                    with frame f-2.
                
        end.
    end.

    else do:
        repeat:

            if connected ("finloja")
            then disconnect finloja.
    
            
            update vip    label "IP - Filial" at 2 skip
            with frame f-1 side-label width 80.
            
    
            message "Conectando banco fin na filial ..." vip.
            connect fin -H value(vip) -S sdrebfin -N tcp -ld finloja no-error.
    
            display vip label "FILIAL"
                     with frame f-3 1 down width 60 row 10 centered.
      
            if not connected ("finloja")
            then do:
                vstatus = "FALHA NA CONEXAO COM A FILIAL".
                display vstatus  label "STATUS"
                    with frame f-3.
                undo, retry.    
            end.
        
            run atu-fil02.p (input vip, output vstatus).
                       
        end.
    
    end.
    
end.