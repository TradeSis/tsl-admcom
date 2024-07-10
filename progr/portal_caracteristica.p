{/admcom/progr/portal_acentos.i}
{/admcom/progr/portal_host.i}

define variable lo-arquivo as longchar no-undo.
Define Variable ch-arquivo As Character No-undo.
define variable i-cont     as integer initial 0 no-undo.
dEFINE VARIABLE vhSocket   AS HANDLE                             NO-UNDO.
     
DEFINE VARIABLE de-tamanho AS DECIMAL     NO-UNDO.
define variable l-primeiro as logical initial yes no-undo.
     
define temp-table tt-valores no-undo serialize-name 'caracteristica'
    field codigo    as integer   serialize-name 'codigo'
    field descricao as character serialize-name 'descricao'
    field cod-pai   as integer   serialize-hidden.
    
define temp-table tt-deleta-tudo serialize-name 'produtos'
    field deleta-tudo as character serialize-name 'deletaTudo'
    field codigo      as integer   serialize-hidden.
    
define dataset bisteka serialize-name 'integracao' for tt-valores,tt-deleta-tudo
    data-relation for tt-deleta-tudo, tt-valores
relation-fields (tt-deleta-tudo.codigo, tt-valores.cod-pai) nested.

create tt-deleta-tudo.
assign tt-deleta-tudo.deleta-tudo = 'Sim'
       tt-deleta-tudo.codigo      = 1.

for each caract no-lock:

    create tt-valores.
    assign tt-valores.codigo    = caract.carcod
           tt-valores.descricao = fnremoveacento(caract.cardes)
           tt-valores.cod-pai   = 1.

end.

dataset
bisteka:write-json("longchar",lo-arquivo,true).

CREATE SOCKET vhSocket.
vhSocket:CONNECT('-H ' + vcHost + ' -S ' + vcPort) NO-ERROR.
    
IF vhSocket:CONNECTED() = FALSE 
THEN DO:
    /*MESSAGE "Connection failure" VIEW-AS ALERT-BOX.
        
    MESSAGE ERROR-STATUS:GET-MESSAGE(1) VIEW-AS ALERT-BOX.*/
    RETURN.
END.
                       
vhSocket:SET-READ-RESPONSE-PROCEDURE('getResponse').

RUN PostRequest (INPUT 'produtos/integracaoCaracteristica', 
                                 INPUT lo-arquivo).
             
WAIT-FOR READ-RESPONSE OF vhSocket. 
vhSocket:DISCONNECT() NO-ERROR.
DELETE OBJECT vhSocket.
/*QUIT.*/
             
PROCEDURE getResponse:
        DEFINE VARIABLE vcWebResp    AS longchar        NO-UNDO.
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
        DEFINE VARIABLE vcRequest      AS Longchar.
    DEFINE VARIABLE mRequest       AS MEMPTR.
    DEFINE INPUT PARAMETER postUrl AS CHAR. 
    DEFINE INPUT PARAMETER postData AS Longchar.

    vcRequest = 'POST /' +
                postUrl +
                ' HTTP/1.1~r~n' +
                ' HOST: ' + vchost + ':' + vcport + '~r~n' +
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
