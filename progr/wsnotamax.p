 
DEFINE input param vcSite     AS CHARACTER     NO-UNDO.
DEFINE input param vcMetodo   AS CHARACTER     NO-UNDO.
DEFINE input param vcXML      AS CHARACTER     NO-UNDO.
/**def    input param vcLeRetorno as logical      no-undo. **/
def    input param vcLOG      as char.

DEFINE VARIABLE vhSocket   AS HANDLE           NO-UNDO.

{wsnotamax.i}

def buffer btt-xmlretorno for tt-xmlretorno.

def var vtime   as int.
def var vretorno as char.
def var vchost as char.
def var vcport as char.
def var p-valor as char.

def var varqbin as char.
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
if vcPort = "" then vcPort = "80".
if vcSite = "" then vcSite = "/notamax/services/wsNotamax.asmx".
if vcMetodo = "" then do:
    message "Metodo obrigatorio".
    return.
end. 
if vcXML = "" 
then vcXML = "envNotamax=<?xml version='1.0'?> <envNotamax> <login> <usuario>publico</usuario~ > <senha>senha</senha> </login> <parametros><CNPJ>96662168014353</CNPJ></parame~ tros></envNotamax>".

pause 1 no-message.

vtime = time.
empty temp-table tt-xmlretorno.

CREATE SOCKET vhSocket.
vhSocket:CONNECT('-H ' + vcHost + ' -S ' + vcPort) NO-ERROR.
    
IF vhSocket:CONNECTED() = FALSE THEN
DO:
    hide message no-pause.
    MESSAGE "Conexao falhou com " vcHost " Porta " vcPort.
    MESSAGE ERROR-STATUS:GET-MESSAGE(1) VIEW-AS ALERT-BOX.
    RETURN.
END.
 
vhSocket:SET-READ-RESPONSE-PROCEDURE('getResponse').

RUN PostRequest (
    INPUT vcSite + "/" + vcMetodo,    INPUT vcXML).
 
WAIT-FOR READ-RESPONSE OF vhSocket. 
vhSocket:DISCONNECT() NO-ERROR.
DELETE OBJECT vhSocket.
return.
 
PROCEDURE getResponse:
    DEFINE VARIABLE vcWebResp    AS CHAR        NO-UNDO.
    DEFINE VARIABLE lSucess      AS LOGICAL          NO-UNDO.
    DEFINE VARIABLE mResponse    AS MEMPTR           NO-UNDO.
    
    IF vhSocket:CONNECTED() = FALSE THEN do:
        MESSAGE 'Not Connected' VIEW-AS ALERT-BOX.
        RETURN.
    END.
    lSucess = TRUE.
        
    DO WHILE vhSocket:GET-BYTES-AVAILABLE() > 0:
            
         SET-SIZE(mResponse) = vhSocket:GET-BYTES-AVAILABLE() + 1.
         SET-BYTE-ORDER(mResponse) = BIG-ENDIAN.
         vhSocket:READ(mResponse,1,1,vhSocket:GET-BYTES-AVAILABLE()).
         vcWebResp = vcWebResp + GET-STRING(mResponse,1).
         /**
         output to socket.resp append.
         put unformatted skip
            vcwebresp.
         output    close.
         **/
         
    END.
    /**if vcleretorno
    then**/ run retorno (input vcwebresp).


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
        'Content-Type: application/x-www-form-urlencoded' +
                    /**  '; charset=utf-8 '  +**/  vlf +
        'Content-Length: ' + string(LENGTH(postData)) +
        vlf + vlf +
        postData + vlf.
 
    if vcLOG <> ""
    then do:
        output to value("/admcom/mdfe/mdfe-xml/wsnotamax-ENV." + vcmetodo + 
                "." + vcLOG + "." + string(vtime)).
        put unformatted vcRequest.
        output close.
    end.
     
    
    SET-SIZE(mRequest)            = 0.
    SET-SIZE(mRequest)            = LENGTH(vcRequest) + 1.
    SET-BYTE-ORDER(mRequest)      = BIG-ENDIAN.
    PUT-STRING(mRequest,1)        = vcRequest .
 
    vhSocket:WRITE(mRequest, 1, LENGTH(vcRequest)).
END PROCEDURE.

 
 
procedure retorno.

    def input param vretorno as char.

    def var vb      as memptr.
    def var Hdoc  as handle.
    def var Hroot as handle.

    if index(vretorno, "<") = 0
    then return.

    set-size(vb) = 60001.

    vretorno = substr(vretorno, index(vretorno, "<") ).
    vretorno = replace(vretorno, "&lt;", "<").
    vretorno = replace(vretorno, "&gt;", ">").
    vretorno = replace(vretorno, "&amp;","&").
    
    put-string(vb, 1) = vretorno.
    if vcLOG <> ""
    then do:
        output to value("/admcom/mdfe/mdfe-xml/wsnotamax-RET." + vcmetodo + 
             "." + vcLOG + "." + string(vtime)).
        put unformatted vretorno.
        output close.
    end.
    
    create x-document HDoc.
    Hdoc:load("MEMPTR", vb, false). /* load do XML */
    create x-noderef hroot.
    hDoc:get-document-element(hroot). 
      
    run obtemnode ("", input hroot).
   /*Aqui chama a procedure que monta uma tt com os dados de retorno passando c~omo parâmetro dos dados recebidos pelo load*/

end procedure.


procedure obtemnode.

    def input parameter p-root  as char.
    def input parameter vh      as handle.

    def var hc   as handle.
    def var loop as int.

    
    create x-noderef hc.
    /* A partir daqui monta o retorno */
    do loop = 1 to vh:num-children: /*faz o loop até o numero total de filhos*/
        vh:get-child(hc,loop).
        run obtemnode (vh:name, input hc:handle).
        if true /**trim(hc:node-value) <> ""**/
        then do.
            
            if p-root = vh:name then next. /* helio */
            
            vconteudo = trim(hc:node-value).

            find first btt-xmlretorno where
                btt-xmlretorno.root = p-root and
                btt-xmlretorno.tag  = vh:name and
                btt-xmlretorno.valor = vconteudo
                no-error.
            if avail btt-xmlretorno then next. /*helio */            

            
            create tt-xmlretorno.
            tt-xmlretorno.child-num = vh:child-num.
            tt-xmlretorno.root  = p-root.
            tt-xmlretorno.tag   = vh:name. /* nomes das tags */
            tt-xmlretorno.valor = vconteudo.
        end.    
    end.                       

end procedure.

