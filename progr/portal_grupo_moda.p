define variable lo-arquivo as longchar no-undo.

define temp-table tt-valores no-undo serialize-name "grupoMixModa"
    field codigo    as integer   serialize-name "codigo"
    field descricao as character serialize-name "descricao".
    
define dataset bisteka for tt-valores.

{/home/kbase/bkps/foreach.i mixmgrupo codgrupo nome}

/*dataset bisteka:write-json("file","/home/kbase/bkps/bisteka_grupomoda.txt",true~ ).*/

dataset
bisteka:write-json("longchar",lo-arquivo,true).

Define Variable ch-arquivo As Character No-undo.

DEFINE VARIABLE vcHost     AS CHARACTER    INITIAL "sv-ca-bis-hml.cloudapp.net"    NO-UNDO.
DEFINE VARIABLE vcPort     AS CHARACTER    INITIAL "1337"        NO-UNDO.
DEFINE VARIABLE vhSocket   AS HANDLE                             NO-UNDO.
 
DEFINE VARIABLE de-tamanho AS DECIMAL     NO-UNDO.

CREATE SOCKET vhSocket.
vhSocket:CONNECT('-H ' + vcHost + ' -S ' + vcPort) NO-ERROR.
    
IF vhSocket:CONNECTED() = FALSE 
THEN DO:
    MESSAGE "Connection failure" VIEW-AS ALERT-BOX.
        
    MESSAGE ERROR-STATUS:GET-MESSAGE(1) VIEW-AS ALERT-BOX.
    RETURN.
END.
ELSE
    MESSAGE "Connect" VIEW-AS ALERT-BOX.
                       
vhSocket:SET-READ-RESPONSE-PROCEDURE('getResponse').
                     
RUN PostRequest (INPUT 'produtos/integracaoGrupoMixModa', 
                                 INPUT lo-arquivo).
             
WAIT-FOR READ-RESPONSE OF vhSocket. 
vhSocket:DISCONNECT() NO-ERROR.
DELETE OBJECT vhSocket.
/*QUIT.*/
             
PROCEDURE getResponse:
        DEFINE VARIABLE vcWebResp    AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE lSucess      AS LOGICAL          NO-UNDO.
    DEFINE VARIABLE mResponse    AS MEMPTR           NO-UNDO.
    
    IF vhSocket:CONNECTED() = FALSE THEN DO:
                MESSAGE '111 - Not Connected' VIEW-AS ALERT-BOX.
        RETURN.
    END.
        lSucess = TRUE.
                                    
    DO WHILE vhSocket:GET-BYTES-AVAILABLE() > 0:
                SET-SIZE(mResponse) = vhSocket:GET-BYTES-AVAILABLE() + 1.
        SET-BYTE-ORDER(mResponse) = BIG-ENDIAN.
        vhSocket:READ(mResponse,1,1,vhSocket:GET-BYTES-AVAILABLE()).
        vcWebResp = vcWebResp + GET-STRING(mResponse,1).
    END.
    

        MESSAGE vcWebResp VIEW-AS ALERT-BOX INFO BUTTONS OK.
                    
        END.
                                
PROCEDURE PostRequest:
        DEFINE VARIABLE vcRequest      AS Longchar.
    DEFINE VARIABLE mRequest       AS MEMPTR.
    DEFINE INPUT PARAMETER postUrl AS CHAR. 
    DEFINE INPUT PARAMETER postData AS Longchar.

    vcRequest = 'POST /' +
                postUrl +
                ' HTTP/1.1~r~n' +
                ' HOST: ' + desenv61:1337~r~n' +
                'Content-Type: application/json~r~n' +
                                'Content-Length: ' + string(LENGTH(postData)) +
                '~r~n' + '~r~n' +
                postData.

    SET-SIZE(mRequest)            = 0.
    SET-SIZE(mRequest)            = LENGTH(vcRequest) + 1.
    SET-BYTE-ORDER(mRequest)      = BIG-ENDIAN.
    PUT-STRING(mRequest,1)        = vcRequest .
         
        vhSocket:WRITE(mRequest, 1, LENGTH(vcRequest)).

END PROCEDURE.