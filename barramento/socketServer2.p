
/*
*
*/


DEFINE VARIABLE hServerSocket AS HANDLE.
DEFINE VARIABLE l-Ok          AS LOGICAL.

DEFINE VARIABLE par-param 	  AS CHARACTER.
DEFINE VARIABLE pPorta 		  AS INTEGER.
 
par-param = SESSION:PARAMETER.
pPorta = int(entry(1, par-param)).
DEFINE VARIABLE contaAcessos 		  AS INTEGER.


IF pPorta = 0 OR pPorta = ?
THEN pPorta = 65500.


CREATE SERVER-SOCKET hServerSocket NO-ERROR.
hServerSocket:SET-CONNECT-PROCEDURE("instanciaClientSocket").
l-Ok = hServerSocket:ENABLE-CONNECTIONS( "-S " + string(pPorta)).

IF NOT l-Ok THEN
 RETURN.

REPEAT ON STOP UNDO, LEAVE ON QUIT UNDO, LEAVE:
	contaAcessos = contaAcessos + 1.
    run gravaLog("Antes do wait-for ").
	
	WAIT-FOR CONNECT OF hServerSocket.
	
	run gravaLog("Apos wait-for").
	
	IF contaAcessos = 200 
    THEN DO:  
		OUTPUT TO value("/work-vnx/integracao-work/log/sockServer_" + string(today, "99999999") + ".log") APPEND.
			PUT UNFORMATTED "\n " + STRING(TIME,"HH:MM:SS") + " - " + STRING(STRING(contaAcessos) + " acessos - Reiniciando server socket...").
		OUTPUT CLOSE.
		
		hServerSocket:DISABLE-CONNECTIONS().
		DELETE OBJECT hServerSocket.	
		
		CREATE SERVER-SOCKET hServerSocket.
		hServerSocket:SET-CONNECT-PROCEDURE("instanciaClientSocket").
		l-Ok = hServerSocket:ENABLE-CONNECTIONS( "-S " + string(pPorta)).
		
		
		IF NOT l-Ok 
        THEN DO: 
			OUTPUT TO value("/work-vnx/integracao-work/log/sockServer_" + string(today, "99999999") + ".log") APPEND.
				PUT UNFORMATTED "\n " + STRING(TIME,"HH:MM:SS") + " - " + STRING("ERRO AO REINICIAR O SOCKET FINALIZANDO REPEAT").
			OUTPUT CLOSE.
            LEAVE. 
        END.
		ELSE DO:
			OUTPUT TO value("/work-vnx/integracao-work/log/sockServer_" + string(today, "99999999") + ".log") APPEND.
				PUT UNFORMATTED "\n " + STRING(TIME,"HH:MM:SS") + " - " + STRING("SOCKET REINICIADO COM SUCESSO!").
			OUTPUT CLOSE.
		END.
			
		contaAcessos = 0.
	END.
/* 20190626 */
        CATCH anyError AS Progress.Lang.Error:
                        OUTPUT TO value("/work-vnx/integracao-work/log/sockServer_" + string(today, "99999999") + ".log") APPEND.
                                PUT UNFORMATTED "\n " + STRING(TIME,"HH:MM:SS") + " - " + STRING("ERRO NO SOCKET FINALIZANDO REPEAT Caiu no catch: ") + anyError:GetMessage(1).
                        OUTPUT CLOSE.

            LEAVE.

        END CATCH.
                
/* 20190626 */

END.

hServerSocket:DISABLE-CONNECTIONS().
DELETE OBJECT hServerSocket.

MESSAGE "SERVER SOCKET FINALIZADO".

QUIT.

