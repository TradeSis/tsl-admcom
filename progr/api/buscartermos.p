/* helio 20/05/2021 Boleto Caixa */
/*VERSAO 1*/
//def input param par-recid-contrato as recid.
def input param cartaoLebes-contnum as int.
def output param vstatus as char.
def output param vmensagem as char.

def var vlcentrada as longchar.
def var vlcsaida as longchar.

{/admcom/progr/api/termos.i} 

find contrato where contnum = cartaoLebes-contnum no-lock.
if not avail contrato
then do:
    return.
end.
else do:
    /*find neuclien  where neuclien.clicod  = contrato.clicod    no-lock.*/
    find    clien  where    clien.clicod  = contrato.clicod    no-lock.
end.


/* dados de entrada
create ttpedidoCartaoLebes.
    ttpedidoCartaoLebes.formatoTermo            = "TXT". 
    ttpedidoCartaoLebes.tipoOperacao            = .
    ttpedidoCartaoLebes.codigoLoja              = contrato.etbcod.
    ttpedidoCartaoLebes.dataTransacao           = string(year(today)) + "-" + string(month(today),"99") + "-" + string(day(today),"99")..
    ttpedidoCartaoLebes.codigoCliente           = contrato.clicod.
    ttpedidoCartaoLebes.idBiometria             = . 
    ttpedidoCartaoLebes.neuroIdOperacao         = . 
    ttpedidoCartaoLebes.codigoProdutoFinanceiro = . 
    ttpedidoCartaoLebes.valorEmprestimo         = . 
    ttpedidoCartaoLebes.codigoVendedor          = . 
    ttpedidoCartaoLebes.codigoOperador          = . 
    ttpedidoCartaoLebes.valorTotal              = trim(replace(string(contrato.vltotal,">>>>>>>>>>>>>>>>9.99"),",",".")).
*/
def var hEntrada as handle.
def var hSaida   as handle.

hEntrada = temp-table ttpedidoCartaoLebes:handle.

hEntrada:WRITE-JSON("longchar",vLCEntrada, false).

def var vsaida as char.
def var vresposta as char.

vsaida  = "/u/bsweb/works/buscarTermos" + string(contrato.contnum) + "_" +
            string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

output to value(vsaida + ".sh").
put unformatted
    "curl -s \"http://localhost/tslebes/api/crediario/buscaTermos" + "\" " +
    " -H \"Content-Type: application/json\" " +
    " -d '" + string(vLCEntrada) + "' " + 
    " -o "  + vsaida.
output close.

unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
unix silent value("echo \"\n\">>"+ vsaida).

input from value(vsaida) no-echo.
import unformatted vresposta.
input close.

vLCsaida = vresposta.

hSaida = temp-table ttreturn:handle.

hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").

/* tabela ttreturn 
 
for each ttreturn where ttreturn.pstatus = "".
    delete ttreturn.
end. */

    find first ttreturn no-error.    
    /*if avail ttreturn
    then do:
        /* */
    end.   */     



