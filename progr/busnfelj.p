{admcab.i}
                                
def var vresp as logical format "SIM/NAO" initial "NAO".
def var vip   as char format "x(15)".
def var vstatus as char format "x(40)".
def var varq_log as char format "x(40)".
def var varq_loj as char.
def var vdti as date .
def var vdtf as date .
vdti = today.
vdtf = today.
def var vtabela as char extent 15.
def var vprograma as char extent 15.
def var vtabela1 as char.
def var vindex as int.
vtabela[1] = "NFE        - Nota Fiscal Eletronica".

disp "     Tabelas do Banco NFE" 
        with frame f-lin1 1 down no-box no-label row 4.

disp vtabela format "x(70)"
    help "ENTER=Seleciona F4=Retorna"
    with frame f-tabela 1 column no-label row 5 centered.
choose field vtabela with frame f-tabela.

vindex = frame-index.
vtabela1 = substr(vtabela[vindex],1,10).

disp vtabela[vindex] at 7 format "x(60)"
    with frame f-lin2 1 down no-box no-label row 4.
pause 0.

def var vnumero as int.
def var vip1 like vip.
repeat:
            
    vnumero = ?.
    update vresp label " Todas as Filiais" at 2 skip
           vdti label "   Periodo" at 9 format "99/99/9999"
           vdtf label " a "             format "99/99/9999"
           vnumero label "Numero" format ">>>>>>>>9"
    with frame f-6 side-label row 5 width 80. 
            
    if vresp
    then do:
        vip1 = "FILIAL01".
        update vip1  label "Iniciar" at 2 skip
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
            if connected ("nfeloja")
                    then disconnect admloja.    
                  
            pause 0.
            message "Conectando..." vip.
  
            connect nfe -H value(vip) -S sdrebnfe -N tcp -ld nfeloja.
    
            display vip label "FILIAL"
            with frame f-3 down width 80 color white/red
                    row 5.
                    
            if not connected ("nfeloja")
            then do:
                vstatus = "FALHA NA CONEXAO COM A FILIAL".
                display vstatus  label "STATUS"
                with frame f-3.
                undo, retry.    
            end.
            
            run busca_nfelj.p ( vdti, vdtf, vnumero,
                                vtabela1, output vstatus ). 
            
            display vstatus  label "STATUS" with frame f-3.
            output to value(varq_log) append.
                put vip space(2) vstatus skip.
            output close.
            if connected ("nfeloja")
            then disconnect nfeloja.
       end.
       message "Deseja visualizar log?" update vresp.
       if vresp
       then do:
            os-command edit value(varq_log).
       end.
   end.

   else do:
            
        if connected ("nfeloja")
        then disconnect nfeloja.
                    
        vip = "FILIAL01".
        update vip  label "Filial" at 2 skip
        with frame f-5 side-label width 80.     
                
        message "Conectando..." vip.
        connect nfe -H value(vip) -S sdrebnfe -N tcp -ld nfeloja.
    
        display vip label "FILIAL"
        with frame f-4 1 down width 80 centered color white/red.
         
        if not connected ("nfeloja")
        then do:
            vstatus = "FALHA NA CONEXAO COM A FILIAL".
            display vstatus  label "STATUS"
            with frame f-4.
            undo, retry.       
        end.                 
        run busca_nfelj.p (vdti, vdtf, vnumero,
                            vtabela1, output vstatus).
        display vstatus  label "STATUS" with frame f-4.
        clear frame f-4.
        if connected ("nfeloja")
        then disconnect nfeloja.
     
     end.                 
end. 