/*
*
*/
PROCEDURE instanciaClientSocket.

	DEFINE INPUT PARAMETER hSocket       AS HANDLE.
	DEFINE VARIABLE lcJsonSaida			 AS LONGCHAR.
	DEFINE VARIABLE lOK					 AS LOGICAL.
	DEFINE VARIABLE memptrEntrada		 AS MEMPTR.
	DEFINE VARIABLE memptrSaida			 AS MEMPTR.
	DEFINE VARIABLE memptrSaidaJson		 AS MEMPTR.
	DEFINE VARIABLE iBytesAvail			 AS INTEGER     NO-UNDO.
	DEFINE VARIABLE iBystesLidos		 AS INTEGER     NO-UNDO.
	DEFINE VARIABLE cDadosEntrada        AS CHARACTER   NO-UNDO.
	DEFINE VARIABLE cRetorno			 AS CHAR.
	DEFINE VARIABLE iPasso				 AS INTEGER     NO-UNDO.
	DEFINE VARIABLE cMetodo				 AS CHARACTER   NO-UNDO.
	DEFINE VARIABLE cMetodoConteudo		 AS CHARACTER   NO-UNDO.
	DEFINE VARIABLE lcJsonEntrada		 AS LONGCHAR.
	DEFINE VARIABLE iTamanhoJsonEntrada  AS INTEGER     NO-UNDO.
	DEFINE VARIABLE iPonteiro			 AS INTEGER     NO-UNDO.
	DEFINE VARIABLE iCiclos				 AS INTEGER     NO-UNDO.
	DEFINE VARIABLE iCiclosRepeat		 AS INTEGER     NO-UNDO.
	DEFINE VARIABLE logStr				 AS CHARACTER   NO-UNDO.
	DEFINE VARIABLE ativaTrace			 AS CHARACTER   NO-UNDO.

	DEFINE VARIABLE intervaloPegaTime	 AS INTEGER     NO-UNDO.
	DEFINE VARIABLE timeInicio			 AS INTEGER     NO-UNDO.
	
	
  iPasso = 1.
  iPonteiro = 1.
  iCiclos = 1.
  iCiclosRepeat = 0.
  ativaTrace = "true".
  intervaloPegaTime = 0.
  
  timeInicio = INT(TIME).
  
  /*run gravaLog("timeInicio = " + STRING(timeInicio)). */
  /* TIMEOUT 8 SEGS */
  timeInicio = timeInicio + 8. 
  
  /*run gravaLog("segTimeout = " + STRING(timeInicio)). */
  
    REPEAT: 
		iCiclosRepeat = iCiclosRepeat + 1.
		intervaloPegaTime = intervaloPegaTime + 1.
        IF iPasso > 3 
        THEN DO: 
            LEAVE.  
        END.  
        IF NOT hsocket:CONNECTED() 
        THEN DO: 
            LEAVE. 
        END.  
        IF hsocket:GET-BYTES-AVAILABLE() > 0 
        THEN DO:   
            /* PASSO 1 - RECEBE O NOME DO METODO E O TAMANHO DO JSON QUE IRA SER RECEBIDO NO PASSO 2 */ 
            IF iPasso = 1 
            THEN DO:  
                ASSIGN 
                    iBytesAvail = hsocket:GET-BYTES-AVAILABLE(). 
                ASSIGN 
                    iBystesLidos                  = iBytesAvail 
                    SET-SIZE(memptrEntrada)       = iBystesLidos 
                    SET-BYTE-ORDER(memptrEntrada) = BIG-ENDIAN 
                    lOK = hsocket:READ(memptrEntrada,1,iBytesAvail,READ-EXACT-NUM).  
                ASSIGN 
                    cDadosEntrada = GET-STRING(memptrEntrada,1) 
                    SET-SIZE(memptrEntrada) = 0.  
					cMetodo = entry(1,cDadosEntrada,"&").                   /* METODO A EXECUTAR */ 
					iTamanhoJsonEntrada = int(entry(2,cDadosEntrada,"&")).  /* TAMANHO DO JSON EM BYTES */

                cRetorno = "STATUS=OK|ID=" + string(hsocket) + "|METODO=" + 
                           cMetodo + "|TAMANHO_JSON=" + string(iTamanhoJsonEntrada).  
               
			    
				IF ativaTrace = "true" THEN DO:
					run gravaLog("cRetorno=" + STRING(cRetorno)).
				END.
				ELSE DO:
					logStr = STRING(logStr) + "\n cRetorno=" + STRING(cRetorno).
				END.
            END. 
            /* PASSO 2 - RECEBE O JSON DE ENTRADA COM O TAMANHO INFORMADO NO PASSO 1 E */ 
            /* RETORNA O TAMANHO DO JSON GERADO COMO SAIDA */
            ELSE 
                IF iPasso = 2 
                THEN DO:  
                    ASSIGN iBytesAvail = hsocket:GET-BYTES-AVAILABLE().  
                    ASSIGN 
                        iBystesLidos                  = iBytesAvail 
                        SET-SIZE(memptrEntrada)       = iTamanhoJsonEntrada . 
                    SET-BYTE-ORDER(memptrEntrada) = BIG-ENDIAN.
                    /* PROCESSO DE LEITURA CONTEMPLANOD MENSAGENS GRANDES */ 
                    REPEAT: 
                        IF iPonteiro > iTamanhoJsonEntrada 
                        THEN DO: 
                            LEAVE. 
                        END. 
                        IF hsocket:GET-BYTES-AVAILABLE() > 0 
                        THEN DO: 
                            ASSIGN iBytesAvail = hsocket:GET-BYTES-AVAILABLE().
                            lOK = hsocket:READ(memptrEntrada,iPonteiro,iBytesAvail,READ-EXACT-NUM).
                            iPonteiro = iPonteiro + iBytesAvail.
                            iCiclos = iCiclos + 1.
                        END.
                    END.  
					
					IF ativaTrace = "true" THEN DO:
						run gravaLog("CICLOS ENTRADA: " + STRING(iCiclos)).
					END.
					ELSE DO:
						logStr = STRING(logStr) + "\n CICLOS ENTRADA: " + STRING(iCiclos).
					END.
					
                    FIX-CODEPAGE (lcJsonEntrada) = 'utf-8'. 
                    COPY-LOB FROM OBJECT memptrEntrada TO lcJsonEntrada CONVERT SOURCE CODEPAGE 'utf-8'.  
                    ASSIGN SET-SIZE(memptrEntrada) = 0.
                    IF ativaTrace = "true" THEN DO:
						run gravaLog(" RUN " + STRING(cMetodo)).
					END.
					ELSE DO:
						logStr = STRING(logStr) + "\n RUN " + STRING(cMetodo).
					END.
				
                    cMetodo = "/admcom/barramento/metodos/" + cMetodo.
                    cMetodo = cMetodo + ".p".
                    RUN value(cMetodo) (input lcJsonEntrada, 
                                        output lcJsonSaida).

                    copy-lob lcJsonSaida to memptrSaidaJson convert target codepage "utf-8".

                    cRetorno = string(GET-SIZE(memptrSaidaJson)).
					
					IF ativaTrace = "true" THEN DO:
						run gravaLog("RETORNANDO TAMANHO JSON SAIDA = " + STRING(cRetorno)).  
					END.
					ELSE DO:
						logStr = STRING(logStr) + "\n RETORNANDO TAMANHO JSON SAIDA = " + STRING(cRetorno).
					END.

                END.
                /* PASSO 3 - ENVIA O JSON DE DE SAIDA */
                ELSE 
                    IF iPasso = 3 
                    THEN DO:  
                        ASSIGN iBytesAvail = hsocket:GET-BYTES-AVAILABLE(). 
                        ASSIGN 
                            iBystesLidos                  = iBytesAvail 
                            SET-SIZE(memptrEntrada)       = iBystesLidos 
                            SET-BYTE-ORDER(memptrEntrada) = BIG-ENDIAN 
                            lOK = hsocket:READ(memptrEntrada,1,iBytesAvail,READ-EXACT-NUM).  
                        ASSIGN 
                            cDadosEntrada = GET-STRING(memptrEntrada,1) 
                            SET-SIZE(memptrEntrada) = 0.
						
						IF ativaTrace = "true" THEN DO:
							run gravaLog(" flow 3 DADOS RECEBIDOS: " + cDadosEntrada + "BYTES").
						END.
						ELSE DO:
							logStr = STRING(logStr) + "\n flow 3 DADOS RECEBIDOS: " + cDadosEntrada + "BYTES".
						END.

                        /* manda o json */
                        hSocket:WRITE(memptrSaidaJson,1, GET-SIZE(memptrSaidaJson)).

						IF ativaTrace = "true" THEN DO:
							run gravaLog(" flow 3 ENVIOU DADOS " + string(GET-SIZE(memptrSaidaJson)) + "BYTES").
						END.
						ELSE DO:
							logStr = STRING(logStr) + "\n flow 3 ENVIOU DADOS " + string(GET-SIZE(memptrSaidaJson)) + "BYTES".
						END.

                        SET-SIZE(memptrSaidaJson) = 0.  
                        iPasso = iPasso + 1. 
                        lOK = no. 
                        iBytesAvail = 0. 
                        iBystesLidos = 0. 
                        cDadosEntrada = ?. 
                        cRetorno = ?.
						
						IF ativaTrace = "true" THEN DO:
							run gravaLog(" " + STRING(cMetodo)).
						END.
						ELSE DO:
							logStr =  STRING(logStr) + "\n " + STRING(cMetodo).
						END.

                    END.

                    /* ENVIA OS RETORNOS DOS PASSSOS 1 E 2 */ 
                    IF iBytesAvail = hsocket:BYTES-READ and iPasso < 3 
                    THEN do:  
                        SET-SIZE(memptrSaida) = (LENGTH(cRetorno, "RAW") + 1). 
                        PUT-STRING(memptrSaida,1) = cRetorno.  
                        hSocket:WRITE (memptrSaida,1,LENGTH(cRetorno)).  
                        SET-SIZE(memptrSaida) = 0.  
                        
                        iPasso = iPasso + 1. 
                        lOK = no. 
                        iBytesAvail = 0. 
                        iBystesLidos = 0. 
                        cDadosEntrada = ?. 
                        cRetorno = ?.

                    END.
        END.
		
		/* TRATAMENTO TIMEOUT */
		IF intervaloPegaTime > 5000 THEN DO:		
			intervaloPegaTime = 0.
			
			IF timeInicio < INT(TIME) THEN DO:
				run gravaLog(" CICLOS REPEAT: " + STRING(iCiclosRepeat) + " - ERRO!!! TIMEOUT FORÇADO DEVIDO A DEMORA.").
			
				hsocket:DISCONNECT().
						
				LEAVE.
			END.		
		END.
		
		
    END.
	
	IF ativaTrace = "true" THEN DO:
		run gravaLog(" CICLOS REPEAT: " + STRING(iCiclosRepeat) + "\n -- FIM --.").
	END.
	ELSE DO:
		logStr = STRING(logStr) + "\n CICLOS REPEAT: " + STRING(iCiclosRepeat) + "\n -- FIM --." + STRING(TIME).		
		run gravaLog(" " + STRING(logStr)).
	END.

hSocket:DISCONNECT().

END procedure.


PROCEDURE gravaLog.

	DEFINE INPUT PARAMETER texto       AS CHARACTER.
	/*
	OUTPUT TO value("/work-vnx/integracao-work/log/sockServer_" + string(today, "99999999") + ".log") APPEND.
		PUT UNFORMATTED "\n " + STRING(TIME,"HH:MM:SS") + " - " + STRING(texto).
	OUTPUT CLOSE.
	*/
END procedure.
