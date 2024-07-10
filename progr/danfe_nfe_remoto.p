{admcab.i}
{wsnotamax.i new}

def input parameter p-recid as recid.

def var vstatus as char.
def var vmensagem_erro as char.
def var vpasta-danfe as char.
def var varq-danfe as char.

find A01_infnfe where recid(A01_infnfe) = p-recid NO-LOCK.

vmetodo      = "NFeEmissaoConsultarDANFE" /* "ConsultarPdfNfe"*/.

if sremoto
then vpasta-danfe = "/admcom/relat-loja/filial" +
                    string(A01_infnfe.etbcod, "999") + "/nfe".
else vpasta-danfe = "/admcom/relat".

varq-danfe = vpasta-danfe + "/NFe" + string(A01_infnfe.etbcod, "999") +
             A01_infnfe.serie + string(A01_infnfe.numero,"999999999") + ".pdf".

vxml = vxml + geraXmlNfe("Inicio", "envNotamax", "").
vxml = vxml + geraXmlNfe("Tag", "chNfe", A01_infnfe.id). 
vxml = vxml + geraXmlNfe("GrupoFIM", "parametros", "").
vxml = vxml + geraXmlNfe("GrupoFIM", "envNotamax", "").

hide message no-pause.
message "Consultando Notamax ...".
/***
run ws-notamax.p (input vmetodo, input vxml, input varq-danfe).
***/
run wsnotamax_danfe.p (input vmetodo, input vxml, input varq-danfe).

hide message no-pause.

find first tt-xmlretorno where tt-xmlretorno.tag = "status" no-error.
vstatus = if avail tt-xmlretorno then tt-xmlretorno.valor else "". 

find first tt-xmlretorno where tt-xmlretorno.tag = "mensagem_erro" no-error.
vmensagem_erro = if avail tt-xmlretorno then tt-xmlretorno.valor else "". 
if vmensagem_erro <> ""
then message "Retorno DANFE:" vstatus "Mensagem:" vmensagem_erro
            view-as alert-box.

