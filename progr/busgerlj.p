{admcab.i}
                         
def new shared var vclicod like clien.clicod.
                                
def var vresp as logical format "SIM/NAO" initial "NAO".
def var vip   as char format "x(15)".
def var vstatus as char format "x(40)".
def var varq_log as char format "x(40)".
def var varq_loj as char.
def var vdata as date .
vdata = today.
def var vtabela as char extent 15.
def var vprograma as char extent 15.
def var vtabela1 as char.
def var vindex as int.
vtabela[1] = "EXC-CLIEN      - Exclusao de Cliente".
vtabela[2] = "DEPOSITO       - Deposito filiais".
vtabela[3] = "PRE-CADASTRO   - Busca PRE-CADASTRO".
vtabela[4] = "INDICA-CLIENTE - Busca indicacl".

disp "     Tabelas do Banco GER" 
        with frame f-lin1 1 down no-box no-label row 4.

disp vtabela format "x(70)"
    help "ENTER=Seleciona F4=Retorna"
    with frame f-tabela 1 column no-label row 5 centered.
choose field vtabela with frame f-tabela.

vindex = frame-index.
vtabela1 = substr(vtabela[vindex],1,15).

disp vtabela[vindex] at 7 format "x(60)"
    with frame f-lin2 1 down no-box no-label row 5.
pause 0.

form vip label "FILIAL"
     vstatus  label "STATUS"
      with frame f-4 3 down width 80 color message
      overlay.
                        
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
def var vi as int.
def var vip1 like vip.
repeat:
            
    update vresp label " Todas as Filiais" at 2 skip
           with frame f-6 side-label row 5 width 80.
    IF vtabela1 <> "PRE-CADASTRO"
    THEN update vdata label "   Apartir do Dia" at 2 
            with frame f-7 side-label row 5 width 80. 
            
    vclicod = 0.
    if vresp
    then do:
        if vtabela1 = "EXC-CLIEN"
        then do:
            update vclicod label "Codigo Cliente"
                with frame f-cli side-label 1 down centered.
        end.
        hide frame f-cli no-pause.
        update vip1  label "Iniciar no IP" at 2 skip
        with frame f-7 side-label width 80.  
        if opsys = "UNIX"
        then do:
            varq_loj = "/admcom/work/listaloja.txt".
            varq_log = "/admcom/logs/buscadd.log".
        end.
        else do:
            varq_loj = "l:\work\listaloja.txt".
            varq_log = "l:\logs\buscadd.log".
        end.
        output to value(varq_log).
            put "FILIAL" space(5) "STATUS" skip.
        output close.
        input from value(varq_loj).
        repeat:
        
            import vip.
            if vip < vip1
            THEN NEXT.
            if connected ("gerloja")
                    then disconnect admloja.    
                  
            pause 0.
            message "Conectando..." vip.
  
            connect ger -H value(vip) -S sdrebger -N tcp -ld gerloja.
    
            display vip label "FILIAL"
            with frame f-3 down width 80 color white/red
                    row 5.
                    
            if not connected ("gerloja")
            then do:
                vstatus = "FALHA NA CONEXAO COM A FILIAL".
                display vstatus  label "STATUS"
                with frame f-3.
                undo, retry.    
            end.
            
            run busca_gerlj.p ( vdata, vtabela1, output vstatus). 
            
            display vstatus  label "STATUS" with frame f-3.
            output to value(varq_log) append.
                put vip space(2) vstatus skip.
            output close.
            if connected ("gerloja")
            then disconnect gerloja.
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
                    
        update vip  label "IP - Filial" at 2 skip
        with frame f-5 side-label width 80.     
                
        if vip <> ""
        then do:
            message "Conectando..." vip.
            pause 2.
            connect ger -H value(vip) -S sdrebger -N tcp -ld gerloja.
    
            display vip with frame f-4  .
            pause 0.
            if not connected ("gerloja")
            then do:
                vstatus = "FALHA NA CONEXAO COM A FILIAL".
                display vstatus  with frame f-4.
                pause 0.
                undo, retry.       
            end.                 
            run busca_gerlj.p (vdata, vtabela1, output vstatus).
            display vstatus  with frame f-4.
            pause 0.
            if connected ("gerloja")
            then disconnect gerloja.
        end.
        else do:
            update vetbi label "Filial inicio"
                   vetbf label "Filial fim"
                   with frame f-fil 1 down width 80 side-label
                   .
            do vi = vetbi to vetbf:
                if connected ("gerloja")
                then disconnect gerloja.
                    
                vip = "filial" + string(vi,"999").
                if vip <> ""
                then do:
                    message "Conectando..." vip.
                    pause 2.
                    connect ger -H value(vip) -S sdrebger -N tcp -ld gerloja.
    
                    display vip  with frame f-4.
                    pause 0.
                    if not connected ("gerloja")
                    then do:
                        vstatus = "FALHA NA CONEXAO COM A FILIAL".
                        display vstatus  with frame f-4.
                        down with frame f-4.
                        undo, retry.       
                    end.   
                    pause 0 before-hide.              
                    run busca_gerlj.p (vdata, vtabela1, output vstatus).
                    display vstatus with frame f-4.
                    down with frame f-4.
                    if connected ("gerloja")
                    then disconnect gerloja.
                end.
            end.
        end.
     end.                 
end. 
