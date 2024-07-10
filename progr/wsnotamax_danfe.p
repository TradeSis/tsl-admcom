 
DEFINE input param vcMetodo   AS CHARACTER     NO-UNDO.
DEFINE input param vcXML      AS CHARACTER     NO-UNDO.
define input param par-arqret as char. /* nome do arquivo de retorno */

DEFINE VARIABLE vhSocket   AS HANDLE           NO-UNDO.
 
{wsnotamax.i}

def buffer btt-xmlretorno for tt-xmlretorno.

def var vtime   as int.
def var vchost  as char.
def var vcport  as char init "80".
def var vcSite  as char init "/notamax/services/wsNotamax.asmx".
def var p-valor as char.
def var vconteudo as char.

run le_tabini.p (0, 0, "NFE - AMBIENTE", OUTPUT p-valor).

if p-valor = "PRODUCAO"
THEN do:
    /**
    run le_tabini.p (0, 0, "NFE - IP PRODUCAO", OUTPUT vcHost).
    **/
    vchost = "10.2.0.121".
end. 
else run le_tabini.p (0, 0, "NFE - IP HOMOLOGACAO", OUTPUT vcHost).

if vcHost = "" then vchost = "10.2.0.42". /* HML NotaMax */
if vcMetodo = ""
then do:
    message "Metodo obrigatorio".
    return.
end. 
if vcXML = "" 
then vcXML = "envNotamax=<?xml version='1.0'?> <envNotamax> <login> <usuario>publico</usuario~ > <senha>senha</senha> </login> <parametros><CNPJ>96662168014353</CNPJ></parame~ tros></envNotamax>".

vtime = time.
empty temp-table tt-xmlretorno.

CREATE SOCKET vhSocket.
vhSocket:CONNECT('-H ' + vcHost + ' -S ' + vcPort) NO-ERROR.
IF vhSocket:CONNECTED() = FALSE
THEN DO:
    hide message no-pause.
    MESSAGE "Conexao falhou com " vcHost " Porta " vcPort.
    MESSAGE ERROR-STATUS:GET-MESSAGE(1) VIEW-AS ALERT-BOX.
    RETURN.
END.
 
vhSocket:SET-READ-RESPONSE-PROCEDURE('getResponse').

RUN PostRequest (INPUT vcSite + "/" + vcMetodo, INPUT vcXML).
 
WAIT-FOR READ-RESPONSE OF vhSocket. 
vhSocket:DISCONNECT() NO-ERROR.
DELETE OBJECT vhSocket.
return.

 
PROCEDURE getResponse:
    DEFINE VARIABLE vcWebResp    AS longCHAR        NO-UNDO.
    DEFINE VARIABLE lSucess      AS LOGICAL          NO-UNDO.
    DEFINE VARIABLE mResponse    AS MEMPTR           NO-UNDO.
    
    IF vhSocket:CONNECTED() = FALSE
    THEN do:
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

    run retorno (input vcwebresp).

END PROCEDURE.


PROCEDURE PostRequest:
    DEFINE VARIABLE vcRequest      AS CHARACTER.
    DEFINE VARIABLE mRequest       AS MEMPTR.
    DEFINE INPUT PARAMETER postUrl AS CHAR. 
    DEFINE INPUT PARAMETER postData AS CHAR.

    def var vlf as char.

    vlf = chr(10).

    vcRequest =
        'POST ' + postUrl + ' HTTP/1.0' + vlf +
        'Content-Type: application/x-www-form-urlencoded' + vlf +
        'Content-Length: ' + string(LENGTH(postData)) + vlf + vlf +
        postData + vlf.
 
/***
    if vcLOG <> ""
    then do:
        output to value("/admcom/mdfe/mdfe-xml/wsnotamax-ENV." + vcmetodo + 
                        "." + vcLOG + "." + string(vtime)).
        put unformatted vcRequest.
        output close.
    end.
***/

    SET-SIZE(mRequest)            = 0.
    SET-SIZE(mRequest)            = LENGTH(vcRequest) + 1.
    SET-BYTE-ORDER(mRequest)      = BIG-ENDIAN.
    PUT-STRING(mRequest,1)        = vcRequest .
 
    vhSocket:WRITE(mRequest, 1, LENGTH(vcRequest)).
END PROCEDURE.


procedure retorno.

    def input param vretorno as longchar.

    def var Hdoc  as handle.
    def var Hroot as handle.

    /* Retira cabecalho */
    vretorno = substr(vretorno, index(vretorno, "<") ).
    create x-document HDoc.
    hDoc:LOAD("LONGCHAR",vretorno  ,FALSE).
    create x-noderef hroot.
    hDoc:get-document-element(hroot).
    run obtemnode ("", input hroot).

end procedure.


procedure obtemnode.

    def input parameter p-root  as char.
    def input parameter vh      as handle.
    
    def var hc   as handle.
    def var loop as int.
    def var vpdfchar as longchar.
    def var vpdfmptr as memptr.

    create x-noderef hc.
    do loop = 1 to vh:num-children: /*faz o loop até o numero total de filhos*/
        vh:get-child(hc,loop).

        if hc:subtype = "text"
        then do:
            if vh:name = "binario_pdf"
            then do.
                message "Gerando PDF...".
                hc:NODE-VALUE-TO-LONGCHAR(vpdfchar).
                vpdfmptr = base64-decode(vpdfchar).
                copy-lob from vpdfmptr to file par-arqret.
            end.
        end.
        
        run obtemnode (vh:name, input hc:handle).
    end.                       

end procedure.

