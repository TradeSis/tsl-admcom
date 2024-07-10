/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : validame.i
***** Diretorio                    : gener
***** Autor                        : Claudir Santolin
***** Descri‡ao Abreviada da Funcao: Validacao de input do Codigo do produto
***** Data de Criacao              : 14/09/2000

                                ALTERACOES
***** 1) Autor     :
***** 1) Descricao : 
***** 1) Data      :

***** 2) Autor     :
***** 2) Descricao : 
***** 2) Data      :

***** 3) Autor     :
***** 3) Descricao : 
***** 3) Data      :
*****************************************************************************/
release produ.
if {1} = "0" or {1} = ""
then do:
    bell. 
    message color red/withe
    "Produto " {1} " nao cadastrado "
    view-as alert-box title " Atencao!! ".
    next.
end.

/***
if length({1}) > 10 
then do:
    
    find first produ where 
               produ.proean = {1} no-lock no-error.
    if  avail produ
    then.
    else do:
        find first produ where
                   produ.proean2 = {1} no-lock no-error.
        if avail produ
        then.
        else do:
            find first produ where
                       produ.proean3 = {1} no-lock no-error.
            if avail produ
            then.
            else do: 
                find first produ where 
                           produ.proant = {1}  no-lock no-error.
                if avail produ 
                then.
                else do:
                    bell. 
                    message color red/withe
                    "Produto " {1} " nao cadastrado "
                    view-as alert-box title " Atencao!! ".
                    next.
                end.
            end. 
        end.
    end.              
end.
else do:
***/
    find first produ where
               produ.procod = int({1}) no-lock no-error.
/***
    if avail produ 
    then.
    else do: 
        find first produ where 
                   produ.proant = {1}  no-lock no-error.
        if avail produ 
        then.      /*
        else do.
            find first produ where
                        produ.rmscodigo = int({1})  no-lock no-error.
            if avail produ
            then do.
                hide message no-pause.
                message "CODIGO RMS".
                pause 1 no-message.
            end.     */
            else do.
                bell. 
                message color red/withe
                    "Produto " {1} " nao cadastrado "
                    view-as alert-box title " Atencao!! ".
                next.
            /*end.*/
        end.
    end. 
end.    
if avail produ and produ.prosit = no
then do:
     bell. 
     message color red/withe
            "Produto " {1} " esta desativado " sfuncod
            view-as alert-box title " Atencao!! ".
     find first seguranca where seguranca.Programa = "validame" and
                                seguranca.funcod   = sfuncod   
                                 no-lock no-error.
     if not avail seguranca
     then
         if program-name(1) <> "proext.p"
         then
             if paramsis("USAPRODUTODESATIVADO") = "N" then
                next.
end.
if avail produ and
   produ.proant begins "X"
then do on endkey undo:  
     bell. 
     message color red/withe
            "Produto " {1} " com tratamento de cor/tamanho "
            view-as alert-box title " Atencao!! ".
     find first seguranca where seguranca.Programa = "validame" and
                                seguranca.funcod   = sfuncod   
                                 no-lock no-error.
     if not avail seguranca
     then

        next.
end.
***/
