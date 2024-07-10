/* helio 21012022 novo layout pix */
/* helio 19112021 - Meio de pagamento PIX suporte ADMCOM */

DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hcupomvendamercadoriaEntrada          as handle.
def var hcupomvendamercadoriaSaida            as handle.

  
DEFINE TEMP-TABLE ttcupomVendaMercadoria NO-UNDO SERIALIZE-NAME "cupomVendaMercadoria"
field id as char 
field tstatus as char serialize-name "status"
field tipo as char 
field operacao as char 
field numeroCupom as char 
field canalOrigem as char 
field codigoSistema as char 
field codigoLoja as char 
field dataTransacao as char 
field numeroComponente as char 
field nsuTransacao as char 
field horaTransacao as char 
field numeroPedido as char 
field chavePedidoExterno as char 
field chaveNotaExterno as char 
field dataEmissao as char 
field numero as char 
field serie as char 
field ecf as char 
field chaveNfce as char 
field statusNFce as char 
field mensagemCorpoNotaFiscal as char 
field mensagemDadosAdicionais as char 
field valorTotalBruto as char 
field valorTotalLiquido as char 
field descontos as char 
field valorMercadorias as char 
field valorServicos as char 
field valorMercadoriasServicos as char 
field valorEncargos as char 
field valorTroco as char 
field valorTotalAPrazo as char 
field optouNFPaulista as char 
index x is unique primary  id asc.

DEFINE TEMP-TABLE ttrecebimentos NO-UNDO SERIALIZE-NAME "recebimentos"
        field id as char 
        field idPai as char 
        field formaPagamento as char 
        field codigoPlano as char 
        field sequencial as char 
        field valorRecebido as char 
        field troco as char 
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcartaoLebes NO-UNDO SERIALIZE-NAME "cartaoLebes"
        field chave as char initial ? serialize-hidden
index x is unique primary chave asc.

DEFINE TEMP-TABLE ttcontrato NO-UNDO SERIALIZE-NAME "contrato"
        field id as char 
        field idPai as char 
        field codigoLoja as char 
        field numeroContrato as char 
        field dataInicial as char 
        field valorTotal as char 
        field planoCredito as char 
        field contratoFinanceira as char 
        field tipoOperacao as char 
        field dataEfetivacao as char 
        field valorEntrada as char 
        field primeiroVencimento as char 
        field qtdParcelas as char 
        field taxaMes as char 
        field valorAcrescimo as char 
        field valorIof as char 
        field valorTFC as char 
        field taxaCetAno as char 
        field taxaCet as char 
        field tipoContrato as char 
        field valorPrincipal as char 
        field modalidade as char 
        field codigoEmpresa as char 
index x is unique primary idpai asc id asc.
                        
