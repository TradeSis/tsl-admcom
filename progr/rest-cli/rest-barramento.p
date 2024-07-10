def input  parameter vcMetodo   as char. 
def input  parameter vLCEntrada as longchar.
def output parameter vLCSaida   as longchar.

DEFINE VARIABLE vhSocket   AS HANDLE           NO-UNDO.
def var vchost as char.
def var vcport as char.
DEFINE var vcSite     AS CHARACTER     NO-UNDO.
/*
def var vtime   as int.
def var vretorno as char.
def var p-valor as char.

def var varqbin as char.
def var vconteudo as char.
*/
def var vmaquina as char.
vchost = "".
 input through value("uname -n") no-echo.
 import vmaquina.
 input close.

/*run lemestre.p (input "IPBARRAMENTO", output vchost).     */
 if vmaquina = "SV-CA-DB-DEV" or
    vmaquina = "sv-ca-linx-h" or
    vmaquina = "SV-CA-DB-QA"
 then vchost = "172.19.130.11".
 else vchost = "172.19.130.175". /* #23082022 helio - estava final 5 */
 if vcPort = "" then vcPort = "5555".

if vchost = "" or vchost = ?
then do:
    vchost = "172.19.130.175". /* #23082022 helio - estava final 5 */
    vcPort = "5555".
end.    


if vcPort = "" then vcPort = "6666".
if vcSite = "" then vcSite = "/gateway/pdvRestAPI/1.0".

message vchost vcPort. pause 1 no-message.

CREATE SOCKET vhSocket.
vhSocket:CONNECT('-H ' + vcHost + ' -S ' + vcPort) NO-ERROR.
hide message no-pause.    
IF vhSocket:CONNECTED() = FALSE THEN
DO:
    hide message no-pause.
    MESSAGE "Conexao falhou com " vcHost " Porta " vcPort.
    MESSAGE ERROR-STATUS:GET-MESSAGE(1) VIEW-AS ALERT-BOX.
    RETURN.
END.
 
vhSocket:SET-READ-RESPONSE-PROCEDURE('getResponse').

RUN PostRequest (
    INPUT vcSite + "/" + vcMetodo,    INPUT vlcEntrada).
 
WAIT-FOR READ-RESPONSE OF vhSocket. 
vhSocket:DISCONNECT() NO-ERROR.
DELETE OBJECT vhSocket.
return.
 
PROCEDURE getResponse:
    DEFINE VARIABLE lJson        AS LOGICAL          NO-UNDO.
    DEFINE VARIABLE mResponse    AS MEMPTR           NO-UNDO.

    def var vstring        as char no-undo.
    
    IF vhSocket:CONNECTED() = FALSE THEN do:
        MESSAGE 'Not Connected' VIEW-AS ALERT-BOX.
        RETURN.
    END.
    lJson = no.
def var vretorno as char.        


/*output to retorno.json. 
output close.*/


    DO WHILE vhSocket:GET-BYTES-AVAILABLE() > 0:
            
         SET-SIZE(mResponse) = vhSocket:GET-BYTES-AVAILABLE() + 1.
         SET-BYTE-ORDER(mResponse) = BIG-ENDIAN.
         vhSocket:READ(mResponse,1,1,vhSocket:GET-BYTES-AVAILABLE()).
         
         vstring = GET-STRING(mResponse,1).
         vretorno = vretorno + vstring.

         /**
         output to retorno.json append.
         put unformatted vretorno skip.
         output close.
         **/
                     
         if ljson = no
         then do:
            if vstring  =  "\{"
            then do:
                vlcsaida= vstring.
                ljson = yes.  
            end.
         end.
         else do:
             vlcSaida = vLCSaida + vstring /*gnGET-STRING(mResponse,1)*/ .
        end.     

    END.

END.

PROCEDURE PostRequest:
    DEFINE VARIABLE vcRequest      AS CHARACTER.
    DEFINE VARIABLE mRequest       AS MEMPTR.
    DEFINE INPUT PARAMETER postUrl AS CHAR. 
    DEFINE INPUT PARAMETER postData AS CHAR.

    def var vlf as char.
    vlf = '~r~n'.
    vlf = chr(10).

    vcRequest =
        'POST ' +
        postUrl +
        ' HTTP/1.0' + vlf +
/*        'Accept-Encoding: gzip,deflate ' + vlf +  */
        'Content-Type: application/json ' + vlf +
        'Content-Length: ' + string(LENGTH(postData)) +
        vlf + vlf +
        postData + vlf.
 

    /*output to post.socket.
    put unformatted vcRequest.
    output close.             */
    
    SET-SIZE(mRequest)            = 0.
    SET-SIZE(mRequest)            = LENGTH(vcRequest) + 1.
    SET-BYTE-ORDER(mRequest)      = BIG-ENDIAN.
    PUT-STRING(mRequest,1)        = vcRequest .
 
    vhSocket:WRITE(mRequest, 1, LENGTH(vcRequest)).
END PROCEDURE.

