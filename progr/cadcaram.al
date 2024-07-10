/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : cadcaram.al
***** Diretorio                    : cadas
***** Autor                        : Claudir Santolin
***** Descri‡ao Abreviada da Funcao: Include de cadastro de caracteristicas
***** Data de Criacao              : 28/08/2000

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
*******************************************************************************/

if keyfunction(lastkey) = "return" 
then repeat TRANSACTION with frame f-linha: 

    update 
        caract.cardes.
        
    caract.cardes = caps(caract.cardes).

    /*update caract.ordem
            caract.logcli.*/

        
/*    if senha_sis = senha_cli
    then*/
/*        update
            caract.logsis.
             .              */
    next keys-loop.
end.
else 
if keyfunction(lastkey) = "GO"
then do TRANSACTION:
    run subcarac.p.
    next keys-loop.
end.    
else
if keyfunction(lastkey) = "delete-line" or
   keyfunction(lastkey) = "cut"
then do TRANSACTION:
    /*if caract.logsis
    then do:
        bell.
        message color red/withe
             "Caracteristica e` Obrigatoria para Sistema"
             view-as alert-box title " Exclusao Negada ".
        next keys-loop.
    end.*/             
             
    for each  subcaract where
              subcaract.carcod = caract.carcod no-lock.
        find first procaract where 
                   procaract.subcod = subcaract.subcod no-lock no-error.
        if avail procaract
        then do:
            bell.
            message Color red/withe
                    "Caracteristica Associada a Produto" 
                    view-as alert-box title " Exclusao Negada ".
            next keys-loop.        
        end.                    
    end. 
    find first subcaract where
              subcaract.carcod = caract.carcod no-lock no-error.
    if avail subcaract
    then do:
        bell.
        message color red/withe
            "Excluir Primeiro as Subcaracteristicas"
            view-as alert-box title " Exclusao Negada ".
        next keys-loop.
    end.            
    bell.
    sresp = no. 
    message color red/withe " Confirma exclusao? " update sresp.
    if sresp
    then 
        delete caract.
    else do:
        bell.
        message color red/withe "Exclusao nao confirmada" 
                view-as alert-box.
    end. 
    color display {&color}/{&color1} {&ofield}.
    pause 0.               
           
    next l1.
end. 

