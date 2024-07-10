~DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hprodutoEntrada          as handle.
def var hprodutoSaida            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttproduto NO-UNDO SERIALIZE-NAME "produto"
    field id as char  
    field  ativo as char  
    field statusItem    as char
    field dataCadastro as char  
    field codigoProduto as char  
    field descricaoCompacta as char  
    field descricaoCompleta as char  
    field tipo as char  
    field descricaoTipo as char  
    field categoria as char  
    field codMercadologico as char  
    field codigoFabricante as char  
    field descricaoFabricante as char  
    field codigoFornecedor as char  
    field descricaoFornecedor as char  
    field classificacaoProduto as char
    field ean as char  
    field tipoEan as char
    field prazoFabricacao as char  
    index x is unique primary id asc.

DEFINE TEMP-TABLE ttcomercial NO-UNDO SERIALIZE-NAME "comercial"
    field id as char  
    field idPai as char 
    field precoCusto as char  
    field precoVenda as char  
    field precoRecomendadoFornecedor as char  
    field pack as char  
    field grupoMix as char  
    field pontoExposicao as char  
    field paraMontagem as char  
    field pedidoEspecial as char  
    field vex as char  
    field dataFimVida as char  
    field tempoGarantia as char  
    field loteMinimo as char  
    field descontinuado as char  
    field openToBuy as char  
    field referencia as char  
    field unidadeVenda as char  
    field controlaImei as char  
    field idServicoHubSeg as char
        index x is unique primary idpai asc id asc.
    
DEFINE TEMP-TABLE ttcaracteristica NO-UNDO SERIALIZE-NAME "caracteristica"
    field id as char
    field idPai as char
    field codigoEstacao as char 
    field codigoTemporada as char
    field grupoCaracteristica as char
    field shelfLife as char
        index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcaracteristicaGenerica NO-UNDO SERIALIZE-NAME "caracteristicaGenerica"
    field id as char
    field idPai as char
    field descricao as char
    field valor as char
        index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttdimensoes NO-UNDO SERIALIZE-NAME "dimensoes"
    field id as char 
    field idPai as char 
    field volume as char 
    field alturaEmbalagem as char 
    field larguraEmbalagem as char 
    field comprimentoEmbalagem as char 
    field pesoEmbalagem as char 
    field alturaProduto as char 
    field larguraProduto as char 
    field comprimentoProduto as char 
    field pesoProduto as char 
    field pesoTotal as char 
    field tara as char 
    field pesoLiquido as char 
        index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcontabil NO-UNDO SERIALIZE-NAME "contabil"
    field id as char 
    field idPai as char
    field indGtin as char
    field categoriaFiscal as char
    field ncm as char
    field codigoCest  as char
        index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcomponentes NO-UNDO SERIALIZE-NAME "componentes"
    field id as char  
    field idPai as char
    field codigoProduto as char  
    field quantidade as char
    field permiteVendaAvulsa as char
    index x is unique primary idPai asc id asc.

/*
DEFINE TEMP-TABLE ttcompcomercial NO-UNDO SERIALIZE-NAME "compComercial"
    field id as char  
    field idPai as char 
    field precoCusto as char  
    field precoVenda as char  
    field precoRecomendadoFornecedor as char  
    field pack as char  
    field grupoMix as char  
    field pontoExposicao as char  
    field paraMontagem as char  
    field pedidoEspecial as char  
    field vex as char  
    field dataFimVida as char  
    field tempoGarantia as char  
    field leadTime as char  
    field loteMinimo as char  
    field descontinuado as char  
    field openToBuy as char  
    field referencia as char  
    field unidadeVenda as char  
    field controlaImei as char  
        index x is unique primary idpai asc id asc.
    
DEFINE TEMP-TABLE ttcompcaracteristica NO-UNDO SERIALIZE-NAME "compCaracteristica"
    field id as char
    field idPai as char
    field codigoEstacao as char 
    field codigoTemporada as char
    field grupoCaracteristica as char
    field shelfLife as char
        index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcompcaracteristicaGenerica NO-UNDO SERIALIZE-NAME "compCaracteristicaGenerica"
    field id as char
    field idPai as char
    field descricao as char
    field valor as char
        index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcompdimensoes NO-UNDO SERIALIZE-NAME "compDimensoes"
    field id as char 
    field idPai as char 
    field volume as char 
    field alturaEmbalagem as char 
    field larguraEmbalagem as char 
    field comprimentoEmbalagem as char 
    field pesoEmbalagem as char 
    field alturaProduto as char 
    field larguraProduto as char 
    field comprimentoProduto as char 
    field pesoProduto as char 
    field pesoTotal as char 
    field tara as char 
    field pesoLiquido as char 
        index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcompcontabil NO-UNDO SERIALIZE-NAME "compContabil"
    field id as char 
    field idPai as char
    field indGtin as char
    field categoriaFiscal as char
    field ncm as char
    field codigoCest  as char
        index x is unique primary idpai asc id asc.
*/


DEFINE DATASET produtoEntrada FOR ttproduto, ttcomercial , ttcaracteristica, ttcaracteristicaGenerica, ttdimensoes, ttcontabil,
                                  ttcomponentes /*, ttcompcomercial , ttcompcaracteristica, ttcompcaracteristicaGenerica, ttcompdimensoes, ttcompcontabil*/
  DATA-RELATION for1 FOR ttproduto, ttcomercial         RELATION-FIELDS(ttproduto.id,ttcomercial.idpai) NESTED
  DATA-RELATION for2 FOR ttproduto, ttcaracteristica    RELATION-FIELDS(ttproduto.id,ttcaracteristica.idpai) NESTED
    DATA-RELATION for21 FOR ttcaracteristica, ttcaracteristicaGenerica RELATION-FIELDS(ttcaracteristica.id,ttcaracteristicaGenerica.idpai) NESTED
  DATA-RELATION for3 FOR ttproduto, ttdimensoes         RELATION-FIELDS(ttproduto.id,ttdimensoes.idpai) NESTED
  DATA-RELATION for4 FOR ttproduto, ttcontabil          RELATION-FIELDS(ttproduto.id,ttcontabil.idpai) NESTED
  DATA-RELATION for5 FOR ttproduto, ttcomponentes       RELATION-FIELDS(ttproduto.id,ttcomponentes.idpai) NESTED
  /*
      DATA-RELATION for51 FOR ttcomponentes, ttcompcomercial         RELATION-FIELDS(ttcomponentes.id,ttcompcomercial.idpai) NESTED
      DATA-RELATION for52 FOR ttcomponentes, ttcompcaracteristica    RELATION-FIELDS(ttcomponentes.id,ttcompcaracteristica.idpai) NESTED
        DATA-RELATION for521 FOR ttcompcaracteristica, ttcompcaracteristicaGenerica RELATION-FIELDS(ttcompcaracteristica.id,ttcompcaracteristicaGenerica.idpai) NESTED
      DATA-RELATION for53 FOR ttcomponentes, ttcompdimensoes         RELATION-FIELDS(ttcomponentes.id,ttcompdimensoes.idpai) NESTED
      DATA-RELATION for54 FOR ttcomponentes, ttcompcontabil          RELATION-FIELDS(ttcomponentes.id,ttcompcontabil.idpai) NESTED*/ .
  

hprodutoEntrada = DATASET produtoEntrada:HANDLE.

/*
/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'produtoSaida'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    index cli is unique primary situacao asc.

DEFINE DATASET conteudoSaida FOR ttstatus.

hprodutoSaida = DATASET conteudoSaida:HANDLE.
*/

