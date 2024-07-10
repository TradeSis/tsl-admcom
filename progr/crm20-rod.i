/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : asrodrel.i
***** Diretorio                    : gener
***** Autor                        : Claudir Santolin
***** Descri‡ao Abreviada da Funco : Rodape de encerramento de relatorios
***** Data de Criacao              : 26/09/2000
*****************************************************************************/

if simpress <> ""
then 
    put unformatted chr(27) + "P" + chr(18).
        
output close.

if simpress <> "" 
then do: 
    if scopias > 1 
    then vcopias = scopias. 
    else vcopias = 1. 
    
    scopias = 0. 
    if opsys = "UNIX" 
    then do: 
        unix silent /usr/bin/escrava {&saida}. 
        /* unix silent lp -d value(simpress)   /**  Impressora  **/
                          -n value(vcopias)   /**  Num Copias  **/
                          -s {&saida}.         /**  Arquivo     **/ */
    end.     
    else do scopias = 1 to vcopias: 
        dos silent type {&saida} > value(simpress). 
    end.
    
    scopias = vcopias.
    vcopias = 0.
end. 
else
    run crm20-win.p .
