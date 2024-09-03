/* helio 24082024 - proj boletagem */
/* faz chama com api bsweb, para transformação dos json e bsweb faz chamada ao barramento */

def input parameter par-banco as int.
def input parameter par-clicod as int.
def input parameter par-numerodocumento as char.
def input parameter par-dtvencimento    as date.
def input parameter par-vlcobrado     as dec.

def output parameter par-recid-boleto as rec.
def output parameter mensagem_erro as char.

DEF VAR vbolcod AS INT64.

def var vhostname as char.
input through hostname.
import vhostname.
input close. 
def var vhml as log.

vhml = no.

if vhostname = "SV-CA-DB-DEV" or 
   vhostname = "SV-CA-DB-QA"
then do: 
    vhml = yes.
end.

find banco where banco.bancod = par-banco no-lock.

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


find    clien  where    clien.clicod  = par-clicod    no-lock.

vbolcod = next-value(boletagbol).

create ttboleto.

ttboleto.seu_numero       = string(vbolcod).
ttboleto.valor_nominal   = trim(replace(string(par-vlcobrado,">>>>>>>>>>>>>>>>9.99"),",",".")).
ttboleto.data_vencimento =   string(year(par-dtvencimento)) + "-" + 
                            string(month(par-dtvencimento),"99") + "-" + 
                            string(day(par-dtvencimento),"99").
ttboleto.nosso_numero    = ?.
ttboleto.id_titulo_empresa  = par-numerodocumento.

ttboleto.data_emissao =  string(year(today)) + "-" + 
                        string(month(today),"99") + "-" + 
                        string(day(today),"99").

create ttpagador.                                                
ttpagador.tipo_pessoa = string(clien.tippes,"F/J").
ttpagador.cpf_cnpj = clien.ciccgc.
ttpagador.nome    = clien.clinom.
ttpagador.cep = string(clien.cep[1]).
ttpagador.endereco = RemoveAcento(clien.endereco[1]) + ", " + string(clien.numero[1]).
ttpagador.cidade = RemoveAcento(clien.cidade[1]).
ttpagador.uf = RemoveAcento(clien.ufecod[1]).

def var hEntrada as handle.
def var hSaida   as handle.

hEntrada = dataset dadosEntrada:handle.

hEntrada:WRITE-JSON("longchar",vLCEntrada, false).

def var vsaida as char.
def var vresposta as char.
message "         api/boletoemitir Chamando bsweb/api/boleto/boletoemitir" .


if OPSYS = "UNIX" then do:
    vsaida  = "/ws/works/emitirboleto" + string(vbolcod) + "_" +
            string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

    output to value(vsaida + ".sh").
    put unformatted
        "curl -s ~"http://localhost/bsweb/api/boleto/boletoemitir" + "~" " +
        " -H ~"Content-Type: application/json~" " +
        " -d '" + string(vLCEntrada) + "' " + 
        " -o "  + vsaida.
    output close.
    message "         api/boletoemitir Chamando bsweb/api/boleto/boletoemitir " vsaida .

    unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
    unix silent value("echo ~"\n~">>"+ vsaida).

    input from value(vsaida) no-echo.
    import unformatted vresposta.
    input close.

    vLCsaida = vresposta.

    hSaida = temp-table ttreturn:handle.

    hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").
end.
ELSE DO:
    CREATE ttreturn.
    ttreturn.retorno = "REGISTRADO".
    ttreturn.nosso_numero = STRING(vbolcod).
    ttreturn.data_emissao = "2024-08-23".
    ttreturn.codigo_barras = "12121212".
    ttreturn.linha_digitavel = "343434 343434 3434".
END.
    find first ttreturn no-error.    
    if avail ttreturn
    then do:
        message "         api/boletoemitir Chamando bsweb/api/boleto/boletoemitir RETORNO=" ttreturn.retorno ttreturn.data_emissao.

            if ttreturn.retorno = "REGISTRADO" /*ttreturn.codigo_barras <> "" and ttreturn.codigo_barras <> ?*/
            then do:
                CREATE boletagbol.
                par-recid-boleto = RECID( boletagbol).
                boletagbol.bolcod         = vbolcod.
                boletagbol.bancod         = par-banco.
                boletagbol.Documento      = par-numerodocumento.
                boletagbol.DtVencimento   = par-dtvencimento .
                boletagbol.VlCobrado      = par-vlcobrado.
                boletagbol.CliFor         = par-clicod.
                boletagbol.dtemissao = date(int(entry(2,ttreturn.data_emissao,"-")),
                                            int(entry(3,ttreturn.data_emissao,"-")),
                                            int(entry(1,ttreturn.data_emissao,"-"))).
                boletagbol.hremissao = TIME.
                boletagbol.codigoBarras = ttreturn.codigo_barras.
                boletagbol.linhaDigitavel = ttreturn.linha_digitavel.
                boletagbol.nossonumero   = int64(ttreturn.nosso_numero) .
                
                unix silent value("rm -f " + vsaida). 
                unix silent value("rm -f " + vsaida + ".erro"). 
                unix silent value("rm -f " + vsaida + ".sh"). 
                
            end.

    End. 
    ELSE do:
            mensagem_erro = "SEM RETORNO".
    end.
    




