/* helio 17022022 - 263458 - Revisão da regra de novações  */

def var vconteudo as char.
def var vlinha as char.
def var vid as int.
def var vparcelas-lista as char.
def var vparcelas-valor as char.
def var viofPerc as dec.
def var vvalorIOF as dec.
def var vprincipal as dec.
def var vprincipalPerc as dec.
def var vprodutos-Lista as char.
def var vcatcod as int init 0.

DEFINE VARIABLE textFile AS LONGCHAR NO-UNDO.
def var vdataNascimento as date.
def var vdataVencimento as date.
def var vdataTransacao as date.
def var vdataTransacaoExtenso as char.
def var vdia as int.
def var vmes as int.
def var vano as int.

def var vmesext         as char format "x(10)"  extent 12
                        initial ["Janeiro" ,"Fevereiro","Marco"   ,"Abril",
                                 "Maio"    ,"Junho"    ,"Julho"   ,"Agosto",
                                 "Setembro","Outubro"  ,"Novembro","Dezembro"] .


def var vvalorSeguroPrestamista as dec init 0.
def var vcopias as int.

def var vdatainivigencia12 as date.
def var vdatafimvigencia13 as date.
def var vvalorSeguroPrestamistaLiquido as dec.
def var vvalorSeguroPrestamistaIof as dec.
def var vvalorSeguroPrestamista29 as dec.
def var vvalorSeguroPrestamista30 as dec.

def  temp-table tttermos no-undo serialize-name "termos"
  field id as char
  field data    as char
  field codigo  as char
  field conteudo as char
  field extensao    as char
  field nome        as char
  field tipo as char.


def var hEntrada     as handle.
def var hSAIDA            as handle.

DEFINE {1} shared TEMP-TABLE ttpedidoCartaoLebes NO-UNDO SERIALIZE-NAME "pedidoCartaoLebes"
    field id as char serialize-hidden
    FIELD   codigoLoja          as char 
    FIELD   dataTransacao as char 
    FIELD   numeroComponente as char 
    field nsuTransacao  as char
    FIELD   codigoVendedor as char 
    FIELD   codigoOperador as char 
    FIELD   valorTotal as char 
    FIELD   codigoCliente as char 
    FIELD   cpfCnpjCliente as char 
    field numeroNotaFiscal as char
    field cnpjLoja as char.

DEFINE {1} shared TEMP-TABLE ttcliente NO-UNDO SERIALIZE-NAME "cliente"
    field idpai as char serialize-hidden
    FIELD tipoPessoa as char
    field rg    as char
    field cpf   as char
    field nome  as char
    field dataNascimento as char
    field codigoCliente as char
    field cep   as char
    field logradouro as char
    field numero as char
    field complemento as char
    field bairro as char
    field cidade as char
    field uf as char
    field pais as char
    field email as char
    field telefone as char.

DEFINE {1} shared TEMP-TABLE ttcartaoLebes NO-UNDO SERIALIZE-NAME "cartaoLebes"
    field idpai as char serialize-hidden
    FIELD   qtdParcelas as char
    FIELD   valorEntrada as char 
    FIELD   valorAcrescimo as char 
    FIELD   dataPrimeiroVencimento as char
    FIELD   dataUltimoVencimento as char 
    FIELD   vendaTerceiros as char  
    field codigoSeguroPrestamista as char
    field valorSeguroPrestamista as char
    field valorSeguroPrestamistaEntrada as char
    field numeroContrato as char
    field cet as char
    field cetAno as char
    field taxaMes as char
    field valorIOF as char
    field numeroBilheteSeguroPrestamista as char
    field numeroSorteSeguroPrestamista as char
    field contratoFinanceira as char.
            
            

DEFINE {1} shared TEMP-TABLE ttparcelas NO-UNDO SERIALIZE-NAME "parcelas"
    field idpai as char serialize-hidden
    field seqParcela as char 
    field valorParcela as char
    field dataVencimento as char.

DEFINE {1} shared TEMP-TABLE ttprodutos NO-UNDO SERIALIZE-NAME "produtos"
    field idpai as char serialize-hidden
    field codigoProduto as char
    field codigoMercadologico as char
    field quantidade as char
    field valorTotal as char 
    field valorUnitario as char 
    field valorTotalDesconto as char.
    

