{/admcom/progr/portal_acentos.i}
{/admcom/progr/portal_host.i}

define variable lo-arquivo as longchar            no-undo.
define Variable ch-arquivo as character           no-undo.
define variable i-cont     as integer initial 0   no-undo.
define variable vhSocket   aS handle              no-undo.

define variable de-tamanho as decimal             no-undo.
define variable l-primeiro as logical initial yes no-undo.

define temp-table tt-unidades no-undo serialize-name 'salesUnits'
    field codigo    as character      serialize-name 'unit'
    field descricao as character      serialize-name 'description'.
           
define dataset bisteka serialize-name 'integracao' for tt-unidades.

for each unida no-lock:
    create tt-unidades.
    assign tt-unidades.codigo    =  fnremoveacento(unida.unicod)
           tt-unidades.descricao =  fnremoveacento(unida.uninom).
end.

TEMP-TABLE tt-unidades:WRITE-JSON("longchar", lo-arquivo, true).

CREATE SOCKET vhSocket.
vhSocket:CONNECT('-H ' + vcHost + ' -S ' + vcPortCore) NO-ERROR.

IF vhSocket:CONNECTED() = FALSE
THEN DO:
    /*MESSAGE "Connection failure" VIEW-AS ALERT-BOX.
    
    MESSAGE ERROR-STATUS:GET-MESSAGE(1) VIEW-AS ALERT-BOX.*/
    RETURN.
END.

vhSocket:SET-READ-RESPONSE-PROCEDURE('getResponse').

RUN PostRequest (INPUT 'sales-units/integrate', 
                 INPUT lo-arquivo).
             
WAIT-FOR READ-RESPONSE OF vhSocket. 
vhSocket:DISCONNECT() NO-ERROR.
DELETE OBJECT vhSocket.
/*QUIT.*/
             
PROCEDURE getResponse:
    DEFINE VARIABLE vcWebResp    AS longchar         NO-UNDO.
    DEFINE VARIABLE lSucess      AS LOGICAL          NO-UNDO.
    DEFINE VARIABLE mResponse    AS MEMPTR           NO-UNDO.
    
    IF vhSocket:CONNECTED() = FALSE THEN DO:
        /*MESSAGE 'Not Connected' VIEW-AS ALERT-BOX.*/
        RETURN.
    END.
        lSucess = TRUE.
                                    
    DO WHILE vhSocket:GET-BYTES-AVAILABLE() > 0:
        SET-SIZE(mResponse) = vhSocket:GET-BYTES-AVAILABLE() + 1.
        SET-BYTE-ORDER(mResponse) = BIG-ENDIAN.
        vhSocket:READ(mResponse,1,1,vhSocket:GET-BYTES-AVAILABLE()).
        vcWebResp = vcWebResp + GET-STRING(mResponse,1).
    END.            
END.
                                
PROCEDURE PostRequest:
    DEFINE INPUT PARAMETER postUrl  AS CHAR. 
    DEFINE INPUT PARAMETER postData AS Longchar.
    
    DEFINE VARIABLE vcRequest      AS Longchar.
    DEFINE VARIABLE mRequest       AS MEMPTR.

    vcRequest = 'POST /' +
                postUrl +
                ' HTTP/1.1~r~n' +
                ' HOST: ' + vchost + ':' + /*vcport*/ vcPortCore  + '~r~n' +
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