DEFINE TEMP-TABLE ttparcelas NO-UNDO SERIALIZE-NAME "parcelas"
        field id as char 
        field idPai as char 
        field sequencial as char 
        field valorParcela as char 
        field dataVencimento as char 
        field dataEmissao as char 
        field codigoCobranca as char 
        field valorPrincipal as char 
        field valorFinanceiroAcrescimo as char 
        field valorSeguro as char 
        field situacao as char
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttseguro NO-UNDO SERIALIZE-NAME "seguro"
        field id as char 
        field idPai as char 
        field tipoSeguro as char
        field valorSeguro as char 
        field numeroSorteio as char
        field numeroApolice as char 
        field codigoSeguro as char
        field codigoSeguradora as char
        field rstatus as char serialize-name "status"
        field dataInicioVigencia as char 
        field dataFimVigencia as char 
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcartaoPresente NO-UNDO SERIALIZE-NAME "cartaoPresente"
        field id as char 
        field idPai as char 
        field numeroCartao as char 
        field codigoAprovacao as char 
        field nsuTransAutorizadora as char 
        field codigoAutorizadora as char 
        field nomeAutorizadora as char 
        field codigoVan as char 
        field nomeVan as char 
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcartaoDebito NO-UNDO SERIALIZE-NAME "cartaoDebito"
        field id as char 
        field idPai as char 
        field codigoAprovacao as char 
        field nsuTransAutorizadora as char 
        field nsuTransCtf as char 
        field valorTotal as char 
        field qtdParcelas as char 
        field codigoAutorizadora as char 
        field nomeAutorizadora as char 
        field codigoVan as char 
        field nomeVan as char 
        field valorAcrescimo as char 
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttvaleTrocaGarantida NO-UNDO SERIALIZE-NAME "valeTrocaGarantida"
        field id as char 
        field idPai as char 
        field certificado as char 
        field numeroAutorizacao as char 
        field seqProduto as char 
        field origemNumeroComponente as char 
        field origemDataTransacao as char 
        field origemNsuTransacao as char 
        field origemCodigoLoja as char 
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcartaoCredito NO-UNDO SERIALIZE-NAME "cartaoCredito"
        field id as char 
        field idPai as char 
        field codigoAprovacao as char 
        field nsuTransAutorizadora as char 
        field nsuTransCtf as char 
        field valorTotal as char 
        field qtdParcelas as char 
        field codigoAutorizadora as char 
        field nomeAutorizadora as char 
        field codigoVan as char 
        field nomeVan as char 
        field valorAcrescimo as char 
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttvaleTroca NO-UNDO SERIALIZE-NAME "valeTroca"
        field id as char 
        field idPai as char 
        field numeroValeTroca as char 
        field codigoAprovacao as char 
        field nsuTransAutorizadora as char 
        field codigoAutorizadora as char 
        field nomeAutorizadora as char 
        field codigoVan as char 
        field nomeVan as char 
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcheque NO-UNDO SERIALIZE-NAME "cheque"
        field id as char 
        field idPai as char 
        field banco as char 
        field agencia as char 
        field conta as char 
        field numeroCheque as char 
        field cpfCnpj as char 
        field valor as char 
        field dataCheque as char 
index x is unique primary idpai asc id asc.

/* helio 21012022 novo layout pix */
DEFINE TEMP-TABLE ttpixDebito NO-UNDO SERIALIZE-NAME "pixDebito"
        field id as char 
        field idPai as char 
        field idTransacao as char 
        field valorAcrescimo as char 
        field valorTotal as char 
index x is unique primary idpai asc id asc.


DEFINE TEMP-TABLE ttchequePre NO-UNDO SERIALIZE-NAME "chequePre"
        field banco as char 
        field agencia as char 
        field conta as char 
        field numeroCheque as char 
        field cpfCnpj as char 
        field valor as char 
        field dataCheque as char 
        field id as char 
        field idPai as char 
        field sequencial as char        
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttboleto NO-UNDO SERIALIZE-NAME "boleto"
        field id as char 
        field idPai as char 
        field valorPrincipal as char 
index x is unique primary idpai asc id asc.


