/********************************************************
 Programa: leb-exp-menu.p
 Autor: Rafael A (Kbase IT)
 Descricao: Menu principal dos extratores de dados
 Historico: 30/04/2015 - Rafael A (Kbase IT) - Criacao
            25/05/2015 - Rafael A (Kbase IT) - Man. Exportacao Func
********************************************************/

{admcab.i}

def var varq    as char  no-undo.
def var recatu1 as recid no-undo.

def temp-table tt-cadMenuExp
    field id    as int
    field nome  as char
    field proc  as char
    field ativo as log
    index idx01 is primary unique 
        id asc.

/* registros tt = linhas menu */
create tt-cadMenuExp.
assign tt-cadMenuExp.id    = 1
       tt-cadMenuExp.nome  = "Filiais"
       tt-cadMenuExp.proc  = "p-filiais"
       tt-cadMenuExp.ativo = yes.
       
create tt-cadMenuExp.
assign tt-cadMenuExp.id    = 2
       tt-cadMenuExp.nome  = "Funcionarios"
       tt-cadMenuExp.proc  = "p-funcionarios"
       tt-cadMenuExp.ativo = yes.
       
create tt-cadMenuExp.
assign tt-cadMenuExp.id    = 3
       tt-cadMenuExp.nome  = "Vendas"
       tt-cadMenuExp.proc  = "p-vendas"
       tt-cadMenuExp.ativo = yes.
       
create tt-cadMenuExp.
assign tt-cadMenuExp.id    = 4
       tt-cadMenuExp.nome  = "Produtos"
       tt-cadMenuExp.proc  = "p-produtos"
       tt-cadMenuExp.ativo = yes.

bl-princ:
repeat:
    
    if recatu1 = ? then 
        run leitura(input "pri").
    else
        find tt-cadMenuExp 
             where recid(tt-cadMenuExp) = recatu1 no-lock no-error.
             
    if not avail tt-cadMenuExp then
        leave.
        
    clear frame frame-a all no-pause.
    
    run frame-a.
    
    recatu1 = recid(tt-cadMenuExp).
    repeat:
        run leitura (input "seg").
        if not avail tt-cadMenuExp then
            leave.
            
        if frame-line(frame-a) = frame-down(frame-a) then
            leave.
            
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.
    
    repeat with frame frame-a:
        find first tt-cadMenuExp 
             where recid(tt-cadMenuExp) = recatu1 no-lock no-error.
        
        color display message
            tt-cadMenuExp.id
            tt-cadMenuExp.nome
            with frame frame-a.
            
        choose field tt-cadMenuExp.id
            go-on(cursor-down cursor-up PF4 F4 ESC return).
            
        color display normal
            tt-cadMenuExp.id
            tt-cadMenuExp.nome
            with frame frame-a.
            
        if keyfunction(lastkey) = "cursor-down" then do:
            run leitura (input "down").
            if not avail tt-cadMenuExp then
                next.
                
            color display white/red tt-cadMenuExp.id with frame frame-a.
            
            if frame-line(frame-a) = frame-down(frame-a) then
                scroll with frame frame-a.
            else
                down with frame frame-a.
        end.
        
        if keyfunction(lastkey) = "cursor-up" then do:
            run leitura (input "up").
            if not avail tt-cadMenuExp then
                next.
                
            color display white/red tt-cadMenuExp.id with frame frame-a.
            
            if frame-line(frame-a) = 1 then
                scroll down with frame frame-a.
            else
                up with frame frame-a.
        end.
        
        if keyfunction(lastkey) = "end-error" then do:
            leave bl-princ.
        end.
                
        if keylabel(lastkey) = "F4" then do:
            leave bl-princ.
        end.
            
        if keyfunction(lastkey) = "return" then do:
            hide frame frame-a no-pause.
            
            run value(tt-cadMenuExp.proc).
        end.
        
        run frame-a.
        recatu1 = recid(tt-cadMenuExp).
    end.
                
    if keyfunction(lastkey) = "end-error" then do:
        view frame fc1.
        view frame fc2.
    end.
        
    if keylabel(lastkey) = "F4" then do:
        leave bl-princ.
    end.
end.
hide frame frame-a no-pause.

procedure frame-a:
    disp tt-cadMenuExp.id   format "99"
         tt-cadMenuExp.nome format "x(15)"
         with frame frame-a 4 down centered color white/red row 4 no-label
         title " EXPORTAR ".
end procedure.

procedure leitura:
    
    def input param p-tipo as char.
    
    if p-tipo = "pri" then
        find first tt-cadMenuExp where tt-cadMenuExp.ativo no-lock no-error.
        
    if p-tipo = "seg" or p-tipo = "down" then
        find next tt-cadMenuExp where tt-cadMenuExp.ativo no-lock no-error.
        
    if p-tipo = "up" then
        find prev tt-cadMenuExp where tt-cadMenuExp.ativo no-lock no-error.
end procedure.

procedure p-filiais:
    message "Exportando filiais, aguarde...".
    run leb-exp-estab.p(output varq).
    message ("Filiais exportadas para " + varq) view-as alert-box.
    
    message "".
end procedure.

procedure p-funcionarios:
    /*
    message "Exportando funcionarios, aguarde...".
    run leb-exp-funcionarios.p(output varq).
    */
    
    run leb-exp-menu-func.p(output varq).
    
    if varq <> "" then
        message ("Funcionarios exportados para " + varq) view-as alert-box.
    
    message "".
end procedure.

procedure p-vendas:
    def var list-fornec as char no-undo label "Fornecedores".
    def var dtini       as date no-undo label "Per. Inicial".
    def var dtfim       as date no-undo label "Per. Final".
    
    update list-fornec 
                format "x(15)"
                help "Insira os fornecedores separados por ','"
           dtini format "99/99/9999"
           dtfim format "99/99/9999"
           with 1 col frame f-vendas 2 down centered row 4
           title " EXPORTAR VENDAS ".
    
    message "Exportando vendas, aguarde...".
    run leb-exp-vendas.p(input list-fornec, 
                         input dtini,
                         input dtfim,
                         output varq).
    message ("Vendas exportadas para " + varq) view-as alert-box.

    message "".
    hide frame f-vendas.
end procedure.

procedure p-produtos:
    
    def var list-fornec as char no-undo label "Fornecedores".
    
    update list-fornec
               format "x(15)"
               help "Insira os fornecedores separados por ','"
           with 1 col frame f-produtos 2 down centered row 4
           title " EXPORTAR PRODUTOS ".
           
    message "Exportando produtos, aguarde...".
    run leb-exp-produ.p(input list-fornec,
                        output varq).
    message ("Produtos exportados para " + varq) view-as alert-box.
    
    message "".
    hide frame f-produtos.
end procedure.