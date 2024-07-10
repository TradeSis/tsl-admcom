{admcab.i}
                                
def var vresp as logical format "SIM/NAO" initial "NAO".
def var vip   as char format "x(15)".
def var vaplicod as char format "x(15)".
def var vmenuprinc as char format "x(20)".
def var vsubmenu as char format "x(30)".
def var vmentit as char format "x(40)".
def var nmentit as char format "x(40)".
def var vmenpro as char format "x(10)".
def var vstatus as char format "x(40)".
def var varq_log as char format "x(40)".
def var vdata as date format "99999999".
def var vmenpar as char .

def var vop as char format "x(15)" extent 3
    init["INCLUIR","ALTERAR","EXCLUIR"].

vdata = today.

def var vindex as int.
 
disp vop with frame f-op 1 down centered side-label no-label.
choose field vop with frame f-op.

vindex = frame-index.
def var varq1 as char.

repeat:
    update vmenuprinc  label "Menu Principal" at 2 skip
    with title "MENUS DE REFERENCIA" frame f-1 side-label 
                                                width 80.
    /* if vmenuprinc = ""
    then do:    
        message "INSIRA UM VALOR PARA ESTE CAMPO".
        undo.
    end. */
            
    update vsubmenu label "Sub Menu" at 2 skip
    with frame f-1.
    /* if vsubmenu = ""
    then do:    
        message "INSIRA UM VALOR PARA ESTE CAMPO".
        undo.
    end. */
    if vindex <= 2
    then do:                  
    update vmentit  label "Nome do Menu" at 2 skip
    with title "DADOS DO NOVO MENU" frame f-2 side-label  row 7 width 80.
    if vindex = 2
    then do:
        
        update nmentit  label "Novo Nome do Menu" at 2 skip
               vmenpar label "Parametro" at 2 skip
        with title "DADOS DO NOVO MENU" frame f-2 .
    end.
    update vmenpro format "x(20)" label "Nome do Programa (sem o '.p')" at 2
           skip
    with frame f-2.
    end.
    else if vindex = 3
    then do:
        update vmentit  label "Nome do Menu" at 2 skip
        with title "DADOS DO MENU PARA EXCLUIR"
         frame f-22 side-label  row 10 width 80.
        if vmentit = ""
        then do:
            bell.
            message color red/with
            "Favor informar o nome do menu para excluir."
            view-as alert-box.
            undo.
        end.
        sresp = no.
        message "Confirma excluir ?" update sresp.
        if not sresp then undo.
    end.        

    update vresp label "Todas as Filiais" at 2 skip
    with frame f-6 side-label row 12 width 60. 
            
    if vresp
    then do:
        if opsys = "UNIX"
        then 
            assign
                varq_log = "/admcom/logs/inclumen_" + vmenpro + ".log"
                varq1 = "/admcom/work/listaloja.txt".
        else 
            assign                                                               varq_log = "l:\logs\inclumen_" + vmenpro + ".log"
                varq1 = "l:\work\listaloja.txt".

        output to value(varq_log).
            put "FILIAL" space(5) "STATUS" skip.
        output close.

        input from value(varq1).
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

            run inclumen2.p (vindex, vmenuprinc, vsubmenu, vmentit, nmentit,
                             vmenpro, vmenpar, output vstatus).
                       
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
                    
        update vip  label "IP - Filial" at 2 skip
        with frame f-6.
                
        message "Conectando..." vip.
        connect ger -H value(vip) -S sdrebger -N tcp -ld gerloja no-error.
    
        display vip label "FILIAL"
        with frame f-4 1 down width 60 row 13 centered color white/red
            overlay.
         
        if not connected ("gerloja")
        then do:
            vstatus = "FALHA NA CONEXAO COM A FILIAL".
            display vstatus  label "STATUS"
            with frame f-4.
            undo, retry.       
         end.                                                        
         run inclumen2.p (vindex, vmenuprinc, vsubmenu, vmentit, nmentit,
                                vmenpro, vmenpar, output vstatus).    
                
         display vstatus  label "STATUS" with frame f-4.
         clear frame f-4.
     end.                 
end. 