DEFINE TEMP-TABLE ttorigemVendaOutraLoja NO-UNDO SERIALIZE-NAME "origemVendaOutraLoja"
        field id as char 
        field idPai as char 
        field codigoLoja as char 
        field dataTransacao as char 
        field numeroComponente as char 
        field nsuTransacao as char 
        field numeroPedido as char 
        field canalOrigem as char 
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcupomOrigemVenda NO-UNDO SERIALIZE-NAME "cupomOrigemVenda"
        field id as char 
        field idPai as char 
        field codigoLoja as char 
        field dataTransacao as char 
        field numeroComponente as char 
        field nsuTransacao as char 
        field numero as char 
        field serie as char 
        field canalOrigem as char 
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcliente NO-UNDO SERIALIZE-NAME "cliente"
        field id as char 
        field idPai as char 
        field tipoCliente as char 
        field codigoCliente as char 
        field cpfCnpj as char 
        field nome as char 
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttendereco NO-UNDO SERIALIZE-NAME "endereco"
        field id as char
        field idPai as char 
        field numero as char 
        field rua as char 
        field bairro as char 
        field pontoReferencia as char 
        field complemento as char 
        field cep as char 
        field cidade as char 
        field codIbgeCidade as char 
        field uf as char 
        field pais as char
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcontato NO-UNDO SERIALIZE-NAME "contato"
        field id as char 
        field idPai as char 
        field email as char 
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE tttelefones NO-UNDO SERIALIZE-NAME "telefones"
        field id as char 
        field idPai as char 
        field numero as char 
        field tipo as char 
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttitens NO-UNDO SERIALIZE-NAME "itens"
        field id as char 
        field idPai as char 
        field sequencial as char 
        field codigoLegado as char 
        field codigo as char 
        field descricao as char 
        field ean as char 
        field quantidade as char 
        field unidadeVenda as char 
        field montagem as char 
        field codigoVendedor as char 
        field nomeVendedor as char 
        field valorUnitarioPadrao as char 
        field valorUnitario as char 
        field valorTotal as char 
        field mercadologico as char 
        field codigoOperador as char 
        field indComposto as char 
        field serial as char 
        field imei as char 
        field custoUnitario as char 
        field valorTotalDesconto as char 
        field pedidoEspecial as char 
        field obsPedidoEspecial as char 
        field dataPedidoEspecial as char 
        field entregaDataFutura as char 
        field formaEntrega as char 
        field lojaEntrega as char 
        field embalagemPresente as char 
        field brinde as char 
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttgarantias NO-UNDO SERIALIZE-NAME "garantias"
        field id as char 
        field idPai as char 
        field seqGarantia as char 
        field codigo as char 
        field tipo as char 
        field descricao as char 
        field valor as char 
        field tempoGarantia as char 
        field dataInicioGarantia as char 
        field dataFimGarantia as char 
        field prazoGarantiaFornecedor as char 
        field custoGarantia as char 
        field certificado as char 
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttdescontos NO-UNDO SERIALIZE-NAME "descontos"
        field id as char 
        field idPai as char 
        field tipoDesconto as char 
        field valorDesconto as char 
        field valorDescontoUnitario as char 
        field codigoIdentificador as char 
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcampanhas NO-UNDO SERIALIZE-NAME "campanhas"
        field id as char 
        field idPai as char 
        field codigoCampanha as char 
        field seqCampanha as char 
        field tipoCampanha as char 
        field descricao as char 
index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttfrete NO-UNDO SERIALIZE-NAME "frete"
        field id as char 
        field idPai as char
        field codigoFrete as char 
        field valorFrete as char 
index x is unique primary idpai asc id asc.


