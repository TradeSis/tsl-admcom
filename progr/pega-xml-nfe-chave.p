{admcab.i}

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

vmetodo = "/notamax/services/wsNotamax.asmx/NFeRecebimentoConsultarXMLDistribuicao".
vxml = vxml + geraXmlNfe("Inicio", "envNotamax", "").
vxml = vxml + geraXmlNfe("Tag", "chNfe", par-chave-nfe).
vxml = vxml + geraXmlNfe("Tag", "download", "S").
vxml = vxml + geraXmlNfe("Tag", "download_cnpj_dest", vdesti-cnpj).
vxml = vxml + geraXmlNfe("Fim", "envNotamax", "").

/******************
def input parameter p-etbcod as int.
def input parameter p-pedido as int.
def input parameter p-produtos as char.
def output parameter p-conecta as log init yes.
def output parameter p-retorno as log init yes.

def var vi as int.
def var vxml as char.
vxml = "<consulta><etbcod>900</etbcod>".
do vi = 1 to num-entries(p-produtos,";"):
    vxml = vxml + "<produto><codigo>" +
           entry(vi,p-produtos,";") + "</codigo></produto>".
end.
vxml = vxml + "</consulta>".
*****************/
 
def var vb as memptr.
set-size(vb) = 20001.
 
def var varqlog as char.
varqlog = "/admcom/relat/log-consulta-produto-" +
            string(time) + ".log".

def var varqretorno as char.
varqretorno = "/admcom/relat/retorno_ws_alcis_produto_"
                + string(time) + ".xml".

def var p-conecta as log.
def var vretorno as char.

run client_socket_1.p(input "10.2.0.121",
                    input "80",
                    input vmetodo,
                    input vxml,
 /*Content-Type*/   input "application/x-www-form-urlencoded",
                    input varqlog,
                    input varqretorno,
                    output p-conecta,
                    output vretorno).
                    
if p-conecta
then do:
    run processa_retorno.
    message varqretorno. pause.
    
end.


procedure processa_retorno.

    def var Hdoc  as handle.
    def var Hroot as handle.

    if index(vretorno, "<") = 0
    then return.

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
        /*if vh:name matches "*nItem*"
        then do:
        message hc:handle p-root vh:name trim(hc:node-value). pause.
        end.*/
        if trim(hc:node-value) <> ""
        then do.
            create tt-xmlretorno.
            tt-xmlretorno.root  = p-root.
            tt-xmlretorno.tag   = vh:name. /* nomes das tags */
            tt-xmlretorno.valor = trim(hc:node-value).
        end.    
    end.                       

end procedure.
