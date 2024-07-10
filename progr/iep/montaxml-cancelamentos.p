def input  param poperacao   as char.
def input  param pacao       as char.
def input  param parquivo    as char.
def output param pcodocorrencia as char.
def output param pocorrencia as char.

def var hEntrada as handle.
def var hSaida   as handle.
def var vlcentrada as longchar.
def var vlcsaida as longchar.

def shared temp-table ttprot
    field precid as recid.

def temp-table ttdadosxml  no-undo serialize-name "dadosEntrada"
      field acao        as char serialize-name "operacao"
      field nome_arquivo    as char 
      field dadosXml        as char.

def temp-table ttresponsejson  no-undo serialize-name "jsonSoapResponse"
      field nome_arquivo    as char 
      field operacaoSol     as char
      field codocorrencia   as char
      field ocorrencia      as char.

hentrada = temp-table ttdadosxml:handle. 
hsaida   = temp-table ttresponsejson:handle. 


create ttdadosxml.
ttdadosxml.acao     = pacao. 
ttdadosxml.nome_arquivo = parquivo.


def var vlayout as char.
def var vlayout-transacao as char.

input from /admcom/progr/iep/cancelamentos-header.xml.
import unformatted vlayout.
input close.

def var vqtdregistros     as int.
def var vlinha as int.
def var vvalortot as dec.

for each ttprot.
    find titprotesto where recid(titprotesto) = ttprot.precid no-lock.
    vqtdregistros = vqtdregistros + 1.
    vvalortot = vvalortot + titprotesto.vlcobrado.
end.


vlayout = replace(vlayout,"@acao",lc(pacao)).

vlinha = 1.
vlayout = replace(vlayout,"@LINHA",string(vlinha)).

ttdadosxml.dadosxml = vlayout .

input from /admcom/progr/iep/cancelamentos-transacao.xml.
import unformatted vlayout-transacao.
input close.


for each ttprot.
    find titprotesto where recid(titprotesto) = ttprot.precid no-lock.
    
    vlayout = vlayout-transacao.
    
    find contrato of titprotesto no-lock.
    find clien of contrato no-lock.
    find neuclien where neuclien.clicod = clien.clicod no-lock no-error.

    vlayout = replace(vlayout,"@PROTOCOLO",titprotesto.protocolo).
    vlayout = replace(vlayout,"@DTPROTOCOLO",titprotesto.dtprotocolo).
    vlayout = replace(vlayout,"@TITNUM"     , string(titprotesto.contnum)).
    vlayout = replace(vlayout,"@NOSSONUMERO", titprotesto.nossonumero).
    
    
    vlayout = replace(vlayout,"@CLINOM",string(clien.clinom)).
    vlayout = replace(vlayout,"@VLDIVIDA",trim(string(titprotesto.vlcobrado,">>>>>>>>>>>>>>>>>>>9.99")) ).
    
    
    
    vlinha = vlinha + 1.
    vlayout = replace(vlayout,"@LINHA",string(vlinha)).
    ttdadosxml.dadosxml = ttdadosxml.dadosxml + vlayout + " " .    


end.

input from /admcom/progr/iep/cancelamentos-trailler.xml.
import unformatted vlayout.
input close.


vlayout = replace(vlayout,"@ACAO",lc(pacao)).


vlinha = vlinha + 1.
vlayout = replace(vlayout,"@LINHA",string(vlinha)).

ttdadosxml.dadosxml = ttdadosxml.dadosxml + vlayout.



hEntrada:WRITE-JSON("longchar",vLCEntrada, true, ?).
hEntrada:WRITE-JSON("file","saida2-1.xml", true, ?).


run api/wc-iepro.p (pacao,
                    input vlcentrada,
                    output vlcSaida).

hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").

find first ttresponsejson no-error.

pocorrencia = "SEM RETORNO".
pcodocorrencia = ?.
if avail ttresponsejson
then do:
    pocorrencia = ttresponsejson.ocorrencia.
    pcodocorrencia = ttresponsejson.codocorrencia no-error.
end.