DEFINE DATASET cupomVendaMercadoriaEntrada FOR ttcupomVendaMercadoria, ttrecebimentos , ttcartaoLebes, ttcontrato, ttparcelas, ttseguro, ttcartaoPresente, ttcartaoDebito, ttvaleTrocaGarantida, ttcartaoCredito, ttvaleTroca, ttcheque, ttchequePre, ttboleto, ttpixDebito,
ttorigemVendaOutraLoja, ttcupomOrigemVenda, ttcliente, ttendereco, ttcontato, tttelefones, ttitens, ttgarantias, ttdescontos , ttcampanhas, ttfrete
  DATA-RELATION for1 FOR ttcupomVendaMercadoria, ttrecebimentos  RELATION-FIELDS(ttcupomVendaMercadoria.id,ttrecebimentos.idpai) NESTED
   DATA-RELATION for12 FOR ttrecebimentos, ttcontrato       RELATION-FIELDS(ttrecebimentos.id,ttcontrato.id) NESTED
    DATA-RELATION for1211 FOR ttcontrato , ttparcelas             RELATION-FIELDS(ttcontrato.id,ttparcelas.idpai) NESTED
    DATA-RELATION for1212 FOR ttcontrato , ttseguro               RELATION-FIELDS(ttcontrato.id,ttseguro.idpai) NESTED
  DATA-RELATION for13 FOR ttrecebimentos, ttcartaoPresente         RELATION-FIELDS(ttrecebimentos.id,ttcartaoPresente.id) NESTED
  DATA-RELATION for14 FOR ttrecebimentos, ttcartaoDebito         RELATION-FIELDS(ttrecebimentos.id,ttcartaoDebito.id) NESTED
  
  DATA-RELATION for15 FOR ttrecebimentos, ttvaleTrocaGarantida         RELATION-FIELDS(ttrecebimentos.id,ttvaleTrocaGarantida.id) NESTED
  DATA-RELATION for16 FOR ttrecebimentos, ttcartaoCredito         RELATION-FIELDS(ttrecebimentos.id,ttcartaoCredito.id) NESTED
  DATA-RELATION for17 FOR ttrecebimentos, ttvaleTroca         RELATION-FIELDS(ttrecebimentos.id,ttvaleTroca.id) NESTED
  DATA-RELATION for18 FOR ttrecebimentos, ttcheque         RELATION-FIELDS(ttrecebimentos.id,ttcheque.id) NESTED
  DATA-RELATION for19 FOR ttrecebimentos, ttchequePre         RELATION-FIELDS(ttrecebimentos.id,ttchequepre.id) NESTED
  DATA-RELATION for20 FOR ttrecebimentos, ttboleto         RELATION-FIELDS(ttrecebimentos.id,ttboleto.id) NESTED
  DATA-RELATION for141 FOR ttrecebimentos, ttpixDebito         RELATION-FIELDS(ttrecebimentos.id,ttpixDebito.id) NESTED
  
  DATA-RELATION for2 FOR ttcupomVendaMercadoria, ttorigemVendaOutraLoja  RELATION-FIELDS(ttcupomVendaMercadoria.id,ttorigemVendaOutraLoja.idpai) NESTED
  DATA-RELATION for3 FOR ttcupomVendaMercadoria, ttcupomOrigemVenda  RELATION-FIELDS(ttcupomVendaMercadoria.id,ttcupomOrigemVenda.idpai) NESTED
  DATA-RELATION for4 FOR ttcupomVendaMercadoria, ttcliente  RELATION-FIELDS(ttcupomVendaMercadoria.id,ttcliente.idpai) NESTED
   DATA-RELATION for41 FOR ttcliente, ttendereco  RELATION-FIELDS(ttcliente.id,ttendereco.idpai) NESTED
   DATA-RELATION for42 FOR ttcliente, ttcontato  RELATION-FIELDS(ttcliente.id,ttcontato.idpai) NESTED
    DATA-RELATION for421 FOR ttcontato,tttelefones  RELATION-FIELDS(ttcontato.id,tttelefones.idpai) NESTED
  DATA-RELATION for5 FOR ttcupomVendaMercadoria, ttitens  RELATION-FIELDS(ttcupomVendaMercadoria.id,ttitens.idpai) NESTED
   DATA-RELATION for51 FOR ttitens,ttgarantias  RELATION-FIELDS(ttitens.id,ttgarantias.idpai) NESTED
   DATA-RELATION for52 FOR ttitens,ttdescontos  RELATION-FIELDS(ttitens.id,ttdescontos.idpai) NESTED
   DATA-RELATION for53 FOR ttitens, ttcampanhas RELATION-FIELDS(ttitens.id,ttcampanhas.idpai) NESTED
  DATA-RELATION for6 FOR ttcupomVendaMercadoria, ttfrete  RELATION-FIELDS(ttcupomVendaMercadoria.id,ttfrete.idpai) NESTED.

   
  
hcupomvendamercadoriaEntrada = DATASET cupomvendamercadoriaEntrada:HANDLE.

/*
/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'cupomvendamercadoriaSaida'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    index cli is unique primary situacao asc.

DEFINE DATASET conteudoSaida FOR ttstatus.

hcupomvendamercadoriaSaida = DATASET conteudoSaida:HANDLE.
*/

