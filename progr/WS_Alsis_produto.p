{admcab.i}

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
 
def var varqlog as char.
varqlog = "/admcom/relat/log-consulta-produto-" +
            string(time) + ".log".

def var varqretorno as char.
varqretorno = "/admcom/relat/retorno_ws_alcis_produto_"
                + string(time) + ".xml".

run client_socket.p(input "10.2.0.119",
                    input "8080",
                    input "/WS-WMS/ws-ConsultaCadastroProdutoWMS/",
                    input vxml,
                    input "text/xml",
                    input varqlog,
                    input varqretorno,
                    output p-conecta).
                    
if p-conecta
then run processa_retorno.

procedure processa_retorno:
    def var va-ret as char.
    def var vb-ret as char.
    def var vstatus as char.
    input from value(varqretorno).
    repeat:
        import unformatted va-ret.
        vb-ret = vb-ret + va-ret.
    end.
    input close.
    vb-ret = replace(vb-ret,"<","|").
    vb-ret = replace(vb-ret,">","=").
    vstatus = acha("status",vb-ret).
    if vstatus = "false"
    then do:
        message color red/with
        acha("erro",vb-ret) 
        " DO PEDIDO " p-pedido
        " DA FILIAL " p-etbcod
        view-as alert-box.
        p-retorno = no.
    end.     
    else p-retorno = yes.
end procedure.
