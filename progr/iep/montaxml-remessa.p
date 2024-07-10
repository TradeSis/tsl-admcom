def input  param poperacao   as char.
def input  param parquivo    as char.
def input  param psequencial as int.
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
ttdadosxml.acao     = "remessas". 
ttdadosxml.nome_arquivo = parquivo.

def var clayout as longchar.
def var vlayout as char.
def var vlayout-transacao as char.

input from /admcom/progr/iep/remessa-header.xml.
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

vlayout = replace(vlayout,"@NOMEDOARQUIVO",ttdadosxml.nome_arquivo).
vlayout = replace(vlayout,"@DATAMOVIMENTO",string(today,"99999999")).
vlayout = replace(vlayout,"@SEQUENCIAREMESSA",string(pSEQUENCIAL)).
vlayout = replace(vlayout,"@QTDREGISTROS",string(vqtdregistros + 2)).
vlayout = replace(vlayout,"@QTDTITULOS",string(vqtdregistros)).

vlinha = 1.
vlayout = replace(vlayout,"@LINHA",string(vlinha)).

/*clayout = vlayout. copy-lob from clayout to ttdadosxml.dadosxml.*/
ttdadosxml.dadosxml = vlayout .


input from /admcom/progr/iep/remessa-transacao.xml.
import unformatted vlayout-transacao.
input close.


for each ttprot.
    find titprotesto where recid(titprotesto) = ttprot.precid no-lock.
    
    vlayout = vlayout-transacao.
    
    find contrato of titprotesto no-lock.
    find clien of titprotesto no-lock.
    find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
                            
    vlayout = replace(vlayout,"@TITNUM"     , string(titprotesto.contnum)).
    vlayout = replace(vlayout,"@NOSSONUMERO", titprotesto.nossonumero).
    
    vlayout = replace(vlayout,"@TITDTEMI",string(contrato.dtinicial,"99999999")).
    vlayout = replace(vlayout,"@TITDTVEN",string(titprotesto.titdtven,"99999999")).
    vlayout = replace(vlayout,"@VLTOTAL",trim(string(contrato.vltotal,">>>>>>>>>>>>>>>>>>>9.99")) ).

    vlayout = replace(vlayout,"@VLDIVIDA",trim(string(titprotesto.vlcobrado,">>>>>>>>>>>>>>>>>>>9.99")) ).
    
    vlayout = replace(vlayout,"@CLINOM",string(clien.clinom)).
    vlayout = replace(vlayout,"@CPF",string(if avail neuclien then string(neuclien.cpf) else if clien.ciccgc = ? then "0" else clien.ciccgc)).
    vlayout = replace(vlayout,"@ENDERECO",string(clien.endereco[1]) + ", " +
                                                if clien.numero[1] <> ? then string(clien.numero[1]) else "").
    vlayout = replace(vlayout,"@CI",string(clien.CIINSC)).
    
    vlayout = replace(vlayout,"@CEP",string(clien.cep[1])).
    vlayout = replace(vlayout,"@CIDADE",string(clien.cidade[1])).
    vlayout = replace(vlayout,"@BAIRRO",string(clien.bairro[1])).
    
    vlayout = replace(vlayout,"@UF",string(clien.ufecod[1])).
    
    
    
    vlinha = vlinha + 1.
    vlayout = replace(vlayout,"@LINHA",string(vlinha)).

    /*clayout = clayout + vlayout. copy-lob clayout to ttdadosxml.dadosxml.*/
    ttdadosxml.dadosxml = ttdadosxml.dadosxml + vlayout + " " .    

end.

input from /admcom/progr/iep/remessa-trailler.xml.
import unformatted vlayout.
input close.


vlayout = replace(vlayout,"@NOMEDOARQUIVO",ttdadosxml.nome_arquivo).
vlayout = replace(vlayout,"@DATAMOVIMENTO",string(today,"99999999")).
vlayout = replace(vlayout,"@SEQUENCIAREMESSA",string(PSEQUENCIAL)).

    vlayout = replace(vlayout,"@QTDREGISTROS",string(vqtdregistros * 3)).

    vlayout = replace(vlayout,"@VALORTOT",trim(string(vvalortot,">>>>>>>>>>>>>>>>>>>9.99"))).

vlinha = vlinha + 1.
vlayout = replace(vlayout,"@LINHA",string(vlinha)).

/*clayout = clayout + vlayout. copy-lob clayout to ttdadosxml.dadosxml .*/
ttdadosxml.dadosxml = ttdadosxml.dadosxml + vlayout.


hEntrada:WRITE-JSON("longchar",vLCEntrada, true, ?).
hEntrada:WRITE-JSON("file","saida2-1.xml", true, ?).


run api/wc-iepro.p ("remessas",
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