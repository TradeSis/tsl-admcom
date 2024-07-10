{/admcom/progr/portal_acentos.i}
{/admcom/progr/portal_host.i}

define variable lo-arquivo as longchar no-undo.

define temp-table tt-valores no-undo serialize-name "classificacaoFiscal"
    field codigo    as integer   serialize-name "codigo"
    field descricao as character serialize-name "descricao".

define dataset data for tt-valores.

define variable i-cont as integer initial 0 no-undo.

define variable ch-arquivo as character no-undo.
define variable vhsocket as handle no-undo.
define variable de-tamanho as decimal no-undo.

CREATE SOCKET vhSocket.

vhSocket:CONNECT('-H ' + vcHost + ' -S ' + vcPortCore) NO-ERROR.

vhSocket:SET-READ-RESPONSE-PROCEDURE('getResponse').

for each clafis no-lock:

    assign i-cont = i-cont + 1.

    create tt-valores.
    assign tt-valores.codigo    = clafis.codfis
           tt-valores.descricao = substring(fnRemoveAcento(clafis.desfis),1,100).

    IF tt-valores.descricao = "" THEN
	ASSIGN tt-valores.descricao = "Sem Descricao".

    dataset data:write-json("longchar",lo-arquivo,true).
   
    if i-cont = 3000 then do:
    
        IF vhSocket:CONNECTED() = FALSE THEN DO:
            MESSAGE "Connection failure".
            RETURN.
        END.

        RUN PostRequest (INPUT 'tax-classifications/integration-admcom', 
                         INPUT lo-arquivo).
             
        WAIT-FOR READ-RESPONSE OF vhSocket. 
    
        empty temp-table tt-valores no-error.

        assign i-cont = 0
               lo-arquivo = ''.

    end.
end.

IF vhSocket:CONNECTED() = FALSE THEN DO:
    MESSAGE "Connection failure".
    RETURN.
END.

RUN PostRequest (INPUT 'tax-classifications/integration-admcom',
                 INPUT lo-arquivo).

WAIT-FOR READ-RESPONSE OF vhSocket.

vhSocket:DISCONNECT() NO-ERROR.

DELETE OBJECT vhSocket.

PROCEDURE getResponse:
    
    DEFINE VARIABLE vcWebResp    AS longchar        NO-UNDO.
    DEFINE VARIABLE lSucess      AS LOGICAL          NO-UNDO.
    DEFINE VARIABLE mResponse    AS MEMPTR           NO-UNDO.
    
    IF vhSocket:CONNECTED() = FALSE THEN DO:
        MESSAGE 'Not Connected' VIEW-AS ALERT-BOX.
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

    DEFINE VARIABLE vcRequest AS Longchar.
    DEFINE VARIABLE mRequest  AS MEMPTR.

    vcRequest = 'POST /' +
                postUrl +
                ' HTTP/1.1~r~n' +
                ' HOST: ' + vchost + ':' + vcPortCore + '~r~n' +
                'Content-Type: text/html;charset=UTF-8~r~n' +
                                'Content-Length: ' + string(LENGTH(postData)) +
                '~r~n' +   
                '~r~n' +
                postData
                .

    SET-SIZE(mRequest)            = 0.
    SET-SIZE(mRequest)            = LENGTH(vcRequest) + 1.
    SET-BYTE-ORDER(mRequest)      = BIG-ENDIAN.
    PUT-STRING(mRequest,1)        = vcRequest .
         
    vhSocket:WRITE(mRequest, 1, LENGTH(vcRequest)).

END PROCEDURE.
