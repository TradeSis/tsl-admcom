
/*
*
*/
DEFINE VARIABLE hServerSocket AS HANDLE.
DEFINE VARIABLE l-Ok          AS LOGICAL.

CREATE SERVER-SOCKET hServerSocket.
hServerSocket:SET-CONNECT-PROCEDURE("instanciaClientSocket").
l-Ok = hServerSocket:ENABLE-CONNECTIONS( "-S 65500").

IF NOT l-Ok THEN
 RETURN.

REPEAT ON STOP UNDO, LEAVE ON QUIT UNDO, LEAVE:
    WAIT-FOR CONNECT OF hServerSocket.
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

  iPasso = 1.
  iPonteiro = 1.
  iCiclos = 1.

    REPEAT: 
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
               
                OUTPUT TO value("/integracao/log/sockServer_" + string(today, "99999999") + ".log") APPEND. 
                    PUT UNFORMATTED "\n cRetorno=" + STRING(cRetorno). 
                OUTPUT CLOSE.  
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
                    FIX-CODEPAGE (lcJsonEntrada) = 'utf-8'. 
                    COPY-LOB FROM OBJECT memptrEntrada TO lcJsonEntrada CONVERT SOURCE CODEPAGE 'utf-8'.  
                    ASSIGN SET-SIZE(memptrEntrada) = 0.
                    
                    OUTPUT TO value("/integracao/log/sockServer_" + string(today, "99999999") + ".log") APPEND.
                        PUT UNFORMATTED "\n RUN " + STRING(cMetodo).
                    OUTPUT CLOSE.

                    cMetodo = "/admcom/barramento/metodos/" + cMetodo.
                    cMetodo = cMetodo + ".p".
                    RUN value(cMetodo) (input lcJsonEntrada, 
                                        output lcJsonSaida).

                    copy-lob lcJsonSaida to memptrSaidaJson convert target codepage "utf-8".

                    cRetorno = string(GET-SIZE(memptrSaidaJson)).

                    OUTPUT TO value("/integracao/log/sockServer_" + string(today, "99999999") + ".log") APPEND.
                        PUT UNFORMATTED "\n RETORNANDO TAMANHO JSON SAIDA = " + STRING(cRetorno).
                    OUTPUT CLOSE.  
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

                        OUTPUT TO value("/integracao/log/sockServer_" + string(today, "99999999") + ".log") APPEND.
                            PUT UNFORMATTED "\n flow 3 DADOS RECEBIDOS: " + cDadosEntrada + "BYTES".
                        OUTPUT CLOSE.

                        /* manda o json */
                        hSocket:WRITE(memptrSaidaJson,1, GET-SIZE(memptrSaidaJson)).

                        OUTPUT TO value("/integracao/log/sockServer_" + string(today, "99999999") + ".log") APPEND.
                            PUT UNFORMATTED "\n flow 3 ENVIOU DADOS " + string(GET-SIZE(memptrSaidaJson)) + "BYTES".
                        OUTPUT CLOSE.

                        SET-SIZE(memptrSaidaJson) = 0.  
                        iPasso = iPasso + 1. 
                        lOK = no. 
                        iBytesAvail = 0. 
                        iBystesLidos = 0. 
                        cDadosEntrada = ?. 
                        cRetorno = ?.
						
						OUTPUT TO value("/integracao/log/sockServer_" + string(today, "99999999") + ".log") APPEND.
                            PUT UNFORMATTED "\n " + STRING(cMetodo) + " -- FIM --.".
                        OUTPUT CLOSE.
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

    END.

END procedure.
