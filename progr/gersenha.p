{admcab.i}

def var vint-codproduto as integer format ">>>>>9".
def var vint-codloja    as integer format ">>>>>>>9".
def var vcha-hora      as character.
def var vcha-senha          as character.
def var vint-cont           as integer.

form vint-codproduto label "Cod. Produto"
     produ.pronom    no-label 
     vint-codloja    label "        Loja"
     estab.etbnom    no-label
     with frame f-gera-senha centered row 5 side-label
         title "Gerador de senha para abertura de OS sem informar cliente".

form vcha-senha no-label
    with frame f-mostra-senha title "Senha Gerada!" centered row 16.

do on error undo,retry:

    update vint-codproduto at 1 
                with frame f-gera-senha.

    find first produ where produ.procod = vint-codproduto no-lock no-error.
    if not available produ
    then do:
        message "Código de Produto inválido.".
        undo, retry.
    end.
    display produ.pronom no-label
                          with frame f-gera-senha.
    
    update vint-codloja at 01 format ">>9"
        with frame f-gera-senha. 
    
    find first estab where estab.etbcod = vint-codloja no-lock no-error.
    if not available estab
    then do.
        message "Código de Estab inválido.".
        undo, retry.
    end.
    display estab.etbnom no-label
                 with frame f-gera-senha.

    if vint-codloja = 998
    then do.
        find func where func.funcod = sfuncod and
                        func.etbcod = setbcod
                  no-lock no-error.
        if not avail func or not func.funfunc matches "*auditoria*"
        then do:
            message "Senha para o SSC restrita ao setor de AUDITORIA"
                    view-as alert-box. 
            return.
        end.
    end.
end.

assign vcha-hora = string(time).
assign vint-cont = length(vcha-hora).

/*****************  A senha será a concatenação  ******************
******************  do codigo do produto mais    ******************
******************  os últimos 3 dígitos da hora *****************/
assign vcha-senha = string(vint-codproduto)   
                        + substring(vcha-hora,(vint-cont - 2),3). 

run p-cria-tabaux.

display vcha-senha format "x(15)"
        with frame f-mostra-senha.
        
pause.        

        
procedure p-cria-tabaux:
    
    find first tabaux where tabaux.Tabela = string(vint-codloja)
                                            + string(vint-codproduto)
                       exclusive-lock no-error.                    
    if not avail tabaux
    then do:
        create tabaux.
        assign tabaux.Tabela = string(vint-codloja) + string(vint-codproduto).
    end.
    assign tabaux.Nome_Campo  = vcha-hora 
           tabaux.Valor_Campo = vcha-senha
           tabaux.datexp      = today. 

    release tabaux.
end.
