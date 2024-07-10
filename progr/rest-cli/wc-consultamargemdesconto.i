
DEFINE {1} SHARED TEMP-TABLE ttconsultamargemdescontoEntrada NO-UNDO SERIALIZE-NAME "consultaMargemDescontoEntrada"
    field codigoLoja     as char
    field codigoProduto  as char
    field valorProduto   as char
    field valorDescontoSolicitado as char
    field codigoOperador as char.

DEFINE {1} SHARED TEMP-TABLE ttmargemDescontoProduto NO-UNDO SERIALIZE-NAME "margemDescontoProduto"
    field codigoLoja    as char     /*":"28",*/ 
    field linha         as char     /*":"MOVEIS",*/ 
    field codigoProduto as char     /*:"211",*/ 
    field valorDescontoSolicitado as char   /*":"100",*/ 
    field valorMaximoPermitido as char
    field autorizaDesconto  as char /*":"true"*/
    field autorizaDescontoRegional as char.

DEFINE {1} SHARED TEMP-TABLE ttmargemdesconto NO-UNDO SERIALIZE-NAME "margemDesconto"
     field codigoLoja   as char     /*":"28",*/ 
     field linha        as char     /*":"MOVEIS",*/ 
     field totalVenda   as char     /*":"90000.00",*/ 
     field totalVendaComAcrescimo   as char     /*":"120000.00",*/ 
     field margem       as char     /*":"2",*/ 
     field margemRegional as char
     field percDescontoProdutoMax   as char /*":"10",*/ 
     field valorDescontoDisponivel  as char /*":"2000.00",*/ 
     field valorDescontoDisponivelRegional  as char
     field valorDescontoUtilizado   as char /*":"400.00",*/ 
     field periodoVendaInicial      as char /*":"2019-12-31",*/ 
     field periodoVendaFinal        as char. /*":"2020-01-30" */

define {1} shared temp-table ttretornomargemdesconto serialize-name "statusRetorno"
    field tstatus   as char serialize-name "status"
    field descricao as char
    .
    
