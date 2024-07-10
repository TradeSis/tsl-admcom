{notamaxxml.i}

def input  parameter par-etbcod    as int.
def input  parameter par-chave-nfe as char.
def output parameter par-ok        as log init yes.

def var vdesti-cnpj as char.

find estab where estab.etbcod = par-etbcod no-lock.
assign vdesti-cnpj = estab.etbcgc.
assign vdesti-cnpj = replace(vdesti-cnpj,".","").
       vdesti-cnpj = replace(vdesti-cnpj,"/","").
       vdesti-cnpj = replace(vdesti-cnpj,"-","").

vmetodo = "NFeRecebimentoConsultarXMLDistribuicao".
vxml = vxml + geraXmlNfe("Inicio", "envNotamax", "").
vxml = vxml + geraXmlNfe("Tag", "chNfe", par-chave-nfe).
vxml = vxml + geraXmlNfe("Tag", "download", "S").
vxml = vxml + geraXmlNfe("Tag", "download_cnpj_dest", vdesti-cnpj).
vxml = vxml + geraXmlNfe("Fim", "envNotamax", "").

run notamaxws1.p (vmetodo, vxml, yes).

find first tt-xmlretorno where tt-xmlretorno.root = "resultado"
                           and tt-xmlretorno.tag  = "mensagem_erro"
                             no-error.
if avail tt-xmlretorno
then do.
    disp tt-xmlretorno.valor format "x(50)"
         with no-label centered title " Retorno Notamax ".
/***    par-ok = no.***/
    return.
end.

find first tt-xmlretorno where tt-xmlretorno.root = "dados"
                           and tt-xmlretorno.tag  = "situacao"
                         no-error.
if not avail tt-xmlretorno or
   (avail tt-xmlretorno and tt-xmlretorno.valor <> "D")
then do.
    message "NFE nao esta na base do Notamax" .
    pause 3 no-message.
/***    par-ok = no.***/
end.