DEFINE DATASET dadosEntrada FOR ttpedidoCartaoLebes, ttcliente, ttcartaoLebes, ttparcelas, ttprodutos
    DATA-RELATION for1 FOR ttpedidoCartaoLebes, ttcartaoLebes      RELATION-FIELDS(ttpedidoCartaoLebes.id,ttcartaoLebes.idpai) NESTED
    DATA-RELATION for11 FOR ttpedidoCartaoLebes, ttcliente      RELATION-FIELDS(ttpedidoCartaoLebes.id,ttcliente.idpai) NESTED
    
    DATA-RELATION for2 FOR ttpedidoCartaoLebes, ttparcelas         RELATION-FIELDS(ttpedidoCartaoLebes.id,ttparcelas.idpai) NESTED
    DATA-RELATION for3 FOR ttpedidoCartaoLebes, ttprodutos         RELATION-FIELDS(ttpedidoCartaoLebes.id,ttprodutos.idpai) NESTED.


DEFINE {1} shared TEMP-TABLE ttcobparam NO-UNDO SERIALIZE-NAME "parametros"
    field id as char serialize-hidden
    field carteira as char.
/*
DEFINE {1} shared TEMP-TABLE ttsaidaparcelas NO-UNDO SERIALIZE-NAME "parcelas"
    field idPai as char serialize-hidden
    field seqParcela as char 
    field valorParcela as char
    field dataVencimento as char
    field valorSeguroRateado as char.
*/

DEFINE DATASET dadosSaida FOR ttcobparam. /*, ttsaidaparcelas
    DATA-RELATION for1 FOR ttcobparam, ttsaidaparcelas         RELATION-FIELDS(ttcobparam.id,ttsaidaparcelas.idpai) NESTED.
*/
hentrada = DATASET dadosEntrada:HANDLE.
hsaida   = DATASET dadosSaida:HANDLE.





procedure trocamnemos.

if avail ttpedidoCartaoLebes
then do:
    if ttpedidoCartaoLebes.codigoLoja <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{codigoLoja\}",ttpedidoCartaoLebes.codigoLoja).
    if vdataTransacao <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{dataTransacao\}",string(vdataTransacao,"99/99/9999")).
    if vdataTransacaoExtenso <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{dataTransacao.extenso\}",vdataTransacaoExtenso).

    if ttpedidoCartaoLebes.numeroComponente <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{numeroComponente\}",ttpedidoCartaoLebes.numeroComponente).
    if ttpedidoCartaoLebes.codigoVendedor <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{codigoVendedor\}",ttpedidoCartaoLebes.codigoVendedor).
    if ttpedidoCartaoLebes.valorTotal <> ?
    then  tttermos.conteudo = replace(tttermos.conteudo,"\{valorTotal\}",ttpedidoCartaoLebes.valorTotal).
    if ttpedidoCartaoLebes.codigoCliente <>?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{codigoCliente\}",ttpedidoCartaoLebes.codigoCliente).
    if ttpedidoCartaoLebes.numeroNotaFiscal <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{numeroNotaFiscal\}",ttpedidoCartaoLebes.numeroNotaFiscal).
end.

if avail ttcliente
then do:
    if ttcliente.cpf <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{cpfCnpjCliente\}",ttcliente.cpf).

    if ttcliente.rg <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{rg\}",ttcliente.rg).
    if ttcliente.nome <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{nomeCliente\}",ttcliente.nome).
    if ttcliente.dataNascimento <> ?
    then do:
        vdia = int(substring(entry(3,ttcliente.dataNascimento,"-"),1,2)).        
        vmes = int(entry(2,ttcliente.dataNascimento,"-")).
        vano = int(entry(1,ttcliente.dataNascimento,"-")).
        vdataNascimento        = date(vmes,vdia,vano).
        tttermos.conteudo = replace(tttermos.conteudo,"\{dataNascimento\}",string(vdataNascimento,"99/99/9999")).
    end.
    if ttcliente.cep <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{endereco.cep\}",ttcliente.cep).
    if ttcliente.logradouro <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{endereco.logradouro\}",ttcliente.logradouro).
    if ttcliente.numero <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{endereco.numero\}",ttcliente.numero).
    if ttcliente.complemento <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{endereco.complemento\}",ttcliente.complemento).
    if ttcliente.bairro <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{endereco.bairro\}",ttcliente.bairro).
    if ttcliente.cidade <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{endereco.cidade\}",ttcliente.cidade).
    if ttcliente.uf <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{endereco.estado\}",ttcliente.uf).
    if ttcliente.pais <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{endereco.pais\}",ttcliente.pais).
    if ttcliente.email <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{email\}",ttcliente.email).
    if ttcliente.telefone = ?
    then ttcliente.telefone= "".
    tttermos.conteudo = replace(tttermos.conteudo,"\{telefone\}",ttcliente.telefone).

