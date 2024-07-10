~DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hestacaoEntrada          as handle.
def var hestacaoSaida            as handle.
/* ENTRADA */

DEFINE TEMP-TABLE ttestacao NO-UNDO SERIALIZE-NAME "estacao"
    field id            as char /*":"1",*/
    field anoEstacao    as char /*":"1000",*/
    field codigoColecao as char /*":"77",*/
    field codigoEstacao as char /*":"1000",*/
    field codigoTema    as char /*":"",*/
    field descricaoColecao  as char /*":"INVERNO 2020 CALCADO",*/
    field descricaoEstacao  as char /*":"INVERNO",*/
    field descricaoTema     as char /*":"",*/
    field dataInicio        as char /*":"2020-03-01",*/
    field dataFim           as char /*":"2020-08-15"*/
    index x is unique primary id asc.

DEFINE DATASET estacaoEntrada FOR ttestacao.
  

hestacaoEntrada = DATASET estacaoEntrada:HANDLE.

/*
/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'estacaoSaida'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    index cli is unique primary situacao asc.

DEFINE DATASET conteudoSaida FOR ttstatus.

hestacaoSaida = DATASET conteudoSaida:HANDLE.
*/

