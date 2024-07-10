{admcab.i}
            
def var vetbcod like estab.etbcod.
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
vtabela[1] = "FINAN       -  Planos de Pagamento      ".
vtabela[2] = "".
vtabela[3] = "".
vtabela[4] = "".
vtabela[5] = "".
vtabela[6] = "".

disp "     Tabelas do Banco FIN" 
        with frame f-lin1 1 down no-box no-label row 4.

disp vtabela format "x(70)"
    help "ENTER=Seleciona F4=Retorna"
    with frame f-tabela 1 column no-label row 5 centered.
choose field vtabela with frame f-tabela.

vindex = frame-index.
vtabela1 = substr(vtabela[vindex],1,12).

disp vtabela[vindex] at 7 format "x(60)"
    with frame f-lin2 1 down no-box no-label row 4.
pause 0.

def var vip1 like vip.
repeat:
            
    update vresp label " Todas as Filiais" at 2 /*skip
           vdata label "   Apartir do Dia" at 2 */
    with frame f-6 side-label row 5 width 80. 
            
    if vresp
    then do:
        update vetbcod label "Iniciar na Filial" with frame f-7.
        vip1 = "filial" + string(vetbcod,"999"). 
        disp vip1  no-label  skip
        with frame f-7 side-label width 80.  
        if opsys = "UNIX"
        then do:
            varq_loj = "/admcom/work/listaloja.txt".
            varq_log = "/admcom/relat/buscadd-" +
                        string(today,"99999999") + "-" +
                        string(time) + ".log".
        end.
        else do:
            varq_loj = "l:\work\listaloja.txt".
            varq_log = "l:\logs\buscadd.log".
        end.
        output to value(varq_log).
            put "FILIAL" space(5) "STATUS" skip.
        output close.
        for each estab where estab.etbcod >= vetbcod /*and
                             estab.etbcod < 189*/ no-lock:
            if /*estab.etbcod = 10 or*/
               estab.etbcod = 22 or
               estab.etbcod = 107 or
               estab.etbcod = 128 or
               estab.etbcod = 188
            then next.
            vip = "filial" + string(estab.etbcod,"999").
            if connected ("finloja")
                    then disconnect admloja.    
                  
            pause 0.
            message "Conectando..." vip.
  
            connect fin -H value(vip) -S sdrebfin -N tcp -ld finloja
            no-error.
            connect adm -H value(vip) -S sadm -N tcp -ld admloja
            no-error.
            
            display vip label "FILIAL"
            with frame f-3 down width 80 color white/red
                    row 5.
                    
            if not connected ("finloja")
            then do:
                vstatus = "FALHA NA CONEXAO COM A FILIAL".
                display vstatus  label "STATUS"
                with frame f-3.
                undo, retry.    
            end.
            
            run envia_finlj.p ( estab.etbcod, vdata, 
                        vtabela1, output vstatus ). 
            
            display vstatus  label "STATUS" with frame f-3.
            output to value(varq_log) append.
                put vip space(2) vstatus skip.
            output close.
            if connected ("finloja")
            then disconnect finloja.
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
            
        if connected ("finloja")
        then disconnect finloja.
        update vetbcod label "Filial" with frame f-5.
        vip = "filial" + string(vetbcod,"999"). 
                    
        disp vip  no-label  skip
        with frame f-5 side-label width 80.     
                
        message "Conectando..." vip.
        connect fin -H value(vip) -S sdrebfin -N tcp -ld finloja
        no-error.
        connect adm -H value(vip) -S sadm -N tcp -ld admloja
        no-error.
    
        display vip label "FILIAL"
        with frame f-4 1 down width 80 centered color white/red.
         
        if not connected ("finloja")
        then do:
            vstatus = "FALHA NA CONEXAO COM A FILIAL".
            display vstatus  label "STATUS"
            with frame f-4.
            undo, retry.       
        end.                 
        run envia_finlj.p (vetbcod, vdata, vtabela1, output vstatus).
        display vstatus  label "STATUS" with frame f-4.
        clear frame f-4.
        if connected ("finloja")
        then disconnect finloja.
        if connected ("admloja")
        then disconnect admloja.
     
     end.                 
end. 
