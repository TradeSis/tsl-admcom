/* Include configuracao XML */
{/u/wse-com/ws-ecm/bsws.i}

def input parameter par-servico  as char.
def input parameter par-metodo   as char.
def input parameter par-xml      as char.

def output parameter par-ret      as char.

def var var-servico-aux     as char.
def var var-wsclient        as char.
def var var-metodo          as char.
def var var-metodo-resp     as char.

def var vip as char.
vip = "".
def var p-valor as char.
p-valor = "".

/*
unix silent chmod 777 value(par-xml).
*/

assign var-metodo      = par-metodo
       var-metodo-resp = par-metodo + "Result". 

if vip = ""
then vip = "sv-mat-ws.lebes.com.br".

case (par-servico):
    
    when "NotaMax" then
       assign
        var-servico-aux = "http://" + vip + "/CustomWsServer/Service.asmx?WSDL"
        var-wsclient   = "http://eteste.lebes.com.br/ws-nfe/clientews.php".

    when "E-Commerce" then
       assign
        var-servico-aux = "http://" + vip + "/WsEcommerce/Service.asmx?WSDL"
        var-wsclient   = "http://eteste.lebes.com.br/ws-ecm/clientews.php".

end case.

/*
if par-filial = 995
then var-wsclient   = "http://eteste.lebes.com.br/ws-nfe/clientews1.php".
*/

/* CHAMA WEBSERVICES E RECEBE O ARQUIVO DE RETORNO */

par-ret = 
  clientewebservices(
                     var-wsclient,
                     var-servico-aux,
                     var-metodo,
                     var-metodo-resp,
                     par-xml).
                         

return par-ret.

