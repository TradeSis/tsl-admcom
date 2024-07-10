/* Include configuracao XML */
{/u/wse-com/ws-nfe/wsnfe.i}

def input parameter par-filial   as integer.     
def input parameter par-nota     as integer.
def input parameter par-servico  as char.
def input parameter par-metodo   as char.
def input parameter par-xml      as char.
def input parameter c-char1    as char.
def input parameter c-char2    as char.
def input parameter c-char3    as char.
def input parameter c-char4    as char.
def output parameter par-ret      as char.

def var var-servico-aux     as char.
def var var-wsclient        as char.
def var var-metodo          as char.
def var var-metodo-resp     as char.

/*
unix silent chmod 777 value(par-xml).
*/

assign var-metodo      = par-metodo
       var-metodo-resp = par-metodo + "Result". 

def var vip as char.
def var p-valor as char.

run le_tabini.p (par-filial, 0, "NFE - AMBIENTE", OUTPUT p-valor).

if p-valor = "PRODUCAO"
THEN run le_tabini.p (par-filial, 0, "NFE - IP PRODUCAO", OUTPUT vip).
else run le_tabini.p (par-filial, 0, "NFE - IP HOMOLOGACAO", OUTPUT vip).
if vip = ""
then vip = "sv-mat-ws.lebes.com.br".

case (par-servico):
    when "NotaMax" then
       assign
        var-servico-aux = "http://" + vip + "/CustomWsServer/Service.asmx?WSDL"
        var-wsclient   = "http://eteste.lebes.com.br/ws-nfe/clientewsnfe.php".

end case.

/* CHAMA WEBSERVICES E RECEBE O ARQUIVO DE RETORNO */
hide message no-pause.
/*
message "Executando WebService... " var-metodo
        " Fil.: " string(par-filial,">>>9")
        " NFe: " string(par-nota,">>>>>>>>9").
*/

par-ret = 
  clientewebservices(par-filial,
                     par-nota,
                     var-wsclient,
                     var-servico-aux,
                     var-metodo,
                     "iXml", 
                     var-metodo-resp,
                     par-xml,
                     c-char1,
                     c-char2,
                     c-char3,
                     c-char4).
hide message no-pause.

return par-ret.
