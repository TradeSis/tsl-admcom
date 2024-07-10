{admcab.i}
 
DEFINE input param vcMetodo   AS CHARACTER     NO-UNDO.

DEFINE var vcENTRADA      AS CHARACTER     NO-UNDO.

DEFINE VARIABLE vhSocket   AS HANDLE           NO-UNDO.

def var varqlog as char.

def var vcsite as char.
def var vmetodo as char.
def var vLOG as char.
def var vxml    as char.

def shared temp-table tt-xmlretorno
    field child-num  as int
    field root       as char format "x(15)"
    field tag        as char format "x(20)"
    field valor      as char format "x(20)"
    /*index x is unique primary child-num asc root asc tag asc valor asc*/.



def shared temp-table tt-EmissaoValeTroca93 no-undo       
        field cestabelecimento      as char 
        field ccodigoloja       as char  
        field cpdv              as char  
        field cvalortransacao   as char  
        field choralocal        as char  
        field cdatalocal        as char  
        field ctipocliente      as char  
        field cnomecliente      as char  
        field ccpfcnpj          as char  
        field crg               as char  
        field corgaoemissaorg   as char  
        field cdatanascimento   as char  
        field cnumerotelefone   as char  
        field cnumerocupomtroca as char 
        field cnumerocupomvale  as char 
        field cdatavenda        as char 
        field cnumerolojavenda  as char 
        field cnumeropdvvenda   as char 
        field cnsuvenda         as char 
        field cnumerocupomvenda as char 
        field cnumerooperadorvenda as char 
        field cnumerooperadoremissao as char
        field cnumeroFiscalEmissao as char 
        field cdataSensibilizacao as char 
        field clojaSensibilizacao  as char
        field cpdvSensibilizacao  as char 
        field cnsuSensibilizacao  as char 
        field coperadorSensibilizacao  as char
        field cfiscalSensibilizacao  as char 
        field cmac  as char 
        field cnsuSafe as char.

if vcMetodo = "EmissaoValeTroca93"
then do:

    find first tt-EmissaoValeTroca93 no-error.
    if not avail tt-EmissaoValeTroca93 then return.

    vcEntrada = 
        'estabelecimento='   + cestabelecimento  +  
        '&codigoLoja='       + ccodigoloja       +  
        '&pdv='              + cpdv              +  
        '&valorTransacao='   + cvalortransacao   +  
        '&horaLocal='        + choralocal        +  
        '&dataLocal='        + cdatalocal        +  
        '&tipoCliente='      + ctipocliente      +  
        '&nomeCliente='      + cnomecliente      +  
        '&cpfCnpj='          + ccpfcnpj          +  
        '&rg='               + crg               +  
        '&orgaoEmissorRg='   + corgaoemissaorg   +  
        '&dataNascimento='   + cdatanascimento   +      
        '&numeroTelefone='   + cnumerotelefone   + 
        '&numeroCupomTroca=' + cnumerocupomtroca + 
        '&numeroCupomVale='  + cnumerocupomvale  + 
        '&dataVenda='        + cdatavenda        + 
        '&numeroLojaVenda='  + cnumerolojavenda  + 
        '&numeroPdvVenda='   + cnumeropdvvenda   + 
        '&nsuVenda='         + cnsuvenda         + 
        '&numeroCupomVenda=' + cnumerocupomvenda + 
        '&numeroOperadorVenda=' + cnumerooperadorvenda + 
        '&numeroOperadorEmissao=' + cnumerooperadoremissao + 
        '&numeroFiscalEmissao=' + cnumeroFiscalEmissao + 
        '&dataSensibilizacao=' + cdataSensibilizacao + 
        '&lojaSensibilizacao=' + clojaSensibilizacao  + 
        '&pdvSensibilizacao=' + cpdvSensibilizacao  + 
        '&nsuSensibilizacao=' + cnsuSensibilizacao  + 
        '&operadorSensibilizacao=' + coperadorSensibilizacao  + 
        '&fiscalSensibilizacao=' + cfiscalSensibilizacao  + 
        '&mac=' + cmac.
end.

if vcMetodo = "ConfirmaDesfazGenerico"
then do:

    find first tt-EmissaoValeTroca93 no-error.
    if not avail tt-EmissaoValeTroca93 then return.

    vcEntrada = 
        '&valor='                   + cvalortransacao   +  
        '&codigoEstabelecimento='    + cestabelecimento  +  
        '&codigoEmpresa=00001'       +  
        '&numeroLoja='              + ccodigoloja       +  
        '&pdv='                     + cpdv              +  
        '&nsuSafe='                 + cnsuSafe        +  
        '&dataLocal='               + cdatalocal        +  
        '&horaLocal='               + choralocal        +  
        '&isDesfazimento=false'.
        
end.



def buffer btt-xmlretorno for tt-xmlretorno.

def var vtime   as int.
def var vretorno as char.
def var vchost as char.
def var vcport as char.

def var varqbin as char.
def var vconteudo as char.

def var p-valor as char.
run le_tabini.p (setbcod, 0, "NFE - AMBIENTE", OUTPUT p-valor).

vchost = if p-valor = "HOMOLOGACAO"
         then "10.2.0.191"
         else if p-valor = "PRODUCAO"
              then "10.2.0.195"
              else "".
vcPort = "80".
vcSite = "/WS-SAFE/Optimus.asmx".

if vcMetodo = "" then do:
    message "Metodo obrigatorio".
    return.
end. 

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

varqlog = "/ws/log/wssafe_ret_" + string(today,"999999") + replace(string(vtime,"HH:MM:SS"),":","") + ".log".

/**
output to value(varqlog).
output close.
**/


RUN postRequest (
    INPUT vcSite + "/" + vcMetodo,    INPUT vcENTRADA).
 
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
         output to value(varqlog) append.
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

    /*message vcrequest. pause.
    */
      
    /*
    if vcLOG <> ""
    then do:
        output to value("/admcom/mdfe/mdfe-xml/wsnotamax-ENV." + vcmetodo + 
                "." + vcLOG + "." + string(vtime)).
        put unformatted vcRequest.
        output close.
    end.
    **/ 
    
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

