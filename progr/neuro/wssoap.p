def input parameter par_props  as char.
def input parameter par_arqlog as char.

def var vpolitica   as char.
def var vidproposta as char.
def var vct  as int.
def var vtag as char.
def var vchave as char.
def var vvalor as char.
def var varqsaida as char.

def var vRequest         as longchar.
def var vnamespace       as char init "neur:".
def var vResponse        as longchar.
def var lConectou        as log.

def SHARED temp-table tt-retorno no-undo
    field PARAMETRO as char format "x(30)"
    field RESPOSTA  as char format "x(40)"
    index par  PARAMETRO asc.


function GeraXml returns log
    (input a-acao  as char,
     input b-acao  as char,
     input p-tag   as char,
     input p-valor as char):

    if p-valor = ? then p-valor = "".

    if a-acao = "XML" and
       b-acao = ""
    then vRequest = vRequest + "<?xml version='1.0' encoding='UTF-8' ?>".

    else if a-acao <> "" and
            b-acao <> "" and
            p-valor = ""
    then vRequest = vRequest + "<" + vnamespace + p-tag + "/>".

    else if a-acao <> "" or
            b-acao <> ""
    then do:
        if a-acao <> ""
        then do.
            if p-valor <> ""
            then vRequest = vRequest + chr(10).
            if a-acao = "TAG"
            then vRequest = vRequest + "<" + vnamespace + p-tag + ">".
        end.

        if p-valor <> ""
        then vRequest = vRequest + p-valor.

        if b-acao = "TAG"
        then vRequest = vRequest + "</" + vnamespace + p-tag + ">".
    end.
end function.


procedure geralog.
    def input parameter p_mensagem as char.

    output to value(par_arqlog + ".log") append.
    put unformatted string(time, "hh:mm:ss") " WS " p_mensagem skip.
    output close.

end procedure.


procedure obtemNode.
    def input param vh as handle.

    def var hc   as handle.
    def var hParam as handle.
    def var loop as int.

    create x-nodeRef hc.
    do loop = 1 to vh:num-children:
        vh:get-child(hc,loop).

        if hc:num-children > 0
        then run obtemnode (input hc:handle).

        if vh:name = "Resultado" or
           vh:name = "CdOperacao" or
           vh:name = "DsMensagem"
        then do:
            create tt-Retorno.
            assign
                tt-Retorno.parametro = vh:name
                tt-Retorno.resposta  = trim(string(hc:node-value)).
        end.

        if vh:name = "ParametroFluxo" and
           vh:num-children = 2 and
           hc:name = "NmParametro" and
           hc:num-children = 1
        then do.
            loop = vh:num-children.
            create x-nodeRef hParam.
            hc:get-child(hParam, 1).

            if hParam:node-value begins "RET_" or
               hParam:node-value = "VI_NEUROTECH_CD_OPERACAO" or
               hParam:node-value = "PROP_IDOPERACAO"
            then do.
                create tt-Retorno.
                tt-Retorno.parametro = hParam:node-value.

                vh:get-child(hc,2). /* VlParametro */
                if hc:num-children > 0
                then do.
                    hc:get-child(hParam, 1).
                    tt-Retorno.resposta = hParam:node-value.
                end.
            end.
        end.
    end.

end procedure.


def var vNeurotechHost    as char.
def var vNeurotechConnect as char.

/*Handles WS*/
def var hWebService        as handle no-undo.
def var hWorkflowWebServiceSoap as handle no-undo.
def var hDoc               as handle.
def var hRoot              as handle.


PROCEDURE executarFluxoComParametros:
    DEFINE INPUT  PARAMETER parameters1 AS LONGCHAR NO-UNDO.
    DEFINE OUTPUT PARAMETER parameters2 AS LONGCHAR NO-UNDO.
END PROCEDURE.

run le_tabini.p (0, 0, "Neurotech_Host", OUTPUT vNeurotechHost).

vNeurotechConnect = "-WSDL " + vNeurotechHost + "?wsdl"
                  + " -ServiceNamespace http://neurotech.com.br/"
                  + " -nohostverify"
                  + " -SOAPEndpoint " + vNeurotechHost.
     
