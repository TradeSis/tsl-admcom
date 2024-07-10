{/admcom/progr/portal_acentos.i}
{/admcom/progr/portal_host.i}

define variable lo-arquivo as longchar no-undo.
Define Variable ch-arquivo As Character No-undo.
define variable i-cont     as integer initial 0 no-undo.
define variable contar     as integer initial 0 no-undo.

DEFINE VARIABLE vhSocket   AS HANDLE                             NO-UNDO.
     
DEFINE VARIABLE de-tamanho AS DECIMAL     NO-UNDO.
define variable l-primeiro as logical initial yes no-undo.

define variable i-conta-arquivo as int no-undo.

assign i-conta-arquivo = 1.
     
define temp-table tt-valores no-undo serialize-name 'classe'
    field codigo     as integer   serialize-name 'numero'
    field descricao  as character serialize-name 'descricao'
    field grau       as integer   serialize-name 'grau'
    field classe-sup as integer   serialize-name 'codigoClasseSuperior'
    field tipo       as logical   serialize-name 'tipo'
    field cod-pai    as integer   serialize-hidden.
    
define temp-table tt-deleta-tudo serialize-name 'produtos'
    field deleta-tudo as character serialize-name 'deletaTudo'
    field codigo      as integer   serialize-hidden.
    
define dataset bisteka serialize-name 'integracao' for tt-valores,tt-deleta-tudo
    data-relation for tt-deleta-tudo, tt-valores
relation-fields (tt-deleta-tudo.codigo, tt-valores.cod-pai) nested.

create tt-deleta-tudo.
assign tt-deleta-tudo.codigo      = 1
       tt-deleta-tudo.deleta-tudo = 'Sim'.

for each clase no-lock:

    assign i-cont = i-cont + 1.

    create tt-valores.
    assign tt-valores.codigo     = clase.clacod
           tt-valores.descricao  = fnremoveacento(clase.clanome)
           tt-valores.grau       = clase.clagrau
           tt-valores.classe-sup = clase.clasup
           tt-valores.tipo       = clase.clatipo
           tt-valores.cod-pai    = 1.
    
    if i-cont = 2000 then do:
        if l-primeiro = no then do:
            find first tt-deleta-tudo exclusive-lock no-error.
            assign tt-deleta-tudo.deleta-tudo = 'Nao'.
        end.

        dataset bisteka:write-json("longchar",lo-arquivo,true).

        CREATE SOCKET vhSocket.
        vhSocket:CONNECT('-H ' + vcHost + ' -S ' + vcPort) NO-ERROR.
    
        IF vhSocket:CONNECTED() = FALSE 
        THEN DO:
	   RETURN.
        END.
                               
        vhSocket:SET-READ-RESPONSE-PROCEDURE('getResponse').
        
        assign i-conta-arquivo = i-conta-arquivo + 1.
                             
        RUN PostRequest (INPUT 'produtos/integracaoClasse', 
                         INPUT lo-arquivo).
             
        WAIT-FOR READ-RESPONSE OF vhSocket. 
        vhSocket:DISCONNECT() NO-ERROR.
        DELETE OBJECT vhSocket.
        /*QUIT.*/
    
        empty temp-table tt-valores no-error.
        assign i-cont = 0
               lo-arquivo = ''
               l-primeiro = no.
        
    end.
end.

if i-cont > 0 then do:
    dataset bisteka:write-json("longchar",lo-arquivo,true).

    CREATE SOCKET vhSocket.
    vhSocket:CONNECT('-H ' + vcHost + ' -S ' + vcPort) NO-ERROR.
                
    IF vhSocket:CONNECTED() = FALSE
    THEN DO:
	RETURN.
    END.
    
    vhSocket:SET-READ-RESPONSE-PROCEDURE('getResponse').
                                                     
     assign i-conta-arquivo = i-conta-arquivo + 1.
        
    RUN PostRequest (INPUT 'produtos/integracaoClasse',
                     input lo-arquivo).
                     
    WAIT-FOR READ-RESPONSE OF vhSocket.
    vhSocket:DISCONNECT() NO-ERROR.
    DELETE OBJECT vhSocket.                               

end.
             
PROCEDURE getResponse:
    DEFINE VARIABLE vcWebResp    AS longchar         NO-UNDO.
    DEFINE VARIABLE lSucess      AS LOGICAL          NO-UNDO.
    DEFINE VARIABLE mResponse    AS MEMPTR           NO-UNDO.
    
    IF vhSocket:CONNECTED() = FALSE THEN DO:
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
