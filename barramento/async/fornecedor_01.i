DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hfornecedorEntrada          as handle.
def var hfornecedorSaida            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttfornecedor NO-UNDO SERIALIZE-NAME "fornecedor"
    field id as char 
    field ativo as char
    field dataCadastro as char
    field origem as char
    field codigo as char
    field codigoPai as char
    field razaoSocial as char
    field nomeFantasia as char
    field cnpj as char
    field inscricaoEstadual as char
    field inscricaoMunicipal as char
    index x is unique primary id asc.

DEFINE TEMP-TABLE ttendereco NO-UNDO SERIALIZE-NAME "endereco"
    field id as char 
    field idPai as char
    field numero as char
    field rua as char
    field bairro    as char
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

    
DEFINE DATASET fornecedorEntrada FOR ttfornecedor, ttendereco , ttcontato, tttelefones
  DATA-RELATION for1 FOR ttfornecedor, ttendereco
        RELATION-FIELDS(ttfornecedor.id,ttendereco.idpai) NESTED
  DATA-RELATION for2 FOR ttfornecedor, ttcontato
        RELATION-FIELDS(ttfornecedor.id,ttcontato.idpai) NESTED
  DATA-RELATION for3 FOR ttcontato, tttelefones
        RELATION-FIELDS(ttcontato.id,tttelefones.idpai) NESTED.

hfornecedorEntrada = DATASET fornecedorEntrada:HANDLE.

/*
/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'fornecedorSaida'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    index cli is unique primary situacao asc.

DEFINE DATASET conteudoSaida FOR ttstatus.

hfornecedorSaida = DATASET conteudoSaida:HANDLE.
*/

