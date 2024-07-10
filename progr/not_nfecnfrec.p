/*
    Enviar a Manifestacao do Destinatario
*/
do:
    return.
end.

{notamaxxml.i}

def input parameter par-rec as recid.

def var vcnpj as char.

find plani where recid(plani) = par-rec no-lock.

vmetodo = "NFeRecebimentoSolicitarConfirmacaoOperacao".

find estab where estab.etbcod = plani.desti no-lock.
vcnpj = replace(estab.etbcgc,".","").
vcnpj = replace(vcnpj,"/","").
vcnpj = replace(vcnpj,"-","").

vxml = vxml + geraXmlNfe("Inicio", "envNotamax", "").
vxml = vxml + geraXmlNfe("Tag", "chNfe", plani.ufdes).
vxml = vxml + geraXmlNfe("Tag", "tipo_confirmacao", "210200").
vxml = vxml + geraXmlNfe("Tag", "dest_cnpj", vcnpj).
vxml = vxml + geraXmlNfe("Tag", "confirmar_operacao_sem_xml", "N").
vxml = vxml + geraXmlNfe("Tag", "motivo_do_confirmar_operacao_sem_xml",
                         "Motivo").
vxml = vxml + geraXmlNfe("Fim", "envNotamax", "").

run notamaxws.p (vmetodo, vxml, no).

