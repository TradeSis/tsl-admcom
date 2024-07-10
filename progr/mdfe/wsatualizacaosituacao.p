{wsnotamax.i new}  

def output parameter vstatus as char.
def output parameter vmensagem_erro as char.
def input parameter rec-mdfe as recid.


find mdfe where recid(mdfe) = rec-mdfe no-lock.

hide message no-pause. 
message "Atualizando Situacao " mdfe.mdfechave.

def var mdfe_versao as char.
def var mdfe_modelo as char.
def var vemite_cnpj as char.
def var mdfe_dhemi as char.
def var mdfe_dhviag as char.



find mdfviagem of mdfe no-lock.
find frete of mdfviagem no-lock.
find forne of frete no-lock.
find tpfrete of frete no-lock.
find veiculo of mdfviagem no-lock.
find estab of mdfviagem no-lock.


vmetodo = "MDFeEmissaoSolicitarAtualizacaoSituacao".
vLOG    = "MDFe_" + string(mdfe.mdfenumero, "999999999").



vxml = vxml + geraXmlNfe("Inicio", "envNotamax", "").

    vxml = vxml + geraXmlNfe("Tag", "chMDFe", mdfe.mdfechave). 

vxml = vxml + geraXmlNfe("GrupoFIM", "parametros", "").


vxml = vxml + geraXmlNfe("GrupoFIM", "envNotamax", "").

run wsnotamax.p (  input "", /* Site em branco para padrao */   
                   input vmetodo, 
                   input vxml,
                   input vlog). /* GRAVA LOG */

find first tt-xmlretorno where
    tt-xmlretorno.tag = "status"
    no-error.
vstatus = if avail tt-xmlretorno
          then tt-xmlretorno.valor
          else "". 

find first tt-xmlretorno where
    tt-xmlretorno.tag = "mensagem_erro"
    no-error.
vmensagem_erro = if avail tt-xmlretorno
               then tt-xmlretorno.valor
               else "". 
if vmensagem_erro <> ""
then do:
    hide message no-pause.
    message 
    "Retorno Status:" vstatus " Mensagem: " vmensagem_erro
        view-as alert-box.
end.    

hide message no-pause.