run geralog("Conectando").
create server hWebService.
lConectou = hWebService:connect(vNeurotechConnect) no-error.
if not lConectou
then do:
    run geralog("ERRO: Nao foi possível conectar ao servidor").
    return.
end.
        
RUN WorkflowWebServiceSoap SET hWorkflowWebServiceSoap ON hWebService.

if not valid-handle(hWorkflowWebServiceSoap)
then do:
    run geralog("Nao foi possivel conectar a porta hWorkflowWebServiceSoap").
    return.
end.

do vct = 1 to num-entries(par_props, "&").
    vtag = entry(vct, par_props, "&").

    if num-entries(vtag, "=") = 2
    then do.
        vchave = entry(1, vtag ,"=").
        vvalor = entry(2, vtag ,"=").
        if vchave = "POLITICA"
        then vpolitica = vvalor.
        else if vchave = "PROP_CPFCLI"
        then vidproposta = vvalor.
    end.
end.

geraxml("TAG","",
'executarFluxoComParametros ' +
'xmlns:soap="http://www.w3.org/2003/05/soap-envelope" ' +
'xmlns:neur="http://neurotech.com.br/"', "").

geraxml("TAG","","Credenciais", "").
geraxml("TAG","TAG","CodigoAssociado", "148").
geraxml("TAG","TAG","CodigoFilial", "0").
geraxml("TAG","TAG","Senha", "abcd@1234").
geraxml("","TAG","Credenciais", "").

geraxml("TAG","","Fluxo", "").

geraxml("TAG","TAG","NmPolitica", vpolitica).
geraxml("TAG","TAG","TagVersaoPolitica", "").
geraxml("TAG","TAG","NmFluxoResultado", "FLX_PRINCIPAL").
geraxml("TAG","TAG","IdProposta", vidproposta).

geraxml("TAG","","LsParametros", "").

do vct = 1 to num-entries(par_props, "&").
    vtag = entry(vct, par_props, "&").

    if num-entries(vtag, "=") = 2
    then do.
        vchave = entry(1, vtag, "=").
        vvalor = entry(2, vtag, "=").
        if vchave <> "POLITICA"
        then do.
            geraxml("TAG","","ParametroFluxo", "").
            geraxml("TAG","TAG","NmParametro", vchave).
            geraxml("TAG","TAG","VlParametro", vvalor).
            geraxml("","TAG","ParametroFluxo", "").
        end.
    end.
end.

geraxml("","TAG","LsParametros", "").

geraxml("","TAG","Fluxo", "").

geraxml("TAG","","Parametros", "").
geraxml("TAG","","Propriedade", "").
geraxml("TAG","TAG","Nome", "USUARIO").
geraxml("TAG","TAG","Valor","USUARIO").
geraxml("","TAG","Propriedade", "").
geraxml("","TAG","Parametros", "").

geraxml("","TAG","executarFluxoComParametros", "").

output to value(par_arqlog + ".log") append.
put unformatted string(time, "hh:mm:ss") " Envio:" skip 
                string(vrequest).
output close.

RUN executarFluxoComParametros
            IN hWorkflowWebServiceSoap(INPUT vrequest, OUTPUT vResponse).

varqsaida = par_arqlog + "_Saida_" + string(mtime) + ".xml".
output to value(varqsaida).
export vResponse.
output close.

hWebService:disconnect().
delete object hWebService.

/* RETORNO */
create x-document hDoc.
Hdoc:load("LONGCHAR",vResponse,false).

create x-noderef hRoot.
hDoc:get-document-element(hRoot).

if error-status:error or
   error-status:num-messages > 0
then do:
    run gera_log("ERRO na leitura do XML de resposta").
    return.
end.

run obtemnode (input hRoot).

output to value(par_arqlog + ".log") append.
put unformatted skip(1) string(time, "hh:mm:ss") " Resposta: " varqsaida skip.
for each tt-retorno no-lock.
    export tt-retorno.
end.
output close.

