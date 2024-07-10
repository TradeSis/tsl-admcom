/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : asrodrel.i
***** Diretorio                    : gener
***** Autor                        : Claudir Santolin
***** Descri‡ao Abreviada da Funcao: Rodape de encerramento de relatorios
***** Data de Criacao              : 26/09/2000

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


if simpress <> "VISUALIZADOR WINDOWS" and
   simpress <> "VISUALIZADOR CARACTER" and
   simpress <> "ESCRAVA" and
   simpress <> "ESCRAVALASER"
then 
    put unformatted chr(27) + "P" + chr(18).
    
output close.
if simpress <> "VISUALIZADOR WINDOWS" and
   simpress <> "VISUALIZADOR CARACTER" and
   simpress <> "ESCRAVA" and
   simpress <> "ESCRAVALASER"
then do:
    if scopias > 1
    then vcopias = scopias.
    else vcopias = 1.
    scopias = 0.
    if opsys = "UNIX"
    then do:

        
        unix silent lp -d value(simpress)   /**  Impressora  **/
                   -n value(vcopias)   /**  Num Copias  **/
                   -s {&saida}.         /**  Arquivo     **/
        
    end.    
    else do:
        hide message no-pause.
        message "Imprimindo " varqsai " em " simpress.
        pause 1 no-message.
        os-command silent type {&saida} > value(simpress).
        hide message no-pause.
    end.
    scopias = vcopias.
    vcopias = 0.
end.
else do:
    if opsys <> "UNIX" 
    then do:
        /*
        if scabrel = "" or scabrel = ? 
        then scabrel = trim(search(varqsai)) + "@" .

        varqsai = "../impress/imp." + string(time).
        output to value(varqsai).
        put     scabrel format "x(400)" skip.
        output close.
        scabrel = "".
        scabrel = varqsai.
        */
        
    end.
    if opsys = "UNIX"
    then do:
        if simpress = "VISUALIZADOR CARACTER" 
        then run sys/visurel.p (varqsai, "").
        if simpress = "ESCRAVA" or simpress = "ESCRAVALASER"
        then unix silent value("../bin/escrava.sh " + varqsai).
        if simpress = "VISUALIZADOR WINDOWS" 
        then do:
            
            {sys/anita.i scabrel}
        end.
    end.        
    else do:
        os-command silent c:\custom\imp value(varqsai).
            /*value(scabrel).*/
    end.    
end.    
