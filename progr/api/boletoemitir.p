/* helio 24082024 - proj boletagem */
/* faz chama com api bsweb, para transformação dos json e bsweb faz chamada ao barramento */

def input param par-recid-boletagbol as recid.
def output param vstatus as char.
def output param vmensagem as char.

vstatus = "N".

def var vlcentrada as longchar.
def var vlcsaida as longchar.

{/admcom/progr/api/acentos.i} /* helio 14/09/2021 */

def temp-table ttboleto no-undo serialize-name "titulo"
    field nosso_numero  as char initial ?
    field seu_numero    as char
    field data_vencimento   as char /*"2024-09-09",*/
    field valor_nominal     as char /*": "100.00",*/
    field data_emissao      as char /*": "2024-08-09", */
    field id_titulo_empresa as char /*": "0300001013-1"*/
    index x IS unique primary seu_numero asc.

def temp-table ttpagador no-undo serialize-name "pagador"
    field tipo_pessoa   as char
    field cpf_cnpj      as char
    field nome          as char
    field endereco      as char
    field cep           as char
    field cidade        as char
    field uf            as char
    index x is unique primary cpf_cnpj asc.
def temp-table ttmensagems no-undo serialize-name "pagmensagensador"    
    field linha as int
    field texto as char.

def dataset  dadosEntrada for    ttboleto, ttpagador, ttmensagems.

def temp-table ttreturn no-undo serialize-name "boleto"
    field retorno       as char
    field nosso_numero  as char
    field seu_numero    as char
    field data_emissao  as char
    field codigo_barras as char
    field linha_digitavel   as char.
 
find boletagbol where recid(boletagbol) = par-recid-boletagbol no-lock.
find    clien  where    clien.clicod  = boletagbol.clifor    no-lock.

create ttboleto.

ttboleto.seu_numero       = string(boletagbol.bolcod).
ttboleto.valor_nominal   = trim(replace(string(boletagbol.VlCobrado,">>>>>>>>>>>>>>>>9.99"),",",".")).
ttboleto.data_vencimento =   string(year(boletagbol.DtVencimento)) + "-" + 
                            string(month(boletagbol.DtVencimento),"99") + "-" + 
                            string(day(boletagbol.DtVencimento),"99").
ttboleto.nosso_numero    = ?.


ttboleto.data_emissao =  string(year(today)) + "-" + 
                        string(month(today),"99") + "-" + 
                        string(day(today),"99").

create ttpagador.                                                
ttpagador.tipo_pessoa = string(clien.tippes,"F/J").
ttpagador.cpf_cnpj = clien.ciccgc.
ttpagador.nome    = clien.clinom.
ttpagador.cep = string(clien.cep[1]).
ttpagador.nome = RemoveAcento(clien.endereco[1]) + ", " + string(clien.numero[1]).
ttpagador.cidade = RemoveAcento(clien.cidade[1]).
ttpagador.uf = RemoveAcento(clien.ufecod[1]).

def var hEntrada as handle.
def var hSaida   as handle.

hEntrada = dataset dadosEntrada:handle.

hEntrada:WRITE-JSON("longchar",vLCEntrada, false).

def var vsaida as char.
def var vresposta as char.

vsaida  = "/ws/works/emitirboleto" + string(boletagbol.bolcod) + "_" +
            string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

output to value(vsaida + ".sh").
put unformatted
    "curl -s ~"http://localhost/bsweb/api/boleto/emitirboleto" + "~" " +
    " -H ~"Content-Type: application/json~" " +
    " -d '" + string(vLCEntrada) + "' " + 
    " -o "  + vsaida.
output close.

unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
unix silent value("echo ~"\n~">>"+ vsaida).

input from value(vsaida) no-echo.
import unformatted vresposta.
input close.

vLCsaida = vresposta.

hSaida = temp-table ttreturn:handle.

hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").

    find first ttreturn no-error.    
    if avail ttreturn
    then do:
            if ttreturn.codigo_barras <> "" and ttreturn.codigo_barras <> ?
            then do:
                find current boletagbol exclusive.
                boletagbol.dtemissao = date(int(entry(2,ttreturn.data_emissao,"-")),
                                            int(entry(3,ttreturn.data_emissao,"-")),
                                            int(entry(1,ttreturn.data_emissao,"-"))).
                boletagbol.codigoBarras = ttreturn.codigo_barras.
                boletagbol.linhaDigitavel = ttreturn.linha_digitavel.
                boletagbol.nossonumero   = int64(ttreturn.nosso_numero).
            
                unix silent value("rm -f " + vsaida). 
                unix silent value("rm -f " + vsaida + ".erro"). 
                unix silent value("rm -f " + vsaida + ".sh"). 
            end.

    End. 
    ELSE do:
            vmensagem = "SEM RETORNO".
    end.
    



