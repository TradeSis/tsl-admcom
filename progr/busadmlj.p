{admcab.i}

pause 0 before-hide.

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
vtabela[1] = "CTDEVVEN    - Controle Devolucao de vendas".
vtabela[2] = "HABIL       - Habilitacoes de Telefonia".
vtabela[3] = "MAPCXA      - Reducao Z".
vtabela[4] = "EX-TBPRICE  - Exclui Registros Tabela Price". 
vtabela[5] = "BUS-TBPRICE - Busca Registros Tabela Price".

def var vetbcod like estab.etbcod.

disp "     Tabelas do Banco ADM" 
        with frame f-lin1 1 down no-box no-label row 4.

disp vtabela format "x(70)"
    help "ENTER=Seleciona F4=Retorna"
    with frame f-tabela 1 column no-label row 5 centered.
choose field vtabela with frame f-tabela.

vindex = frame-index.
vtabela1 = substr(vtabela[vindex],1,11).

disp vtabela[vindex] at 7 format "x(60)"
    with frame f-lin2 1 down no-box no-label row 4.
pause 0.

def var vip1 like vip.
def var vetb1 like estab.etbcod.
def var vetb2 like estab.etbcod.
repeat:
            
    update vresp label " Todas as Filiais" at 2 skip
           vdata label "   Apartir do Dia" at 2 
    with frame f-6 side-label row 5 width 80. 
            
    if vresp
    then do:

        update vetbcod  label "Iniciar no Filial" at 2 skip
        
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
        
        
        /*input from value(varq_loj).
        repeat:
        */
        for each estab where estab.etbcod >= vetbcod and
                             estab.etbcod < 189 no-lock:
            if estab.etbcod = 10 or
               estab.etbcod = 22
            then next.
            if vresp = no and
               estab.etbcod <> vetbcod 
            then next.
               
            vip = "filial" + string(estab.etbcod,"999").   
            /*
            if vip < vip1
            THEN NEXT.
            */
            if connected ("admloja")
                    then disconnect admloja.    
                  
            pause 0.
            message "Conectando..." vip.
  
            connect adm -H value(vip) -S sadm -N tcp -ld admloja
                no-error.
    
            display vip label "FILIAL"
            with frame f-3 down width 80 color white/red
                    row 5.
                    
            if not connected ("admloja")
            then do:
                vstatus = "FALHA NA CONEXAO COM A FILIAL".
                display vstatus  label "STATUS"
                with frame f-3.
                undo, retry.    
            end.
            vetbcod = int(substr(string(vip),7,3)).
            run busca_admlj.p ( vetbcod, vdata, vtabela1, output vstatus ). 
            
            display vstatus  label "STATUS" with frame f-3.
            output to value(varq_log) append.
                put vip space(2) vstatus skip.
            output close.
            if connected ("admloja")
            then disconnect admloja.
       end.
       message "Deseja visualizar log?" update vresp.
       if vresp
       then do:
            os-command edit value(varq_log).
       end.
   end.
   else do:
            
        if connected ("admloja")
        then disconnect admloja.
        
        update vetb1 label "Filial inicio"
               vetb2 label "Filial fim"
               with frame f-5.
        
        do vetbcod = vetb1 to vetb2:
        vip = "filial" + string(vetbcod,"999").
            
        disp vip  label "IP - Filial" at 2 skip
        with frame f-5 side-label width 80.     
                
        pause 0.
        message "Conectando..." vip.
        connect adm -H value(vip) -S sadm -N tcp -ld admloja.
    
        display vip label "FILIAL"
        with frame f-4 1 down width 80 centered color white/red.
        pause 0. 
        if not connected ("admloja")
        then do:
            vstatus = "FALHA NA CONEXAO COM A FILIAL".
            display vstatus  label "STATUS"
            with frame f-4.
            undo, retry.       
        end. 
        vetbcod = int(substr(string(vip),7,3)).
        run busca_admlj.p (vetbcod, vdata, vtabela1, output vstatus).
        display vstatus  label "STATUS" with frame f-4.
        clear frame f-4.
        pause 0.
        
        if connected ("admloja")
        then disconnect admloja.
        end.
     end.                 
      
end. 
