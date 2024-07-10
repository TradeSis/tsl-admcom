{admcab.i}

def var vetbcod as int .
def var vfuncod as int.

do on error undo:
    
    update vetbcod label "Estabelecimento"
           with frame f-dados.
    
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento nao cadastrado.".
        undo, retry.
    end.
    else disp estab.etbnom no-label with frame f-dados.
end.           
        
do on error undo:
    
    update vfuncod label "Funcionario...."
           with frame f-dados width 80 side-labels.

    find first func where func.etbcod = vetbcod
                and func.funcod = vfuncod no-lock no-error.
    if not avail func 
    then do:
        message "Funcionario nao cadastrado.". 
        undo, retry.
    end.                        
    else disp func.funnom no-label with frame f-dados.
    
end.        


find first acesso where acesso.etbcod = vetbcod
              and acesso.funcod = vfuncod no-error.
if avail acesso
then do:

    update skip acesso.qtdace label "Qtd. Acesso...."
           with frame f-dados.

end.
