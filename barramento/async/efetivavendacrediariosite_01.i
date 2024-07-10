DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hefetivavendacrediariositeEntrada          as handle.
def var hefetivavendacrediariositeSaida            as handle.

DEFINE TEMP-TABLE ttefetivavendacrediariosite NO-UNDO SERIALIZE-NAME "efetivaVendaCrediarioSite" 
    field id            as char
    field sequencial    as char  /*":null,*/ 
    field dataTransacao as char  /*":"2019-07-22",*/ 
    field horaTransacao as char /*":"11:00:00",*/ 
    field cpfCliente    as char /*":"51555330150", */
    field nome          as char /* ":"cliente teste",*/ 
    field emailCliente  as char /*":"teste@teste.com.br",*/ 
    field celular       as char /*":"5551988888888",*/ 
    field fixo          as char /*":"555134440000",*/ 
    field codigoVendedor    as char /*":null, */
    field codigoOperador    as char /*":null,*/ 
    field idOperacaoMotor   as char /*":"9913114512241512315235523523",*/
    field numeroPdv         as char     /*":"31",*/ 
    field codigoLoja        as char     /*":"200",*/ 
    field origem            as char     /*":"wevo",*/ 
    field codigoPedido      as char     /*":"leb-1234",*/ 
    field valorTotal        as char     /*":"500.00",*/ 
    field valorFrete        as char.     /*":"0.00"*/

DEFINE TEMP-TABLE ttitens NO-UNDO SERIALIZE-NAME "itens" 
    field id        as char
    field idPai     as char
    field codigoProduto as char
    field descricao as char
    field qtd   as char
    field valorUnitario as char
    field valorTotal    as char
    field codigoVendedor as char.

DEFINE TEMP-TABLE ttdescontos NO-UNDO SERIALIZE-NAME "descontos" 
    field id        as char
    field idPai     as char
    field tipoDesconto as char
    field valorDesconto as char
    field codigoIdentificador   as char.

DEFINE TEMP-TABLE ttcondicao NO-UNDO SERIALIZE-NAME "condicao"
    field id            as char
    field idPai         as char
    field codPlano  as char     /*":"603",*/ 
    field descricaoPlano    as char     /*":"MOVEIS 3x",*/ 
    field taxaJuros as char     /*":"12.00",*/ 
    field tipoJuros     as char /*":null,*/ 
    field valorEntrada  as char /*":"0.00",*/ 
    field valorTfc      as char /*":null,*/ 
    field qtdParcelas   as char /*":"3",*/ 
    field valorParcela  as char    
    field valorTotalSeguro  as char /*":null,*/ 
    field codigoSeguro  as char /*":null,*/ 
    field acrescimoTotal    as char /*":null,*/ 
    field coeficiente   as char /*":null,*/ 
    field valorIof  as char /*":null,*/ 
    field taxaCet   as char /*":null,*/ 
    field taxaCetAno    as char /*":null,*/ 
    field valorIrr  as char /*":null,*/
    field primeiroVencimento    as char     /*":"2019-08-22",*/ 
    field valorTotalPrazo   as char. /*":"825.00",*/ 

DEFINE DATASET efetivaVendaCrediarioSiteEntrada 
        FOR ttefetivavendacrediariosite , ttitens, ttdescontos, ttcondicao
   DATA-RELATION for0 FOR ttefetivavendacrediariosite, ttitens   
        RELATION-FIELDS(ttefetivavendacrediariosite.id,ttitens.idpai) NESTED       
   DATA-RELATION for1 FOR ttitens, ttdescontos   
        RELATION-FIELDS(ttitens.id,ttdescontos.idpai) NESTED        
   DATA-RELATION for0 FOR ttefetivavendacrediariosite, ttcondicao   
        RELATION-FIELDS(ttefetivavendacrediariosite.id,ttcondicao.idpai) NESTED        .
        
   
hefetivavendacrediariositeEntrada = DATASET efetivavendacrediariositeEntrada:HANDLE.


