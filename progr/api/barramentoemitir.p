/* helio 20/05/2021 Boleto Caixa */
/*VERSAO 1*/
def input param par-recid-banboleto as recid.
def output param vstatus as char.
def output param vmensagem as char.

vstatus = "N".

def var vlcentrada as longchar.
def var vlcsaida as longchar.

{/admcom/progr/api/acentos.i} /* helio 14/09/2021 */

def temp-table ttboleto  no-undo serialize-name "boleto"
    field valorCobrado      as char
    field dataVencimento    as char /*" => "2021-05-15", */
    field nossoNumero       as char /*"    => "123", */
    field dataEmissao       as char /*"    => "2021-05-11", */
    field cpfCnpjPagador    as char /*"  => "00315554037", */
    field codigoInternoPagador    as char /*"  => "00315554037", */
    field nomePagador       as char /*"     => "ROBERTO MORAES", */
    field cepPagador        as char
    field ufPagador        as char
    field cidadePagador     as char
    field logradouroPagador as char
    field bairroPagador     as char
    field numeroPagador     as char.

def temp-table ttreturn no-undo serialize-name "return"
    field pstatus as char serialize-name "status"
    field linhaDigitavel    as char
    field codigoBarras      as char
    field DVNossoNumero as char.

find banboleto where recid(banboleto) = par-recid-banboleto no-lock.
/*find neuclien  where neuclien.clicod  = banboleto.clifor    no-lock.*/
find    clien  where    clien.clicod  = banboleto.clifor    no-lock.

create ttboleto.
ttboleto.valorCobrado   = trim(replace(string(banBoleto.VlCobrado,">>>>>>>>>>>>>>>>9.99"),",",".")).
ttboleto.dataVencimento =   string(year(banBoleto.DtVencimento)) + "-" + 
                            string(month(banBoleto.DtVencimento),"99") + "-" + 
                            string(day(banBoleto.DtVencimento),"99").
if banboleto.bancod = 104
then  ttboleto.nossoNumero    = banboleto.impnossonumero.
else  ttboleto.nossoNumero    = string(banboleto.nossonumero).


ttboleto.dataEmissao =  string(year(banBoleto.DtEmissao)) + "-" + 
                        string(month(banBoleto.DtEmissao),"99") + "-" + 
                        string(day(banBoleto.DtEmissao),"99").
                        
ttboleto.cpfCnpjPagador = clien.ciccgc.
ttboleto.codigoInternoPagador = string(banboleto.clifor).

ttboleto.nomePagador    = clien.clinom.

                ttboleto.cepPagador = string(clien.cep[1]).
                ttboleto.ufPagador = RemoveAcento(clien.ufecod[1]).
                ttboleto.cidadePagador = RemoveAcento(clien.cidade[1]).
                ttboleto.logradouroPagador = RemoveAcento(clien.endereco[1]).
                ttboleto.bairroPagador = RemoveAcento(clien.bairro[1]).
                ttboleto.numeroPagador = string(clien.numero[1]).


def var hEntrada as handle.
def var hSaida   as handle.

hEntrada = temp-table ttboleto:handle.

hEntrada:WRITE-JSON("longchar",vLCEntrada, false).

def var vsaida as char.
def var vresposta as char.

vsaida  = "/u/bsweb/works/boletoemitir" + string(banboleto.nossonumero) + "_" +
            string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

output to value(vsaida + ".sh").
put unformatted
    "curl -s \"http://localhost/bsweb/api/boleto/barramentoEmitir" + "\" " +
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

for each ttreturn where ttreturn.pstatus = "".
    delete ttreturn.
end.

    find first ttreturn no-error.    
    if avail ttreturn
    then do:
        if ttreturn.pstatus = "REGISTRADO"
        then do on error undo:

            find current banboleto exclusive.
            banBoleto.codigoBarras      = ttreturn.codigoBarras.

            /* formatar a linha digitavel recebida */
            ttreturn.LinhaDigitavel     = replace(ttreturn.LinhaDigitavel,".","").
            ttreturn.LinhaDigitavel     = replace(ttreturn.LinhaDigitavel," ","").
            banBoleto.LinhaDigitavel    = substring(ttreturn.LinhaDigitavel,1,5)  + "."  + substring(ttreturn.LinhaDigitavel,6,5) + " " +  
                                          substring(ttreturn.LinhaDigitavel,11,5) + "." + substring(ttreturn.LinhaDigitavel,16,6) + " " +                                                                          substring(ttreturn.LinhaDigitavel,22,5) + "." + substring(ttreturn.LinhaDigitavel,27,6) + " " + 
                                          substring(ttreturn.LinhaDigitavel,33,1) + " " + substring(ttreturn.LinhaDigitavel,34). 
            /* formatar a linha digitavel recebida */
            
            /*
            banBoleto.DVNossoNumero     = 
            */
            vstatus = "S".
            
            vmensagem = "".
            
            unix silent value("rm -f " + vsaida). 
            
            unix silent value("rm -f " + vsaida + ".erro"). 
            unix silent value("rm -f " + vsaida + ".sh"). 
                
              
        end.    
        else do:
            vmensagem = ttreturn.pstatus.
        end.
    end.        