end.

if avail ttcartaolebes
then do:

    if vparcelas-lista <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{parcelas.lista\}",vparcelas-lista).
    if vparcelas-valor <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{parcelas.valor\}",vparcelas-valor).
    if ttcartaoLebes.qtdParcelas <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{qtdParcelas\}",ttcartaoLebes.qtdParcelas).
    if ttcartaoLebes.valorEntrada <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{valorEntrada\}",ttcartaoLebes.valorEntrada).
    if ttcartaoLebes.valorAcrescimo <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{valorAcrescimo\}",ttcartaoLebes.valorAcrescimo).
    if ttcartaoLebes.dataPrimeiroVencimento <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{dataPrimeiroVencimento\}",ttcartaoLebes.dataPrimeiroVencimento).
    if ttcartaoLebes.dataUltimoVencimento <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{dataUltimoVencimento\}",ttcartaoLebes.dataUltimoVencimento).
    if ttcartaoLebes.numeroContrato <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{numeroContrato\}",ttcartaoLebes.numeroContrato).
    if ttcartaoLebes.cet <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{cet\}",ttcartaoLebes.cet).
    if ttcartaoLebes.cetAno <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{cetAno\}",ttcartaoLebes.cetAno).
    if ttcartaoLebes.taxaMes <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{taxaMes\}",ttcartaoLebes.taxaMes).
    if ttcartaoLebes.valorIOF <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{valorIOF\}",ttcartaoLebes.valorIOF).
    if viofPerc <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{iof.perc\}",trim(string(viofPerc,">>>>>>>>9.99"))).
    if vprincipal <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{principal\}",trim(string(vprincipal,">>>>>>>>9.99"))).
    if vprincipalPerc <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{principal.perc\}",trim(string(vprincipalPerc,">>>>>>>>9.99"))).
    
    if ttcartaoLebes.numeroBilheteSeguroPrestamista <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{numeroBilheteSeguroPrestamista\}",ttcartaoLebes.numeroBilheteSeguroPrestamista).

    if ttcartaoLebes.numeroSorteSeguroPrestamista <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{numeroSorte\}",ttcartaoLebes.numeroSorteSeguroPrestamista).
    
    if vvalorSeguroPrestamista <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{sp18\}",trim(string(vvalorSeguroPrestamista,">>>>>>>>9.99"))).
    if vvalorSeguroPrestamistaLiquido <> ?                                    
    then tttermos.conteudo = replace(tttermos.conteudo,"\{sp16\}",trim(string(vvalorSeguroPrestamistaLiquido,">>>>>>>>9.99"))).
    if vvalorSeguroPrestamistaIof <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{sp17\}",trim(string(vvalorSeguroPrestamistaIof,">>>>>>>>9.99"))).
    if vvalorSeguroPrestamista29 <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{sp29\}",trim(string(vvalorSeguroPrestamista29,">>>>>>>>9.99"))).
    if vvalorSeguroPrestamista30 <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{sp30\}",trim(string(vvalorSeguroPrestamista30,">>>>>>>>9.99"))).
    
    
    if vdatainivigencia12 <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{sp12\}",string(vdatainivigencia12,"99/99/9999")).
    else tttermos.conteudo = replace(tttermos.conteudo,"\{sp12\}","").
    
    if vdatafimvigencia13 <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{sp13\}",string(vdatafimvigencia13,"99/99/9999")).
    else tttermos.conteudo = replace(tttermos.conteudo,"\{sp13\}","").
   

end.

    if vprodutos-lista <> ?
    then tttermos.conteudo = replace(tttermos.conteudo,"\{produtos.lista\}",vprodutos-lista).

end procedure.


