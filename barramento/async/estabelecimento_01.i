DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hestabelecimentoEntrada          as handle.
def var hestabelecimentoSaida            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttestabelecimento NO-UNDO SERIALIZE-NAME "estabelecimento"
    field id as char
    field ativo as char 
    field tipo as char 
    field dataCadastro as char
    field codigo as char
    field razaoSocial as char
    field nomeFantasia as char
    field cnpj as char
    field inscricaoEstadual as char
    field regiao as char
    field tamanho as char
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
        index x is unique primary idPai asc id asc.
    
DEFINE TEMP-TABLE ttcontato NO-UNDO SERIALIZE-NAME "contato"
    field id as char 
    field idPai as char
    field email as char 
        index x is unique primary idPai asc id asc.


DEFINE TEMP-TABLE tttelefones NO-UNDO SERIALIZE-NAME "telefones"
    field id as char 
    field idPai as char
    field numero as char
    field tipo as char
        index x is unique primary idPai asc id asc.

DEFINE TEMP-TABLE expedientes no-undo /*SERIALIZE-NAME "expedientes" no-undo */
    field id as char 
    field idPai as char
    field descricao as char
    field diaSemanaInicial as char
    field diaSemanaFinal    as char
        index x is unique primary idPai asc id asc.

DEFINE TEMP-TABLE ttturnos NO-UNDO SERIALIZE-NAME "turnos"
    field id as char 
    field idPai as char
    field descricao as char
    field horaInicial   as char
    field horaFinal as char
        index x is unique primary idPai asc id asc.
    

    
DEFINE DATASET estabelecimentoEntrada FOR ttestabelecimento, ttendereco , ttcontato, tttelefones, expedientes, ttturnos
  DATA-RELATION for1 FOR ttestabelecimento, ttendereco
        RELATION-FIELDS(ttestabelecimento.id,ttendereco.idPai) NESTED
  DATA-RELATION for2 FOR ttestabelecimento, ttcontato
        RELATION-FIELDS(ttestabelecimento.id,ttcontato.idPai) NESTED
    DATA-RELATION for3 FOR ttcontato, tttelefones
        RELATION-FIELDS(ttcontato.id,tttelefones.idPai) NESTED
  DATA-RELATION for4 FOR ttestabelecimento, expedientes
        RELATION-FIELDS(ttestabelecimento.id,expedientes.idPai) NESTED
    DATA-RELATION for5 FOR expedientes, ttturnos
        RELATION-FIELDS(expedientes.id,ttturnos.idPai) NESTED .

hestabelecimentoEntrada = DATASET estabelecimentoEntrada:HANDLE.



