~DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hprodutoLojaEntrada          as handle.
def var hprodutolojaSaida            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttprodutoloja NO-UNDO SERIALIZE-NAME "produtoLoja"
    field id as char  
    field codigoProduto as char
    field codigoLoja as char 
    field ativo as char
    field mixLoja as char
    field mixDistribuicaoLoja as char
    field tipo as char
    field tempoGarantia as char
    index x is unique primary id asc.

DEFINE TEMP-TABLE ttpreco NO-UNDO SERIALIZE-NAME "preco"
    field id as char  
    field idPai as char 
    field precoCusto as char
    field precoRegular as char 
    field precoRemarcado as char 
    field precoPraticado as char
        index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttprecoPromocional NO-UNDO SERIALIZE-NAME "precoPromocional"
    field id as char  
    field idPai as char 
    field precoPromocional as char
    field dataInicialPromocao as char
    field dataFinalPromocao as char
        index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttdesconto NO-UNDO SERIALIZE-NAME "desconto"
    field id as char
    field idPai as char
    field nivelDesconto as char
    field percentualDescontoPermitido as char
        index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE tttributacao NO-UNDO SERIALIZE-NAME "tributacao"
    field id as char
    field idPai as char
    field codTributacao as char
    field cfop as char
    field aliquotaIcms as char
    field aliquotaPis as char
    field aliquotaCofins as char
    field cst as char 
    field cstPis as char
    field cstCofins as char 
    field aliquotaIcmsEfetivo as char 
    field aliquotaFundoCombatePobreza as char
    field percentualImpostoMedio as char 
    field percentualImpostoMedioFederal as char 
    field percentualImpostoMedioEstadual as char
    field percentualImpostoMedioMunicipal as char
    field codigoCbenef as char
    field percentualBaseReduzida as char 
        index x is unique primary idpai asc id asc.

DEFINE DATASET produtoLojaEntrada FOR ttprodutoloja, ttpreco, ttprecopromocional, ttdesconto , tttributacao
  DATA-RELATION for1 FOR ttprodutoloja, ttpreco         RELATION-FIELDS(ttprodutoloja.id,ttpreco.idpai) NESTED
    DATA-RELATION for11 FOR ttpreco, ttdesconto         RELATION-FIELDS(ttpreco.id,ttdesconto.idpai) NESTED
    DATA-RELATION for11 FOR ttpreco, ttprecopromocional RELATION-FIELDS(ttpreco.id,ttprecopromocional.idpai) NESTED
  DATA-RELATION for2 FOR ttprodutoloja, tttributacao    RELATION-FIELDS(ttprodutoloja.id,tttributacao.idpai) NESTED.
  

hprodutoLojaEntrada = DATASET produtoLojaEntrada:HANDLE.

/*
/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'produtolojaSaida'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    index cli is unique primary situacao asc.

DEFINE DATASET conteudoSaida FOR ttstatus.

hprodutolojaSaida = DATASET conteudoSaida:HANDLE.
*/

