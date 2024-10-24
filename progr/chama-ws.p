/* Include configuracao XML */
{/u/wse-com/ws-nfe/soap/bsws.i}

def input parameter par-filial   as integer.     
def input parameter par-nota     as integer.
def input parameter par-servico  as char.
def input parameter par-metodo   as char.
def input parameter par-xml      as char.

def output parameter par-ret      as char.

def var var-servico-aux     as char.
def var var-wsclient        as char.
def var var-metodo          as char.
def var var-metodo-resp     as char.

def var vip     as char.
def var p-valor as char.

/*
unix silent chmod 777 value(par-xml).
*/

run le_tabini.p (par-filial, 0, "NFE - AMBIENTE", OUTPUT p-valor).
if p-valor = "PRODUCAO"
THEN run le_tabini.p (par-filial, 0, "NFE - IP PRODUCAO", OUTPUT vip).
else run le_tabini.p (par-filial, 0, "NFE - IP HOMOLOGACAO", OUTPUT vip).

assign var-metodo      = par-metodo
       var-metodo-resp = par-metodo + "Result". 

if vip = ""
then vip = "sv-mat-ws.lebes.com.br".

case (par-servico):
    
    when "NotaMax" then
       assign
        var-servico-aux = "http://" + vip + "/CustomWsServer/Service.asmx?WSDL"
        var-wsclient   = "http://eteste.lebes.com.br/ws-nfe/clientews.php".

end case.
/*
if par-filial = 995
then var-wsclient   = "http://eteste.lebes.com.br/ws-nfe/clientews1.php".
*/

if p-valor = "HOMOLOGACAO"
then assign
        var-wsclient = "http://sv-ca-linx-h/ws-nfe/clientewsnfe.php".

/* CHAMA WEBSERVICES E RECEBE O ARQUIVO DE RETORNO */

message "Executando WebService... " var-metodo
        " Fil.: " string(par-filial,">>>9")
        " NFe: " string(par-nota,">>>>>>>>9").
                
pause 0.

par-ret = 
  clientewebservices(par-filial,
                     par-nota,
                     var-wsclient,
                     var-servico-aux,
                     var-metodo,
                     "iXml", 
                     var-metodo-resp,
                     par-xml).

return par-ret.
